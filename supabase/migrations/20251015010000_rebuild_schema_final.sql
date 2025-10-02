/*
          # [RECONSTRUÇÃO COMPLETA E CORRIGIDA DO SCHEMA]
          Este script apaga completamente o schema 'public' e o recria do zero.
          Todas as tabelas, tipos, funções e dados existentes serão PERDIDOS.
          Esta é uma operação destrutiva projetada para resolver inconsistências e reiniciar o banco de dados.
          ## Query Description: [Esta operação irá apagar todos os dados do seu banco de dados. É altamente recomendável fazer um backup antes de prosseguir, caso haja alguma informação que você não queira perder. As mudanças são irreversíveis e visam criar um ambiente limpo e consistente para o desenvolvimento.]
          ## Metadata:
          - Schema-Category: ["Dangerous"]
          - Impact-Level: ["High"]
          - Requires-Backup: [true]
          - Reversible: [false]
          ## Structure Details:
          - Todas as tabelas, views, functions e types no schema 'public'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [Added]
          - Estimated Impact: [Recriação completa do schema, o impacto inicial é de reset, seguido por performance otimizada com os novos índices.]
*/
-- PASSO 1: LIMPEZA COMPLETA
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;
-- PASSO 2: EXTENSÕES E FUNÇÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- PASSO 3: CRIAÇÃO DOS TIPOS (ENUMS) COM LABELS CORRIGIDOS
CREATE TYPE public.tipo_pessoa AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO');
CREATE TYPE public.contribuinte_icms AS ENUM ('Não informado', 'Contribuinte ICMS', 'Contribuinte Isento (sem IE)', 'Não Contribuinte');
CREATE TYPE public.tipo_pessoa_vendedor AS ENUM ('Física', 'Jurídica', 'Estrangeiro', 'Estrangeiro no Brasil');
CREATE TYPE public.situacao_vendedor AS ENUM ('Ativo com acesso ao sistema', 'Ativo sem acesso ao sistema', 'Inativo');
CREATE TYPE public.regra_comissao AS ENUM ('Liberação parcial (pelo pagamento)', 'Liberação total (no faturamento)', 'Liberação total (no pagamento)');
CREATE TYPE public.tipo_comissao_vendedor AS ENUM ('Comissão com alíquota fixa', 'Comissão com alíquota conforme descontos');
CREATE TYPE public.status_os AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA', 'ORCAMENTO');
CREATE TYPE public.prioridade_os AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');
CREATE TYPE public.status_pedido_venda AS ENUM ('ABERTO', 'FATURADO', 'CANCELADO');
CREATE TYPE public.status_fatura AS ENUM ('EMITIDA', 'PAGA', 'VENCIDA', 'CANCELADA');
CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
CREATE TYPE public.ocorrencia_conta AS ENUM ('Única', 'Recorrente');
CREATE TYPE public.tipo_movimento_caixa AS ENUM ('ENTRADA', 'SAIDA');
CREATE TYPE public.tipo_produto AS ENUM ('Simples', 'Com variações', 'Kit', 'Fabricado', 'Matéria Prima');
CREATE TYPE public.situacao_produto AS ENUM ('Ativo', 'Inativo');
CREATE TYPE public.situacao_servico AS ENUM ('ATIVO', 'INATIVO');
CREATE TYPE public.origem_produto AS ENUM ('0 - Nacional', '1 - Estrangeira (Imp. Direta)', '2 - Estrangeira (Merc. Interno)', '3 - Nacional (Imp. > 40%)', '4 - Nacional (Proc. Básico)', '5 - Nacional (Imp. <= 40%)', '6 - Estrangeira (Imp. Direta, s/ similar)', '7 - Estrangeira (Merc. Interno, s/ similar)', '8 - Nacional (Imp. > 70%)');
CREATE TYPE public.tipo_embalagem_produto AS ENUM ('Pacote / Caixa', 'Envelope', 'Rolo / Cilindrico');
CREATE TYPE public.embalagem_produto AS ENUM ('Embalagem customizada', 'Caixa de Encomenda Flex', 'Caixa de Encomenda CE – 01', 'Caixa de Encomenda CE – 02', 'Caixa de Encomenda CE – 03', 'Caixa de Encomenda CE – 07', 'Caixa de Encomenda 5B', 'Caixa de Encomenda 6B', 'Caixa de Encomenda Vai e Vem', 'Caixa de Encomenda B', 'Caixa de Encomenda 2B', 'Caixa de Encomenda 4B', 'Caixa de Encomenda Temática 01', 'Caixa de Encomenda Temática 02', 'Caixa de Encomenda Temática 03', 'Criar nova embalagem ...');
CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
CREATE TYPE public.status_expedicao AS ENUM ('AGUARDANDO_ENVIO', 'ENVIADO', 'ENTREGUE', 'CANCELADO');
CREATE TYPE public.frete_por_conta AS ENUM ('CIF', 'FOB');
CREATE TYPE public.status_ordem_compra AS ENUM ('ABERTA', 'RECEBIDA', 'CANCELADA');
-- PASSO 4: CRIAÇÃO DAS TABELAS
-- Tabela de Clientes/Fornecedores/Transportadoras
CREATE TABLE public.clientes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    codigo TEXT,
    nome TEXT NOT NULL,
    nome_fantasia TEXT,
    tipo_pessoa tipo_pessoa NOT NULL,
    cpf_cnpj TEXT UNIQUE,
    rg TEXT,
    inscricao_estadual TEXT,
    inscricao_municipal TEXT,
    contribuinte_icms contribuinte_icms NOT NULL,
    is_cliente BOOLEAN DEFAULT TRUE,
    is_fornecedor BOOLEAN DEFAULT FALSE,
    is_transportadora BOOLEAN DEFAULT FALSE,
    logradouro TEXT,
    numero TEXT,
    complemento TEXT,
    bairro TEXT,
    cep TEXT,
    cidade TEXT,
    estado TEXT,
    pais TEXT,
    cobranca_logradouro TEXT,
    cobranca_numero TEXT,
    cobranca_complemento TEXT,
    cobranca_bairro TEXT,
    cobranca_cep TEXT,
    cobranca_cidade TEXT,
    cobranca_estado TEXT,
    telefone TEXT,
    telefone_adicional TEXT,
    celular TEXT,
    email TEXT NOT NULL,
    email_nfe TEXT,
    site TEXT,
    estado_civil TEXT,
    profissao TEXT,
    sexo TEXT,
    data_nascimento DATE,
    naturalidade TEXT,
    status_crm TEXT,
    vendedor_id UUID,
    condicao_pagamento_padrao_id TEXT,
    limite_credito NUMERIC,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.pessoas_contato (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    setor TEXT,
    email TEXT,
    telefone TEXT,
    ramal TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.cliente_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabela de Vendedores
CREATE TABLE public.vendedores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL,
    fantasia TEXT,
    codigo TEXT,
    tipo_pessoa tipo_pessoa_vendedor NOT NULL,
    cpf_cnpj TEXT UNIQUE,
    contribuinte contribuinte_icms NOT NULL,
    inscricao_estadual TEXT,
    cep TEXT,
    cidade TEXT,
    uf TEXT,
    logradouro TEXT,
    bairro TEXT,
    numero TEXT,
    complemento TEXT,
    telefone TEXT,
    celular TEXT,
    email TEXT NOT NULL UNIQUE,
    situacao situacao_vendedor NOT NULL,
    deposito TEXT,
    email_comunicacoes TEXT,
    usuario_sistema TEXT,
    acesso_restrito_horario BOOLEAN DEFAULT FALSE,
    acesso_restrito_ip BOOLEAN DEFAULT FALSE,
    ips_permitidos TEXT,
    perfil_acesso_contatos TEXT,
    modulos_acessiveis TEXT[],
    pode_incluir_produtos_nao_cadastrados BOOLEAN DEFAULT FALSE,
    pode_emitir_cobrancas BOOLEAN DEFAULT FALSE,
    regra_liberacao_comissao regra_comissao NOT NULL,
    tipo_comissao tipo_comissao_vendedor NOT NULL,
    aliquota_comissao NUMERIC,
    desconsiderar_comissao_linha_produto BOOLEAN DEFAULT FALSE,
    observacoes TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.clientes ADD CONSTRAINT fk_vendedor FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
-- Tabela de Produtos
CREATE TABLE public.produtos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tipo_produto tipo_produto NOT NULL,
    nome TEXT NOT NULL,
    codigo_barras TEXT,
    codigo TEXT UNIQUE,
    origem origem_produto NOT NULL,
    unidade TEXT NOT NULL,
    ncm TEXT,
    cest TEXT,
    preco_venda NUMERIC NOT NULL,
    peso_liquido NUMERIC,
    peso_bruto NUMERIC,
    volumes INTEGER,
    tipo_embalagem tipo_embalagem_produto,
    embalagem embalagem_produto,
    largura NUMERIC,
    altura NUMERIC,
    comprimento NUMERIC,
    controlar_estoque BOOLEAN DEFAULT FALSE,
    estoque_inicial INTEGER,
    estoque_minimo INTEGER,
    estoque_maximo INTEGER,
    controlar_lotes BOOLEAN DEFAULT FALSE,
    localizacao TEXT,
    dias_preparacao INTEGER,
    situacao situacao_produto NOT NULL,
    marca TEXT,
    tabela_medidas TEXT,
    descricao_complementar TEXT,
    link_video TEXT,
    slug TEXT,
    keywords TEXT,
    titulo_seo TEXT,
    descricao_seo TEXT,
    unidade_por_caixa INTEGER,
    custo NUMERIC,
    linha_produto TEXT,
    garantia TEXT,
    markup NUMERIC,
    permitir_vendas BOOLEAN DEFAULT TRUE,
    gtin_tributavel TEXT,
    unidade_tributavel TEXT,
    fator_conversao NUMERIC,
    codigo_enquadramento_ipi TEXT,
    valor_ipi_fixo NUMERIC,
    ex_tipi TEXT,
    observacoes_produto TEXT,
    atributos JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.produto_imagens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    nome_arquivo TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.produto_anuncios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    ecommerce TEXT NOT NULL,
    identificador TEXT NOT NULL,
    descricao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(produto_id, ecommerce, identificador)
);
CREATE TABLE public.produtos_fornecedores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    fornecedor_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    codigo_no_fornecedor TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(produto_id, fornecedor_id)
);
-- Tabela de Serviços
CREATE TABLE public.servicos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    codigo TEXT UNIQUE,
    preco NUMERIC NOT NULL,
    unidade TEXT,
    situacao situacao_servico NOT NULL,
    codigo_servico TEXT,
    nbs TEXT,
    descricao_complementar TEXT,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabela de Embalagens
