-- Run this in your Supabase SQL Editor

-- 1. Create a Profiles table to store user data (extends auth.users)
-- Note: We use a trigger to automatically create a profile when a user signs up
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  email text,
  full_name text,
  role text default 'user',  -- 'admin' or 'user'
  m3u_url text,              -- The playlist URL assigned to this user
  is_active boolean default true,
  expiration_date timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 3. Create Policies

-- Allow users to view their own profile
create policy "Users can view own profile"
  on public.profiles for select
  using ( auth.uid() = id );

-- Allow users to update their own non-sensitive data (optional)
-- create policy "Users can update own profile"
--   on public.profiles for update
--   using ( auth.uid() = id );

-- Allow Admins to view ALL profiles
-- (Note: You need to manually set your first user to 'admin' in the database row)
create policy "Admins can view all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- Allow Admins to insert/update profiles
create policy "Admins can insert profiles"
  on public.profiles for insert
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

create policy "Admins can update all profiles"
  on public.profiles for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

create policy "Admins can delete profiles"
  on public.profiles for delete
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- 4. Create a Trigger to handle new user signups automatically
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', 'user');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 5. Create a specific table for "Pre-registered" configs if needed, 
-- but 'profiles' is usually enough if you rely on users signing up themselves.

-- IMPORTANT: Manually update your own user to be admin after signing up!
-- update public.profiles set role = 'admin' where email = 'your-email@example.com';
