import { useState } from 'react';
import { User, Building, Bell, Check, Save } from 'lucide-react';
import Layout from '../../shared/components/Layout';
import { useAuth } from '../auth/AuthContext';

const PengaturanPage = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'profil' | 'instansi' | 'notifikasi'>('profil');
  const [isSaved, setIsSaved] = useState(false);

  // Form State
  const [nama, setNama] = useState(user?.nama || 'Dr. Siti Aminah');
  const [email, setEmail] = useState('siti.aminah@kemenkes.go.id');
  const [noHp, setNoHp] = useState('081234567890');
  const [namaInstansi, setNamaInstansi] = useState(user?.wilayah || 'Puskesmas Caringin');

  // Preferences
  const [emailAlert, setEmailAlert] = useState(true);
  const [pushAlert, setPushAlert] = useState(true);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 3000);
  };

  return (
    <Layout>
      <div className="max-w-[1000px] mx-auto space-y-6">
        {/* Header */}
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Pengaturan Sistem & Profil</h2>
          <p className="text-sm text-gray-500 mt-0.5">
            Pengelolaan identitas akun, data instansi kesehatan, dan preferensi notifikasi
          </p>
        </div>

        {/* Saved Alert Toast */}
        {isSaved && (
          <div className="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-xl flex items-center gap-2 text-xs font-semibold animate-in fade-in duration-200">
            <Check size={16} className="text-green-600" />
            Pengaturan berhasil diperbarui dan disimpan.
          </div>
        )}

        {/* Tab Switcher */}
        <div className="flex bg-white p-1.5 rounded-2xl border border-gray-200 shadow-sm gap-2">
          <button
            onClick={() => setActiveTab('profil')}
            className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-semibold transition ${
              activeTab === 'profil' ? 'bg-green-800 text-white shadow-sm' : 'text-gray-600 hover:text-gray-800'
            }`}
          >
            <User size={16} />
            Profil Pengguna
          </button>
          <button
            onClick={() => setActiveTab('instansi')}
            className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-semibold transition ${
              activeTab === 'instansi' ? 'bg-green-800 text-white shadow-sm' : 'text-gray-600 hover:text-gray-800'
            }`}
          >
            <Building size={16} />
            Data Instansi
          </button>
          <button
            onClick={() => setActiveTab('notifikasi')}
            className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-semibold transition ${
              activeTab === 'notifikasi' ? 'bg-green-800 text-white shadow-sm' : 'text-gray-600 hover:text-gray-800'
            }`}
          >
            <Bell size={16} />
            Preferensi Notifikasi
          </button>
        </div>

        {/* Content Box */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-8">
          <form onSubmit={handleSave} className="space-y-6">
            {activeTab === 'profil' && (
              <div className="space-y-5">
                <div className="flex items-center gap-4 pb-5 border-b border-gray-100">
                  <div className="w-16 h-16 rounded-full bg-green-800 text-white flex items-center justify-center text-xl font-bold">
                    {user?.avatar || 'SA'}
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-gray-800">{user?.nama}</h3>
                    <p className="text-xs text-gray-400 font-medium uppercase tracking-wider mt-0.5">
                      Role: {user?.role === 'admin_dinkes' ? 'Admin Dinas Kesehatan' : 'Petugas Puskesmas'}
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Nama Lengkap</label>
                    <input
                      type="text"
                      value={nama}
                      onChange={(e) => setNama(e.target.value)}
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                      required
                    />
                  </div>
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Email Resmi</label>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                      required
                    />
                  </div>
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">No. Telepon / WA</label>
                    <input
                      type="text"
                      value={noHp}
                      onChange={(e) => setNoHp(e.target.value)}
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Wilayah Tugas</label>
                    <input
                      type="text"
                      value={user?.wilayah}
                      readOnly
                      className="w-full px-4 py-2.5 bg-gray-100 border border-gray-200 rounded-xl text-sm text-gray-500 cursor-not-allowed"
                    />
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'instansi' && (
              <div className="space-y-5">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Nama Puskesmas / Dinas</label>
                    <input
                      type="text"
                      value={namaInstansi}
                      onChange={(e) => setNamaInstansi(e.target.value)}
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Kode Faskes Kemenkes</label>
                    <input
                      type="text"
                      defaultValue="PKM-3201-089"
                      readOnly
                      className="w-full px-4 py-2.5 bg-gray-100 border border-gray-200 rounded-xl text-sm text-gray-500 font-mono"
                    />
                  </div>
                  <div className="col-span-2">
                    <label className="text-xs font-semibold text-gray-500 mb-1.5 block">Alamat Kantor Faskes</label>
                    <input
                      type="text"
                      defaultValue="Jl. Raya Caringin No. 100, Kab. Bogor, Jawa Barat"
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                    />
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'notifikasi' && (
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                  <div>
                    <h4 className="text-sm font-bold text-gray-800">Email Notifikasi Kasus Risiko Tinggi</h4>
                    <p className="text-xs text-gray-400">Kirim email otomatis saat balita baru terdeteksi stunting berat</p>
                  </div>
                  <input
                    type="checkbox"
                    checked={emailAlert}
                    onChange={(e) => setEmailAlert(e.target.checked)}
                    className="w-5 h-5 accent-green-800 rounded cursor-pointer"
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                  <div>
                    <h4 className="text-sm font-bold text-gray-800">Notifikasi Pop-up Real-time</h4>
                    <p className="text-xs text-gray-400">Tampilkan lonceng merah di header saat server mendeteksi perubahan data</p>
                  </div>
                  <input
                    type="checkbox"
                    checked={pushAlert}
                    onChange={(e) => setPushAlert(e.target.checked)}
                    className="w-5 h-5 accent-green-800 rounded cursor-pointer"
                  />
                </div>
              </div>
            )}

            <div className="pt-4 border-t border-gray-100 flex items-center justify-end">
              <button
                type="submit"
                className="flex items-center gap-2 px-6 py-2.5 bg-green-800 text-white text-xs font-semibold rounded-xl hover:bg-green-900 transition shadow-sm"
              >
                <Save size={16} />
                Simpan Perubahan
              </button>
            </div>
          </form>
        </div>
      </div>
    </Layout>
  );
};

export default PengaturanPage;
