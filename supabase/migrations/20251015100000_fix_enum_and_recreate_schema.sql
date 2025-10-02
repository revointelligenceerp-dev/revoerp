-- Limpa o schema existente para garantir um ambiente limpo
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;

-- Recria os ENUMs com as definições corretas
CREATE TYPE "public"."tipo_pessoa" AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO');
CREATE TYPE "public"."contribuinte_icms" AS ENUM ('Não informado', 'Contribuinte ICMS', 'Contribuinte Isento de Inscrição Estadual', 'Não Contribuinte');
CREATE TYPE "public"."tipo_pessoa_vendedor" AS ENUM ('Física', 'Jurídica', 'Estrangeiro', 'Estrangeiro no Brasil');
CREATE TYPE "public"."situacao_vendedor" AS ENUM ('Ativo com acesso ao sistema', 'Ativo sem acesso ao sistema', 'Inativo');
CREATE TYPE "public"."regra_comissao" AS ENUM ('Liberação parcial vinculada ao pagamento das parcelas', 'Liberação total no faturamento do pedido', 'Liberação total no pagamento integral do pedido');
CREATE TYPE "public"."tipo_comissao_vendedor" AS ENUM ('Comissão com alíquota fixa', 'Comissão com alíquota conforme descontos');
CREATE TYPE "public"."status_os" AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA', 'ORCAMENTO');
CREATE TYPE "public"."prioridade_os" AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');
CREATE TYPE "public"."status_pedido_venda" AS ENUM ('ABERTO', 'FATURADO', 'CANCELADO');
CREATE TYPE "public"."status_fatura" AS ENUM ('EMITIDA', 'PAGA', 'VENCIDA', 'CANCELADA');
CREATE TYPE "public"."status_conta_receber" AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
CREATE TYPE "public"."status_conta_pagar" AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
CREATE TYPE "public"."ocorrencia_conta" AS ENUM ('Única', 'Recorrente');
CREATE TYPE "public"."tipo_movimento_caixa" AS ENUM ('ENTRADA', 'SAIDA');
CREATE TYPE "public"."tipo_produto" AS ENUM ('Simples', 'Com variações', 'Kit', 'Fabricado', 'Matéria Prima');
CREATE TYPE "public"."situacao_produto" AS ENUM ('Ativo', 'Inativo');
CREATE TYPE "public"."situacao_servico" AS ENUM ('ATIVO', 'INATIVO');
CREATE TYPE "public"."origem_produto" AS ENUM ('0 - Nacional, exceto as indicadas nos códigos 3 a 5', '1 - Estrangeira – Importação direta, exceto a indicada no código 6', '2 - Estrangeira – Adquirida no mercado interno, exceto a indicada no código 7', '3 - Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%', '4 - Nacional, cuja produção tenha sido feita em conformidade com os processos produtivos básicos', '5 - Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40%', '6 - Estrangeira – Importação direta, sem similar nacional, constante em lista da CAMEX', '7 - Estrangeira – Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX', '8 - Nacional, mercadoria ou bem com Conteúdo de Importação superior a 70%');
CREATE TYPE "public"."tipo_embalagem_produto" AS ENUM ('Pacote / Caixa', 'Envelope', 'Rolo / Cilíndrico');
CREATE TYPE "public"."embalagem_produto" AS ENUM ('Embalagem customizada', 'Caixa de Encomenda Flex', 'Caixa de Encomenda CE – 01', 'Caixa de Encomenda CE – 02', 'Caixa de Encomenda CE – 03', 'Caixa de Encomenda CE – 07', 'Caixa de Encomenda 5B', 'Caixa de Encomenda 6B', 'Caixa de Encomenda Vai e Vem', 'Caixa de Encomenda B', 'Caixa de Encomenda 2B', 'Caixa de Encomenda 4B', 'Caixa de Encomenda Temática 01', 'Caixa de Encomenda Temática 02', 'Caixa de Encomenda Temática 03', 'Criar nova embalagem ...');
CREATE TYPE "public"."tipo_embalagem" AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
CREATE TYPE "public"."status_expedicao" AS ENUM ('AGUARDANDO_ENVIO', 'ENVIADO', 'ENTREGUE', 'CANCELADO');
CREATE TYPE "public"."frete_por_conta" AS ENUM ('CIF', 'FOB');

