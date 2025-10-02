-- Function to create a new vendedor profile for a new user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.vendedores (id, nome, email, cpf_cnpj, tipo_pessoa, situacao, ativo, regra_liberacao_comissao, tipo_comissao)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.email,
    new.raw_user_meta_data->>'cpf_cnpj',
    'Física', -- Default value
    'Ativo com acesso ao sistema', -- Default value
    true, -- Default value
    'Liberação parcial (pelo pagamento)', -- Default value
    'Comissão com alíquota fixa' -- Default value
  );
  RETURN new;
END;
$$;

-- Trigger to call the function when a new user is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
