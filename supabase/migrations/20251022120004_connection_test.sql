/*
  # [Connection Test]
  Este é um script de diagnóstico para verificar a conectividade básica com o banco de dados.
  Ele não faz nenhuma alteração no esquema ou nos dados.

  ## Query Description: [Executa um comando SELECT simples para confirmar que a conexão está ativa e pode executar queries.]

  ## Metadata:
  - Schema-Category: ["Safe"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]

  ## Structure Details:
  [Nenhuma estrutura é afetada.]

  ## Security Implications:
  - RLS Status: [N/A]
  - Policy Changes: [No]
  - Auth Requirements: [N/A]

  ## Performance Impact:
  - Indexes: [N/A]
  - Triggers: [N/A]
  - Estimated Impact: [Nenhum impacto no desempenho.]
*/
SELECT 1 as connection_test_result;
