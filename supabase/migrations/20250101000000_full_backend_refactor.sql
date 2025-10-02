/*
# [Refatoração Completa do Backend]
Este script zera e recria toda a estrutura de backend para as tabelas 'clientes' e 'ordens_servico', incluindo a inserção de dados iniciais (seeding).

## Query Description: [Este script é destrutivo e irá apagar quaisquer dados existentes nas tabelas 'clientes' e 'ordens_servico' antes de recriá-las. É seguro para um ambiente de desenvolvimento onde o objetivo é resetar a estrutura.]

## Metadata:
- Schema-Category: ["Dangerous", "Structural", "Data"]
- Impact-Level: ["High"]
- Requires-Backup: [true]
- Reversible: [false]

## Structure Details:
- Tabelas afetadas: 'clientes', 'ordens_servico'
- Tipos afetados: 'cliente_status', 'tipo_cliente', 'status_os', 'prioridade_os'

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [Yes]
- Auth Requirements: [Nenhuma, políticas abertas para 'anon' e 'authenticated']

## Performance Impact:
- Indexes: [Primary keys e Foreign keys serão recriados]
- Triggers: [Nenhum]
- Estimated Impact: [Baixo, recriação de tabelas pequenas]
*/

-- Limpeza completa de estruturas antigas
DROP TABLE IF EXISTS public.ordens_servico CASCADE;
DROP TABLE IF EXISTS public.clientes CASCADE;
DROP TYPE IF EXISTS public.cliente_status;
DROP TYPE IF EXISTS public.tipo_cliente;
DROP TYPE IF EXISTS public.status_os;
DROP TYPE IF EXISTS public.prioridade_os;

-- Criação dos tipos ENUM
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
CREATE TYPE public.status_os AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
CREATE TYPE public.prioridade_os AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- Criação da tabela de clientes
CREATE TABLE public.clientes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    email text NOT NULL,
    telefone text,
    documento text,
    tipo public.tipo_cliente NOT NULL,
    status public.cliente_status NOT NULL,
    endereco jsonb,
    CONSTRAINT clientes_pkey PRIMARY KEY (id),
    CONSTRAINT clientes_email_key UNIQUE (email)
);
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Criação da tabela de ordens de serviço
CREATE TABLE public.ordens_servico (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    numero text NOT NULL,
    cliente_id uuid NOT NULL,
    descricao text NOT NULL,
    status public.status_os NOT NULL,
    prioridade public.prioridade_os NOT NULL,
    data_inicio timestamp with time zone,
    data_previsao timestamp with time zone,
    data_finalizada timestamp with time zone,
    valor numeric,
    responsavel text,
    CONSTRAINT ordens_servico_pkey PRIMARY KEY (id),
    CONSTRAINT ordens_servico_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança (abertas para desenvolvimento)
CREATE POLICY "Permitir acesso total para usuários anônimos" ON public.clientes FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.clientes FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso total para usuários anônimos" ON public.ordens_servico FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.ordens_servico FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Inserção de dados iniciais (Seeding)
INSERT INTO public.clientes (id, nome, email, telefone, documento, tipo, status, endereco) VALUES
('8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f01', 'Ana Silva', 'ana.silva@email.com', '11987654321', '12345678901', 'CLIENTE', 'ATIVO', '{"cep": "01000-000", "cidade": "São Paulo", "estado": "SP"}'),
('8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f02', 'Bruno Costa', 'bruno.costa@email.com', '21987654322', '23456789012', 'CLIENTE', 'ATIVO', '{"cep": "20000-000", "cidade": "Rio de Janeiro", "estado": "RJ"}'),
('8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f03', 'Carla Dias', 'carla.dias@email.com', '31987654323', '34567890123', 'AMBOS', 'ATIVO', '{"cep": "30000-000", "cidade": "Belo Horizonte", "estado": "MG"}'),
('8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f04', 'Daniel Souza', 'daniel.souza@email.com', '41987654324', '45678901234', 'FORNECEDOR', 'INATIVO', '{"cep": "40000-000", "cidade": "Salvador", "estado": "BA"}'),
('8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f05', 'Eduarda Lima', 'eduarda.lima@email.com', '51987654325', '56789012345', 'CLIENTE', 'ATIVO', '{"cep": "50000-000", "cidade": "Recife", "estado": "PE"}');

INSERT INTO public.ordens_servico (numero, cliente_id, descricao, status, prioridade, valor, responsavel, data_previsao) VALUES
('OS-1001', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f01', 'Manutenção de servidor', 'ABERTA', 'ALTA', 500, 'Marcos', NOW() + interval '3 day'),
('OS-1002', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f02', 'Instalação de software', 'ABERTA', 'MEDIA', 250, 'Julia', NOW() + interval '5 day'),
('OS-1003', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f03', 'Consultoria de rede', 'EM_ANDAMENTO', 'ALTA', 1200, 'Marcos', NOW() + interval '7 day'),
('OS-1004', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f05', 'Reparo de hardware', 'EM_ANDAMENTO', 'URGENTE', 800, 'Pedro', NOW() + interval '1 day'),
('OS-1005', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f01', 'Backup de dados', 'FINALIZADA', 'BAIXA', 150, 'Julia', NOW() - interval '2 day'),
('OS-1006', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f02', 'Treinamento de equipe', 'FINALIZADA', 'MEDIA', 950, 'Ana', NOW() - interval '1 day'),
('OS-1007', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f03', 'Configuração de firewall', 'CANCELADA', 'MEDIA', 300, 'Marcos', NOW() + interval '10 day'),
('OS-1008', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f01', 'Desenvolvimento de relatório', 'ABERTA', 'BAIXA', 400, 'Julia', NOW() + interval '14 day'),
('OS-1009', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f05', 'Atualização de sistema', 'EM_ANDAMENTO', 'ALTA', 650, 'Pedro', NOW() + interval '4 day'),
('OS-1010', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f02', 'Suporte técnico remoto', 'FINALIZADA', 'BAIXA', 100, 'Ana', NOW() - interval '3 day'),
('OS-1011', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f03', 'Análise de vulnerabilidades', 'ABERTA', 'URGENTE', 1500, 'Marcos', NOW() + interval '2 day'),
('OS-1012', '8d8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f01', 'Migração de e-mails', 'EM_ANDAMENTO', 'MEDIA', 750, 'Pedro', NOW() + interval '6 day');
