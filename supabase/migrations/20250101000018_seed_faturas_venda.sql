/*
          # População de Faturas de Venda
          Cria 5 faturas de venda baseadas em pedidos existentes que estão com o status 'ABERTO'.

          ## Query Description: 
          Este script irá selecionar até 5 pedidos de venda com status 'ABERTO', criar uma fatura correspondente para cada um e, em seguida, atualizar o status desses pedidos para 'FATURADO'. A operação é segura e mantém a consistência dos dados. Se não houver 5 pedidos abertos, ele faturará quantos estiverem disponíveis.

          ## Metadata:
          - Schema-Category: "Data"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: false
          
          ## Structure Details:
          - Tabela afetada (INSERT): public.faturas_venda
          - Tabela afetada (UPDATE): public.pedidos_venda
          
          ## Security Implications:
          - RLS Status: As políticas existentes são respeitadas.
          - Policy Changes: No
          - Auth Requirements: N/A
          
          ## Performance Impact:
          - Indexes: Utiliza índices existentes para buscar os pedidos.
          - Triggers: N/A
          - Estimated Impact: Baixo, a operação é rápida e afeta um número limitado de registros.
          */

DO $$
DECLARE
    pedido_record RECORD;
BEGIN
    FOR pedido_record IN
        SELECT *
        FROM public.pedidos_venda
        WHERE status = 'ABERTO'
        LIMIT 5
    LOOP
        -- Insere a fatura correspondente
        INSERT INTO public.faturas_venda (pedido_id, numero_fatura, data_emissao, data_vencimento, valor_total, status)
        VALUES (
            pedido_record.id,
            'FAT-' || pedido_record.numero,
            NOW(),
            NOW() + INTERVAL '30 days',
            pedido_record.valor_total,
            'EMITIDA'
        );

        -- Atualiza o status do pedido para 'FATURADO'
        UPDATE public.pedidos_venda
        SET status = 'FATURADO'
        WHERE id = pedido_record.id;
    END LOOP;
END $$;
