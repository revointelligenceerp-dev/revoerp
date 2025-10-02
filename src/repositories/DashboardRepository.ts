import { supabase } from '../lib/supabaseClient';
import { PostgrestError } from '@supabase/supabase-js';
import { snakeToCamel } from '../lib/utils';
import { DashboardStats, FaturamentoMensal } from '../types';
import { IDashboardRepository } from './interfaces';

export class DashboardRepository implements IDashboardRepository {
  protected supabase = supabase;

  protected handleError(error: PostgrestError | null, context?: string): void {
    if (error) {
      console.error(`Error in DashboardRepository${context ? ` (${context})` : ''}:`, error);
      throw new Error(error.message);
    }
  }

  async getDashboardStats(): Promise<DashboardStats> {
    const { data, error } = await this.supabase.rpc('get_dashboard_stats');
    this.handleError(error, 'getDashboardStats');
    if (!data || data.length === 0) {
      // Retorna um objeto zerado se não houver dados
      return {
        faturamentoTotalMesAtual: 0,
        faturamentoTotalMesAnterior: 0,
        novosClientesMesAtual: 0,
        novosClientesMesAnterior: 0,
        pedidosRealizadosMesAtual: 0,
        pedidosRealizadosMesAnterior: 0,
      };
    }
    return snakeToCamel(data[0]) as DashboardStats;
  }

  async getFaturamentoMensal(): Promise<FaturamentoMensal[]> {
    const { data, error } = await this.supabase.rpc('get_faturamento_ultimos_12_meses');
    this.handleError(error, 'getFaturamentoMensal');
    return (snakeToCamel(data) as FaturamentoMensal[]) || [];
  }
}
