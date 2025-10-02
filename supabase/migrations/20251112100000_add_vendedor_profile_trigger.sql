/*
  # Criação de Perfil de Vendedor Automático
  Cria uma função e um gatilho para inserir automaticamente um novo registro na tabela `vendedores`
  sempre que um novo usuário é criado na tabela `auth.users`.

  ## Query Description:
  - **Função `handle_new_user`**: Esta função é executada pelo gatilho. Ela extrai os metadados (nome completo e CPF/CNPJ) do novo usuário e os utiliza para criar um perfil de vendedor.
  - **Gatilho `on_auth_user_created`**: Este gatilho é acionado após cada novo registro na tabela `auth.users`, garantindo que todo usuário tenha um perfil de vendedor correspondente.
  Isso mantém a consistência dos dados e automatiza o processo de criação de perfil. Não há risco para dados existentes, pois afeta apenas novos usuários.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (DROP TRIGGER e DROP FUNCTION)

  ## Structure Details:
  - Affects: `auth.users`, `public.vendedores`
  - Creates: Function `handle_new_user`, Trigger `on_auth_user_created`

  ## Security Implications:
  - RLS Status: A função é executada com os privilégios do usuário que a define (definer), mas opera de forma segura, inserindo dados apenas na tabela `vendedores`.
  - Policy Changes: No
  - Auth Requirements: A função lê da tabela `auth.users`, o que é uma operação padrão para gatilhos de perfil.

  ## Performance Impact:
  - Indexes: None
  - Triggers: Adds one trigger to `auth.users`. O impacto é mínimo, pois a operação de inserção é rápida e ocorre apenas no momento do cadastro do usuário.
  - Estimated Impact: Baixo.
*/

-- Função para criar um perfil de vendedor para um novo usuário
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.vendedores (id, nome, email, cpf_cnpj, tipo_pessoa, contribuinte, situacao, ativo)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.email,
    new.raw_user_meta_data ->> 'cpf_cnpj',
    'Física', -- Default value
    'Não informado', -- Default value
    'Ativo com acesso ao sistema', -- Default value
    true -- Default value
  );
  return new;
end;
$$;

-- Gatilho para chamar a função quando um novo usuário é criado
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
