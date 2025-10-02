-- Adiciona a capacidade de criar contas a receber manualmente, sem uma fatura.

-- 1. Torna a fatura_id opcional e adiciona colunas para cliente e descrição.
alter table public.contas_receber alter column fatura_id drop not null;
alter table public.contas_receber add column if not exists cliente_id uuid null references public.clientes(id);
alter table public.contas_receber add column if not exists descricao text;

-- 2. Recria a função do gatilho para ser mais inteligente.
-- Ela agora lida com contas de faturas e contas manuais.
drop function if exists public.handle_conta_recebida();
create or replace function public.handle_conta_recebida()
returns trigger as $$
declare
    mov_descricao text;
begin
    -- Se a conta veio de uma fatura
    if new.fatura_id is not null then
        select 'Recebimento Fatura ' || fv.numero_fatura || ' - Cliente: ' || c.nome
        into mov_descricao
        from public.faturas_venda fv
        join public.pedidos_venda pv on fv.pedido_id = pv.id
        join public.clientes c on pv.cliente_id = c.id
        where fv.id = new.fatura_id;
    -- Se foi uma conta manual com cliente
    elsif new.cliente_id is not null then
        select 'Recebimento Avulso - Cliente: ' || c.nome
        into mov_descricao
        from public.clientes c
        where c.id = new.cliente_id;
    -- Se não tem nem fatura nem cliente, usa a descrição da própria conta
    else
        mov_descricao := new.descricao;
    end if;

    insert into public.fluxo_caixa(data, descricao, valor, tipo, conta_receber_id)
    values(new.data_pagamento, coalesce(mov_descricao, 'Recebimento sem descrição'), new.valor, 'ENTRADA', new.id);
    
    return new;
end;
$$ language plpgsql security definer;

-- 3. Recria o gatilho para usar a nova função
drop trigger if exists on_conta_recebida on public.contas_receber;
create trigger on_conta_recebida
  after update of status on public.contas_receber
  for each row
  when (new.status = 'RECEBIDO' and old.status <> 'RECEBIDO')
  execute procedure public.handle_conta_recebida();
