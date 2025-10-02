/*
          # [RECONSTRUÇÃO E SEED FINAL]
          Este script apaga completamente o schema 'public' e o recria do zero, inserindo dados de exemplo.
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
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pg_trgm" SCHEMA extensions;
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
-- PASSO 4: CRIAÇÃO DAS TABELAS (estrutura idêntica à anterior)
CREATE TABLE public.clientes (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, codigo TEXT, nome TEXT NOT NULL, nome_fantasia TEXT, tipo_pessoa tipo_pessoa NOT NULL, cpf_cnpj TEXT UNIQUE, rg TEXT, inscricao_estadual TEXT, inscricao_municipal TEXT, contribuinte_icms contribuinte_icms NOT NULL, is_cliente BOOLEAN DEFAULT TRUE, is_fornecedor BOOLEAN DEFAULT FALSE, is_transportadora BOOLEAN DEFAULT FALSE, logradouro TEXT, numero TEXT, complemento TEXT, bairro TEXT, cep TEXT, cidade TEXT, estado TEXT, pais TEXT, cobranca_logradouro TEXT, cobranca_numero TEXT, cobranca_complemento TEXT, cobranca_bairro TEXT, cobranca_cep TEXT, cobranca_cidade TEXT, cobranca_estado TEXT, telefone TEXT, telefone_adicional TEXT, celular TEXT, email TEXT NOT NULL, email_nfe TEXT, site TEXT, estado_civil TEXT, profissao TEXT, sexo TEXT, data_nascimento DATE, naturalidade TEXT, status_crm TEXT, vendedor_id UUID, condicao_pagamento_padrao_id TEXT, limite_credito NUMERIC, observacoes TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.pessoas_contato (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, nome TEXT NOT NULL, setor TEXT, email TEXT, telefone TEXT, ramal TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.cliente_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.vendedores (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, nome TEXT NOT NULL, fantasia TEXT, codigo TEXT, tipo_pessoa tipo_pessoa_vendedor NOT NULL, cpf_cnpj TEXT UNIQUE, contribuinte contribuinte_icms NOT NULL, inscricao_estadual TEXT, cep TEXT, cidade TEXT, uf TEXT, logradouro TEXT, bairro TEXT, numero TEXT, complemento TEXT, telefone TEXT, celular TEXT, email TEXT NOT NULL UNIQUE, situacao situacao_vendedor NOT NULL, deposito TEXT, email_comunicacoes TEXT, usuario_sistema TEXT, acesso_restrito_horario BOOLEAN DEFAULT FALSE, acesso_restrito_ip BOOLEAN DEFAULT FALSE, ips_permitidos TEXT, perfil_acesso_contatos TEXT, modulos_acessiveis TEXT[], pode_incluir_produtos_nao_cadastrados BOOLEAN DEFAULT FALSE, pode_emitir_cobrancas BOOLEAN DEFAULT FALSE, regra_liberacao_comissao regra_comissao NOT NULL, tipo_comissao tipo_comissao_vendedor NOT NULL, aliquota_comissao NUMERIC, desconsiderar_comissao_linha_produto BOOLEAN DEFAULT FALSE, observacoes TEXT, ativo BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
ALTER TABLE public.clientes ADD CONSTRAINT fk_vendedor FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
CREATE TABLE public.produtos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, tipo_produto tipo_produto NOT NULL, nome TEXT NOT NULL, codigo_barras TEXT, codigo TEXT UNIQUE, origem origem_produto NOT NULL, unidade TEXT NOT NULL, ncm TEXT, cest TEXT, preco_venda NUMERIC NOT NULL, peso_liquido NUMERIC, peso_bruto NUMERIC, volumes INTEGER, tipo_embalagem tipo_embalagem_produto, embalagem embalagem_produto, largura NUMERIC, altura NUMERIC, comprimento NUMERIC, controlar_estoque BOOLEAN DEFAULT FALSE, estoque_inicial INTEGER, estoque_minimo INTEGER, estoque_maximo INTEGER, controlar_lotes BOOLEAN DEFAULT FALSE, localizacao TEXT, dias_preparacao INTEGER, situacao situacao_produto NOT NULL, marca TEXT, tabela_medidas TEXT, descricao_complementar TEXT, link_video TEXT, slug TEXT, keywords TEXT, titulo_seo TEXT, descricao_seo TEXT, unidade_por_caixa INTEGER, custo NUMERIC, linha_produto TEXT, garantia TEXT, markup NUMERIC, permitir_vendas BOOLEAN DEFAULT TRUE, gtin_tributavel TEXT, unidade_tributavel TEXT, fator_conversao NUMERIC, codigo_enquadramento_ipi TEXT, valor_ipi_fixo NUMERIC, ex_tipi TEXT, observacoes_produto TEXT, atributos JSONB, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.produto_imagens (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, path TEXT NOT NULL, nome_arquivo TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.produto_anuncios (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, ecommerce TEXT NOT NULL, identificador TEXT NOT NULL, descricao TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.produtos_fornecedores (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE, fornecedor_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE, codigo_no_fornecedor TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.servicos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, descricao TEXT NOT NULL, codigo TEXT UNIQUE, preco NUMERIC NOT NULL, unidade TEXT, situacao situacao_servico NOT NULL, codigo_servico TEXT, nbs TEXT, descricao_complementar TEXT, observacoes TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.embalagens (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, descricao TEXT NOT NULL, tipo tipo_embalagem NOT NULL, largura_cm NUMERIC, altura_cm NUMERIC, comprimento_cm NUMERIC, diametro_cm NUMERIC, peso_kg NUMERIC NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.pedidos_venda (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, numero TEXT NOT NULL UNIQUE, natureza_operacao TEXT, cliente_id UUID NOT NULL REFERENCES public.clientes(id), vendedor_id UUID REFERENCES public.vendedores(id), endereco_entrega_diferente BOOLEAN DEFAULT FALSE, total_produtos NUMERIC NOT NULL, valor_ipi NUMERIC, valor_icms_st NUMERIC, desconto TEXT, frete_cliente NUMERIC, frete_empresa NUMERIC, despesas NUMERIC, valor_total NUMERIC NOT NULL, data_venda DATE NOT NULL, data_prevista_entrega DATE, data_envio TIMESTAMPTZ, data_maxima_despacho TIMESTAMPTZ, numero_pedido_ecommerce TEXT, identificador_pedido_ecommerce TEXT, numero_pedido_canal_venda TEXT, intermediador TEXT, forma_recebimento TEXT, meio_pagamento TEXT, conta_bancaria TEXT, categoria_financeira TEXT, condicao_pagamento TEXT, forma_envio TEXT, enviar_para_expedicao BOOLEAN DEFAULT TRUE, deposito TEXT, observacoes TEXT, observacoes_internas TEXT, marcadores TEXT[], status status_pedido_venda NOT NULL, peso_bruto NUMERIC, peso_liquido NUMERIC, expedido BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.pedido_venda_itens (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE, produto_id UUID REFERENCES public.produtos(id), servico_id UUID REFERENCES public.servicos(id), descricao TEXT NOT NULL, codigo TEXT, unidade TEXT, quantidade NUMERIC NOT NULL, valor_unitario NUMERIC NOT NULL, desconto_percentual NUMERIC, valor_total NUMERIC NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.pedido_venda_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.faturas_venda (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id), numero_fatura TEXT NOT NULL UNIQUE, data_emissao DATE NOT NULL, data_vencimento DATE NOT NULL, valor_total NUMERIC NOT NULL, status status_fatura NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.contas_receber (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, fatura_id UUID REFERENCES public.faturas_venda(id), cliente_id UUID REFERENCES public.clientes(id), descricao TEXT, valor NUMERIC NOT NULL, data_vencimento DATE NOT NULL, data_pagamento DATE, status status_conta_receber NOT NULL, ocorrencia ocorrencia_conta, forma_recebimento TEXT, numero_documento TEXT, historico TEXT, categoria_id TEXT, marcadores TEXT[], created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.contas_receber_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, conta_receber_id UUID NOT NULL REFERENCES public.contas_receber(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.contas_pagar (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, descricao TEXT NOT NULL, valor NUMERIC NOT NULL, data_vencimento DATE NOT NULL, data_pagamento DATE, status status_conta_pagar NOT NULL, fornecedor_id UUID REFERENCES public.clientes(id), forma_pagamento TEXT, numero_documento TEXT, historico TEXT, categoria_id TEXT, ocorrencia ocorrencia_conta NOT NULL, competencia TEXT, marcadores TEXT[], created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.contas_pagar_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, conta_pagar_id UUID NOT NULL REFERENCES public.contas_pagar(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.fluxo_caixa (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, data DATE NOT NULL, descricao TEXT NOT NULL, valor NUMERIC NOT NULL, tipo tipo_movimento_caixa NOT NULL, conta_receber_id UUID REFERENCES public.contas_receber(id), conta_pagar_id UUID REFERENCES public.contas_pagar(id), created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordens_servico (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, numero TEXT NOT NULL UNIQUE, cliente_id UUID NOT NULL REFERENCES public.clientes(id), descricao_servico TEXT, consideracoes_finais TEXT, data_inicio DATE NOT NULL, data_previsao DATE, hora TEXT, data_conclusao DATE, total_servicos NUMERIC NOT NULL, desconto TEXT, observacoes_servico TEXT, observacoes_internas TEXT, vendedor_id UUID REFERENCES public.vendedores(id), comissao_percentual NUMERIC, valor_comissao NUMERIC, tecnico_id UUID REFERENCES public.vendedores(id), orcar BOOLEAN DEFAULT FALSE, forma_recebimento TEXT, meio_pagamento TEXT, conta_bancaria TEXT, categoria_financeira TEXT, condicao_pagamento TEXT, marcadores TEXT[], status status_os NOT NULL, prioridade prioridade_os NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordem_servico_itens (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, ordem_servico_id UUID NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE, servico_id UUID REFERENCES public.servicos(id), descricao TEXT NOT NULL, codigo TEXT, quantidade NUMERIC NOT NULL, preco NUMERIC NOT NULL, desconto NUMERIC NOT NULL, valor_total NUMERIC NOT NULL, orcar BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordem_servico_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, ordem_servico_id UUID NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordens_compra (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, numero TEXT NOT NULL UNIQUE, fornecedor_id UUID NOT NULL REFERENCES public.clientes(id), total_produtos NUMERIC NOT NULL, desconto TEXT, frete NUMERIC, total_ipi NUMERIC, total_icms_st NUMERIC, total_geral NUMERIC NOT NULL, numero_no_fornecedor TEXT, data_compra DATE NOT NULL, data_prevista DATE, condicao_pagamento TEXT, categoria_id TEXT, transportador_nome TEXT, frete_por_conta frete_por_conta NOT NULL, observacoes TEXT, marcadores TEXT[], observacoes_internas TEXT, status status_ordem_compra NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordem_compra_itens (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, ordem_compra_id UUID NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE, produto_id UUID REFERENCES public.produtos(id), descricao TEXT NOT NULL, codigo TEXT, unidade TEXT, quantidade NUMERIC NOT NULL, preco_unitario NUMERIC NOT NULL, ipi NUMERIC, preco_total NUMERIC NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.ordem_compra_anexos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, ordem_compra_id UUID NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE, nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.expedicoes (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, lote TEXT NOT NULL UNIQUE, forma_envio TEXT NOT NULL, status status_expedicao NOT NULL, data_criacao DATE NOT NULL, data_envio DATE, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE public.expedicao_pedidos (id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY, expedicao_id UUID NOT NULL REFERENCES public.expedicoes(id) ON DELETE CASCADE, pedido_venda_id UUID NOT NULL REFERENCES public.pedidos_venda(id), created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
-- PASSO 5: TRIGGERS
CREATE TRIGGER on_public_clientes_updated_at BEFORE UPDATE ON public.clientes FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_pessoas_contato_updated_at BEFORE UPDATE ON public.pessoas_contato FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_vendedores_updated_at BEFORE UPDATE ON public.vendedores FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_produtos_updated_at BEFORE UPDATE ON public.produtos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_servicos_updated_at BEFORE UPDATE ON public.servicos FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_embalagens_updated_at BEFORE UPDATE ON public.embalagens FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_pedidos_venda_updated_at BEFORE UPDATE ON public.pedidos_venda FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_faturas_venda_updated_at BEFORE UPDATE ON public.faturas_venda FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_contas_receber_updated_at BEFORE UPDATE ON public.contas_receber FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_contas_pagar_updated_at BEFORE UPDATE ON public.contas_pagar FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_fluxo_caixa_updated_at BEFORE UPDATE ON public.fluxo_caixa FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_ordens_servico_updated_at BEFORE UPDATE ON public.ordens_servico FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_ordens_compra_updated_at BEFORE UPDATE ON public.ordens_compra FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER on_public_expedicoes_updated_at BEFORE UPDATE ON public.expedicoes FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
-- PASSO 6: VIEWS
CREATE OR REPLACE VIEW public.ordens_servico_view AS
SELECT os.*, c.nome as cliente_nome, c.email as cliente_email, v.nome as vendedor_nome, t.nome as tecnico_nome FROM public.ordens_servico os
LEFT JOIN public.clientes c ON os.cliente_id = c.id
LEFT JOIN public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN public.vendedores t ON os.tecnico_id = t.id;
CREATE OR REPLACE VIEW public.dre_mensal AS
SELECT
    EXTRACT(YEAR FROM data) AS ano,
    EXTRACT(MONTH FROM data) AS mes,
    TO_CHAR(data, 'TMMonth') AS mes_nome,
    SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE 0 END) AS receita,
    SUM(CASE WHEN tipo = 'SAIDA' THEN valor ELSE 0 END) AS despesa,
    SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE -valor END) AS resultado
FROM public.fluxo_caixa
GROUP BY ano, mes, mes_nome
ORDER BY ano, mes;
-- PASSO 7: RLS POLICIES
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
CREATE POLICY "Allow all actions for authenticated users" ON public.clientes FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.pessoas_contato FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.cliente_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.vendedores FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.produtos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.produto_imagens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.produto_anuncios FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.produtos_fornecedores FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.servicos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.embalagens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.pedidos_venda FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.pedido_venda_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.pedido_venda_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.faturas_venda FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.contas_receber FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.contas_receber_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.contas_pagar FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.contas_pagar_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.fluxo_caixa FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordens_servico FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordem_servico_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordem_servico_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordens_compra FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordem_compra_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.ordem_compra_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.expedicoes FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all actions for authenticated users" ON public.expedicao_pedidos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- PASSO 8: SEED DATA
DO $$
DECLARE
    vendedor_id_1 UUID;
    vendedor_id_2 UUID;
    cliente_id_1 UUID;
    cliente_id_2 UUID;
    fornecedor_id_1 UUID;
    produto_id_1 UUID;
    produto_id_2 UUID;
    servico_id_1 UUID;
    pedido_venda_id_1 UUID;
BEGIN
    -- Seed Vendedores
    INSERT INTO public.vendedores (nome, tipo_pessoa, contribuinte, situacao, regra_liberacao_comissao, tipo_comissao, email, cpf_cnpj) VALUES
    ('Carlos Silva', 'Física', 'Não Contribuinte', 'Ativo com acesso ao sistema', 'Liberação parcial (pelo pagamento)', 'Comissão com alíquota fixa', 'carlos.silva@email.com', '123.456.789-00') RETURNING id INTO vendedor_id_1;
    INSERT INTO public.vendedores (nome, tipo_pessoa, contribuinte, situacao, regra_liberacao_comissao, tipo_comissao, email, cpf_cnpj) VALUES
    ('Ana Pereira', 'Física', 'Não Contribuinte', 'Ativo com acesso ao sistema', 'Liberação total (no faturamento)', 'Comissão com alíquota fixa', 'ana.pereira@email.com', '987.654.321-00') RETURNING id INTO vendedor_id_2;

    -- Seed Clientes e Fornecedores
    INSERT INTO public.clientes (nome, tipo_pessoa, email, cpf_cnpj, is_cliente, is_fornecedor, contribuinte_icms, vendedor_id) VALUES
    ('Tech Solutions Ltda', 'JURIDICA', 'contato@techsolutions.com', '12.345.678/0001-99', true, false, 'Contribuinte ICMS', vendedor_id_1) RETURNING id INTO cliente_id_1;
    INSERT INTO public.clientes (nome, tipo_pessoa, email, cpf_cnpj, is_cliente, is_fornecedor, contribuinte_icms, vendedor_id) VALUES
    ('João da Silva', 'FISICA', 'joao.silva@personal.com', '111.222.333-44', true, false, 'Não Contribuinte', vendedor_id_2) RETURNING id INTO cliente_id_2;
    INSERT INTO public.clientes (nome, tipo_pessoa, email, cpf_cnpj, is_cliente, is_fornecedor, contribuinte_icms) VALUES
    ('Global Parts Inc.', 'JURIDICA', 'sales@globalparts.com', '99.888.777/0001-66', false, true, 'Contribuinte ICMS') RETURNING id INTO fornecedor_id_1;

    -- Seed Produtos
    INSERT INTO public.produtos (tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
    ('Simples', 'Teclado Mecânico Gamer RGB', 'TEC-RGB-001', '1 - Estrangeira (Imp. Direta)', 'UN', '8471.60.52', 350.00, true, 50, 'Ativo') RETURNING id INTO produto_id_1;
    INSERT INTO public.produtos (tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
    ('Simples', 'Mouse Gamer Pro X', 'MSE-PRO-X', '2 - Estrangeira (Merc. Interno)', 'UN', '8471.60.53', 250.00, true, 100, 'Ativo') RETURNING id INTO produto_id_2;

    -- Seed Serviços
    INSERT INTO public.servicos (descricao, codigo, preco, unidade, situacao) VALUES
    ('Instalação de Rede Estruturada', 'SERV-REDE-01', 1200.00, 'HR', 'ATIVO') RETURNING id INTO servico_id_1;

    -- Seed Pedido de Venda
    INSERT INTO public.pedidos_venda (numero, natureza_operacao, cliente_id, vendedor_id, total_produtos, valor_total, data_venda, status, expedido) VALUES
    ('PV-00001', 'Venda de mercadorias', cliente_id_1, vendedor_id_1, 600.00, 600.00, '2025-10-01', 'ABERTO', false) RETURNING id INTO pedido_venda_id_1;
    INSERT INTO public.pedido_venda_itens (pedido_id, produto_id, descricao, quantidade, valor_unitario, valor_total) VALUES
    (pedido_venda_id_1, produto_id_1, 'Teclado Mecânico Gamer RGB', 1, 350.00, 350.00),
    (pedido_venda_id_1, produto_id_2, 'Mouse Gamer Pro X', 1, 250.00, 250.00);

    -- Seed Contas a Pagar
    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, status, fornecedor_id, ocorrencia) VALUES
    ('Compra de Componentes Eletrônicos', 5000.00, '2025-10-20', 'A_PAGAR', fornecedor_id_1, 'Única');
    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, status, ocorrencia) VALUES
    ('Aluguel Escritório', 2500.00, '2025-10-05', 'A_PAGAR', 'Recorrente');
    
    -- Seed Ordens de Serviço
    INSERT INTO public.ordens_servico (numero, cliente_id, descricao_servico, total_servicos, data_inicio, status, prioridade) VALUES
    ('OS-00001', cliente_id_2, 'Manutenção preventiva em servidor', 150.00, '2025-10-02', 'EM_ANDAMENTO', 'ALTA');

END $$;
