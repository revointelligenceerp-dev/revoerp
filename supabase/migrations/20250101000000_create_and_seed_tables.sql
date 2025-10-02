/*
          # [Operação de Criação e População de Tabelas]
          Este script recria a estrutura completa das tabelas `clientes` e `ordens_servico` e as popula com dados de exemplo.

          ## Query Description: [Este script é destrutivo. Ele removerá quaisquer dados existentes nas tabelas `clientes` e `ordens_servico` antes de recriá-las. Esta é uma medida para garantir um estado limpo e consistente do banco de dados, resolvendo quaisquer problemas de configurações anteriores. Prossiga apenas se você estiver ciente de que os dados atuais nessas tabelas serão perdidos.]
          
          ## Metadata:
          - Schema-Category: ["Dangerous"]
          - Impact-Level: ["High"]
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - Tabelas afetadas: `clientes`, `ordens_servico`
          - Tipos ENUM afetados: `cliente_status`, `tipo_cliente`, `status_os`, `prioridade_os`
          
          ## Security Implications:
          - RLS Status: Habilitado para ambas as tabelas.
          - Policy Changes: Políticas permissivas (permitindo todas as ações para `anon` e `authenticated`) serão aplicadas para facilitar o desenvolvimento inicial.
          
          ## Performance Impact:
          - Indexes: Índices de chave primária e estrangeira serão criados.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo.
          */

-- Limpeza completa para garantir um estado limpo
DROP TABLE IF EXISTS public.ordens_servico;
DROP TABLE IF EXISTS public.clientes;
DROP TYPE IF EXISTS public.cliente_status;
DROP TYPE IF EXISTS public.tipo_cliente;
DROP TYPE IF EXISTS public.status_os;
DROP TYPE IF EXISTS public.prioridade_os;

-- Recriação dos tipos ENUM
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
CREATE TYPE public.status_os AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
CREATE TYPE public.prioridade_os AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- Tabela de Clientes
CREATE TABLE public.clientes (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text NOT NULL,
    email text UNIQUE NOT NULL,
    telefone text,
    documento text UNIQUE,
    tipo public.tipo_cliente DEFAULT 'CLIENTE'::public.tipo_cliente NOT NULL,
    status public.cliente_status DEFAULT 'ATIVO'::public.cliente_status NOT NULL,
    endereco jsonb
);

-- Tabela de Ordens de Serviço
CREATE TABLE public.ordens_servico (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    numero text NOT NULL,
    cliente_id uuid REFERENCES public.clientes(id) ON DELETE SET NULL,
    descricao text,
    status public.status_os DEFAULT 'ABERTA'::public.status_os NOT NULL,
    prioridade public.prioridade_os DEFAULT 'MEDIA'::public.prioridade_os NOT NULL,
    data_inicio timestamp with time zone,
    data_previsao timestamp with time zone,
    data_finalizada timestamp with time zone,
    valor numeric,
    responsavel text
);

-- Habilita RLS para ambas as tabelas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança permissivas para desenvolvimento
CREATE POLICY "Permitir acesso total para desenvolvimento (Clientes)"
ON public.clientes FOR ALL
USING (true)
WITH CHECK (true);

CREATE POLICY "Permitir acesso total para desenvolvimento (Ordens de Serviço)"
ON public.ordens_servico FOR ALL
USING (true)
WITH CHECK (true);

