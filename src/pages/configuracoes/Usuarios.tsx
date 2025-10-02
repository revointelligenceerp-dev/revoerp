import React, { useState, useMemo } from 'react';
import { AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Plus, Edit2, Filter, Mail, KeyRound } from 'lucide-react';
import { GlassCard } from '../../components/ui/GlassCard';
import { GlassButton } from '../../components/ui/GlassButton';
import { GlassInput } from '../../components/ui/GlassInput';
import { Pagination } from '../../components/ui/Pagination';
import { DataTable } from '../../components/ui/DataTable';
import { useModalForm } from '../../hooks/useModalForm';
import { Vendedor, SituacaoVendedor } from '../../types';
import { useVendedores } from '../../hooks/data/useVendedores';
import { ConvidarUsuarioModal } from '../../components/settings/usuarios/ConvidarUsuarioModal';
import toast from 'react-hot-toast';

export const Usuarios: React.FC = () => {
  const { vendedores, loading, error, currentPage, totalPages, goToPage } = useVendedores();
  const { isFormOpen, handleOpenCreateForm, handleCloseForm } = useModalForm();
  const [filtro, setFiltro] = useState('');
  const navigate = useNavigate();

  const vendedoresFiltrados = vendedores.filter(vendedor =>
    vendedor.nome.toLowerCase().includes(filtro.toLowerCase()) ||
    (vendedor.email && vendedor.email.toLowerCase().includes(filtro.toLowerCase()))
  );

  const handleInvite = async (email: string) => {
    toast.promise(
      new Promise(resolve => setTimeout(resolve, 1500)),
      {
        loading: `Enviando convite para ${email}...`,
        success: `Convite enviado para ${email}! O usuário precisa se cadastrar para ter acesso.`,
        error: 'Falha ao enviar convite.',
      }
    );
    handleCloseForm();
  };

  const handleNovoUsuario = () => {
    navigate('/vendedores');
  };

  const handleEditPermissions = (vendedorId: string) => {
    navigate(`/configuracoes/usuarios/${vendedorId}/permissoes`);
  };

  const getStatusBadge = (status: SituacaoVendedor) => {
    const colors = {
      [SituacaoVendedor.ATIVO_COM_ACESSO]: 'bg-green-100 text-green-700 border-green-200',
      [SituacaoVendedor.ATIVO_SEM_ACESSO]: 'bg-blue-100 text-blue-700 border-blue-200',
      [SituacaoVendedor.INATIVO]: 'bg-red-100 text-red-700 border-red-200'
    };
    return <span className={`glass-badge ${colors[status]}`}>{status}</span>;
  };

  const columns = useMemo(() => [
    { header: 'Nome', accessorKey: 'nome', cell: (item: Vendedor) => <p className="font-medium text-gray-800">{item.nome}</p> },
    { header: 'Email', accessorKey: 'email' },
    { header: 'Situação', accessorKey: 'situacao', cell: (item: Vendedor) => getStatusBadge(item.situacao), className: 'text-center' },
  ], []);

  return (
    <>
      <GlassCard className="mb-6">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4 flex-1 min-w-[250px]">
            <GlassInput placeholder="Buscar por nome ou email..." value={filtro} onChange={(e) => setFiltro(e.target.value)} className="w-full max-w-md" />
            <GlassButton icon={Filter} variant="secondary">Filtros</GlassButton>
          </div>
          <div className="flex items-center gap-2">
            <GlassButton icon={Mail} onClick={handleOpenCreateForm}>Convidar Usuário</GlassButton>
            <GlassButton icon={Plus} onClick={handleNovoUsuario}>Novo Usuário</GlassButton>
          </div>
        </div>
      </GlassCard>

      <GlassCard>
        <DataTable
          data={vendedoresFiltrados}
          columns={columns}
          loading={loading && vendedores.length === 0}
          error={error}
          entityName="Usuário"
          actions={(item) => (
            <div className="flex items-center gap-2">
              <GlassButton icon={Edit2} variant="secondary" size="sm" onClick={() => navigate(`/vendedores?edit=${item.id}`)} title="Editar Dados do Vendedor" />
              <GlassButton icon={KeyRound} variant="secondary" size="sm" onClick={() => handleEditPermissions(item.id)} title="Editar Permissões" />
            </div>
          )}
        />
        <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={goToPage} />
      </GlassCard>

      <AnimatePresence>
        {isFormOpen && (
          <ConvidarUsuarioModal
            onInvite={handleInvite}
            onCancel={handleCloseForm}
          />
        )}
      </AnimatePresence>
    </>
  );
};

export default Usuarios;
