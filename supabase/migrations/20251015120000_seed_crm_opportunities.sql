/*
          # [POPULAR MÓDULO DE CRM]
          Este script insere dados de exemplo na tabela 'crm_oportunidades'.

          ## Query Description: [Esta operação é segura e apenas adiciona novos registros. Nenhum dado existente será modificado ou apagado. As oportunidades criadas serão vinculadas a clientes e vendedores já existentes no banco de dados para simular um ambiente realista.]
          
          ## Metadata:
          - Schema-Category: ["Data"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela afetada: public.crm_oportunidades
          
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo, apenas inserção de poucos registros.]
*/
DO $$
DECLARE
    cliente1_id UUID;
    cliente2_id UUID;
    vendedor1_id UUID;
    vendedor2_id UUID;
BEGIN
    -- Selecionar IDs de clientes e vendedores existentes para usar nas oportunidades
    -- Tenta pegar IDs específicos para consistência, se não encontrar, pega qualquer um.
    SELECT id INTO cliente1_id FROM public.clientes WHERE nome = 'Empresa de Tecnologia Inovadora S.A.' LIMIT 1;
    IF cliente1_id IS NULL THEN SELECT id INTO cliente1_id FROM public.clientes LIMIT 1; END IF;

    SELECT id INTO cliente2_id FROM public.clientes WHERE nome = 'Soluções Criativas Ltda.' LIMIT 1;
    IF cliente2_id IS NULL THEN SELECT id INTO cliente2_id FROM public.clientes WHERE id <> cliente1_id LIMIT 1; END IF;

    SELECT id INTO vendedor1_id FROM public.vendedores WHERE nome = 'Ana Oliveira' LIMIT 1;
    IF vendedor1_id IS NULL THEN SELECT id INTO vendedor1_id FROM public.vendedores LIMIT 1; END IF;

    SELECT id INTO vendedor2_id FROM public.vendedores WHERE nome = 'Bruno Costa' LIMIT 1;
    IF vendedor2_id IS NULL THEN SELECT id INTO vendedor2_id FROM public.vendedores WHERE id <> vendedor1_id LIMIT 1; END IF;

    -- Inserir oportunidades de exemplo se os IDs foram encontrados
    IF cliente1_id IS NOT NULL AND cliente2_id IS NOT NULL AND vendedor1_id IS NOT NULL AND vendedor2_id IS NOT NULL THEN
        INSERT INTO public.crm_oportunidades (nome, cliente_id, vendedor_id, valor_estimado, etapa, data_fechamento_prevista)
        VALUES
            ('Desenvolvimento de novo E-commerce', cliente1_id, vendedor1_id, 50000.00, 'Prospecção', NOW() + INTERVAL '30 days'),
            ('Contrato de Suporte Técnico Anual', cliente2_id, vendedor2_id, 12000.00, 'Negociação', NOW() + INTERVAL '15 days'),
            ('Consultoria de SEO para Blog', cliente1_id, vendedor1_id, 5000.00, 'Lead', NOW() + INTERVAL '45 days'),
            ('Renovação de Licença de Software', cliente2_id, vendedor2_id, 8000.00, 'Ganho', NOW() - INTERVAL '10 days'),
            ('Projeto de Migração para Nuvem', cliente1_id, vendedor2_id, 75000.00, 'Perdido', NOW() - INTERVAL '5 days'),
            ('Implementação de Sistema de Pagamentos', cliente2_id, vendedor1_id, 25000.00, 'Negociação', NOW() + INTERVAL '20 days');
    END IF;
END $$;
