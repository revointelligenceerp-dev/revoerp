import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { supabase } from '../lib/supabaseClient';
import toast from 'react-hot-toast';
import { GlassInput } from '../components/ui/GlassInput';
import { GlassButton } from '../components/ui/GlassButton';
import { LogIn, Loader2 } from 'lucide-react';
import { Logo } from '../components/ui/Logo';
import { IMaskInput } from 'react-imask';

export const SignUp: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [cpf, setCpf] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          cpf_cnpj: cpf,
        },
      },
    });

    if (error) {
      toast.error(error.message);
    } else {
      toast.success('Cadastro realizado! Verifique seu e-mail para confirmação.');
      navigate('/login');
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
          <h2 className="text-2xl font-bold text-center text-gray-800 mb-2">Crie sua Conta</h2>
          <p className="text-center text-gray-600 mb-8">Comece a gerenciar sua empresa em minutos.</p>
          
          <form onSubmit={handleSignUp} className="space-y-4">
            <GlassInput
              type="text"
              placeholder="Seu nome completo"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              required
            />
            <IMaskInput
              mask="000.000.000-00"
              placeholder="Seu CPF"
              value={cpf}
              onAccept={(value) => setCpf(value as string)}
              className="glass-input"
              required
            />
            <GlassInput
              type="email"
              placeholder="Seu melhor e-mail"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <GlassInput
              type="password"
              placeholder="Crie uma senha forte (mín. 6 caracteres)"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
            />
            <GlassButton type="submit" disabled={loading} className="w-full">
              {loading ? <Loader2 className="animate-spin" /> : <LogIn />}
              {loading ? 'Criando conta...' : 'Criar conta'}
            </GlassButton>
          </form>

          <p className="text-center text-sm text-gray-600 mt-6">
            Já tem uma conta?{' '}
            <Link to="/login" className="font-medium text-blue-600 hover:underline">
              Faça login
            </Link>
          </p>
        </div>
      </motion.div>
    </div>
  );
};
