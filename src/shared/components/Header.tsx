import { useLocation } from 'react-router-dom';
import { Bell } from 'lucide-react';

const pageTitles: Record<string, string> = {
  '/': 'Dashboard Kesehatan',
  '/data-anak': 'Data Anak',
  '/laporan': 'Laporan',
  '/pengaturan': 'Pengaturan',
};

const Header = () => {
  const location = useLocation();
  const currentTitle = pageTitles[location.pathname] || 'Dashboard';

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-10">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm">
        <span className="text-gray-400">Beranda</span>
        <span className="text-gray-300">›</span>
        <span className="text-green-700 font-semibold">{currentTitle}</span>
      </div>

      {/* Right side */}
      <div className="flex items-center gap-5">
        {/* Notification Bell */}
        <button className="relative p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition" aria-label="Notifikasi">
          <Bell size={20} />
          <span className="absolute -top-0.5 -right-0.5 w-4 h-4 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
            1
          </span>
        </button>

        {/* Divider */}
        <div className="w-px h-8 bg-gray-200" />

        {/* User Profile */}
        <div className="flex items-center gap-3">
          <div className="text-right">
            <p className="text-sm font-semibold text-gray-800 leading-tight">Dr. Siti Aminah</p>
            <p className="text-[10px] text-gray-400 uppercase tracking-wider font-medium">Kepala Puskesmas</p>
          </div>
          <div className="w-9 h-9 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center text-white text-sm font-bold shadow-sm">
            SA
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
