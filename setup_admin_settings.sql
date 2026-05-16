-- Tabela para armazenar configurações administrativas (ex: chaves de serviço, configurações de pagamento)
CREATE TABLE IF NOT EXISTS public.admin_settings (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    key text NOT NULL UNIQUE,
    value jsonb NOT NULL,
    description text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- RLS: Apenas admins podem ver ou editar
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can do everything on admin_settings" ON public.admin_settings
    AS PERMISSIVE FOR ALL
    TO public
    USING (
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin' OR
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR
      auth.email() IN ('admin@startflix.com', 'admin@startflix.app')
    )
    WITH CHECK (
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin' OR
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR
      auth.email() IN ('admin@startflix.com', 'admin@startflix.app')
    );

-- Exemplo de inserção (comentado)
-- INSERT INTO public.admin_settings (key, value, description)
-- VALUES ('fcm_service_account', '{"type": "service_account", ...}'::jsonb, 'Chave de serviço do Firebase para FCM V1');
