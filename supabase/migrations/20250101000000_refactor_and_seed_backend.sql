-- Full Backend Refactor and Seeding
-- This script will reset the database schema for 'clientes' and 'ordens_servico'
-- and populate them with initial data.

/*
  # [Full Backend Reset and Seed]
  This operation will completely reset and rebuild the 'clientes' and 'ordens_servico' tables. It will first DROP existing structures to ensure a clean state, then recreate them with the correct schema and relationships. Finally, it will INSERT initial seed data directly into the tables.

  ## Query Description: [This is a destructive and reconstructive operation. All existing data in 'clientes' and 'ordens_servico' tables will be lost. This is intended to fix any previous migration issues and establish a definitive, working backend structure with initial data.]
  
  ## Metadata:
  - Schema-Category: ["Dangerous", "Structural", "Data"]
  - Impact-Level: ["High"]
  - Requires-Backup: [true]
  - Reversible: [false]
  
  ## Structure Details:
  - Drops: tables 'clientes', 'ordens_servico'; types 'cliente_status', 'tipo_cliente', 'status_os', 'prioridade_os'.
  - Creates: types 'cliente_status', 'tipo_cliente', 'status_os', 'prioridade_os'; tables 'clientes', 'ordens_servico'.
  - Inserts: 5 records into 'clientes', 12 records into 'ordens_servico'.
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes] - Creates permissive policies for 'anon' and 'authenticated' roles to allow all actions during development.
  
  ## Performance Impact:
  - Indexes: [Added] - Primary keys are indexed by default.
  - Triggers: [None]
  - Estimated Impact: [Low, as it's setting up initial schema.]
*/

-- Step 1: Drop existing objects if they exist to ensure a clean slate
DROP TABLE IF EXISTS public.ordens_servico;
DROP TABLE IF EXISTS public.clientes;
DROP TYPE IF EXISTS public.cliente_status;
DROP TYPE IF EXISTS public.tipo_cliente;
DROP TYPE IF EXISTS public.status_os;
DROP TYPE IF EXISTS public.prioridade_os;

-- Step 2: Create custom ENUM types
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
CREATE TYPE public.status_os AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
CREATE TYPE public.prioridade_os AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- Step 3: Create the 'clientes' table
CREATE TABLE public.clientes (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text NOT NULL,
    email text UNIQUE,
    telefone text,
    documento text UNIQUE,
    tipo public.tipo_cliente DEFAULT 'CLIENTE'::public.tipo_cliente NOT NULL,
    status public.cliente_status DEFAULT 'ATIVO'::public.cliente_status NOT NULL,
    endereco jsonb
);
COMMENT ON TABLE public.clientes IS 'Tabela para armazenar informações de clientes e fornecedores.';

-- Step 4: Create the 'ordens_servico' table
CREATE TABLE public.ordens_servico (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    numero text NOT NULL,
    cliente_id uuid REFERENCES public.clientes(id) ON DELETE SET NULL,
    descricao text NOT NULL,
    status public.status_os DEFAULT 'ABERTA'::public.status_os NOT NULL,
    prioridade public.prioridade_os DEFAULT 'MEDIA'::public.prioridade_os NOT NULL,
    data_inicio timestamp with time zone,
    data_previsao timestamp with time zone,
    data_finalizada timestamp with time zone,
    valor numeric,
    responsavel text
);
COMMENT ON TABLE public.ordens_servico IS 'Tabela para armazenar ordens de serviço.';

