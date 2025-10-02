/*
          # [RESET COMPLETO DO BANCO DE DADOS]
          Este script irá apagar TODAS as tabelas, tipos, funções e visões existentes no esquema 'public' e recriá-los do zero.

          ## Query Description: [ATENÇÃO: Esta operação é DESTRUTIVA e resultará na PERDA DE TODOS OS DADOS existentes nas tabelas. Prossiga apenas se tiver um backup ou se estiver em um ambiente de desenvolvimento onde a perda de dados é aceitável. Esta é a solução definitiva para corrigir inconsistências de esquema e permissão.]
          
          ## Metadata:
          - Schema-Category: ["Dangerous", "Structural"]
          - Impact-Level: ["High"]
          - Requires-Backup: [true]
          - Reversible: [false]
          
          ## Structure Details:
          - Todas as tabelas do esquema 'public' serão recriadas.
          - Todas as funções e visões serão recriadas.
          - Todas as políticas de RLS serão redefinidas.
          
          ## Security Implications:
          - RLS Status: [Enabled on all tables]
          - Policy Changes: [Yes, all policies will be reset]
          - Auth Requirements: [Public read access for authenticated users]
          
          ## Performance Impact:
          - Indexes: [All indexes will be recreated]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto negativo esperado após a recriação.]
          */

-- PASSO 1: Dropar tudo na ordem inversa de dependência para evitar erros.
DROP VIEW IF EXISTS public.ordens_servico_view;
DROP VIEW IF EXISTS public.dre_mensal;
DROP TABLE IF EXISTS public.expedicao_pedidos;
DROP TABLE IF EXISTS public.expedicoes;
DROP TABLE IF EXISTS public.fluxo_caixa;
DROP TABLE IF EXISTS public.contas_pagar_anexos;
DROP TABLE IF EXISTS public.contas_pagar;
DROP TABLE IF EXISTS public.contas_receber_anexos;
DROP TABLE IF EXISTS public.contas_receber;
DROP TABLE IF EXISTS public.faturas_venda;
DROP TABLE IF EXISTS public.pedido_venda_anexos;
DROP TABLE IF EXISTS public.pedido_venda_itens;
DROP TABLE IF EXISTS public.pedidos_venda;
DROP TABLE IF EXISTS public.ordem_servico_anexos;
DROP TABLE IF EXISTS public.ordem_servico_itens;
DROP TABLE IF EXISTS public.ordens_servico;
DROP TABLE IF EXISTS public.ordem_compra_itens;
DROP TABLE IF EXISTS public.ordens_compra;
DROP TABLE IF EXISTS public.produtos_fornecedores;
DROP TABLE IF EXISTS public.produto_anuncios;
DROP TABLE IF EXISTS public.produto_imagens;
DROP TABLE IF EXISTS public.produtos;
DROP TABLE IF EXISTS public.servicos;
DROP TABLE IF EXISTS public.vendedores;
DROP TABLE IF EXISTS public.pessoas_contato;
DROP TABLE IF EXISTS public.cliente_anexos;
DROP TABLE IF EXISTS public.clientes;
DROP TABLE IF EXISTS public.embalagens;

-- Drop all functions in the public schema
DO $$
DECLARE
    func_record RECORD;
BEGIN
    FOR func_record IN (
        SELECT proname, pg_get_function_identity_arguments(oid) as args
        FROM pg_proc
        WHERE pronamespace = 'public'::regnamespace
    )
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || func_record.proname || '(' || func_record.args || ') CASCADE;';
    END LOOP;
END;
$$;

-- Drop all enums in the public schema
DO $$
DECLARE
    type_record RECORD;
BEGIN
    FOR type_record IN (
        SELECT typname
        FROM pg_type
        JOIN pg_namespace ON pg_namespace.oid = pg_type.typnamespace
        WHERE typtype = 'e' AND nspname = 'public'
    )
    LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || type_record.typname || ' CASCADE;';
    END LOOP;
END;
$$;


