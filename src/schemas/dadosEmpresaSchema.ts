import { z } from 'zod';

const requiredString = (field: string) => z.string({ required_error: `${field} é obrigatório.` }).min(1, `${field} é obrigatório.`);

const ieSchema = z.object({
  uf: requiredString('UF'),
  ie: requiredString('Inscrição Estadual'),
});

export const dadosEmpresaSchema = z.object({
  razaoSocial: requiredString('Razão Social').max(120, 'Máximo de 120 caracteres.'),
  nomeCompleto: z.string().max(120, 'Máximo de 120 caracteres.').optional().nullable(),
  fantasia: z.string().max(60, 'Máximo de 60 caracteres.').optional().nullable(),

  endereco: z.object({
    cep: requiredString('CEP').regex(/^\d{5}-\d{3}$/, 'CEP inválido.'),
    logradouro: requiredString('Logradouro').max(120, 'Máximo de 120 caracteres.'),
    numero: z.string().max(10, 'Máximo de 10 caracteres.').optional().nullable(),
    semNumero: z.boolean().optional(),
    complemento: z.string().max(60, 'Máximo de 60 caracteres.').optional().nullable(),
    bairro: requiredString('Bairro').max(60, 'Máximo de 60 caracteres.'),
    cidade: requiredString('Cidade').max(60, 'Máximo de 60 caracteres.'),
    uf: requiredString('UF'),
  }).refine(data => data.semNumero || (data.numero && data.numero.trim() !== ''), {
    message: "Número é obrigatório se 'S/N' não estiver marcado.",
    path: ['numero'],
  }),

  contato: z.object({
    fone: z.string().optional().nullable(),
    fax: z.string().optional().nullable(),
    celular: z.string().optional().nullable(),
    email: z.string().email('E-mail inválido.').optional().nullable(),
    website: z.string().url('URL inválida.').or(z.literal('')).optional().nullable(),
  }),

  regime: z.object({
    segmento: z.string().optional().nullable(),
    tipoPessoa: z.enum(['PJ', 'PF', 'Estrangeiro']),
    cnpj: z.string().optional().nullable(),
    ie: z.string().optional().nullable(),
    ieIsento: z.boolean().optional(),
    im: z.string().optional().nullable(),
    cnae: z.string().optional().nullable(),
    crt: z.string().optional().nullable(),
    cpf: z.string().optional().nullable(),
  }).superRefine((data, ctx) => {
    if (data.tipoPessoa === 'PJ' && (!data.cnpj || data.cnpj.replace(/\D/g, '').length !== 14)) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'CNPJ inválido.', path: ['cnpj'] });
    }
    if (data.tipoPessoa === 'PF' && (!data.cpf || data.cpf.replace(/\D/g, '').length !== 11)) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'CPF inválido.', path: ['cpf'] });
    }
  }),

  substitutosTributarios: z.array(ieSchema).optional(),

  preferenciasContato: z.object({
    comoChamar: z.string().max(60, 'Máximo de 60 caracteres.').optional().nullable(),
    canais: z.string().optional().nullable(),
  }),

  administrador: z.object({
    nome: z.string().max(120, 'Máximo de 120 caracteres.').optional().nullable(),
    email: z.string().email('E-mail inválido.').optional().nullable(),
    celular: z.string().optional().nullable(),
  }),

  logoUrl: z.string().optional().nullable(),
});

export type DadosEmpresaFormData = z.infer<typeof dadosEmpresaSchema>;
