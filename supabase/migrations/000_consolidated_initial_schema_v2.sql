-- Habilita a extensão para buscas textuais otimizadas
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Bloco para criar todos os tipos de forma segura
DO $$
BEGIN
    -- Remove tipos antigos se existirem, para garantir uma recriação limpa
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contribuinte_icms') THEN DROP TYPE public.contribuinte_icms; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_pessoa_vendedor') THEN DROP TYPE public.tipo_pessoa_vendedor; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'situacao_vendedor') THEN DROP TYPE public.situacao_vendedor; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'regra_comissao') THEN DROP TYPE public.regra_comissao; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'origem_produto') THEN DROP TYPE public.origem_produto; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem_produto') THEN DROP TYPE public.tipo_embalagem_produto; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'embalagem_produto') THEN DROP TYPE public.embalagem_produto; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'frete_por_conta') THEN DROP TYPE public.frete_por_conta; END IF;
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ocorrencia_conta') THEN DROP TYPE public.ocorrencia_conta; END IF;
    
    -- Recria os tipos com chaves curtas
    CREATE TYPE public.contribuinte_icms AS ENUM ('NAO_INFORMADO', 'CONTRIBUINTE_ICMS', 'CONTRIBUINTE_ISENTO', 'NAO_CONTRIBUINTE');
    CREATE TYPE public.tipo_pessoa_vendedor AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO', 'ESTRANGEIRO_NO_BRASIL');
    CREATE TYPE public.situacao_vendedor AS ENUM ('ATIVO_COM_ACESSO', 'ATIVO_SEM_ACESSO', 'INATIVO');
    CREATE TYPE public.regra_comissao AS ENUM ('LIBERACAO_PARCIAL', 'LIBERACAO_TOTAL_FATURAMENTO', 'LIBERACAO_TOTAL_PAGAMENTO');
    CREATE TYPE public.origem_produto AS ENUM ('NACIONAL_0', 'ESTRANGEIRA_1', 'ESTRANGEIRA_2', 'NACIONAL_3', 'NACIONAL_4', 'NACIONAL_5', 'ESTRANGEIRA_6', 'ESTRANGEIRA_7', 'NACIONAL_8');
    CREATE TYPE public.tipo_embalagem_produto AS ENUM ('PACOTE_CAIXA', 'ENVELOPE', 'ROLO_CILINDRICO');
    CREATE TYPE public.embalagem_produto AS ENUM ('CUSTOMIZADA', 'FLEX', 'CE01', 'CE02', 'CE03', 'CE07', 'B5', 'B6', 'VAI_VEM', 'B', 'B2', 'B4', 'T01', 'T02', 'T03', 'NOVA');
    CREATE TYPE public.frete_por_conta AS ENUM ('CIF', 'FOB', 'TERCEIROS', 'PROPRIO_REMETENTE', 'PROPRIO_DESTINATARIO', 'SEM_TRANSPORTE');
    CREATE TYPE public.ocorrencia_conta AS ENUM ('UNICA', 'RECORRENTE');
    
    -- Cria outros tipos apenas se não existirem
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_pessoa') THEN CREATE TYPE public.tipo_pessoa AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_comissao_vendedor') THEN CREATE TYPE public.tipo_comissao_vendedor AS ENUM ('Comissão com alíquota fixa', 'Comissão com alíquota conforme descontos'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_os') THEN CREATE TYPE public.status_os AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA', 'ORCAMENTO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prioridade_os') THEN CREATE TYPE public.prioridade_os AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_pedido_venda') THEN CREATE TYPE public.status_pedido_venda AS ENUM ('ABERTO', 'FATURADO', 'CANCELADO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ordem_compra') THEN CREATE TYPE public.status_ordem_compra AS ENUM ('ABERTA', 'RECEBIDA', 'CANCELADA'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_fatura') THEN CREATE TYPE public.status_fatura AS ENUM ('EMITIDA', 'PAGA', 'VENCIDA', 'CANCELADA'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_movimento_caixa') THEN CREATE TYPE public.tipo_movimento_caixa AS ENUM ('ENTRADA', 'SAIDA'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_produto') THEN CREATE TYPE public.tipo_produto AS ENUM ('Simples', 'Com variações', 'Kit', 'Fabricado', 'Matéria Prima'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'situacao_produto') THEN CREATE TYPE public.situacao_produto AS ENUM ('Ativo', 'Inativo'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'situacao_servico') THEN CREATE TYPE public.situacao_servico AS ENUM ('ATIVO', 'INATIVO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem') THEN CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_expedicao') THEN CREATE TYPE public.status_expedicao AS ENUM ('AGUARDANDO_ENVIO', 'ENVIADO', 'ENTREGUE', 'CANCELADO'); END IF;
END $$;