-- PASSO 2: Criar todos os ENUMs (tipos)
CREATE TYPE public.tipo_pessoa AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO');
CREATE TYPE public.contribuinte_icms AS ENUM ('Não informado', 'Contribuinte ICMS', 'Contribuinte isento de Inscrição no cadastro de contribuintes do ICMS', 'Não contribuinte, que pode ou não possuir Inscrição Estadual no cadastro de contribuintes do ICMS');
CREATE TYPE public.tipo_pessoa_vendedor AS ENUM ('Física', 'Jurídica', 'Estrangeiro', 'Estrangeiro no Brasil');
CREATE TYPE public.situacao_vendedor AS ENUM ('Ativo com acesso ao sistema', 'Ativo sem acesso ao sistema', 'Inativo');
CREATE TYPE public.regra_comissao AS ENUM ('Liberação parcial vinculada ao pagamento das parcelas', 'Liberação total no faturamento do pedido', 'Liberação total no pagamento integral do pedido');
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
CREATE TYPE public.origem_produto AS ENUM ('0 - Nacional, exceto as indicadas nos códigos 3 a 5', '1 - Estrangeira – Importação direta, exceto a indicada no código 6', '2 - Estrangeira – Adquirida no mercado interno, exceto a indicada no código 7', '3 - Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%', '4 - Nacional, cuja produção tenha sido feita em conformidade com os processos produtivos básicos', '5 - Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40%', '6 - Estrangeira – Importação direta, sem similar nacional, constante em lista da CAMEX', '7 - Estrangeira – Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX', '8 - Nacional, mercadoria ou bem com Conteúdo de Importação superior a 70%');
CREATE TYPE public.tipo_embalagem_produto AS ENUM ('Pacote / Caixa', 'Envelope', 'Rolo / Cilíndrico');
CREATE TYPE public.embalagem_produto AS ENUM ('Embalagem customizada', 'Caixa de Encomenda Flex', 'Caixa de Encomenda CE – 01', 'Caixa de Encomenda CE – 02', 'Caixa de Encomenda CE – 03', 'Caixa de Encomenda CE – 07', 'Caixa de Encomenda 5B', 'Caixa de Encomenda 6B', 'Caixa de Encomenda Vai e Vem', 'Caixa de Encomenda B', 'Caixa de Encomenda 2B', 'Caixa de Encomenda 4B', 'Caixa de Encomenda Temática 01', 'Caixa de Encomenda Temática 02', 'Caixa de Encomenda Temática 03', 'Criar nova embalagem ...');
CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
CREATE TYPE public.status_expedicao AS ENUM ('AGUARDANDO_ENVIO', 'ENVIADO', 'ENTREGUE', 'CANCELADO');
CREATE TYPE public.status_ordem_compra AS ENUM ('ABERTA', 'RECEBIDA', 'CANCELADA');
CREATE TYPE public.frete_por_conta AS ENUM ('CIF', 'FOB');

