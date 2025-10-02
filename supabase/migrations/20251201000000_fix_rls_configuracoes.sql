-- Habilita a Row Level Security para a tabela de configurações
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;

-- Remove políticas antigas para garantir um estado limpo
DROP POLICY IF EXISTS "Allow full access for authenticated users" ON public.configuracoes;

-- Cria uma política que permite que usuários autenticados gerenciem as configurações
CREATE POLICY "Allow full access for authenticated users"
ON public.configuracoes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
