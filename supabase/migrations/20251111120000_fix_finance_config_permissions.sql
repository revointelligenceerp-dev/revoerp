-- Remove políticas antigas para garantir que o script possa ser executado várias vezes sem erro.
DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.categorias_financeiras;
DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.formas_pagamento;

-- Cria uma nova política que permite todas as operações (SELECT, INSERT, UPDATE, DELETE)
-- para qualquer usuário que esteja autenticado.
CREATE POLICY "Allow all access for authenticated users"
ON public.categorias_financeiras
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow all access for authenticated users"
ON public.formas_pagamento
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Garante que o RLS está habilitado, caso tenha sido desativado em algum momento.
ALTER TABLE public.categorias_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.formas_pagamento ENABLE ROW LEVEL SECURITY;