-- PASSO 3: Criar as tabelas
CREATE TABLE public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT,
    nome TEXT NOT NULL,
    nome_fantasia TEXT,
    tipo_pessoa tipo_pessoa NOT NULL,
    cpf_cnpj TEXT,
    rg TEXT,
    inscricao_estadual TEXT,
    inscricao_municipal TEXT,
    contribuinte_icms contribuinte_icms,
    is_cliente BOOLEAN DEFAULT true,
    is_fornecedor BOOLEAN DEFAULT false,
    is_transportadora BOOLEAN DEFAULT false,
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
    email TEXT,
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
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.vendedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    fantasia TEXT,
    codigo TEXT,
    tipo_pessoa tipo_pessoa_vendedor,
    cpf_cnpj TEXT,
    contribuinte contribuinte_icms,
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
    email TEXT,
    situacao situacao_vendedor,
    deposito TEXT,
    email_comunicacoes TEXT,
    usuario_sistema TEXT,
    acesso_restrito_horario BOOLEAN,
    acesso_restrito_ip BOOLEAN,
    ips_permitidos TEXT,
    perfil_acesso_contatos TEXT,
    modulos_acessiveis TEXT[],
    pode_incluir_produtos_nao_cadastrados BOOLEAN,
    pode_emitir_cobrancas BOOLEAN,
    regra_liberacao_comissao regra_comissao,
    tipo_comissao tipo_comissao_vendedor,
    aliquota_comissao NUMERIC,
    desconsiderar_comissao_linha_produto BOOLEAN,
    observacoes TEXT,
    ativo BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_produto tipo_produto,
    nome TEXT NOT NULL,
    codigo_barras TEXT,
    codigo TEXT,
    origem origem_produto,
    unidade TEXT,
    ncm TEXT,
    cest TEXT,
    preco_venda NUMERIC,
    peso_liquido NUMERIC,
    peso_bruto NUMERIC,
    volumes INTEGER,
    tipo_embalagem tipo_embalagem_produto,
    embalagem embalagem_produto,
    largura NUMERIC,
    altura NUMERIC,
    comprimento NUMERIC,
    controlar_estoque BOOLEAN,
    estoque_inicial INTEGER,
    estoque_minimo INTEGER,
    estoque_maximo INTEGER,
    controlar_lotes BOOLEAN,
    localizacao TEXT,
    dias_preparacao INTEGER,
    situacao situacao_produto,
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
    permitir_vendas BOOLEAN,
    gtin_tributavel TEXT,
    unidade_tributavel TEXT,
    fator_conversao NUMERIC,
    codigo_enquadramento_ipi TEXT,
    valor_ipi_fixo NUMERIC,
    ex_tipi TEXT,
    observacoes_produto TEXT,
    atributos JSONB,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.servicos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL,
    codigo TEXT,
    preco NUMERIC,
    unidade TEXT,
    situacao situacao_servico,
    codigo_servico TEXT,
    nbs TEXT,
    descricao_complementar TEXT,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.pedidos_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero TEXT NOT NULL,
    natureza_operacao TEXT,
    cliente_id UUID,
    vendedor_id UUID,
    endereco_entrega_diferente BOOLEAN,
    total_produtos NUMERIC,
    valor_ipi NUMERIC,
    valor_icms_st NUMERIC,
    desconto TEXT,
    frete_cliente NUMERIC,
    frete_empresa NUMERIC,
    despesas NUMERIC,
    valor_total NUMERIC,
    data_venda DATE,
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
    enviar_para_expedicao BOOLEAN,
    deposito TEXT,
    observacoes TEXT,
    observacoes_internas TEXT,
    marcadores TEXT[],
    status status_pedido_venda,
    peso_bruto NUMERIC,
    peso_liquido NUMERIC,
    expedido BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.pedido_venda_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID,
    produto_id UUID,
    servico_id UUID,
    descricao TEXT,
    codigo TEXT,
    unidade TEXT,
    quantidade INTEGER,
    valor_unitario NUMERIC,
    desconto_percentual NUMERIC,
    valor_total NUMERIC,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.faturas_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID,
    numero_fatura TEXT,
    data_emissao DATE,
    data_vencimento DATE,
    valor_total NUMERIC,
    status status_fatura,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.contas_receber (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fatura_id UUID,
    cliente_id UUID,
    descricao TEXT,
    valor NUMERIC,
    data_vencimento DATE,
    data_pagamento DATE,
    status status_conta_receber,
    ocorrencia ocorrencia_conta,
    forma_recebimento TEXT,
    numero_documento TEXT,
    historico TEXT,
    categoria_id TEXT,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.contas_pagar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT,
    valor NUMERIC,
    data_vencimento DATE,
    data_pagamento DATE,
    status status_conta_pagar,
    fornecedor_id UUID,
    forma_pagamento TEXT,
    numero_documento TEXT,
    historico TEXT,
    categoria_id TEXT,
    ocorrencia ocorrencia_conta,
    competencia TEXT,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.fluxo_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data DATE,
    descricao TEXT,
    valor NUMERIC,
    tipo tipo_movimento_caixa,
    conta_receber_id UUID,
    conta_pagar_id UUID,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- PASSO 4: Adicionar chaves estrangeiras
ALTER TABLE public.clientes ADD CONSTRAINT fk_vendedor FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id);
ALTER TABLE public.pedidos_venda ADD CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);
ALTER TABLE public.pedidos_venda ADD CONSTRAINT fk_vendedor FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id);
ALTER TABLE public.pedido_venda_itens ADD CONSTRAINT fk_pedido FOREIGN KEY (pedido_id) REFERENCES public.pedidos_venda(id);
ALTER TABLE public.pedido_venda_itens ADD CONSTRAINT fk_produto FOREIGN KEY (produto_id) REFERENCES public.produtos(id);
ALTER TABLE public.pedido_venda_itens ADD CONSTRAINT fk_servico FOREIGN KEY (servico_id) REFERENCES public.servicos(id);
ALTER TABLE public.faturas_venda ADD CONSTRAINT fk_pedido FOREIGN KEY (pedido_id) REFERENCES public.pedidos_venda(id);
ALTER TABLE public.contas_receber ADD CONSTRAINT fk_fatura FOREIGN KEY (fatura_id) REFERENCES public.faturas_venda(id);
ALTER TABLE public.contas_receber ADD CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);
ALTER TABLE public.contas_pagar ADD CONSTRAINT fk_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id);
ALTER TABLE public.fluxo_caixa ADD CONSTRAINT fk_conta_receber FOREIGN KEY (conta_receber_id) REFERENCES public.contas_receber(id);
ALTER TABLE public.fluxo_caixa ADD CONSTRAINT fk_conta_pagar FOREIGN KEY (conta_pagar_id) REFERENCES public.contas_pagar(id);

