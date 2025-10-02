/*
          # [Structural] Criação da Tabela de Anúncios de Produtos
          [Este script cria a tabela 'produto_anuncios' para armazenar os links de anúncios de produtos em diferentes plataformas de e-commerce.]

          ## Query Description: [Cria uma nova tabela para vincular produtos a anúncios externos. Não há risco de perda de dados, pois a tabela é nova. As políticas de RLS garantem que apenas usuários autenticados possam acessar e modificar seus próprios dados.]
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Tabela 'produto_anuncios' (nova)
          - Colunas: id, created_at, produto_id, ecommerce, identificador, descricao
          - Chave estrangeira: produto_id -> produtos.id
          - Constraint: UNIQUE(produto_id, ecommerce, identificador)
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (novas políticas para a tabela 'produto_anuncios')
          - Auth Requirements: Usuário autenticado
          
          ## Performance Impact:
          - Indexes: Adicionado índice de chave primária e constraint 'unique'.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo.
          */

-- 1. CRIAÇÃO DA TABELA
CREATE TABLE IF NOT EXISTS public.produto_anuncios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    produto_id uuid NOT NULL,
    ecommerce text NOT NULL,
    identificador text NOT NULL,
    descricao text,
    CONSTRAINT produto_anuncios_pkey PRIMARY KEY (id),
    CONSTRAINT produto_anuncios_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id) ON DELETE CASCADE,
    CONSTRAINT produto_anuncios_unique_idx UNIQUE (produto_id, ecommerce, identificador)
);

ALTER TABLE public.produto_anuncios OWNER TO postgres;
COMMENT ON TABLE public.produto_anuncios IS 'Armazena os anúncios de um produto em diferentes e-commerces.';

-- 2. HABILITAR RLS
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS DE ACESSO
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.produto_anuncios;
CREATE POLICY "Permitir acesso total para usuários autenticados"
ON public.produto_anuncios
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
