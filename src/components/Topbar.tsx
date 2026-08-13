import React from 'react';

const Topbar = () => {
  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-end px-8">
      <div className="flex items-center gap-4">
        <div className="text-right">
          <p className="font-semibold text-gray-800">Dr. Siti Aminah</p>
          <p className="text-xs text-gray-500 uppercase">Kepala Puskesmas</p>
        </div>
        <img src="/avatar.jpg" alt="Profile" className="w-10 h-10 rounded-full bg-gray-300" />
      </div>
    </header>
  );
};

export default Topbar;