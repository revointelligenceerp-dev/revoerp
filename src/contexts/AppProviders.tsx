import React, { ReactNode } from 'react';
import { SidebarProvider } from './SidebarContext';
import { PdvProvider } from './PdvContext';
import { ConfiguracoesProvider } from './ConfiguracoesContext';
import { ServiceProvider } from './ServiceContext';
import { AuthProvider } from './AuthContext';

interface AppProvidersProps {
  children: ReactNode;
}

const providers = [
  AuthProvider,
  ServiceProvider,
  SidebarProvider,
  PdvProvider,
  ConfiguracoesProvider,
];

export const AppProviders: React.FC<AppProvidersProps> = ({ children }) => {
  return providers.reduceRight((acc, Provider) => {
    return <Provider>{acc}</Provider>;
  }, <>{children}</>);
};
