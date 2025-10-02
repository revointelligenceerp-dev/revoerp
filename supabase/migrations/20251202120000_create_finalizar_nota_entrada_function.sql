/*
          # [Function] finalizar_nota_entrada
          Cria uma função para finalizar uma nota de entrada, atualizando seu status e registrando as movimentações de estoque correspondentes.

          ## Query Description: 
          - Esta operação cria uma função no banco de dados.
          - A função `finalizar_nota_entrada` recebe o ID de uma nota de entrada.
          - Ela atualiza o status da nota para 'FINALIZADA'.
          - Em seguida, itera sobre os itens da nota. Para cada item cujo produto correspondente controla estoque, uma nova movimentação de 'ENTRADA' é inserida na tabela `estoque_movimentos`.
          - A operação é segura e não afeta dados existentes de forma destrutiva.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (a função pode ser removida)

          ## Structure Details:
          - Cria a função `public.finalizar_nota_entrada(uuid)`.
          - A função interage com as tabelas `notas_entrada`, `nota_entrada_itens`, `produtos` e `estoque_movimentos`.

          ## Security Implications:
          - RLS Status: A função é executada com os privilégios do usuário que a chama. As políticas de RLS nas tabelas envolvidas serão respeitadas.
          - Policy Changes: No
          - Auth Requirements: O usuário deve ter permissão para executar a função e para realizar as operações de UPDATE e INSERT nas tabelas afetadas.

          ## Performance Impact:
          - Indexes: A performance depende dos índices nas colunas `id` e `produto_id` das tabelas envolvidas, que já são chaves primárias ou estrangeiras.
          - Triggers: No
          - Estimated Impact: Baixo. A operação é executada por nota e o número de itens é geralmente pequeno.
          */

CREATE OR REPLACE FUNCTION public.finalizar_nota_entrada(p_nota_entrada_id uuid)
RETURNS void AS $$
DECLARE
    item_record RECORD;
    produto_record RECORD;
    v_nota_numero TEXT;
BEGIN
    -- 1. Atualiza o status da nota de entrada para 'FINALIZADA' e obtém o número da nota
    UPDATE public.notas_entrada
    SET status = 'FINALIZADA'
    WHERE id = p_nota_entrada_id
    RETURNING numero INTO v_nota_numero;

    -- Se não encontrar a nota, encerra a função
    IF NOT FOUND THEN
        RAISE WARNING 'Nota de entrada com ID % não encontrada.', p_nota_entrada_id;
        RETURN;
    END IF;

    -- 2. Itera sobre os itens da nota de entrada
    FOR item_record IN
        SELECT *
        FROM public.nota_entrada_itens
        WHERE nota_entrada_id = p_nota_entrada_id
    LOOP
        -- 3. Verifica se o produto correspondente controla estoque
        SELECT controlar_estoque INTO produto_record
        FROM public.produtos
        WHERE id = item_record.produto_id;

        -- 4. Se controlar estoque, insere o movimento de entrada
        IF produto_record.controlar_estoque THEN
            INSERT INTO public.estoque_movimentos (produto_id, tipo, quantidade, data, origem)
            VALUES (
                item_record.produto_id,
                'ENTRADA',
                item_record.quantidade,
                NOW(),
                'Nota de Entrada ' || v_nota_numero
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
