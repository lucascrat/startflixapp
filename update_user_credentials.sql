-- Function to allow Admins to update User Login Credentials
-- This function is SECURITY DEFINER, meaning it runs with the privileges of the creator (postgres/admin)
-- It bypasses RLS on auth.users to perform the update.

CREATE OR REPLACE FUNCTION admin_update_user_credentials(
  target_user_id UUID,
  new_email TEXT,
  new_password TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update Email and Password in Auth System
  UPDATE auth.users
  SET 
    email = new_email,
    encrypted_password = crypt(new_password, gen_salt('bf')),
    updated_at = now()
  WHERE id = target_user_id;

  -- Update Username in Profiles (assuming standard profile structure)
  -- Uses split_part to get 'username' from 'username@startflix.app'
  UPDATE public.profiles
  SET 
    username = split_part(new_email, '@', 1)
  WHERE id = target_user_id;
END;
$$;
