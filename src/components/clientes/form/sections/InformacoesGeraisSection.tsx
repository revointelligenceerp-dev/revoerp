import React from 'react';
import { Control, Controller, UseFormWatch } from 'react-hook-form';
import { IMaskInput } from 'react-imask';
import { TipoPessoa, ContribuinteICMS } from '../../../../types';
import { GlassInput } from '../../../ui/GlassInput';
import { InputWrapper } from '../../../ui/InputWrapper';
import { ClienteFormData } from '../../../../schemas/clienteSchema';

interface InformacoesGeraisSectionProps {
  control: Control<ClienteFormData>;
  watch: UseFormWatch<ClienteFormData>;
}

export const InformacoesGeraisSection: React.FC<InformacoesGeraisSectionProps> = ({ control, watch }) => {
  const tipoPessoa = watch('tipoPessoa');

  return (
    <section>
      <h3 className="text-lg font-semibold text-gray-800 mb-4 border-b border-white/30 pb-2">Informações Gerais</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Controller
          name="tipoPessoa"
          control={control}
          render={({ field }) => (
            <InputWrapper label="Tipo de Pessoa *">
              <select className="glass-input" {...field}>
                {Object.values(TipoPessoa).map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </InputWrapper>
          )}
        />
        {tipoPessoa === TipoPessoa.FISICA ? (
          <>
            <Controller name="cpfCnpj" control={control} render={({ field, fieldState }) => (
              <InputWrapper label="CPF *" error={fieldState.error?.message}>
                <IMaskInput mask="000.000.000-00" value={field.value || ''} onAccept={field.onChange} className="glass-input" />
              </InputWrapper>
            )} />
            <Controller name="rg" control={control} render={({ field }) => (
              <InputWrapper label="RG">
                <GlassInput {...field} value={field.value || ''} maxLength={20} />
              </InputWrapper>
            )} />
            <Controller name="nome" control={control} render={({ field, fieldState }) => (
              <InputWrapper label="Nome *" error={fieldState.error?.message}>
                <GlassInput {...field} value={field.value || ''} maxLength={120} />
              </InputWrapper>
            )} />
          </>
        ) : (
          <>
            <Controller name="cpfCnpj" control={control} render={({ field, fieldState }) => (
              <InputWrapper label="CNPJ *" error={fieldState.error?.message}>
                <IMaskInput mask="00.000.000/0000-00" value={field.value || ''} onAccept={field.onChange} className="glass-input" />
              </InputWrapper>
            )} />
            <Controller name="inscricaoEstadual" control={control} render={({ field }) => (
              <InputWrapper label="Inscrição Estadual">
                <GlassInput {...field} value={field.value || ''} maxLength={20} />
              </InputWrapper>
            )} />
            <Controller name="nome" control={control} render={({ field, fieldState }) => (
              <InputWrapper label="Razão Social *" error={fieldState.error?.message}>
                <GlassInput {...field} value={field.value || ''} maxLength={120} />
              </InputWrapper>
            )} />
          </>
        )}
        <Controller name="codigo" control={control} render={({ field }) => (
          <InputWrapper label="Código">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
        <Controller name="contribuinteIcms" control={control} render={({ field }) => (
          <InputWrapper label="Contribuinte ICMS *">
            <select className="glass-input" {...field}>
              {Object.values(ContribuinteICMS).map(c => <option key={c} value={c}>{c}</option>)}
            </select>
          </InputWrapper>
        )} />
        <div className="lg:col-span-2">
          <InputWrapper label="Tipo de Contato">
            <div className="flex gap-4 items-center h-full">
              <Controller name="isCliente" control={control} render={({ field }) => (
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked={field.value} onChange={field.onChange} className="form-checkbox" /> Cliente
                </label>
              )} />
              <Controller name="isFornecedor" control={control} render={({ field }) => (
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked={field.value} onChange={field.onChange} className="form-checkbox" /> Fornecedor
                </label>
              )} />
              <Controller name="isTransportadora" control={control} render={({ field }) => (
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked={field.value} onChange={field.onChange} className="form-checkbox" /> Transportadora
                </label>
              )} />
            </div>
          </InputWrapper>
        </div>
      </div>
    </section>
  );
};
