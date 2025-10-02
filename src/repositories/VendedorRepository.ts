import { BaseRepository } from './BaseRepository';
import { Vendedor } from '../types';
import { snakeToCamel } from '../lib/utils';
import { IVendedorRepository } from './interfaces';

export class VendedorRepository extends BaseRepository<Vendedor> implements IVendedorRepository {
  constructor() {
    super('vendedores');
  }

  protected createEntity(data: Omit<Vendedor, 'id' | 'createdAt' | 'updatedAt'>): Vendedor {
    return {
      ...data,
      id: '',
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  async findAll(options: { page?: number; pageSize?: number } = {}): Promise<{ data: Vendedor[]; count: number }> {
    const selectString = 'id, user_id, nome, cpf_cnpj, email, situacao';
    return super.findAll(options, selectString);
  }

  async search(query: string): Promise<Pick<Vendedor, 'id' | 'nome'>[]> {
    const { data, error } = await this.supabase
      .from(this.tableName)
      .select('id, nome')
      .ilike('nome', `%${query}%`)
      .limit(10);

    this.handleError(error, 'search');
    return snakeToCamel(data || []) as Pick<Vendedor, 'id' | 'nome'>[];
  }

  async getPermissions(userId: string): Promise<string[]> {
    const { data, error } = await this.supabase
      .from('user_permissions')
      .select('permission')
      .eq('user_id', userId);
    this.handleError(error, 'getPermissions');
    return data ? data.map(p => p.permission) : [];
  }

  async setPermissions(userId: string, permissions: string[]): Promise<void> {
    const { error: deleteError } = await this.supabase
      .from('user_permissions')
      .delete()
      .eq('user_id', userId);
    this.handleError(deleteError, 'setPermissions (delete)');

    if (permissions.length > 0) {
      const permissionsToInsert = permissions.map(p => ({
        user_id: userId,
        permission: p,
      }));
      const { error: insertError } = await this.supabase
        .from('user_permissions')
        .insert(permissionsToInsert);
      this.handleError(insertError, 'setPermissions (insert)');
    }
  }
}
