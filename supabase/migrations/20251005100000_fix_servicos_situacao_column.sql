/*
# [SCRIPT DE CORREÇÃO] Adiciona a coluna 'situacao' à tabela 'servicos'

## Descrição da Query:
Esta operação adiciona a coluna `situacao` à tabela `servicos`, caso ela não exista. Esta coluna é essencial para a funcionalidade de "soft delete" (exclusão lógica), permitindo que serviços sejam marcados como 'ATIVO' ou 'INATIVO' em vez de serem permanentemente apagados. Isso preserva a integridade dos dados históricos (pedidos de venda e ordens de serviço que já utilizaram o serviço).

## Metadados:
- Categoria do Esquema: "Estrutural"
- Nível de Impacto: "Baixo"
- Requer Backup: false
- Reversível: true (pode ser revertido com `ALTER TABLE public.servicos DROP COLUMN situacao;`)

## Detalhes da Estrutura:
- Tabela Afetada: `public.servicos`
- Coluna Adicionada: `situacao` (TEXT, NOT NULL, DEFAULT 'ATIVO')

## Implicações de Segurança:
- Status RLS: Mantém o status existente.
- Mudanças de Política: Não.
- Requisitos de Autenticação: Nenhum.

## Impacto no Desempenho:
- Índices: Nenhum índice novo é adicionado.
- Triggers: Nenhum.
- Impacto Estimado: Mínimo. A operação é rápida em tabelas de tamanho moderado.
*/

BEGIN;

-- Adiciona a coluna 'situacao' apenas se ela não existir.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'servicos'
        AND column_name = 'situacao'
    ) THEN
        ALTER TABLE public.servicos
        ADD COLUMN situacao TEXT NOT NULL DEFAULT 'ATIVO';

        COMMENT ON COLUMN public.servicos.situacao IS 'Situação do serviço (ATIVO ou INATIVO) para controle de exclusão lógica.';
    END IF;
END $$;

COMMIT;
