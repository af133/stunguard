import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { ShieldCheck, User, Lock, ArrowRight, CheckCircle2, Loader2 } from 'lucide-react';
import { useAuth, type UserRole } from './AuthContext';
import API_URL from '../../config/api';

const LoginPage = () => {
  const [email, setEmail] = useState('petugas.caringin@stunguard.com');
  const [password, setPassword] = useState('password123');
  const [role, setRole] = useState<UserRole>('petugas_puskesmas');
  
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const { login } = useAuth();
  const navigate = useNavigate();

 const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage('');
    try {
      const response = await fetch(`${API_URL}/auth/login/petugas`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role, email, password }),
      });
      const result = await response.json();
      console.log("Respon Login Backend:", result);
      
      if (!response.ok || !result.success) {
        const errMsg = result.error?.message || result.error || result.message || 'Username atau password salah';
        throw new Error(typeof errMsg === 'string' ? errMsg : 'Username atau password salah');
      }
      
      if (result.data && result.data.token) {
        localStorage.setItem('token', result.data.token);
        localStorage.setItem('user', JSON.stringify(result.data.user)); 
      } else {
        throw new Error('Token tidak ditemukan dari server');
      }
      login(role);
      navigate('/dashboard');
    } catch (error: any) {
      setErrorMessage(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div className="w-full max-w-[960px] bg-white rounded-3xl shadow-xl border border-gray-100 overflow-hidden grid grid-cols-2">
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
            <p className="text-xs text-gray-400 mb-6">
              Masukkan kredensial akun Anda untuk mengakses dashboard
            </p>

            {/* Error Notification Alert */}
            {errorMessage && (
              <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-600 text-xs rounded-xl">
                {errorMessage}
              </div>
            )}

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
                      setEmail('petugas.caringin@stunguard.com');
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
                      setEmail('admin.dinkes@stunguard.com');
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

              {/* Email Input */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-1.5 block">
                  Email
                </label>
                <div className="relative">
                  <User size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
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
                disabled={isLoading}
                className="w-full bg-green-800 text-white py-3 rounded-xl text-sm font-semibold hover:bg-green-900 transition flex items-center justify-center gap-2 shadow-md shadow-green-800/20 disabled:opacity-50"
              >
                {isLoading ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    Memproses...
                  </>
                ) : (
                  <>
                    Masuk ke Dashboard
                    <ArrowRight size={16} />
                  </>
                )}
              </button>
            </form>

            {/* Tombol ke Register */}
            <div className="text-center mt-4">
              <p className="text-xs text-gray-500">
                Belum punya akun?{' '}
                <Link to="/register" className="text-green-800 font-semibold hover:underline">
                  Daftar di sini
                </Link>
              </p>
            </div>
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