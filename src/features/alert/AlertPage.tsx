import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Bell, AlertTriangle, FileText, CheckCheck, Eye, Sparkles, CheckCircle2,
} from 'lucide-react';
import Layout from '../../shared/components/Layout';
import { listAlerts, type AlertData } from '../../shared/data/mockData';

const AlertPage = () => {
  const [alerts, setAlerts] = useState<AlertData[]>(listAlerts);
  const [filter, setFilter] = useState<'semua' | 'unread' | 'kritis'>('semua');

  const unreadCount = alerts.filter((a) => !a.read).length;

  const markAllRead = () => {
    setAlerts((prev) => prev.map((a) => ({ ...a, read: true })));
  };

  const markAsRead = (id: string) => {
    setAlerts((prev) => prev.map((a) => (a.id === id ? { ...a, read: true } : a)));
  };

  const filteredAlerts = alerts.filter((a) => {
    if (filter === 'unread') return !a.read;
    if (filter === 'kritis') return a.kategori === 'risiko_tinggi';
    return true;
  });

  return (
    <Layout>
      <div className="max-w-[1000px] mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Sistem Alert & Notifikasi</h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Pemberitahuan otomatis real-time untuk kasus risiko tinggi dan laporan sistem
            </p>
          </div>

          {unreadCount > 0 && (
            <button
              onClick={markAllRead}
              className="flex items-center gap-1.5 px-4 py-2 bg-green-50 text-green-700 border border-green-200 rounded-xl text-xs font-semibold hover:bg-green-100 transition"
            >
              <CheckCheck size={16} />
              Tandai Semua Dibaca
            </button>
          )}
        </div>

        {/* Banner Status */}
        <div className="bg-gradient-to-r from-red-50 to-orange-50 border border-red-100 rounded-2xl p-5 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-red-500 text-white flex items-center justify-center font-bold shadow-md shadow-red-500/20">
              <Bell size={22} />
            </div>
            <div>
              <h3 className="text-base font-bold text-gray-800">
                {unreadCount} Notifikasi Belum Dibaca
              </h3>
              <p className="text-xs text-gray-500 mt-0.5">
                Segera tindak lanjuti kasus risiko tinggi yang memerlukan intervensi medis puskesmas.
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setFilter('semua')}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                filter === 'semua' ? 'bg-green-800 text-white' : 'bg-white text-gray-600 border border-gray-200'
              }`}
            >
              Semua ({alerts.length})
            </button>
            <button
              onClick={() => setFilter('unread')}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                filter === 'unread' ? 'bg-green-800 text-white' : 'bg-white text-gray-600 border border-gray-200'
              }`}
            >
              Belum Dibaca ({unreadCount})
            </button>
            <button
              onClick={() => setFilter('kritis')}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                filter === 'kritis' ? 'bg-green-800 text-white' : 'bg-white text-gray-600 border border-gray-200'
              }`}
            >
              Risiko Tinggi
            </button>
          </div>
        </div>

        {/* Alert List */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm divide-y divide-gray-100 overflow-hidden">
          {filteredAlerts.length === 0 ? (
            <div className="p-12 text-center text-gray-400">
              <CheckCircle2 size={36} className="mx-auto mb-2 text-green-500" />
              <p className="text-sm font-semibold">Tidak ada notifikasi dalam kategori ini</p>
            </div>
          ) : (
            filteredAlerts.map((item) => (
              <div
                key={item.id}
                className={`p-5 flex items-start justify-between gap-4 transition ${
                  !item.read ? 'bg-red-50/30' : 'hover:bg-gray-50/50'
                }`}
              >
                <div className="flex items-start gap-4">
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${
                      item.kategori === 'risiko_tinggi'
                        ? 'bg-red-100 text-red-600'
                        : item.kategori === 'anomali'
                        ? 'bg-amber-100 text-amber-600'
                        : 'bg-blue-100 text-blue-600'
                    }`}
                  >
                    {item.kategori === 'risiko_tinggi' ? (
                      <AlertTriangle size={20} />
                    ) : item.kategori === 'anomali' ? (
                      <Sparkles size={20} />
                    ) : (
                      <FileText size={20} />
                    )}
                  </div>

                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="text-sm font-bold text-gray-800">{item.judul}</h4>
                      {!item.read && (
                        <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
                      )}
                      <span className="text-[10px] text-gray-400 font-medium ml-2">{item.waktu}</span>
                    </div>
                    <p className="text-xs text-gray-600 leading-relaxed max-w-2xl">{item.pesan}</p>
                  </div>
                </div>

                <div className="flex items-center gap-2 flex-shrink-0">
                  {item.balitaId && (
                    <Link
                      to={`/data-anak/${item.balitaId}`}
                      onClick={() => markAsRead(item.id)}
                      className="flex items-center gap-1 px-3 py-1.5 bg-green-800 text-white rounded-lg text-xs font-semibold hover:bg-green-900 transition"
                    >
                      <Eye size={14} />
                      Detail Anak
                    </Link>
                  )}
                  {!item.read && (
                    <button
                      onClick={() => markAsRead(item.id)}
                      className="px-3 py-1.5 border border-gray-200 text-gray-600 hover:bg-gray-100 rounded-lg text-xs font-medium"
                    >
                      Tandai Dibaca
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </Layout>
  );
};

export default AlertPage;
