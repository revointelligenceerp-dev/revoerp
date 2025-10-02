import React, { useState } from 'react';
import { Control, Controller } from 'react-hook-form';
import { IMaskInput } from 'react-imask';
import { GlassInput } from '../../../ui/GlassInput';
import { InputWrapper } from '../../../ui/InputWrapper';
import { ClienteFormData } from '../../../../schemas/clienteSchema';

interface EnderecoSectionProps {
  control: Control<ClienteFormData>;
  onBuscaCep: (cep: string, isCobranca?: boolean) => void;
}

export const EnderecoSection: React.FC<EnderecoSectionProps> = ({ control, onBuscaCep }) => {
  const [possuiCobranca, setPossuiCobranca] = useState(false);

  return (
    <section>
      <h3 className="text-lg font-semibold text-gray-800 mb-4 border-b border-white/30 pb-2">Endereço</h3>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Controller name="cep" control={control} render={({ field }) => (
          <InputWrapper label="CEP *">
            <IMaskInput mask="00000-000" value={field.value || ''} onAccept={(v) => { field.onChange(v); if ((v as string).replace(/\D/g, '').length === 8) onBuscaCep(v as string); }} className="glass-input" />
          </InputWrapper>
        )} />
        <Controller name="cidade" control={control} render={({ field }) => (
          <InputWrapper label="Município" className="md:col-span-2">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
        <Controller name="estado" control={control} render={({ field }) => (
          <InputWrapper label="UF">
            <GlassInput {...field} value={field.value || ''} maxLength={2} />
          </InputWrapper>
        )} />
        <Controller name="logradouro" control={control} render={({ field }) => (
          <InputWrapper label="Endereço" className="md:col-span-3">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
        <Controller name="numero" control={control} render={({ field }) => (
          <InputWrapper label="Número">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
        <Controller name="bairro" control={control} render={({ field }) => (
          <InputWrapper label="Bairro" className="md:col-span-2">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
        <Controller name="complemento" control={control} render={({ field }) => (
          <InputWrapper label="Complemento">
            <GlassInput {...field} value={field.value || ''} />
          </InputWrapper>
        )} />
      </div>
      <div className="mt-4">
        <label className="flex items-center gap-2 cursor-pointer">
          <input type="checkbox" checked={possuiCobranca} onChange={(e) => setPossuiCobranca(e.target.checked)} className="form-checkbox" />
          Possui endereço de cobrança
        </label>
      </div>
      {possuiCobranca && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-4 p-4 border border-white/20 rounded-lg">
          <Controller name="cobrancaCep" control={control} render={({ field }) => (
            <InputWrapper label="CEP Cobrança">
              <IMaskInput mask="00000-000" value={field.value || ''} onAccept={(v) => { field.onChange(v); if ((v as string).replace(/\D/g, '').length === 8) onBuscaCep(v as string, true); }} className="glass-input" />
            </InputWrapper>
          )} />
          <Controller name="cobrancaCidade" control={control} render={({ field }) => (
            <InputWrapper label="Município Cobrança" className="md:col-span-2">
              <GlassInput {...field} value={field.value || ''} />
            </InputWrapper>
          )} />
          <Controller name="cobrancaEstado" control={control} render={({ field }) => (
            <InputWrapper label="UF Cobrança">
              <GlassInput {...field} value={field.value || ''} maxLength={2} />
            </InputWrapper>
          )} />
        </div>
      )}
    </section>
  );
};
