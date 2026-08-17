import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  Map,
  Baby,
  Building2,
  Bell,
  FileBarChart,
  TrendingUp,
  Settings,
  ShieldCheck,
  LogOut,
} from 'lucide-react';
import { useAuth } from '../../features/auth/AuthContext';
import { listAlerts } from '../data/mockData';

const menuItems = [
  { label: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
  { label: 'Peta Risiko', path: '/peta-risiko', icon: Map },
  { label: 'Data Anak', path: '/data-anak', icon: Baby },
  { label: 'Posyandu', path: '/posyandu', icon: Building2 },
  { label: 'Alert', path: '/alert', icon: Bell, hasBadge: true },
  { label: 'Laporan', path: '/laporan', icon: FileBarChart },
  { label: 'Analitik', path: '/analitik', icon: TrendingUp },
  { label: 'Pengaturan', path: '/pengaturan', icon: Settings },
];

const Sidebar = () => {
  const location = useLocation();
  const { user, logout } = useAuth();
  const unreadAlerts = listAlerts.filter((a) => !a.read).length;

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <aside className="w-[220px] min-w-[220px] h-screen bg-white border-r border-gray-200 flex flex-col sticky top-0">
      {/* Logo */}
      <div className="px-6 pt-6 pb-6">
        <Link to="/" className="flex items-center gap-2 no-underline">
          <div className="w-8 h-8 bg-green-800 rounded-lg flex items-center justify-center shadow-sm">
            <ShieldCheck size={18} className="text-white" />
          </div>
          <div>
            <span className="text-lg font-bold text-green-800 leading-none block">StuntGuard</span>
            <span className="text-[9px] text-gray-400 font-semibold uppercase tracking-wider block mt-0.5">
              {user?.role === 'admin_dinkes' ? 'Admin Dinkes' : 'Puskesmas Mode'}
            </span>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 space-y-0.5 overflow-y-auto">
        {menuItems.map((item) => {
          const active = isActive(item.path);
          const Icon = item.icon;
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150 no-underline ${
                active
                  ? 'bg-green-800 text-white shadow-sm'
                  : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <Icon size={16} />
                {item.label}
              </div>
              {item.hasBadge && unreadAlerts > 0 && (
                <span
                  className={`px-1.5 py-0.5 text-[10px] font-bold rounded-full ${
                    active ? 'bg-red-500 text-white' : 'bg-red-100 text-red-600'
                  }`}
                >
                  {unreadAlerts}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* Server Status & Logout */}
      <div className="px-3 pb-5 pt-3 space-y-2 border-t border-gray-100">
        <div className="bg-green-50 border border-green-200 rounded-xl px-3 py-2.5">
          <p className="text-[9px] font-bold text-green-700 uppercase tracking-wider mb-0.5">
            Status Server
          </p>
          <div className="flex items-center gap-1.5">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
            <span className="text-[11px] text-green-800 font-semibold truncate">
              {user?.wilayah || 'Terhubung: Puskesmas'}
            </span>
          </div>
        </div>

        <button
          onClick={logout}
          className="w-full flex items-center gap-2 px-3 py-2 text-xs font-semibold text-red-600 hover:bg-red-50 rounded-xl transition"
        >
          <LogOut size={14} />
          Keluar (Logout)
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