-- Recria as tabelas
CREATE TABLE "public"."clientes" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "codigo" text, "nome" text NOT NULL, "nome_fantasia" text, "tipo_pessoa" tipo_pessoa NOT NULL, "cpf_cnpj" text NOT NULL, "rg" text, "inscricao_estadual" text, "inscricao_municipal" text, "contribuinte_icms" contribuinte_icms NOT NULL, "is_cliente" boolean DEFAULT true NOT NULL, "is_fornecedor" boolean DEFAULT false NOT NULL, "is_transportadora" boolean DEFAULT false NOT NULL, "logradouro" text, "numero" text, "complemento" text, "bairro" text, "cep" text, "cidade" text, "estado" text, "pais" text, "cobranca_logradouro" text, "cobranca_numero" text, "cobranca_complemento" text, "cobranca_bairro" text, "cobranca_cep" text, "cobranca_cidade" text, "cobranca_estado" text, "telefone" text, "telefone_adicional" text, "celular" text, "email" text NOT NULL, "email_nfe" text, "site" text, "estado_civil" text, "profissao" text, "sexo" text, "data_nascimento" date, "naturalidade" text, "status_crm" text, "vendedor_id" uuid, "condicao_pagamento_padrao_id" text, "limite_credito" numeric, "observacoes" text, PRIMARY KEY ("id") );
CREATE TABLE "public"."pessoas_contato" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "cliente_id" uuid NOT NULL, "nome" text NOT NULL, "setor" text, "email" text, "telefone" text, "ramal" text, PRIMARY KEY ("id"), FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE );
CREATE TABLE "public"."cliente_anexos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "cliente_id" uuid NOT NULL, "nome_arquivo" text NOT NULL, "path" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE );
CREATE TABLE "public"."produtos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "tipo_produto" tipo_produto NOT NULL, "nome" text NOT NULL, "codigo_barras" text, "codigo" text, "origem" origem_produto NOT NULL, "unidade" text, "ncm" text, "cest" text, "preco_venda" numeric NOT NULL, "peso_liquido" numeric, "peso_bruto" numeric, "volumes" integer, "tipo_embalagem" tipo_embalagem_produto, "embalagem" embalagem_produto, "largura" numeric, "altura" numeric, "comprimento" numeric, "controlar_estoque" boolean DEFAULT false NOT NULL, "estoque_inicial" integer, "estoque_minimo" integer, "estoque_maximo" integer, "controlar_lotes" boolean DEFAULT false NOT NULL, "localizacao" text, "dias_preparacao" integer, "situacao" situacao_produto NOT NULL, "marca" text, "tabela_medidas" text, "descricao_complementar" text, "link_video" text, "slug" text, "keywords" text, "titulo_seo" text, "descricao_seo" text, "unidade_por_caixa" integer, "custo" numeric, "linha_produto" text, "garantia" text, "markup" numeric, "permitir_vendas" boolean DEFAULT true NOT NULL, "gtin_tributavel" text, "unidade_tributavel" text, "fator_conversao" numeric, "codigo_enquadramento_ipi" text, "valor_ipi_fixo" numeric, "ex_tipi" text, "observacoes_produto" text, "atributos" jsonb, PRIMARY KEY ("id") );
CREATE TABLE "public"."produto_imagens" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "produto_id" uuid NOT NULL, "path" text NOT NULL, "nome_arquivo" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") ON DELETE CASCADE );
CREATE TABLE "public"."produto_anuncios" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "produto_id" uuid NOT NULL, "ecommerce" text NOT NULL, "identificador" text NOT NULL, "descricao" text, PRIMARY KEY ("id"), FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") ON DELETE CASCADE );
CREATE TABLE "public"."produtos_fornecedores" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "produto_id" uuid NOT NULL, "fornecedor_id" uuid NOT NULL, "codigo_no_fornecedor" text, PRIMARY KEY ("id"), FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") ON DELETE CASCADE, FOREIGN KEY ("fornecedor_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE );
CREATE TABLE "public"."servicos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "descricao" text NOT NULL, "codigo" text, "preco" numeric NOT NULL, "unidade" text, "situacao" situacao_servico NOT NULL, "codigo_servico" text, "nbs" text, "descricao_complementar" text, "observacoes" text, PRIMARY KEY ("id") );
CREATE TABLE "public"."vendedores" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "nome" text NOT NULL, "fantasia" text, "codigo" text, "tipo_pessoa" tipo_pessoa_vendedor NOT NULL, "cpf_cnpj" text NOT NULL, "contribuinte" contribuinte_icms NOT NULL, "inscricao_estadual" text, "cep" text, "cidade" text, "uf" text, "logradouro" text, "bairro" text, "numero" text, "complemento" text, "telefone" text, "celular" text, "email" text NOT NULL, "situacao" situacao_vendedor NOT NULL, "deposito" text, "email_comunicacoes" text, "usuario_sistema" text, "acesso_restrito_horario" boolean DEFAULT false NOT NULL, "acesso_restrito_ip" boolean DEFAULT false NOT NULL, "ips_permitidos" text, "perfil_acesso_contatos" text, "modulos_acessiveis" text[], "pode_incluir_produtos_nao_cadastrados" boolean DEFAULT false NOT NULL, "pode_emitir_cobrancas" boolean DEFAULT false NOT NULL, "regra_liberacao_comissao" regra_comissao NOT NULL, "tipo_comissao" tipo_comissao_vendedor NOT NULL, "aliquota_comissao" numeric, "desconsiderar_comissao_linha_produto" boolean DEFAULT false NOT NULL, "observacoes" text, "ativo" boolean DEFAULT true NOT NULL, PRIMARY KEY ("id") );
ALTER TABLE "public"."clientes" ADD FOREIGN KEY ("vendedor_id") REFERENCES "public"."vendedores"("id") ON DELETE SET NULL;
CREATE TABLE "public"."embalagens" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "descricao" text NOT NULL, "tipo" tipo_embalagem NOT NULL, "largura_cm" numeric, "altura_cm" numeric, "comprimento_cm" numeric, "diametro_cm" numeric, "peso_kg" numeric NOT NULL, PRIMARY KEY ("id") );
CREATE TABLE "public"."ordens_servico" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "numero" text NOT NULL, "cliente_id" uuid NOT NULL, "descricao_servico" text, "consideracoes_finais" text, "data_inicio" date NOT NULL, "data_previsao" date, "hora" time without time zone, "data_conclusao" date, "total_servicos" numeric NOT NULL, "desconto" text, "observacoes_servico" text, "observacoes_internas" text, "vendedor_id" uuid, "comissao_percentual" numeric, "valor_comissao" numeric, "tecnico_id" uuid, "orcar" boolean NOT NULL, "forma_recebimento" text, "meio_pagamento" text, "conta_bancaria" text, "categoria_financeira" text, "condicao_pagamento" text, "marcadores" text[], "status" status_os NOT NULL, "prioridade" prioridade_os NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id"), FOREIGN KEY ("vendedor_id") REFERENCES "public"."vendedores"("id"), FOREIGN KEY ("tecnico_id") REFERENCES "public"."vendedores"("id") );
CREATE TABLE "public"."ordem_servico_itens" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "ordem_servico_id" uuid NOT NULL, "servico_id" uuid, "descricao" text NOT NULL, "codigo" text, "quantidade" numeric NOT NULL, "preco" numeric NOT NULL, "desconto" numeric NOT NULL, "valor_total" numeric NOT NULL, "orcar" boolean NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("ordem_servico_id") REFERENCES "public"."ordens_servico"("id") ON DELETE CASCADE, FOREIGN KEY ("servico_id") REFERENCES "public"."servicos"("id") ON DELETE SET NULL );
CREATE TABLE "public"."ordem_servico_anexos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "ordem_servico_id" uuid NOT NULL, "nome_arquivo" text NOT NULL, "path" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("ordem_servico_id") REFERENCES "public"."ordens_servico"("id") ON DELETE CASCADE );
CREATE TABLE "public"."pedidos_venda" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "numero" text NOT NULL, "natureza_operacao" text NOT NULL, "cliente_id" uuid NOT NULL, "vendedor_id" uuid, "endereco_entrega_diferente" boolean DEFAULT false NOT NULL, "total_produtos" numeric NOT NULL, "valor_ipi" numeric, "valor_icms_st" numeric, "desconto" text, "frete_cliente" numeric, "frete_empresa" numeric, "despesas" numeric, "valor_total" numeric NOT NULL, "data_venda" date NOT NULL, "data_prevista_entrega" date, "data_envio" timestamp with time zone, "data_maxima_despacho" timestamp with time zone, "numero_pedido_ecommerce" text, "identificador_pedido_ecommerce" text, "numero_pedido_canal_venda" text, "intermediador" text, "forma_recebimento" text, "meio_pagamento" text, "conta_bancaria" text, "categoria_financeira" text, "condicao_pagamento" text, "forma_envio" text, "enviar_para_expedicao" boolean DEFAULT true NOT NULL, "deposito" text, "observacoes" text, "observacoes_internas" text, "marcadores" text[], "status" status_pedido_venda NOT NULL, "peso_bruto" numeric, "peso_liquido" numeric, "expedido" boolean DEFAULT false NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id"), FOREIGN KEY ("vendedor_id") REFERENCES "public"."vendedores"("id") );
CREATE TABLE "public"."pedido_venda_itens" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "pedido_id" uuid NOT NULL, "produto_id" uuid, "servico_id" uuid, "descricao" text NOT NULL, "codigo" text, "unidade" text, "quantidade" numeric NOT NULL, "valor_unitario" numeric NOT NULL, "desconto_percentual" numeric, "valor_total" numeric NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos_venda"("id") ON DELETE CASCADE, FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id"), FOREIGN KEY ("servico_id") REFERENCES "public"."servicos"("id") );
CREATE TABLE "public"."pedido_venda_anexos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "pedido_id" uuid NOT NULL, "nome_arquivo" text NOT NULL, "path" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos_venda"("id") ON DELETE CASCADE );
CREATE TABLE "public"."faturas_venda" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "pedido_id" uuid NOT NULL, "numero_fatura" text NOT NULL, "data_emissao" date NOT NULL, "data_vencimento" date NOT NULL, "valor_total" numeric NOT NULL, "status" status_fatura NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos_venda"("id") );
CREATE TABLE "public"."contas_receber" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "fatura_id" uuid, "cliente_id" uuid, "descricao" text, "valor" numeric NOT NULL, "data_vencimento" date NOT NULL, "data_pagamento" date, "status" status_conta_receber NOT NULL, "ocorrencia" ocorrencia_conta, "forma_recebimento" text, "numero_documento" text, "historico" text, "categoria_id" text, "marcadores" text[], PRIMARY KEY ("id"), FOREIGN KEY ("fatura_id") REFERENCES "public"."faturas_venda"("id"), FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") );
CREATE TABLE "public"."contas_receber_anexos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "conta_receber_id" uuid NOT NULL, "nome_arquivo" text NOT NULL, "path" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("conta_receber_id") REFERENCES "public"."contas_receber"("id") ON DELETE CASCADE );
CREATE TABLE "public"."contas_pagar" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "descricao" text NOT NULL, "valor" numeric NOT NULL, "data_vencimento" date NOT NULL, "data_pagamento" date, "status" status_conta_pagar NOT NULL, "fornecedor_id" uuid, "forma_pagamento" text, "numero_documento" text, "historico" text, "categoria_id" text, "ocorrencia" ocorrencia_conta NOT NULL, "competencia" text, "marcadores" text[], PRIMARY KEY ("id"), FOREIGN KEY ("fornecedor_id") REFERENCES "public"."clientes"("id") );
CREATE TABLE "public"."contas_pagar_anexos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "conta_pagar_id" uuid NOT NULL, "nome_arquivo" text NOT NULL, "path" text NOT NULL, "tamanho" integer NOT NULL, "tipo" text NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("conta_pagar_id") REFERENCES "public"."contas_pagar"("id") ON DELETE CASCADE );
CREATE TABLE "public"."fluxo_caixa" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "data" date NOT NULL, "descricao" text NOT NULL, "valor" numeric NOT NULL, "tipo" tipo_movimento_caixa NOT NULL, "conta_receber_id" uuid, "conta_pagar_id" uuid, PRIMARY KEY ("id"), FOREIGN KEY ("conta_receber_id") REFERENCES "public"."contas_receber"("id"), FOREIGN KEY ("conta_pagar_id") REFERENCES "public"."contas_pagar"("id") );
CREATE TABLE "public"."expedicoes" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "lote" text NOT NULL, "forma_envio" text NOT NULL, "status" status_expedicao NOT NULL, "data_criacao" date NOT NULL, "data_envio" date, PRIMARY KEY ("id") );
CREATE TABLE "public"."expedicao_pedidos" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "expedicao_id" uuid NOT NULL, "pedido_venda_id" uuid NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("expedicao_id") REFERENCES "public"."expedicoes"("id") ON DELETE CASCADE, FOREIGN KEY ("pedido_venda_id") REFERENCES "public"."pedidos_venda"("id") ON DELETE CASCADE );
CREATE TABLE "public"."ordens_compra" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "numero" text NOT NULL, "fornecedor_id" uuid NOT NULL, "total_produtos" numeric NOT NULL, "desconto" text, "frete" numeric, "total_ipi" numeric, "total_icms_st" numeric, "total_geral" numeric NOT NULL, "numero_no_fornecedor" text, "data_compra" date NOT NULL, "data_prevista" date, "condicao_pagamento" text, "categoria_id" text, "transportador_nome" text, "frete_por_conta" frete_por_conta, "observacoes" text, "observacoes_internas" text, "marcadores" text[], "status" status_pedido_venda NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("fornecedor_id") REFERENCES "public"."clientes"("id") );
CREATE TABLE "public"."ordem_compra_itens" ( "id" uuid DEFAULT gen_random_uuid() NOT NULL, "created_at" timestamp with time zone DEFAULT now() NOT NULL, "updated_at" timestamp with time zone DEFAULT now() NOT NULL, "ordem_compra_id" uuid NOT NULL, "produto_id" uuid, "descricao" text NOT NULL, "codigo" text, "unidade" text, "quantidade" numeric NOT NULL, "preco_unitario" numeric NOT NULL, "ipi" numeric, "preco_total" numeric NOT NULL, PRIMARY KEY ("id"), FOREIGN KEY ("ordem_compra_id") REFERENCES "public"."ordens_compra"("id") ON DELETE CASCADE, FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") );

-- Recria as Views
CREATE OR REPLACE VIEW "public"."ordens_servico_view" AS
SELECT
  os.id, os.created_at, os.updated_at, os.numero, os.cliente_id,
  c.nome AS cliente_nome, c.email AS cliente_email,
  os.descricao_servico, os.data_inicio, os.data_previsao, os.data_conclusao,
  os.total_servicos, os.vendedor_id, v.nome AS vendedor_nome,
  os.tecnico_id, t.nome AS tecnico_nome, os.status, os.prioridade
FROM
  ordens_servico os
  LEFT JOIN clientes c ON os.cliente_id = c.id
  LEFT JOIN vendedores v ON os.vendedor_id = v.id
  LEFT JOIN vendedores t ON os.tecnico_id = t.id;

CREATE OR REPLACE VIEW "public"."dre_mensal" AS
SELECT
  EXTRACT(YEAR FROM data) AS ano,
  EXTRACT(MONTH FROM data) AS mes,
  to_char(data, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE 0 END) AS receita,
  SUM(CASE WHEN tipo = 'SAIDA' THEN valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE -valor END) AS resultado
FROM
  fluxo_caixa
GROUP BY
  ano, mes, mes_nome
ORDER BY
  ano, mes;

-- Recria as Políticas de Segurança (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read-only access" ON "public"."clientes" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."pessoas_contato" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."cliente_anexos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."produtos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."produto_imagens" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."produto_anuncios" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."produtos_fornecedores" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."servicos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."vendedores" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."embalagens" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."ordens_servico" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."ordem_servico_itens" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."ordem_servico_anexos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."pedidos_venda" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."pedido_venda_itens" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."pedido_venda_anexos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."faturas_venda" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."contas_receber" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."contas_receber_anexos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."contas_pagar" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."contas_pagar_anexos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."fluxo_caixa" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."expedicoes" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."expedicao_pedidos" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."ordens_compra" FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access" ON "public"."ordem_compra_itens" FOR SELECT USING (true);

CREATE POLICY "Allow all access for authenticated users" ON "public"."clientes" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."pessoas_contato" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."cliente_anexos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."produtos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."produto_imagens" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."produto_anuncios" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."produtos_fornecedores" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."servicos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."vendedores" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."embalagens" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."ordens_servico" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."ordem_servico_itens" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."ordem_servico_anexos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."pedidos_venda" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."pedido_venda_itens" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."pedido_venda_anexos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."faturas_venda" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."contas_receber" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."contas_receber_anexos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."contas_pagar" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."contas_pagar_anexos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."fluxo_caixa" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."expedicoes" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."expedicao_pedidos" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."ordens_compra" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all access for authenticated users" ON "public"."ordem_compra_itens" FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- Cria os Buckets de Storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('cliente-anexos', 'cliente-anexos', true, 2097152, '{"application/pdf", "image/*", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}'),
    ('produto-imagens', 'produto-imagens', true, 2097152, '{"image/*"}'),
    ('anexos-financeiro', 'anexos-financeiro', false, 2097152, '{"application/pdf", "image/*"}'),
    ('os-anexos', 'os-anexos', false, 2097152, '{"application/pdf", "image/*"}'),
    ('pedido-anexos', 'pedido-anexos', false, 2097152, '{"application/pdf", "image/*"}')
ON CONFLICT (id) DO NOTHING;