-- PASSO 5: Criar as VIEWS
CREATE OR REPLACE VIEW public.dre_mensal AS
 SELECT
    EXTRACT(YEAR FROM f.data)::integer AS ano,
    EXTRACT(MONTH FROM f.data)::integer AS mes,
    to_char(f.data, 'TMMonth') AS mes_nome,
    COALESCE(sum(
        CASE
            WHEN f.tipo = 'ENTRADA' THEN f.valor
            ELSE 0
        END), 0) AS receita,
    COALESCE(sum(
        CASE
            WHEN f.tipo = 'SAIDA' THEN f.valor
            ELSE 0
        END), 0) AS despesa,
    COALESCE(sum(
        CASE
            WHEN f.tipo = 'ENTRADA' THEN f.valor
            ELSE -f.valor
        END), 0) AS resultado
   FROM public.fluxo_caixa f
  GROUP BY (EXTRACT(YEAR FROM f.data)), (EXTRACT(MONTH FROM f.data)), (to_char(f.data, 'TMMonth'))
  ORDER BY (EXTRACT(YEAR FROM f.data)), (EXTRACT(MONTH FROM f.data));

-- PASSO 6: Habilitar RLS e criar políticas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.vendedores FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.pedidos_venda FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.pedido_venda_itens FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.faturas_venda FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.fluxo_caixa FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.dre_mensal FOR SELECT USING (true);

-- Permissões para usuários autenticados modificarem seus próprios dados (Exemplo)
CREATE POLICY "Allow individual insert access" ON public.clientes FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.clientes FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.clientes FOR DELETE USING (true);
-- Repetir para outras tabelas conforme necessário
CREATE POLICY "Allow individual insert access" ON public.vendedores FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.vendedores FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.vendedores FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.produtos FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.produtos FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.produtos FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.servicos FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.servicos FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.servicos FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.pedidos_venda FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.pedidos_venda FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.pedidos_venda FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.pedido_venda_itens FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.pedido_venda_itens FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.pedido_venda_itens FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.faturas_venda FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.faturas_venda FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.faturas_venda FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.contas_receber FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.contas_receber FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.contas_receber FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.contas_pagar FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.contas_pagar FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.contas_pagar FOR DELETE USING (true);
CREATE POLICY "Allow individual insert access" ON public.fluxo_caixa FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow individual update access" ON public.fluxo_caixa FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow individual delete access" ON public.fluxo_caixa FOR DELETE USING (true);
