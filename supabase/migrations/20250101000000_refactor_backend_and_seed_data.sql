/*
# [Refatoração Completa do Backend e População de Dados]
Este script redefine a estrutura do banco de dados para as entidades 'clientes' e 'ordens_servico', garantindo um ambiente limpo e funcional. Ele também insere dados iniciais para que a aplicação seja imediatamente utilizável.

## Query Description: Este script executará operações destrutivas (DROP TABLE) para limpar configurações antigas antes de recriar as tabelas. Qualquer dado existente nas tabelas 'clientes' e 'ordens_servico' será perdido. Esta ação é necessária para garantir a integridade e consistência da nova estrutura.

## Metadata:
- Schema-Category: "Dangerous"
- Impact-Level: "High"
- Requires-Backup: true
- Reversible: false

## Structure Details:
- Remove: Tabelas 'ordens_servico', 'clientes' e os tipos ENUM associados.
- Create: Tipos ENUM 'cliente_status', 'tipo_cliente', 'os_status', 'os_prioridade'.
- Create: Tabela 'clientes' com estrutura e constraints corretas.
- Create: Tabela 'ordens_servico' com estrutura, constraints e chave estrangeira para 'clientes'.
- Insert: 5 registros na tabela 'clientes'.
- Insert: 12 registros na tabela 'ordens_servico'.

## Security Implications:
- RLS Status: Habilitado para ambas as tabelas.
- Policy Changes: Sim. Políticas permissivas (acesso público total) serão criadas para permitir o funcionamento da aplicação no estágio atual de desenvolvimento.
- Auth Requirements: Nenhuma autenticação é necessária para as operações de CRUD.

## Performance Impact:
- Indexes: Índices de chave primária e chave estrangeira serão criados.
- Triggers: Nenhum.
- Estimated Impact: Baixo. A operação é rápida em bancos de dados com poucos dados.
*/

-- Habilita a extensão para gerar UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- Remove objetos existentes para garantir um ambiente limpo
DROP TABLE IF EXISTS public.ordens_servico;
DROP TABLE IF EXISTS public.clientes;
DROP TYPE IF EXISTS public.os_status;
DROP TYPE IF EXISTS public.os_prioridade;
DROP TYPE IF EXISTS public.tipo_cliente;
DROP TYPE IF EXISTS public.cliente_status;