-- Inserção de dados de exemplo
WITH inserted_clientes AS (
  INSERT INTO public.clientes (nome, email, telefone, documento, tipo, status, endereco)
  VALUES
    ('Ana Silva', 'ana.silva@email.com', '(11) 98765-4321', '11122233344', 'CLIENTE', 'ATIVO', '{"cep": "01001-000", "cidade": "São Paulo", "estado": "SP"}'),
    ('Bruno Costa', 'bruno.costa@email.com', '(21) 91234-5678', '22233344455', 'CLIENTE', 'ATIVO', '{"cep": "20040-001", "cidade": "Rio de Janeiro", "estado": "RJ"}'),
    ('Carla Dias', 'carla.dias@email.com', '(31) 95555-8888', '33344455566', 'FORNECEDOR', 'ATIVO', '{"cep": "30112-010", "cidade": "Belo Horizonte", "estado": "MG"}'),
    ('Daniel Farias', 'daniel.farias@email.com', '(51) 94321-8765', '44455566677', 'AMBOS', 'INATIVO', '{"cep": "90010-110", "cidade": "Porto Alegre", "estado": "RS"}'),
    ('Empresa Exemplo SA', 'contato@exemplo.com', '(41) 3030-4040', '12345678000199', 'CLIENTE', 'ATIVO', '{"cep": "80010-010", "cidade": "Curitiba", "estado": "PR"}')
  RETURNING id, nome
)
INSERT INTO public.ordens_servico (numero, cliente_id, descricao, status, prioridade, data_previsao, valor, responsavel)
VALUES
  ('OS-001', (SELECT id FROM inserted_clientes WHERE nome = 'Ana Silva'), 'Manutenção preventiva no servidor principal.', 'ABERTA', 'ALTA', now() + interval '3 day', 500.00, 'Marcos'),
  ('OS-002', (SELECT id FROM inserted_clientes WHERE nome = 'Bruno Costa'), 'Instalação de novo software de gestão.', 'ABERTA', 'MEDIA', now() + interval '5 day', 1200.00, 'Laura'),
  ('OS-003', (SELECT id FROM inserted_clientes WHERE nome = 'Empresa Exemplo SA'), 'Configuração de firewall e políticas de segurança.', 'EM_ANDAMENTO', 'URGENTE', now() + interval '1 day', 850.00, 'Marcos'),
  ('OS-004', (SELECT id FROM inserted_clientes WHERE nome = 'Ana Silva'), 'Troca de HD de estação de trabalho.', 'EM_ANDAMENTO', 'BAIXA', now() + interval '7 day', 250.00, 'Pedro'),
  ('OS-005', (SELECT id FROM inserted_clientes WHERE nome = 'Bruno Costa'), 'Treinamento de equipe para novo sistema.', 'FINALIZADA', 'MEDIA', now() - interval '2 day', 900.00, 'Laura'),
  ('OS-006', (SELECT id FROM inserted_clientes WHERE nome = 'Empresa Exemplo SA'), 'Verificação de rotina nos backups.', 'FINALIZADA', 'BAIXA', now() - interval '5 day', 150.00, 'Pedro'),
  ('OS-007', (SELECT id FROM inserted_clientes WHERE nome = 'Ana Silva'), 'Diagnóstico de lentidão na rede interna.', 'CANCELADA', 'MEDIA', now() + interval '1 day', 100.00, 'Marcos'),
  ('OS-008', (SELECT id FROM inserted_clientes WHERE nome = 'Empresa Exemplo SA'), 'Desenvolvimento de relatório customizado.', 'ABERTA', 'ALTA', now() + interval '10 day', 2500.00, 'Laura'),
  ('OS-009', (SELECT id FROM inserted_clientes WHERE nome = 'Bruno Costa'), 'Consultoria para migração de nuvem.', 'EM_ANDAMENTO', 'ALTA', now() + interval '15 day', 5000.00, 'Marcos'),
  ('OS-010', (SELECT id FROM inserted_clientes WHERE nome = 'Ana Silva'), 'Suporte técnico remoto para impressora.', 'FINALIZADA', 'BAIXA', now() - interval '1 day', 80.00, 'Pedro'),
  ('OS-011', (SELECT id FROM inserted_clientes WHERE nome = 'Empresa Exemplo SA'), 'Atualização do sistema ERP para a versão mais recente.', 'ABERTA', 'URGENTE', now() + interval '2 day', 1800.00, 'Laura'),
  ('OS-012', (SELECT id FROM inserted_clientes WHERE nome = 'Bruno Costa'), 'Formatação e reinstalação de sistema operacional.', 'EM_ANDAMENTO', 'MEDIA', now() + interval '4 day', 350.00, 'Pedro');
