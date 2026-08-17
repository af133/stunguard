import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { ShieldCheck, User, Lock, ArrowRight, CheckCircle2, Loader2, MapPin } from 'lucide-react';
import { type UserRole } from './AuthContext';
import API_URL from '../../config/api';

interface Posyandu {
  ID: string | number;
  Nama: string;
  WilayahKerja: string;
}

const RegisterPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<UserRole>('petugas_puskesmas');
  const [posyanduList, setPosyanduList] = useState<Posyandu[]>([]);
  const [selectedPosyanduId, setSelectedPosyanduId] = useState('');
  
  const [isLoading, setIsLoading] = useState(false);
  const [isFetchingPosyandu, setIsFetchingPosyandu] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const navigate = useNavigate();
  useEffect(() => {
    const fetchPosyandu = async () => {
      setIsFetchingPosyandu(true);
      try {
        const response = await fetch(`${API_URL}/v1/posyandu/get-all`);
        const result = await response.json();

        if (!response.ok) {
          throw new Error(result.message || 'Gagal memuat data posyandu');
        }

        if (result.success && Array.isArray(result.data)) {
          setPosyanduList(result.data);
          if (result.data.length > 0) {
            setSelectedPosyanduId(String(result.data[0].ID));
          }
        }
      } catch (error: unknown) {
        console.error('Gagal mengambil posyandu:', error instanceof Error ? error.message : String(error));
      } finally {
        setIsFetchingPosyandu(false);
      }
    };

    fetchPosyandu();
  }, []);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    try {
      const response = await fetch(`${API_URL}/auth/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          role,
          email,
          password,
          wilayah_kerja_id: Number(selectedPosyanduId), 
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || data.message || 'Gagal melakukan pendaftaran. Silakan coba lagi.');
      }

      setSuccessMessage('Pendaftaran berhasil! Mengarahkan ke halaman login...');
      setTimeout(() => {
        navigate('/');
      }, 2000);
      
    } catch (error: unknown) {
      setErrorMessage(error instanceof Error ? error.message : 'Terjadi kesalahan pada jaringan.');
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
              Bergabung dengan Platform Deteksi Dini Stunting
            </h1>
            <p className="text-green-100 text-sm leading-relaxed">
              Daftarkan akun Anda untuk mulai mengelola dan memantau data gizi balita secara terintegrasi.
            </p>
          </div>
          <div className="relative z-10 space-y-3 pt-8 border-t border-green-700/60">
            <div className="flex items-center gap-2.5 text-xs text-green-100 font-medium">
              <CheckCircle2 size={16} className="text-green-300" />
              Akses Dasbor Real-time
            </div>
            <div className="flex items-center gap-2.5 text-xs text-green-100 font-medium">
              <CheckCircle2 size={16} className="text-green-300" />
              Pencatatan Data Sesuai Standar Kemenkes
            </div>
          </div>
        </div>
        <div className="p-10 flex flex-col justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800 mb-1">Buat Akun Baru</h2>
            <p className="text-xs text-gray-400 mb-6">
              Lengkapi informasi di bawah ini untuk mendaftar
            </p>

            {/* Error Notification Alert */}
            {errorMessage && (
              <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-600 text-xs rounded-xl">
                {errorMessage}
              </div>
            )}

            {/* Success Notification Alert */}
            {successMessage && (
              <div className="mb-4 p-3 bg-green-50 border border-green-200 text-green-700 text-xs rounded-xl">
                {successMessage}
              </div>
            )}

            <form onSubmit={handleRegister} className="space-y-4">
              {/* Role Selector Tabs */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-2 block">
                  Pilih Role Akses
                </label>
                <div className="grid grid-cols-2 gap-2 p-1 bg-gray-100 rounded-xl">
                  <button
                    type="button"
                    onClick={() => setRole('petugas_puskesmas')}
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
                    onClick={() => setRole('admin_dinkes')}
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

              {/* Dropdown Posyandu */}
              <div>
                <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-1.5 block">
                  Pilih Posyandu
                </label>
                <div className="relative">
                  <MapPin size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 z-10" />
                  <select
                    value={selectedPosyanduId}
                    onChange={(e) => setSelectedPosyanduId(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition appearance-none cursor-pointer"
                    required
                  >
                    {isFetchingPosyandu ? (
                      <option value="">Memuat data posyandu...</option>
                    ) : posyanduList.length === 0 ? (
                      <option value="">Tidak ada posyandu tersedia</option>
                    ) : (
                      posyanduList.map((posyandu) => (
                        <option key={posyandu.ID} value={posyandu.ID}>
                          {posyandu.Nama} ({posyandu.WilayahKerja})
                        </option>
                      ))
                    )}
                  </select>
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
                    placeholder="nama@email.com"
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
                    placeholder="••••••••"
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full bg-green-800 text-white py-3 rounded-xl text-sm font-semibold hover:bg-green-900 transition flex items-center justify-center gap-2 shadow-md shadow-green-800/20 disabled:opacity-50 mt-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    Memproses...
                  </>
                ) : (
                  <>
                    Daftar Akun
                    <ArrowRight size={16} />
                  </>
                )}
              </button>
            </form>

            <div className="text-center mt-4">
              <p className="text-xs text-gray-500">
                Sudah punya akun?{' '}
                <Link to="/" className="text-green-800 font-semibold hover:underline">
                  Masuk di sini
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

export default RegisterPage;