import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { supabase } from '../lib/supabaseClient';
import toast from 'react-hot-toast';
import { GlassInput } from '../components/ui/GlassInput';
import { GlassButton } from '../components/ui/GlassButton';
import { LogIn, Loader2 } from 'lucide-react';
import { Logo } from '../components/ui/Logo';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      toast.error(error.message);
    } else {
      toast.success('Login realizado com sucesso!');
      navigate('/dashboard');
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md"
      >
        <div className="bg-glass-100 backdrop-blur-md border border-white/20 rounded-2xl shadow-glass-lg p-8">
          <div className="flex justify-center mb-6">
            <Logo />
          </div>
          <h2 className="text-2xl font-bold text-center text-gray-800 mb-2">Bem-vindo de volta!</h2>
          <p className="text-center text-gray-600 mb-8">Faça login para acessar seu painel.</p>
          
          <form onSubmit={handleLogin} className="space-y-6">
            <GlassInput
              type="email"
              placeholder="seu@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <GlassInput
              type="password"
              placeholder="Sua senha"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <GlassButton type="submit" disabled={loading} className="w-full">
              {loading ? <Loader2 className="animate-spin" /> : <LogIn />}
              {loading ? 'Entrando...' : 'Entrar'}
            </GlassButton>
          </form>

          <p className="text-center text-sm text-gray-600 mt-6">
            Não tem uma conta?{' '}
            <Link to="/signup" className="font-medium text-blue-600 hover:underline">
              Cadastre-se
            </Link>
          </p>
        </div>
      </motion.div>
    </div>
  );
};
