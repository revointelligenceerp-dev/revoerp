import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { PageLoader } from '../layout/PageLoader';

export const ProtectedRoute: React.FC = () => {
  const { session, loading } = useAuth();

  if (loading) {
    return <PageLoader />;
  }

  if (!session) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
};