CREATE TABLE public.embalagens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    tipo tipo_embalagem NOT NULL,
    largura_cm NUMERIC,
    altura_cm NUMERIC,
    comprimento_cm NUMERIC,
    diametro_cm NUMERIC,
    peso_kg NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabelas de Pedidos de Venda
CREATE TABLE public.pedidos_venda (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    numero TEXT NOT NULL UNIQUE,
    natureza_operacao TEXT,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    vendedor_id UUID REFERENCES public.vendedores(id),
    endereco_entrega_diferente BOOLEAN DEFAULT FALSE,
    total_produtos NUMERIC NOT NULL,
    valor_ipi NUMERIC,
    valor_icms_st NUMERIC,
    desconto TEXT,
    frete_cliente NUMERIC,
    frete_empresa NUMERIC,
    despesas NUMERIC,
    valor_total NUMERIC NOT NULL,
    data_venda DATE NOT NULL,
    data_prevista_entrega DATE,
    data_envio TIMESTAMPTZ,
    data_maxima_despacho TIMESTAMPTZ,
    numero_pedido_ecommerce TEXT,
    identificador_pedido_ecommerce TEXT,
    numero_pedido_canal_venda TEXT,
    intermediador TEXT,
    forma_recebimento TEXT,
    meio_pagamento TEXT,
    conta_bancaria TEXT,
    categoria_financeira TEXT,
    condicao_pagamento TEXT,
    forma_envio TEXT,
    enviar_para_expedicao BOOLEAN DEFAULT TRUE,
    deposito TEXT,
    observacoes TEXT,
    observacoes_internas TEXT,
    marcadores TEXT[],
    status status_pedido_venda NOT NULL,
    peso_bruto NUMERIC,
    peso_liquido NUMERIC,
    expedido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.pedido_venda_itens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    codigo TEXT,
    unidade TEXT,
    quantidade NUMERIC NOT NULL,
    valor_unitario NUMERIC NOT NULL,
    desconto_percentual NUMERIC,
    valor_total NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.pedido_venda_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabelas de Faturas e Contas a Receber
CREATE TABLE public.faturas_venda (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id),
    numero_fatura TEXT NOT NULL UNIQUE,
    data_emissao DATE NOT NULL,
    data_vencimento DATE NOT NULL,
    valor_total NUMERIC NOT NULL,
    status status_fatura NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.contas_receber (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fatura_id UUID REFERENCES public.faturas_venda(id),
    cliente_id UUID REFERENCES public.clientes(id),
    descricao TEXT,
    valor NUMERIC NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status status_conta_receber NOT NULL,
    ocorrencia ocorrencia_conta,
    forma_recebimento TEXT,
    numero_documento TEXT,
    historico TEXT,
    categoria_id TEXT,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.contas_receber_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conta_receber_id UUID NOT NULL REFERENCES public.contas_receber(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabela de Contas a Pagar
CREATE TABLE public.contas_pagar (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor NUMERIC NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status status_conta_pagar NOT NULL,
    fornecedor_id UUID REFERENCES public.clientes(id),
    forma_pagamento TEXT,
    numero_documento TEXT,
    historico TEXT,
    categoria_id TEXT,
    ocorrencia ocorrencia_conta NOT NULL,
    competencia TEXT,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.contas_pagar_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conta_pagar_id UUID NOT NULL REFERENCES public.contas_pagar(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabela de Fluxo de Caixa
CREATE TABLE public.fluxo_caixa (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    data DATE NOT NULL,
    descricao TEXT NOT NULL,
    valor NUMERIC NOT NULL,
    tipo tipo_movimento_caixa NOT NULL,
    conta_receber_id UUID REFERENCES public.contas_receber(id),
    conta_pagar_id UUID REFERENCES public.contas_pagar(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabelas de Ordens de Serviço
CREATE TABLE public.ordens_servico (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    numero TEXT NOT NULL UNIQUE,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    descricao_servico TEXT,
    consideracoes_finais TEXT,
    data_inicio DATE NOT NULL,
    data_previsao DATE,
    hora TEXT,
    data_conclusao DATE,
    total_servicos NUMERIC NOT NULL,
    desconto TEXT,
    observacoes_servico TEXT,
    observacoes_internas TEXT,
    vendedor_id UUID REFERENCES public.vendedores(id),
    comissao_percentual NUMERIC,
    valor_comissao NUMERIC,
    tecnico_id UUID REFERENCES public.vendedores(id),
    orcar BOOLEAN DEFAULT FALSE,
    forma_recebimento TEXT,
    meio_pagamento TEXT,
    conta_bancaria TEXT,
    categoria_financeira TEXT,
    condicao_pagamento TEXT,
    marcadores TEXT[],
    status status_os NOT NULL,
    prioridade prioridade_os NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.ordem_servico_itens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ordem_servico_id UUID NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    codigo TEXT,
    quantidade NUMERIC NOT NULL,
    preco NUMERIC NOT NULL,
    desconto NUMERIC NOT NULL,
    valor_total NUMERIC NOT NULL,
    orcar BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.ordem_servico_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ordem_servico_id UUID NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabelas de Ordens de Compra
CREATE TABLE public.ordens_compra (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    numero TEXT NOT NULL UNIQUE,
    fornecedor_id UUID NOT NULL REFERENCES public.clientes(id),
    total_produtos NUMERIC NOT NULL,
    desconto TEXT,
    frete NUMERIC,
    total_ipi NUMERIC,
    total_icms_st NUMERIC,
    total_geral NUMERIC NOT NULL,
    numero_no_fornecedor TEXT,
    data_compra DATE NOT NULL,
    data_prevista DATE,
    condicao_pagamento TEXT,
    categoria_id TEXT,
    transportador_nome TEXT,
    frete_por_conta frete_por_conta NOT NULL,
    observacoes TEXT,
    marcadores TEXT[],
    observacoes_internas TEXT,
    status status_ordem_compra NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.ordem_compra_itens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ordem_compra_id UUID NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    descricao TEXT NOT NULL,
    codigo TEXT,
    unidade TEXT,
    quantidade NUMERIC NOT NULL,
    preco_unitario NUMERIC NOT NULL,
    ipi NUMERIC,
    preco_total NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE public.ordem_compra_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ordem_compra_id UUID NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Tabelas de Expedição
CREATE TABLE public.expedicoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lote TEXT NOT NULL UNIQUE,
    forma_envio TEXT NOT NULL,
    status status_expedicao NOT NULL,
    data_criacao TIMESTAMPTZ DEFAULT NOW(),
    data_envio TIMESTAMPTZ
);
CREATE TABLE public.expedicao_pedidos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    expedicao_id UUID NOT NULL REFERENCES public.expedicoes(id) ON DELETE CASCADE,
    pedido_venda_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    UNIQUE(expedicao_id, pedido_venda_id)
);
-- PASSO 5: CRIAÇÃO DOS TRIGGERS
CREATE TRIGGER handle_clientes_updated_at BEFORE UPDATE ON public.clientes FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_pessoas_contato_updated_at BEFORE UPDATE ON public.pessoas_contato FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_cliente_anexos_updated_at BEFORE UPDATE ON public.cliente_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_vendedores_updated_at BEFORE UPDATE ON public.vendedores FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_produtos_updated_at BEFORE UPDATE ON public.produtos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_produto_imagens_updated_at BEFORE UPDATE ON public.produto_imagens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_produto_anuncios_updated_at BEFORE UPDATE ON public.produto_anuncios FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_produtos_fornecedores_updated_at BEFORE UPDATE ON public.produtos_fornecedores FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_servicos_updated_at BEFORE UPDATE ON public.servicos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_embalagens_updated_at BEFORE UPDATE ON public.embalagens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_pedidos_venda_updated_at BEFORE UPDATE ON public.pedidos_venda FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_pedido_venda_itens_updated_at BEFORE UPDATE ON public.pedido_venda_itens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_pedido_venda_anexos_updated_at BEFORE UPDATE ON public.pedido_venda_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_faturas_venda_updated_at BEFORE UPDATE ON public.faturas_venda FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_contas_receber_updated_at BEFORE UPDATE ON public.contas_receber FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_contas_receber_anexos_updated_at BEFORE UPDATE ON public.contas_receber_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_contas_pagar_updated_at BEFORE UPDATE ON public.contas_pagar FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_contas_pagar_anexos_updated_at BEFORE UPDATE ON public.contas_pagar_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_fluxo_caixa_updated_at BEFORE UPDATE ON public.fluxo_caixa FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordens_servico_updated_at BEFORE UPDATE ON public.ordens_servico FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordem_servico_itens_updated_at BEFORE UPDATE ON public.ordem_servico_itens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordem_servico_anexos_updated_at BEFORE UPDATE ON public.ordem_servico_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordens_compra_updated_at BEFORE UPDATE ON public.ordens_compra FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordem_compra_itens_updated_at BEFORE UPDATE ON public.ordem_compra_itens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_ordem_compra_anexos_updated_at BEFORE UPDATE ON public.ordem_compra_anexos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
-- PASSO 6: CRIAÇÃO DAS VIEWS
CREATE OR REPLACE VIEW public.ordens_servico_view AS
SELECT
  os.id, os.numero, os.descricao_servico, os.consideracoes_finais, os.data_inicio, os.data_previsao, os.hora, os.data_conclusao,
  os.total_servicos, os.desconto, os.observacoes_servico, os.observacoes_internas, os.orcar, os.forma_recebimento, os.meio_pagamento,
  os.conta_bancaria, os.categoria_financeira, os.condicao_pagamento, os.marcadores, os.status, os.prioridade, os.created_at, os.updated_at,
  c.id AS cliente_id, c.nome AS cliente_nome, c.email AS cliente_email,
  v.id AS vendedor_id, v.nome AS vendedor_nome,
  t.id AS tecnico_id, t.nome AS tecnico_nome,
  os.comissao_percentual, os.valor_comissao
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
LEFT JOIN vendedores v ON os.vendedor_id = v.id
LEFT JOIN vendedores t ON os.tecnico_id = t.id;
CREATE OR REPLACE VIEW public.dre_mensal AS
WITH meses AS (
  SELECT generate_series(
    date_trunc('year', now() - interval '11 months'),
    date_trunc('month', now()),
    '1 month'
  )::date AS mes
),
entradas AS (
  SELECT
    date_trunc('month', data_pagamento)::date AS mes,
    sum(valor) as total
  FROM contas_receber
  WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
  GROUP BY 1
),
saidas AS (
  SELECT
    date_trunc('month', data_pagamento)::date AS mes,
    sum(valor) as total
  FROM contas_pagar
  WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
  GROUP BY 1
)
SELECT
  EXTRACT(YEAR FROM m.mes)::integer AS ano,
  EXTRACT(MONTH FROM m.mes)::integer AS mes,
  to_char(m.mes, 'TMMonth') AS mes_nome,
  COALESCE(e.total, 0) AS receita,
  COALESCE(s.total, 0) AS despesa,
  (COALESCE(e.total, 0) - COALESCE(s.total, 0)) AS resultado
FROM meses m
LEFT JOIN entradas e ON m.mes = e.mes
LEFT JOIN saidas s ON m.mes = s.mes
ORDER BY 1, 2;
-- PASSO 7: HABILITAÇÃO DO RLS E CRIAÇÃO DAS POLÍTICAS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.pessoas_contato FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.cliente_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.vendedores FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.produto_imagens FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.produto_anuncios FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.produtos_fornecedores FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.embalagens FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.pedidos_venda FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.pedido_venda_itens FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.pedido_venda_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.faturas_venda FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.contas_receber_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.contas_pagar_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.fluxo_caixa FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordens_servico FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordem_servico_itens FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordem_servico_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordens_compra FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordem_compra_itens FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.ordem_compra_anexos FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.expedicoes FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.expedicao_pedidos FOR SELECT USING (true);
-- Permissões de escrita para usuários autenticados
CREATE POLICY "Allow insert for authenticated users" ON public.clientes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.clientes FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.clientes FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.pessoas_contato FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.pessoas_contato FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.pessoas_contato FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.cliente_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.cliente_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.cliente_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.vendedores FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.vendedores FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.vendedores FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.produtos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.produtos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.produtos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.produto_imagens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.produto_imagens FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.produto_imagens FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.produto_anuncios FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.produto_anuncios FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.produto_anuncios FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.produtos_fornecedores FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.produtos_fornecedores FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.produtos_fornecedores FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.servicos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.servicos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.servicos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.embalagens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.embalagens FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.embalagens FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.pedidos_venda FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.pedidos_venda FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.pedidos_venda FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.pedido_venda_itens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.pedido_venda_itens FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.pedido_venda_itens FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.pedido_venda_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.pedido_venda_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.pedido_venda_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.faturas_venda FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.faturas_venda FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.faturas_venda FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.contas_receber FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.contas_receber FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.contas_receber FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.contas_receber_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.contas_receber_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.contas_receber_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.contas_pagar FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.contas_pagar FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.contas_pagar FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.contas_pagar_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.contas_pagar_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.contas_pagar_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.fluxo_caixa FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.fluxo_caixa FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.fluxo_caixa FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordens_servico FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordens_servico FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordens_servico FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordem_servico_itens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordem_servico_itens FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordem_servico_itens FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordem_servico_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordem_servico_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordem_servico_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordens_compra FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordens_compra FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordens_compra FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordem_compra_itens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordem_compra_itens FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordem_compra_itens FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.ordem_compra_anexos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.ordem_compra_anexos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.ordem_compra_anexos FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.expedicoes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.expedicoes FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.expedicoes FOR DELETE TO authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.expedicao_pedidos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow update for authenticated users" ON public.expedicao_pedidos FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow delete for authenticated users" ON public.expedicao_pedidos FOR DELETE TO authenticated USING (true);
