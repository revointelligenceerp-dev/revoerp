-- Habilita RLS para as novas tabelas, caso ainda não esteja.
ALTER TABLE public.categorias_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.formas_pagamento ENABLE ROW LEVEL SECURITY;

-- Remove políticas antigas para garantir um estado limpo
DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.categorias_financeiras;
DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.formas_pagamento;

-- Cria uma política permissiva para usuários autenticados
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