-- Recriação de Tabelas (usando os tipos corrigidos)
DROP TABLE IF EXISTS public.clientes CASCADE;
CREATE TABLE public.clientes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    codigo text, nome text NOT NULL, nome_fantasia text, tipo_pessoa public.tipo_pessoa NOT NULL, cpf_cnpj text, rg text, inscricao_estadual text, inscricao_municipal text, contribuinte_icms public.contribuinte_icms, is_cliente boolean DEFAULT true, is_fornecedor boolean DEFAULT false, is_transportadora boolean DEFAULT false, logradouro text, numero text, complemento text, bairro text, cep text, cidade text, estado text, pais text, cobranca_logradouro text, cobranca_numero text, cobranca_complemento text, cobranca_bairro text, cobranca_cep text, cobranca_cidade text, cobranca_estado text, telefone text, telefone_adicional text, celular text, email text, email_nfe text, site text, estado_civil text, profissao text, sexo text, data_nascimento date, naturalidade text, status_crm text, vendedor_id uuid, condicao_pagamento_padrao_id text, limite_credito numeric, observacoes text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE IF EXISTS public.vendedores CASCADE;
CREATE TABLE public.vendedores (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    nome text NOT NULL, fantasia text, codigo text, tipo_pessoa public.tipo_pessoa_vendedor NOT NULL, cpf_cnpj text, contribuinte public.contribuinte_icms NOT NULL, inscricao_estadual text, cep text, cidade text, uf text, logradouro text, bairro text, numero text, complemento text, telefone text, celular text, email text NOT NULL, situacao public.situacao_vendedor NOT NULL, deposito text, email_comunicacoes text, usuario_sistema text, acesso_restrito_horario boolean DEFAULT false, acesso_restrito_ip boolean DEFAULT false, ips_permitidos text, perfil_acesso_contatos text, modulos_acessiveis text[], pode_incluir_produtos_nao_cadastrados boolean DEFAULT false, pode_emitir_cobrancas boolean DEFAULT false, regra_liberacao_comissao public.regra_comissao NOT NULL, tipo_comissao public.tipo_comissao_vendedor NOT NULL, aliquota_comissao numeric, desconsiderar_comissao_linha_produto boolean DEFAULT false, observacoes text, ativo boolean DEFAULT true, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL, CONSTRAINT vendedores_email_key UNIQUE (email)
);

