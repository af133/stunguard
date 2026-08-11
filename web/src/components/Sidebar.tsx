import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const Sidebar = () => {
  const location = useLocation(); 

  return (
    <aside className="w-64 h-screen bg-white border-r border-gray-200 p-6 flex flex-col justify-between">
      <div>
        <h1 className="text-2xl font-bold text-green-700 mb-10">StuntGuard</h1>
        <nav className="space-y-4">
          <NavItem label="Dashboard" path="/" active={location.pathname === '/'} />
          <NavItem label="Data Anak" path="/data-anak" active={location.pathname === '/data-anak'} />
          <NavItem label="Laporan" path="/laporan" active={location.pathname === '/laporan'} />
          <NavItem label="Pengaturan" path="/pengaturan" active={location.pathname === '/pengaturan'} />
        </nav>
      </div>
      {/* ... bagian status server ... */}
    </aside>
  );
};

const NavItem = ({ label, active, path }: { label: string, active: boolean, path: string }) => (
  <Link 
    to={path} 
    className={`block p-3 rounded-lg cursor-pointer transition ${
      active ? 'bg-green-700 text-white' : 'text-gray-600 hover:bg-gray-100'
    }`}
  >
    {label}
  </Link>
);

export default Sidebar;