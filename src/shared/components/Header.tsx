import { useLocation, Link } from 'react-router-dom';
import { Bell } from 'lucide-react';
import { useAuth } from '../../features/auth/AuthContext';
import { listAlerts } from '../data/mockData';

const pageTitles: Record<string, string> = {
  '/': 'Dashboard Kesehatan',
  '/peta-risiko': 'Peta Risiko Wilayah',
  '/data-anak': 'Data Anak',
  '/posyandu': 'Manajemen Posyandu & Kader',
  '/alert': 'Sistem Alert & Notifikasi',
  '/laporan': 'Laporan Bulanan',
  '/analitik': 'Analitik Lanjutan & Proyeksi AI',
  '/pengaturan': 'Pengaturan System',
};

const Header = () => {
  const location = useLocation();
  const { user } = useAuth();
  const unreadCount = listAlerts.filter((a) => !a.read).length;

  const getBreadcrumbTitle = () => {
    if (location.pathname.startsWith('/data-anak/')) return 'Detail Balita';
    return pageTitles[location.pathname] || 'Dashboard';
  };

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-10">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm">
        <span className="text-gray-400">Beranda</span>
        <span className="text-gray-300">›</span>
        <span className="text-green-800 font-bold">{getBreadcrumbTitle()}</span>
      </div>

      {/* Right side */}
      <div className="flex items-center gap-5">
        {/* Notification Bell */}
        <Link
          to="/alert"
          className="relative p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition flex items-center justify-center"
          aria-label="Notifikasi"
        >
          <Bell size={20} />
          {unreadCount > 0 && (
            <span className="absolute -top-0.5 -right-0.5 w-4 h-4 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center animate-pulse">
              {unreadCount}
            </span>
          )}
        </Link>

        {/* Divider */}
        <div className="w-px h-8 bg-gray-200" />

        {/* User Profile */}
        <Link to="/pengaturan" className="flex items-center gap-3 no-underline group">
          <div className="text-right">
            <p className="text-sm font-bold text-gray-800 leading-tight group-hover:text-green-800 transition">
              {user?.nama || 'Dr. Siti Aminah'}
            </p>
            <p className="text-[10px] text-gray-400 uppercase tracking-wider font-semibold">
              {user?.role === 'admin_dinkes' ? 'Admin Dinas Kesehatan' : 'Kepala Puskesmas'}
            </p>
          </div>
          <div className="w-9 h-9 rounded-full bg-green-800 text-white text-xs font-bold flex items-center justify-center shadow-sm">
            {user?.avatar || 'SA'}
          </div>
        </Link>
      </div>
    </header>
  );
};

export default Header;