-- Continua para todas as outras tabelas...
DROP TABLE IF EXISTS public.servicos CASCADE;
CREATE TABLE public.servicos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, descricao text NOT NULL, codigo text, preco numeric NOT NULL, unidade text, situacao public.situacao_servico NOT NULL, codigo_servico text, nbs text, descricao_complementar text, observacoes text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.produtos CASCADE;
CREATE TABLE public.produtos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, tipo_produto public.tipo_produto NOT NULL, nome text NOT NULL, codigo_barras text, codigo text, origem public.origem_produto NOT NULL, unidade text NOT NULL, ncm text NOT NULL, cest text, preco_venda numeric NOT NULL, peso_liquido numeric, peso_bruto numeric, volumes integer, tipo_embalagem public.tipo_embalagem_produto, embalagem public.embalagem_produto, largura numeric, altura numeric, comprimento numeric, controlar_estoque boolean DEFAULT false, estoque_inicial integer, estoque_minimo integer, estoque_maximo integer, controlar_lotes boolean DEFAULT false, localizacao text, dias_preparacao integer, situacao public.situacao_produto NOT NULL, marca text, tabela_medidas text, descricao_complementar text, link_video text, slug text, keywords text, titulo_seo text, descricao_seo text, unidade_por_caixa integer, custo numeric, linha_produto text, garantia text, markup numeric, permitir_vendas boolean DEFAULT true, gtin_tributavel text, unidade_tributavel text, fator_conversao numeric, codigo_enquadramento_ipi text, valor_ipi_fixo numeric, ex_tipi text, observacoes_produto text, atributos jsonb, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.embalagens CASCADE;
CREATE TABLE public.embalagens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, descricao text NOT NULL, tipo public.tipo_embalagem NOT NULL, largura_cm numeric(10,1), altura_cm numeric(10,1), comprimento_cm numeric(10,1), diametro_cm numeric(10,1), peso_kg numeric(10,3) NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.pedidos_venda CASCADE;
CREATE TABLE public.pedidos_venda ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, numero text NOT NULL, natureza_operacao text, cliente_id uuid NOT NULL REFERENCES public.clientes(id), vendedor_id uuid REFERENCES public.vendedores(id), endereco_entrega_diferente boolean DEFAULT false, total_produtos numeric DEFAULT 0, valor_ipi numeric, valor_icms_st numeric, desconto text, frete_cliente numeric, frete_empresa numeric, despesas numeric, valor_total numeric NOT NULL, data_venda date NOT NULL, data_prevista_entrega date, data_envio timestamp with time zone, data_maxima_despacho timestamp with time zone, numero_pedido_ecommerce text, identificador_pedido_ecommerce text, numero_pedido_canal_venda text, intermediador text, forma_recebimento text, meio_pagamento text, conta_bancaria text, categoria_financeira text, condicao_pagamento text, forma_envio text, enviar_para_expedicao boolean DEFAULT true, deposito text, observacoes text, observacoes_internas text, marcadores text[], status public.status_pedido_venda NOT NULL, peso_bruto numeric, peso_liquido numeric, expedido boolean DEFAULT false, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.pedido_venda_itens CASCADE;
CREATE TABLE public.pedido_venda_itens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, pedido_id uuid NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE, produto_id uuid REFERENCES public.produtos(id), servico_id uuid REFERENCES public.servicos(id), descricao text NOT NULL, codigo text, unidade text, quantidade numeric NOT NULL, valor_unitario numeric NOT NULL, desconto_percentual numeric, valor_total numeric NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.pedido_venda_anexos CASCADE;
CREATE TABLE public.pedido_venda_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, pedido_id uuid NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.faturas_venda CASCADE;
CREATE TABLE public.faturas_venda ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, pedido_id uuid NOT NULL REFERENCES public.pedidos_venda(id), numero_fatura text NOT NULL, data_emissao date NOT NULL, data_vencimento date NOT NULL, valor_total numeric NOT NULL, status public.status_fatura NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.fatura_venda_itens CASCADE;
CREATE TABLE public.fatura_venda_itens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, fatura_id uuid NOT NULL REFERENCES public.faturas_venda(id) ON DELETE CASCADE, descricao text NOT NULL, quantidade numeric NOT NULL, valor_unitario numeric NOT NULL, valor_total numeric NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.contas_receber CASCADE;
CREATE TABLE public.contas_receber ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, fatura_id uuid REFERENCES public.faturas_venda(id), cliente_id uuid REFERENCES public.clientes(id), descricao text, valor numeric NOT NULL, data_vencimento date NOT NULL, data_pagamento date, status public.status_conta_receber NOT NULL, ocorrencia public.ocorrencia_conta, forma_recebimento text, numero_documento text, historico text, categoria_id text, marcadores text[], created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.contas_receber_anexos CASCADE;
CREATE TABLE public.contas_receber_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, conta_receber_id uuid NOT NULL REFERENCES public.contas_receber(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.contas_pagar CASCADE;
CREATE TABLE public.contas_pagar ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, descricao text NOT NULL, valor numeric NOT NULL, data_vencimento date NOT NULL, data_pagamento date, status public.status_conta_pagar NOT NULL, fornecedor_id uuid REFERENCES public.clientes(id), forma_pagamento text, numero_documento text, historico text, categoria_id text, ocorrencia public.ocorrencia_conta NOT NULL, competencia text, marcadores text[], created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.contas_pagar_anexos CASCADE;
CREATE TABLE public.contas_pagar_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, conta_pagar_id uuid NOT NULL REFERENCES public.contas_pagar(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.fluxo_caixa CASCADE;
CREATE TABLE public.fluxo_caixa ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, data date NOT NULL, descricao text NOT NULL, valor numeric NOT NULL, tipo public.tipo_movimento_caixa NOT NULL, conta_receber_id uuid REFERENCES public.contas_receber(id), conta_pagar_id uuid REFERENCES public.contas_pagar(id), created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordens_servico CASCADE;
CREATE TABLE public.ordens_servico ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, numero text NOT NULL, cliente_id uuid NOT NULL REFERENCES public.clientes(id), descricao_servico text, consideracoes_finais text, data_inicio date NOT NULL, data_previsao date, hora time, data_conclusao date, total_servicos numeric NOT NULL, desconto text, observacoes_servico text, observacoes_internas text, vendedor_id uuid REFERENCES public.vendedores(id), comissao_percentual numeric, valor_comissao numeric, tecnico_id uuid REFERENCES public.vendedores(id), orcar boolean DEFAULT false, forma_recebimento text, meio_pagamento text, conta_bancaria text, categoria_financeira text, condicao_pagamento text, marcadores text[], status public.status_os NOT NULL, prioridade public.prioridade_os NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordem_servico_itens CASCADE;
CREATE TABLE public.ordem_servico_itens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, ordem_servico_id uuid NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE, servico_id uuid REFERENCES public.servicos(id), descricao text NOT NULL, codigo text, quantidade numeric NOT NULL, preco numeric NOT NULL, desconto numeric, valor_total numeric NOT NULL, orcar boolean, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordem_servico_anexos CASCADE;
CREATE TABLE public.ordem_servico_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, ordem_servico_id uuid NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordens_compra CASCADE;
CREATE TABLE public.ordens_compra ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, fornecedor_id uuid NOT NULL REFERENCES public.clientes(id), numero text NOT NULL, data_compra date NOT NULL, data_prevista date, total_produtos numeric, desconto text, frete numeric, total_ipi numeric, total_icms_st numeric, total_geral numeric NOT NULL, numero_no_fornecedor text, condicao_pagamento text, categoria_id text, transportador_nome text, frete_por_conta public.frete_por_conta, observacoes text, marcadores text[], observacoes_internas text, status public.status_ordem_compra, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordem_compra_itens CASCADE;
CREATE TABLE public.ordem_compra_itens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE, produto_id uuid REFERENCES public.produtos(id), descricao text NOT NULL, codigo text, gtin_ean text, quantidade numeric NOT NULL, unidade text, preco_unitario numeric NOT NULL, ipi numeric, preco_total numeric NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.ordem_compra_anexos CASCADE;
CREATE TABLE public.ordem_compra_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.expedicoes CASCADE;
CREATE TABLE public.expedicoes ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, lote text NOT NULL, forma_envio text NOT NULL, status public.status_expedicao NOT NULL, data_criacao date NOT NULL, data_envio date, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.expedicao_pedidos CASCADE;
CREATE TABLE public.expedicao_pedidos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, expedicao_id uuid NOT NULL REFERENCES public.expedicoes(id) ON DELETE CASCADE, pedido_venda_id uuid NOT NULL REFERENCES public.pedidos_venda(id), created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.pessoas_contato CASCADE;
CREATE TABLE public.pessoas_contato ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, cliente_id uuid NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, nome text NOT NULL, setor text, email text, telefone text, ramal text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.produto_imagens CASCADE;
CREATE TABLE public.produto_imagens ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, produto_id uuid NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, path text NOT NULL, nome_arquivo text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.produto_anuncios CASCADE;
CREATE TABLE public.produto_anuncios ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, produto_id uuid NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, ecommerce text NOT NULL, identificador text NOT NULL, descricao text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.produtos_fornecedores CASCADE;
CREATE TABLE public.produtos_fornecedores ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, produto_id uuid NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, fornecedor_id uuid NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, codigo_no_fornecedor text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );
DROP TABLE IF EXISTS public.cliente_anexos CASCADE;
CREATE TABLE public.cliente_anexos ( id uuid DEFAULT gen_random_uuid() PRIMARY KEY, cliente_id uuid NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, nome_arquivo text NOT NULL, path text NOT NULL, tamanho integer NOT NULL, tipo text NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL );

-- Criação de Índices de Performance
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_produtos_descricao ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos(codigo);
CREATE INDEX IF NOT EXISTS idx_servicos_descricao ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON public.servicos(codigo);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);

