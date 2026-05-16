-- Tabela para armazenar a lista pessoal do usuário
CREATE TABLE IF NOT EXISTS public.user_watchlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tmdb_id INTEGER NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('movie', 'tv')),
  title TEXT NOT NULL,
  poster_path TEXT,
  backdrop_path TEXT,
  overview TEXT,
  vote_average NUMERIC(3,1),
  release_date TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, tmdb_id, media_type)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_watchlist_user_id ON public.user_watchlist(user_id);
CREATE INDEX IF NOT EXISTS idx_user_watchlist_added_at ON public.user_watchlist(added_at DESC);

-- Habilitar RLS
ALTER TABLE public.user_watchlist ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Users can view own watchlist" ON public.user_watchlist;
DROP POLICY IF EXISTS "Users can add to own watchlist" ON public.user_watchlist;
DROP POLICY IF EXISTS "Users can remove from own watchlist" ON public.user_watchlist;

-- Políticas RLS - Usuário só vê sua própria lista
CREATE POLICY "Users can view own watchlist" ON public.user_watchlist
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can add to own watchlist" ON public.user_watchlist
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove from own watchlist" ON public.user_watchlist
  FOR DELETE USING (auth.uid() = user_id);
