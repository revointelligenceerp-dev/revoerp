import { IConfiguracoesService } from './interfaces';
import { IConfiguracoesRepository } from '../repositories/interfaces';

export class ConfiguracoesService implements IConfiguracoesService {
  public repository: IConfiguracoesRepository;

  constructor(repository: IConfiguracoesRepository) {
    this.repository = repository;
  }

  async getSettings(): Promise<Record<string, any>> {
    const settingsArray = await this.repository.getAllSettings();
    const settingsObject = settingsArray.reduce((acc, setting) => {
      acc[setting.chave] = setting.valor;
      return acc;
    }, {} as Record<string, any>);
    return settingsObject;
  }

  async saveSettings(settings: Record<string, any>): Promise<void> {
    const settingsArray = Object.entries(settings).map(([chave, valor]) => ({
      chave,
      valor,
    }));
    await this.repository.saveSettings(settingsArray);
  }
}
