import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  Baby,
  FileBarChart,
  Settings,
  ShieldCheck,
} from 'lucide-react';

const menuItems = [
  { label: 'Dashboard', path: '/', icon: LayoutDashboard },
  { label: 'Data Anak', path: '/data-anak', icon: Baby },
  { label: 'Laporan', path: '/laporan', icon: FileBarChart },
  { label: 'Pengaturan', path: '/pengaturan', icon: Settings },
];

const Sidebar = () => {
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <aside className="w-[220px] min-w-[220px] h-screen bg-white border-r border-gray-200 flex flex-col sticky top-0">
      {/* Logo */}
      <div className="px-6 pt-6 pb-8">
        <Link to="/" className="flex items-center gap-2 no-underline">
          <div className="w-8 h-8 bg-green-700 rounded-lg flex items-center justify-center">
            <ShieldCheck size={18} className="text-white" />
          </div>
          <span className="text-xl font-bold text-green-800">StuntGuard</span>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-4 space-y-1">
        {menuItems.map((item) => {
          const active = isActive(item.path);
          const Icon = item.icon;
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 no-underline ${
                active
                  ? 'bg-green-800 text-white shadow-sm'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <Icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Server Status */}
      <div className="px-4 pb-6">
        <div className="bg-green-50 border border-green-200 rounded-xl px-4 py-3">
          <p className="text-[10px] font-semibold text-green-700 uppercase tracking-wider mb-1">
            Status Server
          </p>
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
            <span className="text-xs text-green-800 font-medium">
              Terhubung: Puskesmas
            </span>
          </div>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