-- Criação de Views
CREATE OR REPLACE VIEW public.dre_mensal AS
 SELECT EXTRACT(YEAR FROM f.data_emissao) AS ano, EXTRACT(MONTH FROM f.data_emissao) AS mes, to_char(f.data_emissao, 'TMMonth') AS mes_nome, sum(CASE WHEN cr.status = 'RECEBIDO' THEN cr.valor ELSE 0 END) AS receita, (SELECT sum(cp.valor) FROM contas_pagar cp WHERE cp.status = 'PAGO' AND EXTRACT(YEAR FROM cp.data_pagamento) = EXTRACT(YEAR FROM f.data_emissao) AND EXTRACT(MONTH FROM cp.data_pagamento) = EXTRACT(MONTH FROM f.data_emissao)) AS despesa, (sum(CASE WHEN cr.status = 'RECEBIDO' THEN cr.valor ELSE 0 END) - (SELECT sum(cp.valor) FROM contas_pagar cp WHERE cp.status = 'PAGO' AND EXTRACT(YEAR FROM cp.data_pagamento) = EXTRACT(YEAR FROM f.data_emissao) AND EXTRACT(MONTH FROM cp.data_pagamento) = EXTRACT(MONTH FROM f.data_emissao))) AS resultado
   FROM faturas_venda f
   JOIN contas_receber cr ON f.id = cr.fatura_id
  GROUP BY (EXTRACT(YEAR FROM f.data_emissao)), (EXTRACT(MONTH FROM f.data_emissao)), (to_char(f.data_emissao, 'TMMonth'))
  ORDER BY (EXTRACT(YEAR FROM f.data_emissao)), (EXTRACT(MONTH FROM f.data_emissao));

