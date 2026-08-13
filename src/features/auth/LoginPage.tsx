import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldCheck, User, Lock, ArrowRight, CheckCircle2 } from 'lucide-react';
import { useAuth, type UserRole } from './AuthContext';

const LoginPage = () => {
  const [username, setUsername] = useState('petugas.caringin');
  const [password, setPassword] = useState('••••••••');
  const [role, setRole] = useState<UserRole>('petugas_puskesmas');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login(role);
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div className="w-full max-w-[960px] bg-white rounded-3xl shadow-xl border border-gray-100 overflow-hidden grid grid-cols-2">
        {/* Left Branding Side */}
        <div className="bg-green-800 p-10 text-white flex flex-col justify-between relative overflow-hidden">
          <div className="absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 bg-green-700 rounded-full opacity-40 blur-2xl" />
          <div className="relative z-10">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center">
                <ShieldCheck size={24} className="text-green-800" />
              </div>
              <span className="text-2xl font-bold tracking-tight">StuntGuard</span>
            </div>
            <h1 className="text-3xl font-bold leading-tight mb-4">
              Platform Deteksi Dini & Monitoring Stunting
            </h1>
            <p className="text-green-100 text-sm leading-relaxed">
              Sistem terintegrasi untuk Petugas Puskesmas dan Dinas Kesehatan Kabupaten/Kota dalam memantau gizi balita real-time.
            </p>
          </div>

          <div className="relative z-10 space-y-3 pt-8 border-t border-green-700/60">
            <div className="flex items-center gap-2.5 text-xs text-green-100 font-medium">
              <CheckCircle2 size={16} className="text-green-300" />
              Analisis Prediksi AI Multimodal
            </div>
            <div className="flex items-center gap-2.5 text-xs text-green-100 font-medium">
              <CheckCircle2 size={16} className="text-green-300" />
              Heatmap Persebaran Risiko Interaktif
            </div>
            <div className="flex items-center gap-2.5 text-xs text-green-100 font-medium">
              <CheckCircle2 size={16} className="text-green-300" />
              Pelaporan Standar Format Kemenkes
            </div>
          </div>
        </div>

        {/* Right Form Side */}
        <div className="p-10 flex flex-col justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800 mb-1">Selamat Datang</h2>
            <p className="text-xs text-gray-400 mb-8">
              Masukkkan kredensial akun Anda untuk mengakses dashboard
            </p>

            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Role Selector Tabs */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-2 block">
                  Pilih Role Akses Demo
                </label>
                <div className="grid grid-cols-2 gap-2 p-1 bg-gray-100 rounded-xl">
                  <button
                    type="button"
                    onClick={() => {
                      setRole('petugas_puskesmas');
                      setUsername('petugas.caringin');
                    }}
                    className={`py-2 px-3 rounded-lg text-xs font-semibold transition ${
                      role === 'petugas_puskesmas'
                        ? 'bg-white text-green-800 shadow-sm'
                        : 'text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    Petugas Puskesmas
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setRole('admin_dinkes');
                      setUsername('admin.dinkes');
                    }}
                    className={`py-2 px-3 rounded-lg text-xs font-semibold transition ${
                      role === 'admin_dinkes'
                        ? 'bg-white text-green-800 shadow-sm'
                        : 'text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    Admin Dinkes
                  </button>
                </div>
              </div>

              {/* Username Input */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-1.5 block">
                  Username / Email
                </label>
                <div className="relative">
                  <User size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    type="text"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                    required
                  />
                </div>
              </div>

              {/* Password Input */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-1.5 block">
                  Kata Sandi
                </label>
                <div className="relative">
                  <Lock size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                className="w-full bg-green-800 text-white py-3 rounded-xl text-sm font-semibold hover:bg-green-900 transition flex items-center justify-center gap-2 shadow-md shadow-green-800/20"
              >
                Masuk ke Dashboard
                <ArrowRight size={16} />
              </button>
            </form>
          </div>

          <p className="text-center text-xs text-gray-400 mt-6">
            &copy; 2026 StuntGuard. Kementerian Kesehatan RI.
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