-- Step 5: Enable Row Level Security (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies (permissive for development)
CREATE POLICY "Allow all actions for anon and authenticated users on clientes"
ON public.clientes
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow all actions for anon and authenticated users on ordens_servico"
ON public.ordens_servico
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Step 7: Seed the 'clientes' table with 5 records
INSERT INTO public.clientes (nome, email, telefone, documento, tipo, status, endereco)
VALUES
('Ana Silva', 'ana.silva@example.com', '(11) 98765-4321', '11122233344', 'CLIENTE', 'ATIVO', '{"cep": "01001-000", "logradouro": "Praça da Sé", "numero": "1", "bairro": "Sé", "cidade": "São Paulo", "estado": "SP"}'),
('Bruno Costa', 'bruno.costa@example.com', '(21) 91234-5678', '22233344455', 'CLIENTE', 'ATIVO', '{"cep": "20040-004", "logradouro": "Avenida Rio Branco", "numero": "156", "bairro": "Centro", "cidade": "Rio de Janeiro", "estado": "RJ"}'),
('Carla Dias', 'carla.dias@example.com', '(31) 95555-4444', '33344455566', 'FORNECEDOR', 'ATIVO', '{"cep": "30130-170", "logradouro": "Avenida Getúlio Vargas", "numero": "840", "bairro": "Funcionários", "cidade": "Belo Horizonte", "estado": "MG"}'),
('Daniel Farias', 'daniel.farias@example.com', '(41) 94321-8765', '44455566677', 'AMBOS', 'INATIVO', '{"cep": "80420-000", "logradouro": "Avenida Batel", "numero": "1868", "bairro": "Batel", "cidade": "Curitiba", "estado": "PR"}'),
('Eduarda Lima', 'eduarda.lima@example.com', '(51) 93322-1100', '55566677788', 'CLIENTE', 'ATIVO', '{"cep": "90010-230", "logradouro": "Rua dos Andradas", "numero": "1001", "bairro": "Centro Histórico", "cidade": "Porto Alegre", "estado": "RS"}');

-- Step 8: Seed the 'ordens_servico' table with 12 records
DO $$
DECLARE
    cliente_id_1 uuid;
    cliente_id_2 uuid;
    cliente_id_3 uuid;
    cliente_id_4 uuid;
    cliente_id_5 uuid;
BEGIN
    SELECT id INTO cliente_id_1 FROM public.clientes WHERE email = 'ana.silva@example.com';
    SELECT id INTO cliente_id_2 FROM public.clientes WHERE email = 'bruno.costa@example.com';
    SELECT id INTO cliente_id_3 FROM public.clientes WHERE email = 'carla.dias@example.com';
    SELECT id INTO cliente_id_4 FROM public.clientes WHERE email = 'daniel.farias@example.com';
    SELECT id INTO cliente_id_5 FROM public.clientes WHERE email = 'eduarda.lima@example.com';

    INSERT INTO public.ordens_servico (numero, cliente_id, descricao, status, prioridade, data_previsao, valor, responsavel)
    VALUES
    ('OS-1001', cliente_id_1, 'Manutenção preventiva em servidor Dell.', 'ABERTA', 'ALTA', now() + interval '3 day', 500.00, 'Marcos'),
    ('OS-1002', cliente_id_2, 'Instalação de 5 pontos de rede.', 'ABERTA', 'MEDIA', now() + interval '5 day', 1200.00, 'Joana'),
    ('OS-1003', cliente_id_5, 'Configuração de backup em nuvem.', 'EM_ANDAMENTO', 'URGENTE', now() + interval '1 day', 800.00, 'Marcos'),
    ('OS-1004', cliente_id_1, 'Troca de HD de notebook para SSD.', 'EM_ANDAMENTO', 'MEDIA', now() + interval '2 day', 350.00, 'Pedro'),
    ('OS-1005', cliente_id_3, 'Consultoria de segurança de rede.', 'FINALIZADA', 'ALTA', now() - interval '2 day', 2500.00, 'Ana'),
    ('OS-1006', cliente_id_2, 'Formatação e reinstalação de sistema operacional.', 'FINALIZADA', 'BAIXA', now() - interval '5 day', 250.00, 'Pedro'),
    ('OS-1007', cliente_id_5, 'Remoção de vírus e otimização de sistema.', 'FINALIZADA', 'MEDIA', now() - interval '1 day', 180.00, 'Joana'),
    ('OS-1008', cliente_id_4, 'Problema com impressora fiscal.', 'CANCELADA', 'ALTA', now() + interval '1 day', 150.00, 'Marcos'),
    ('OS-1009', cliente_id_1, 'Desenvolvimento de novo relatório de vendas.', 'ABERTA', 'MEDIA', now() + interval '10 day', 1800.00, 'Ana'),
    ('OS-1010', cliente_id_2, 'Upgrade de memória RAM em 10 estações.', 'EM_ANDAMENTO', 'BAIXA', now() + interval '7 day', 950.00, 'Pedro'),
    ('OS-1011', cliente_id_5, 'Configuração de VPN para acesso remoto.', 'ABERTA', 'URGENTE', now() + interval '2 day', 400.00, 'Joana'),
    ('OS-1012', cliente_id_1, 'Análise de lentidão na rede interna.', 'EM_ANDAMENTO', 'ALTA', now() + interval '4 day', 600.00, 'Marcos');
END $$;
