# Configuração do Supabase: Desabilitar Confirmação de Email

Para que o cadastro no aplicativo seja imediato e não exija que o usuário clique em um link no email, você deve desabilitar a confirmação de email no painel do Supabase.

Não é possível fazer isso via SQL, apenas pelo painel de controle.

## Passos:

1. Acesse o painel do seu projeto no Supabase: https://supabase.com/dashboard/project/_/auth/providers
2. No menu lateral, vá em **Authentication** -> **Providers**.
3. Clique em **Email** para expandir as configurações.
4. **Desabilite** (desmarque) a opção: `Confirm email`.
   - *Isso permite que os usuários façam login imediatamente após o cadastro.*
5. **(Opcional) Desabilite** também `Secure email change` se quiser facilitar a troca de email sem confirmação dupla.
6. Clique em **Save**.

Após fazer isso, o fluxo de cadastro no aplicativo `StartFlix` funcionará instantaneamente sem enviar emails.
