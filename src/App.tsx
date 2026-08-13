import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import DashboardPage from './features/dashboard/DashboardPage';
import DataAnakPage from './features/data-anak/DataAnakPage';
import LaporanPage from './features/laporan/LaporanPage';
import Layout from './shared/components/Layout';
import { Settings } from 'lucide-react';
import './App.css';

// Placeholder for Pengaturan page
const PengaturanPage = () => (
  <Layout>
    <div className="max-w-[1200px] mx-auto flex flex-col items-center justify-center h-[60vh] text-center">
      <div className="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center mb-4">
        <Settings size={28} className="text-gray-400" />
      </div>
      <h2 className="text-xl font-semibold text-gray-700 mb-2">Pengaturan</h2>
      <p className="text-sm text-gray-400">Halaman pengaturan akan segera tersedia.</p>
    </div>
  </Layout>
);

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/data-anak" element={<DataAnakPage />} />
        <Route path="/laporan" element={<LaporanPage />} />
        <Route path="/pengaturan" element={<PengaturanPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