-- Cria os tipos ENUM necessários
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
CREATE TYPE public.os_status AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
CREATE TYPE public.os_prioridade AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- Cria a tabela de clientes
CREATE TABLE public.clientes (
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
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

-- Cria a tabela de ordens de serviço
CREATE TABLE public.ordens_servico (
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    numero text NOT NULL,
    cliente_id uuid NOT NULL,
    descricao text NOT NULL,
    status public.os_status NOT NULL,
    prioridade public.os_prioridade NOT NULL,
    data_inicio timestamp with time zone,
    data_previsao timestamp with time zone,
    data_finalizada timestamp with time zone,
    valor numeric,
    responsavel text,
    CONSTRAINT ordens_servico_pkey PRIMARY KEY (id),
    CONSTRAINT ordens_servico_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

-- Habilita a Segurança em Nível de Linha (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Cria políticas de segurança permissivas para o estágio atual de desenvolvimento
CREATE POLICY "Public access for all" ON public.clientes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public access for all" ON public.ordens_servico FOR ALL USING (true) WITH CHECK (true);

-- Popula a tabela de clientes com dados iniciais
INSERT INTO public.clientes (id, nome, email, telefone, documento, tipo, status, endereco) VALUES
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Ana Silva', 'ana.silva@example.com', '(11) 98765-4321', '12345678901', 'CLIENTE', 'ATIVO', '{"cep": "01001-000", "logradouro": "Praça da Sé", "numero": "1", "bairro": "Sé", "cidade": "São Paulo", "estado": "SP"}'),
('b2c3d4e5-f6a7-8901-2345-67890abcdef1', 'Bruno Costa', 'bruno.costa@example.com', '(21) 91234-5678', '23456789012', 'CLIENTE', 'ATIVO', '{"cep": "20040-004", "logradouro": "Avenida Rio Branco", "numero": "156", "bairro": "Centro", "cidade": "Rio de Janeiro", "estado": "RJ"}'),
('c3d4e5f6-a7b8-9012-3456-7890abcdef2', 'Carla Dias', 'carla.dias@example.com', '(31) 92345-6789', '34567890123', 'AMBOS', 'ATIVO', '{"cep": "30110-044", "logradouro": "Avenida do Contorno", "numero": "6594", "bairro": "Savassi", "cidade": "Belo Horizonte", "estado": "MG"}'),
('d4e5f6a7-b8c9-0123-4567-890abcdef3', 'Daniel Souza', 'daniel.souza@example.com', '(41) 93456-7890', '45678901234', 'FORNECEDOR', 'INATIVO', '{"cep": "80420-090", "logradouro": "Rua Comendador Araújo", "numero": "731", "bairro": "Batel", "cidade": "Curitiba", "estado": "PR"}'),
('e5f6a7b8-c9d0-1234-5678-90abcdef4', 'Eduarda Lima', 'eduarda.lima@example.com', '(51) 94567-8901', '56789012345', 'CLIENTE', 'SUSPENSO', '{"cep": "90010-210", "logradouro": "Rua dos Andradas", "numero": "1001", "bairro": "Centro Histórico", "cidade": "Porto Alegre", "estado": "RS"}');

-- Popula a tabela de ordens de serviço com dados iniciais, referenciando os clientes criados
INSERT INTO public.ordens_servico (cliente_id, numero, descricao, status, prioridade, data_previsao, valor, responsavel) VALUES
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'OS-1001', 'Manutenção preventiva em servidor Dell', 'ABERTA', 'ALTA', NOW() + interval '5 day', 500.00, 'Marcos'),
('b2c3d4e5-f6a7-8901-2345-67890abcdef1', 'OS-1002', 'Instalação de 5 pontos de rede', 'EM_ANDAMENTO', 'MEDIA', NOW() + interval '3 day', 850.00, 'Juliana'),
('c3d4e5f6-a7b8-9012-3456-7890abcdef2', 'OS-1003', 'Configuração de firewall e VPN', 'ABERTA', 'URGENTE', NOW() + interval '2 day', 1200.00, 'Marcos'),
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'OS-1004', 'Troca de HD de notebook para SSD', 'FINALIZADA', 'BAIXA', NOW() - interval '1 day', 350.00, 'Pedro'),
('d4e5f6a7-b8c9-0123-4567-890abcdef3', 'OS-1005', 'Consultoria de infraestrutura de nuvem', 'EM_ANDAMENTO', 'ALTA', NOW() + interval '10 day', 3500.00, 'Juliana'),
('e5f6a7b8-c9d0-1234-5678-90abcdef4', 'OS-1006', 'Reparo em impressora fiscal', 'CANCELADA', 'MEDIA', NOW() - interval '5 day', 200.00, 'Pedro'),
('b2c3d4e5-f6a7-8901-2345-67890abcdef1', 'OS-1007', 'Desenvolvimento de novo relatório de vendas', 'ABERTA', 'MEDIA', NOW() + interval '15 day', 2500.00, 'Ana'),
('c3d4e5f6-a7b8-9012-3456-7890abcdef2', 'OS-1008', 'Suporte técnico remoto para 10 usuários', 'EM_ANDAMENTO', 'BAIXA', NOW() + interval '30 day', 1800.00, 'Carlos'),
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'OS-1009', 'Backup completo de dados do servidor principal', 'FINALIZADA', 'ALTA', NOW() - interval '2 day', 450.00, 'Marcos'),
('b2c3d4e5-f6a7-8901-2345-67890abcdef1', 'OS-1010', 'Formatação e reinstalação de sistema operacional', 'ABERTA', 'BAIXA', NOW() + interval '4 day', 250.00, 'Pedro'),
('e5f6a7b8-c9d0-1234-5678-90abcdef4', 'OS-1011', 'Análise de vulnerabilidades de segurança', 'EM_ANDAMENTO', 'URGENTE', NOW() + interval '7 day', 4200.00, 'Juliana'),
('c3d4e5f6-a7b8-9012-3456-7890abcdef2', 'OS-1012', 'Migração de e-mails para nova plataforma', 'CANCELADA', 'MEDIA', NOW() - interval '10 day', 950.00, 'Carlos');