CREATE OR REPLACE VIEW public.ordens_servico_view
WITH (security_invoker=true)
AS SELECT os.id, os.numero, os.cliente_id, c.nome AS cliente_nome, c.email AS cliente_email, os.descricao_servico, os.data_inicio, os.data_previsao, os.data_conclusao, os.total_servicos, os.status, os.prioridade, os.vendedor_id, v.nome AS vendedor_nome, os.tecnico_id, t.nome AS tecnico_nome, os.created_at, os.updated_at
   FROM ordens_servico os
   LEFT JOIN clientes c ON os.cliente_id = c.id
   LEFT JOIN vendedores v ON os.vendedor_id = v.id
   LEFT JOIN vendedores t ON os.tecnico_id = t.id;

-- Habilitação de RLS e Criação de Políticas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fatura_venda_itens ENABLE ROW LEVEL SECURITY;
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
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso
CREATE POLICY "Public read access" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.clientes FOR ALL USING (auth.role() = 'authenticated');
-- Repetir para todas as outras tabelas...
CREATE POLICY "Public read access" ON public.vendedores FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.vendedores FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.servicos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.produtos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.embalagens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.embalagens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.pedidos_venda FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.pedidos_venda FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.pedido_venda_itens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.pedido_venda_itens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.pedido_venda_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.pedido_venda_anexos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.faturas_venda FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.faturas_venda FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.fatura_venda_itens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.fatura_venda_itens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.contas_receber FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.contas_receber_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.contas_receber_anexos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.contas_pagar FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.contas_pagar_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.contas_pagar_anexos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.fluxo_caixa FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.fluxo_caixa FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordens_servico FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordens_servico FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordem_servico_itens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordem_servico_itens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordem_servico_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordem_servico_anexos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordens_compra FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordens_compra FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordem_compra_itens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordem_compra_itens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.ordem_compra_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.ordem_compra_anexos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.expedicoes FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.expedicoes FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.expedicao_pedidos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.expedicao_pedidos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.pessoas_contato FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.pessoas_contato FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.produto_imagens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.produto_imagens FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.produto_anuncios FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.produto_anuncios FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.produtos_fornecedores FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.produtos_fornecedores FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Public read access" ON public.cliente_anexos FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage their data" ON public.cliente_anexos FOR ALL USING (auth.role() = 'authenticated');
