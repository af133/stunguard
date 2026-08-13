import { useState } from 'react';
import {
  Building2, Users, Search, Plus, Trash2, Edit3, MapPin, Phone, CheckCircle,
} from 'lucide-react';
import Layout from '../../shared/components/Layout';
import { useAuth } from '../auth/AuthContext';
import { listPosyandu, listKader, type PosyanduData, type KaderData } from '../../shared/data/mockData';

const PosyanduPage = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'posyandu' | 'kader'>('posyandu');
  const [search, setSearch] = useState('');
  const [posyanduList, setPosyanduList] = useState<PosyanduData[]>(listPosyandu);
  const [kaderList] = useState<KaderData[]>(listKader);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newNama, setNewNama] = useState('');
  const [newAlamat, setNewAlamat] = useState('');
  const [newKelurahan, setNewKelurahan] = useState('Mekar Jaya');

  const isAdmin = user?.role === 'admin_dinkes';

  const handleDeletePosyandu = (id: string) => {
    if (!isAdmin) {
      alert('Akses Ditolak: Hanya Admin Dinas Kesehatan yang dapat menghapus data Posyandu.');
      return;
    }
    if (confirm('Apakah Anda yakin ingin menghapus data Posyandu ini?')) {
      setPosyanduList((prev) => prev.filter((p) => p.id !== id));
    }
  };

  const handleAddPosyandu = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newNama) return;
    const newPos: PosyanduData = {
      id: `P${Date.now()}`,
      nama: newNama,
      alamat: newAlamat || 'Jl. Raya No. 1',
      kelurahan: newKelurahan,
      kecamatan: 'Caringin',
      jumlahBalita: 0,
      jumlahKader: 1,
      status: 'Aktif',
    };
    setPosyanduList((prev) => [newPos, ...prev]);
    setIsModalOpen(false);
    setNewNama('');
    setNewAlamat('');
  };

  const filteredPosyandu = posyanduList.filter((p) =>
    p.nama.toLowerCase().includes(search.toLowerCase()) ||
    p.kelurahan.toLowerCase().includes(search.toLowerCase())
  );

  const filteredKader = kaderList.filter((k) =>
    k.nama.toLowerCase().includes(search.toLowerCase()) ||
    k.posyandu.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Manajemen Posyandu & Kader</h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Pengelolaan unit posyandu dan kader kesehatan pembina stunting di wilayah kerja
            </p>
          </div>

          <button
            onClick={() => setIsModalOpen(true)}
            className="flex items-center gap-2 px-5 py-2.5 bg-green-800 text-white rounded-xl text-sm font-semibold hover:bg-green-900 transition shadow-sm"
          >
            <Plus size={16} />
            {activeTab === 'posyandu' ? 'Tambah Posyandu' : 'Tambah Kader'}
          </button>
        </div>

        {/* Tab Switcher & Search Bar */}
        <div className="flex items-center justify-between gap-4">
          <div className="flex bg-white p-1 rounded-xl border border-gray-200 shadow-sm">
            <button
              onClick={() => setActiveTab('posyandu')}
              className={`flex items-center gap-2 px-5 py-2 rounded-lg text-xs font-semibold transition ${
                activeTab === 'posyandu'
                  ? 'bg-green-800 text-white shadow-sm'
                  : 'text-gray-600 hover:text-gray-800'
              }`}
            >
              <Building2 size={16} />
              Daftar Posyandu ({posyanduList.length})
            </button>
            <button
              onClick={() => setActiveTab('kader')}
              className={`flex items-center gap-2 px-5 py-2 rounded-lg text-xs font-semibold transition ${
                activeTab === 'kader'
                  ? 'bg-green-800 text-white shadow-sm'
                  : 'text-gray-600 hover:text-gray-800'
              }`}
            >
              <Users size={16} />
              Daftar Kader ({kaderList.length})
            </button>
          </div>

          <div className="relative w-80">
            <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder={`Cari ${activeTab}...`}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
            />
          </div>
        </div>

        {/* Tab Content 1: Posyandu List */}
        {activeTab === 'posyandu' && (
          <div className="grid grid-cols-3 gap-6">
            {filteredPosyandu.map((pos) => (
              <div
                key={pos.id}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex flex-col justify-between hover:border-green-200 transition group"
              >
                <div>
                  <div className="flex items-start justify-between mb-3">
                    <div className="w-10 h-10 rounded-xl bg-green-50 text-green-700 flex items-center justify-center font-bold">
                      <Building2 size={20} />
                    </div>
                    <span className="bg-green-50 text-green-700 text-[10px] font-bold px-2.5 py-0.5 rounded-full border border-green-200">
                      {pos.status}
                    </span>
                  </div>

                  <h3 className="text-base font-bold text-gray-800 group-hover:text-green-800 transition">
                    {pos.nama}
                  </h3>
                  <p className="text-xs text-gray-400 flex items-center gap-1 mt-1 mb-4">
                    <MapPin size={12} /> {pos.alamat}, Kel. {pos.kelurahan}
                  </p>

                  <div className="grid grid-cols-2 gap-2 pt-3 border-t border-gray-100 mb-4">
                    <div className="bg-gray-50 p-2.5 rounded-xl">
                      <span className="text-[10px] text-gray-400 font-semibold uppercase">Balita Active</span>
                      <p className="text-lg font-bold text-gray-800">{pos.jumlahBalita}</p>
                    </div>
                    <div className="bg-gray-50 p-2.5 rounded-xl">
                      <span className="text-[10px] text-gray-400 font-semibold uppercase">Total Kader</span>
                      <p className="text-lg font-bold text-gray-800">{pos.jumlahKader}</p>
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                  <span className="text-[10px] font-mono text-gray-400">ID: {pos.id}</span>
                  <div className="flex items-center gap-2">
                    <button className="p-1.5 text-gray-400 hover:text-green-600 transition rounded-lg hover:bg-gray-100">
                      <Edit3 size={16} />
                    </button>
                    <button
                      onClick={() => handleDeletePosyandu(pos.id)}
                      className={`p-1.5 transition rounded-lg ${
                        isAdmin
                          ? 'text-gray-400 hover:text-red-600 hover:bg-red-50'
                          : 'text-gray-300 cursor-not-allowed'
                      }`}
                      title={isAdmin ? 'Hapus Posyandu' : 'Akses Khusus Admin Dinkes'}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Tab Content 2: Kader List */}
        {activeTab === 'kader' && (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50/50 border-b border-gray-100 text-[10px] font-bold uppercase text-gray-400">
                <tr>
                  <th className="py-3.5 px-6">Nama Kader</th>
                  <th className="py-3.5 px-6">Posyandu Induk</th>
                  <th className="py-3.5 px-6">No. Telepon / WA</th>
                  <th className="py-3.5 px-6">Peran Kader</th>
                  <th className="py-3.5 px-6">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {filteredKader.map((k) => (
                  <tr key={k.id} className="hover:bg-gray-50/50">
                    <td className="py-4 px-6 font-semibold text-gray-800 flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-xs font-bold">
                        {k.nama.slice(0, 2).toUpperCase()}
                      </div>
                      {k.nama}
                    </td>
                    <td className="py-4 px-6 text-gray-600 font-medium">{k.posyandu}</td>
                    <td className="py-4 px-6 text-gray-600 flex items-center gap-1.5">
                      <Phone size={14} className="text-gray-400" />
                      {k.noHp}
                    </td>
                    <td className="py-4 px-6 text-xs text-gray-700 font-medium">{k.peran}</td>
                    <td className="py-4 px-6">
                      <span className="inline-flex items-center gap-1 text-xs font-semibold text-green-700 bg-green-50 px-2.5 py-0.5 rounded-full border border-green-200">
                        <CheckCircle size={10} />
                        {k.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Modal Form Tambah Posyandu */}
        {isModalOpen && (
          <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl space-y-5 animate-in fade-in zoom-in duration-150">
              <h3 className="text-lg font-bold text-gray-800">Tambah Unit Posyandu Baru</h3>
              <form onSubmit={handleAddPosyandu} className="space-y-4">
                <div>
                  <label className="text-xs font-semibold text-gray-500 mb-1 block">Nama Posyandu</label>
                  <input
                    type="text"
                    placeholder="Contoh: Posyandu Mawar VI"
                    value={newNama}
                    onChange={(e) => setNewNama(e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                    required
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-gray-500 mb-1 block">Alamat</label>
                  <input
                    type="text"
                    placeholder="Contoh: Jl. Merdeka No. 10"
                    value={newAlamat}
                    onChange={(e) => setNewAlamat(e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-gray-500 mb-1 block">Kelurahan</label>
                  <select
                    value={newKelurahan}
                    onChange={(e) => setNewKelurahan(e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-white"
                  >
                    <option value="Mekar Jaya">Kel. Mekar Jaya</option>
                    <option value="Sukamaju">Kel. Sukamaju</option>
                    <option value="Bojongloa">Kel. Bojongloa</option>
                    <option value="Pasir Putih">Kel. Pasir Putih</option>
                  </select>
                </div>

                <div className="flex items-center justify-end gap-3 pt-3">
                  <button
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    className="px-4 py-2 text-xs font-semibold text-gray-500 hover:bg-gray-100 rounded-xl"
                  >
                    Batal
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-green-800 text-white text-xs font-semibold rounded-xl hover:bg-green-900 shadow-sm"
                  >
                    Simpan Data
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
};

export default PosyanduPage;
