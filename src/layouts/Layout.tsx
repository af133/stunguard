import React from 'react';
import Sidebar from '../components/Sidebar';
import Topbar from '../components/Topbar';
const  Layout = ({ children }: { children: React.ReactNode }) => {
    return (
      <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Topbar />
        <main className="p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
export default Layout;
