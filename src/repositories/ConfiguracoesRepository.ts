import { BaseRepository } from './BaseRepository';
import { Configuracao } from '../types';
import { snakeToCamel } from '../lib/utils';

export class ConfiguracoesRepository extends BaseRepository<Configuracao> {
  constructor() {
    super('configuracoes');
  }

  protected createEntity(data: any): Configuracao {
    return data as Configuracao;
  }

  async getAllSettings(): Promise<Configuracao[]> {
    const { data, error } = await this.supabase
      .from(this.tableName)
      .select('*');
    
    this.handleError(error, 'getAllSettings');
    return snakeToCamel(data || []) as Configuracao[];
  }

  async saveSettings(settings: { chave: string; valor: any }[]): Promise<void> {
    const settingsToUpsert = settings.map(s => ({
      chave: s.chave,
      valor: s.valor,
    }));

    const { error } = await this.supabase
      .from(this.tableName)
      .upsert(settingsToUpsert, { onConflict: 'chave' });

    this.handleError(error, 'saveSettings');
  }
}
