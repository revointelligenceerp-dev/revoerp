-- Function to create a new vendedor profile when a new user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.vendedores (id, nome, email, cpf_cnpj)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.email,
    new.raw_user_meta_data->>'cpf_cnpj'
  );
  return new;
end;
$$;

-- Trigger to call the function after a new user is inserted into auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
