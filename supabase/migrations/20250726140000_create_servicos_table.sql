/*
          # Criação da Tabela de Serviços e Inserção de Dados
          Este script cria a tabela 'servicos' para armazenar os serviços oferecidos pela empresa e insere 5 registros de exemplo.

          ## Query Description: 
          - **CRIAÇÃO DA TABELA:** Define a estrutura da tabela `servicos` com colunas para nome, descrição, categoria, preço, tempo estimado e status.
          - **POLÍTICAS DE SEGURANÇA (RLS):** Habilita a segurança em nível de linha e cria políticas que permitem acesso total para usuários anônimos, ideal para o estágio atual de desenvolvimento.
          - **INSERÇÃO DE DADOS:** Insere 5 serviços de exemplo para que a funcionalidade possa ser testada imediatamente.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (pode ser revertido com um script de remoção)

          ## Structure Details:
          - Tabela afetada: `public.servicos`
          - Colunas adicionadas: `id`, `created_at`, `updated_at`, `nome`, `descricao`, `categoria`, `preco`, `tempo_estimado`, `ativo`

          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (criação de políticas de acesso total para `anon` e `authenticated`)
          - Auth Requirements: Nenhuma no momento.

          ## Performance Impact:
          - Indexes: Adicionado um índice primário na coluna `id`.
          - Triggers: Nenhum.
          - Estimated Impact: Mínimo, criação de uma nova tabela.
          */

-- 1. Criação da tabela de serviços
CREATE TABLE IF NOT EXISTS public.servicos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text NOT NULL,
    descricao text,
    categoria text,
    preco numeric(10, 2) DEFAULT 0 NOT NULL,
    tempo_estimado integer DEFAULT 0 NOT NULL, -- Em minutos
    ativo boolean DEFAULT true NOT NULL
);

-- 2. Habilita a Segurança em Nível de Linha (RLS)
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;

-- 3. Cria as políticas de segurança
DROP POLICY IF EXISTS "Permite acesso total para anon" ON public.servicos;
CREATE POLICY "Permite acesso total para anon"
ON public.servicos
FOR ALL
TO anon
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Permite acesso total para usuários autenticados" ON public.servicos;
CREATE POLICY "Permite acesso total para usuários autenticados"
ON public.servicos
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 4. Insere dados de exemplo (se a tabela estiver vazia)
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM public.servicos) THEN
      INSERT INTO public.servicos (nome, descricao, categoria, preco, tempo_estimado) VALUES
      ('Consultoria em TI', 'Sessão de consultoria para otimização de infraestrutura de TI.', 'Consultoria', 250.00, 60),
      ('Desenvolvimento de Software', 'Criação de software customizado para atender necessidades específicas.', 'Desenvolvimento', 5000.00, 2400),
      ('Suporte Técnico Remoto', 'Pacote de suporte técnico remoto por hora.', 'Suporte', 120.00, 60),
      ('Manutenção Preventiva de Servidores', 'Serviço de manutenção e verificação de servidores.', 'Manutenção', 450.00, 180),
      ('Instalação e Configuração de Rede', 'Setup completo de redes cabeadas e Wi-Fi para escritórios.', 'Infraestrutura', 800.00, 300);
   END IF;
END $$;
