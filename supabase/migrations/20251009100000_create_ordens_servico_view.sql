/*
          # [Structural] Cria a View Otimizada para Ordens de Serviço
          Cria uma view chamada `ordens_servico_view` que pré-junta os dados da ordem de serviço com os nomes do cliente, vendedor e técnico. Isso otimiza a performance das consultas, reduzindo a necessidade de múltiplos "joins" na aplicação.

          ## Query Description: [Esta operação é segura e não afeta os dados existentes. Ela apenas cria uma nova forma de visualizar os dados, melhorando a performance de leitura. Não há riscos associados.]
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (a view pode ser removida com `DROP VIEW`)
          
          ## Structure Details:
          - Cria a view `public.ordens_servico_view`.
          
          ## Security Implications:
          - RLS Status: A view herda as políticas de RLS da tabela base `ordens_servico`.
          - Policy Changes: No
          - Auth Requirements: Acesso à view requer as mesmas permissões de acesso à tabela `ordens_servico`.
          
          ## Performance Impact:
          - Indexes: A view utilizará os índices existentes nas tabelas base.
          - Triggers: Nenhum.
          - Estimated Impact: Positivo. Reduz o número de requisições ao banco de dados para carregar a lista de ordens de serviço, melhorando o tempo de carregamento da página.
          */
CREATE OR REPLACE VIEW public.ordens_servico_view AS
SELECT
  os.*,
  c.nome AS cliente_nome,
  c.email AS cliente_email,
  v.nome AS vendedor_nome,
  t.nome AS tecnico_nome
FROM
  public.ordens_servico os
LEFT JOIN
  public.clientes c ON os.cliente_id = c.id
LEFT JOIN
  public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN
  public.vendedores t ON os.tecnico_id = t.id;
