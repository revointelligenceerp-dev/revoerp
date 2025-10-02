/*
          # Correção de Relações de Cliente
          [Adiciona as constraints de chave estrangeira que faltavam nas tabelas 'cliente_anexos' e 'pessoas_contato', ligando-as à tabela 'clientes'.]

          ## Query Description: [Esta operação é segura e não destrutiva. Ela apenas define as relações corretas entre as tabelas, o que é essencial para a integridade dos dados e para o funcionamento das consultas que unem informações de clientes, contatos e anexos. Sem essa correção, a funcionalidade de anexos e contatos não opera corretamente.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela 'cliente_anexos': Adiciona uma FOREIGN KEY na coluna 'cliente_id' referenciando 'clientes.id'.
          - Tabela 'pessoas_contato': Adiciona uma FOREIGN KEY na coluna 'cliente_id' referenciando 'clientes.id'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [None]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [None]
          - Estimated Impact: [Positivo. A criação de chaves estrangeiras geralmente cria índices automaticamente, o que melhora a performance das consultas que unem essas tabelas.]
          */

ALTER TABLE public.cliente_anexos
ADD CONSTRAINT cliente_anexos_cliente_id_fkey
FOREIGN KEY (cliente_id)
REFERENCES public.clientes (id)
ON DELETE CASCADE;

ALTER TABLE public.pessoas_contato
ADD CONSTRAINT pessoas_contato_cliente_id_fkey
FOREIGN KEY (cliente_id)
REFERENCES public.clientes (id)
ON DELETE CASCADE;
