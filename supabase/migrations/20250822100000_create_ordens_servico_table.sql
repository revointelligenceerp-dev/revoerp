/*
          # Criação da Tabela de Ordens de Serviço
          Este script cria a tabela `ordens_servico` e os tipos de dados necessários para o quadro Kanban.

          ## Query Description: 
          - Cria os tipos ENUM `os_status` e `os_prioridade` para garantir a consistência dos dados.
          - Cria a tabela `ordens_servico` com colunas para número, descrição, cliente, datas e valores.
          - Estabelece uma chave estrangeira para a tabela `clientes`.
          - Habilita a segurança de nível de linha (RLS) e adiciona políticas permissivas para desenvolvimento, permitindo todas as operações para qualquer usuário (autenticado ou anônimo).

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (com um script de remoção)

          ## Structure Details:
          - Tipos criados: `os_status`, `os_prioridade`
          - Tabela criada: `ordens_servico`
          - Políticas RLS criadas para `ordens_servico`

          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (políticas permissivas para desenvolvimento)
          - Auth Requirements: Nenhuma (permite acesso anônimo para desenvolvimento)

          ## Performance Impact:
          - Indexes: Chave primária e chave estrangeira são indexadas automaticamente.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo.
          */

-- Cria o tipo para o status da Ordem de Serviço, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'os_status') THEN
        CREATE TYPE public.os_status AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
    END IF;
END$$;

-- Cria o tipo para a prioridade da Ordem de Serviço, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'os_prioridade') THEN
        CREATE TYPE public.os_prioridade AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');
    END IF;
END$$;

-- Cria a tabela de Ordens de Serviço, se não existir
CREATE TABLE IF NOT EXISTS public.ordens_servico (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    numero text NOT NULL,
    descricao text NOT NULL,
    cliente_id uuid,
    status public.os_status NOT NULL DEFAULT 'ABERTA'::public.os_status,
    prioridade public.os_prioridade NOT NULL DEFAULT 'MEDIA'::public.os_prioridade,
    data_inicio date,
    data_previsao date,
    data_finalizada date,
    valor numeric(10, 2),
    responsavel text,
    
    CONSTRAINT ordens_servico_pkey PRIMARY KEY (id),
    CONSTRAINT ordens_servico_numero_key UNIQUE (numero),
    CONSTRAINT ordens_servico_cliente_id_fkey FOREIGN KEY (cliente_id) 
        REFERENCES public.clientes(id) ON DELETE SET NULL
);

-- Habilita a Segurança de Nível de Linha (RLS)
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Remove políticas antigas se existirem
DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (SELECT)" ON public.ordens_servico;
DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (INSERT)" ON public.ordens_servico;
DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (UPDATE)" ON public.ordens_servico;
DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (DELETE)" ON public.ordens_servico;

-- Adiciona políticas permissivas para o ambiente de desenvolvimento
CREATE POLICY "Permite acesso total para desenvolvimento (SELECT)"
    ON public.ordens_servico FOR SELECT
    USING (true);

CREATE POLICY "Permite acesso total para desenvolvimento (INSERT)"
    ON public.ordens_servico FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Permite acesso total para desenvolvimento (UPDATE)"
    ON public.ordens_servico FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Permite acesso total para desenvolvimento (DELETE)"
    ON public.ordens_servico FOR DELETE
    USING (true);
