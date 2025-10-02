import React, { createContext, useState, useCallback, useContext, ReactNode } from 'react';
import { useService } from '../hooks/useService';
import toast from 'react-hot-toast';

export interface SettingsData {
  empresa?: {
    nome: string;
    cnpj: string;
    endereco: string;
  };
  financeiro?: {
    moedaPadrao: string;
  };
  [key: string]: any;
}

interface ConfiguracoesContextType {
  settings: SettingsData;
  loading: boolean;
  error: string | null;
  loadSettings: () => Promise<void>;
  saveSettings: (newSettings: SettingsData) => Promise<void>;
}

const ConfiguracoesContext = createContext<ConfiguracoesContextType | undefined>(undefined);

export const ConfiguracoesProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [settings, setSettings] = useState<SettingsData>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const service = useService('configuracoes');

  const loadSettings = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await service.getSettings();
      setSettings(data);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar configurações';
      setError(errorMessage);
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }, [service]);

  const saveSettings = async (newSettings: SettingsData) => {
    const promise = service.saveSettings(newSettings);
    toast.promise(promise, {
      loading: 'Salvando configurações...',
      success: () => {
        setSettings(newSettings);
        return 'Configurações salvas com sucesso!';
      },
      error: (err) => `Falha ao salvar: ${err.message}`,
    });
    await promise;
  };

  React.useEffect(() => {
    loadSettings();
  }, [loadSettings]);

  const value = {
    settings,
    loading,
    error,
    loadSettings,
    saveSettings,
  };

  return (
    <ConfiguracoesContext.Provider value={value}>
      {children}
    </ConfiguracoesContext.Provider>
  );
};

export const useConfiguracoes = () => {
  const context = useContext(ConfiguracoesContext);
  if (context === undefined) {
    throw new Error('useConfiguracoes must be used within a ConfiguracoesProvider');
  }
  return context;
};
