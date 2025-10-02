import React, { useState, useEffect, useCallback } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { GlassCard } from '../../components/ui/GlassCard';
import { GlassButton } from '../../components/ui/GlassButton';
import { useService } from '../../hooks/useService';
import { Loader2, Save } from 'lucide-react';
import toast from 'react-hot-toast';
import { DadosEmpresaSection } from '../../components/settings/dados-empresa/DadosEmpresaSection';
import { EnderecoSection } from '../../components/settings/dados-empresa/EnderecoSection';
import { ContatoSection } from '../../components/settings/dados-empresa/ContatoSection';
import { RegimeSection } from '../../components/settings/dados-empresa/RegimeSection';
import { InscricoesEstaduaisSection } from '../../components/settings/dados-empresa/InscricoesEstaduaisSection';
import { PreferenciasContatoSection } from '../../components/settings/dados-empresa/PreferenciasContatoSection';
import { AdministradorSection } from '../../components/settings/dados-empresa/AdministradorSection';
import { LogoSection } from '../../components/settings/dados-empresa/LogoSection';
import { dadosEmpresaSchema, DadosEmpresaFormData } from '../../schemas/dadosEmpresaSchema';

export const DadosEmpresa: React.FC = () => {
    const configuracoesService = useService('configuracoes');
    const [settings, setSettings] = useState<any>({});
    const [loadingContext, setLoadingContext] = useState(true);
    const [isSaving, setIsSaving] = useState(false);
    const [logoFile, setLogoFile] = useState<File | null>(null);

    const form = useForm<DadosEmpresaFormData>({
        resolver: zodResolver(dadosEmpresaSchema),
        defaultValues: {},
    });

    const { control, handleSubmit, reset, watch, setValue } = form;
    const logoPreview = watch('logoUrl');

    const loadData = useCallback(async () => {
        setLoadingContext(true);
        try {
            const data = await configuracoesService.getSettings();
            setSettings(data);
            reset(data.dados_empresa || {});
        } catch (error) {
            toast.error("Falha ao carregar configurações.");
        } finally {
            setLoadingContext(false);
        }
    }, [configuracoesService, reset]);

    useEffect(() => {
        loadData();
    }, [loadData]);

    const onSubmit = async (data: DadosEmpresaFormData) => {
        setIsSaving(true);
        const dataToSave = {
            ...settings,
            dados_empresa: {
                ...data,
                logoUrl: logoFile ? 'https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://placehold.co/256.png' : data.logoUrl,
            }
        };
        try {
            await configuracoesService.saveSettings(dataToSave);
            setSettings(dataToSave);
            toast.success('Configurações salvas com sucesso!');
        } catch (error) {
            toast.error("Falha ao salvar configurações.");
        } finally {
            setIsSaving(false);
        }
    };

    const handleCancel = () => {
        reset(settings.dados_empresa || {});
        setLogoFile(null);
        toast.success("Alterações descartadas.");
    };

    const onDrop = useCallback((acceptedFiles: File[]) => {
        const file = acceptedFiles[0];
        if (file) {
            if (file.size > 2 * 1024 * 1024) {
                toast.error("Arquivo inválido: Máx. 2 MB.");
                return;
            }
            if (!['image/png', 'image/jpeg', 'image/svg+xml'].includes(file.type)) {
                toast.error("Arquivo inválido: PNG/JPG/SVG permitidos.");
                return;
            }
            setLogoFile(file);
            const previewUrl = URL.createObjectURL(file);
            setValue('logoUrl', previewUrl, { shouldValidate: true });
        }
    }, [setValue]);

    const removeLogo = () => {
        setLogoFile(null);
        setValue('logoUrl', null, { shouldValidate: true });
    };

    if (loadingContext) {
        return <div className="flex items-center justify-center h-full w-full"><Loader2 className="animate-spin text-blue-500" size={48} /></div>;
    }

    return (
        <GlassCard>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-12">
                <DadosEmpresaSection control={control} />
                <EnderecoSection control={control} />
                <ContatoSection control={control} />
                <RegimeSection control={control} watch={watch} />
                <InscricoesEstaduaisSection control={control} />
                <PreferenciasContatoSection control={control} />
                <AdministradorSection control={control} />
                <LogoSection logoPreview={logoPreview} onDrop={onDrop} onRemove={removeLogo} />

                <div className="flex justify-end mt-8 pt-6 border-t border-white/30 gap-4">
                    <GlassButton type="button" variant="secondary" onClick={handleCancel} disabled={isSaving}>Cancelar</GlassButton>
                    <GlassButton type="submit" disabled={isSaving || loadingContext}>
                        {isSaving ? <Loader2 className="animate-spin" /> : <Save />}
                        {isSaving ? 'Salvando...' : 'Salvar'}
                    </GlassButton>
                </div>
            </form>
        </GlassCard>
    );
};

export default DadosEmpresa;
