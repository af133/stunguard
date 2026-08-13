import React from 'react';
import DashboardLayout from '../layouts/Layout';
import { Calendar, MapPin, FileText,  Download, BarChart3,  AlertTriangle, CheckCircle } from 'lucide-react';

const StatCard = ({ title, value, sub, icon: Icon, colorClass }: any) => (
  <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex-1">
    <div className="flex items-center gap-3 mb-4">
      <div className={`p-2 rounded-lg ${colorClass} bg-opacity-10`}>
        <Icon size={20} className={colorClass} />
      </div>
      <p className="text-sm text-gray-500 font-medium">{title}</p>
    </div>
    <h3 className="text-3xl font-bold text-gray-800">{value}</h3>
    {sub && <p className="text-sm text-green-600 mt-1">{sub}</p>}
  </div>
);

const DashboardPage = () => {
  return (
    <DashboardLayout>
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-800">Laporan Bulanan</h2>
          <p className="text-gray-500">Pilih periode dan wilayah untuk menghasilkan laporan ringkasan kesehatan anak. Laporan ini dapat diunduh dalam format PDF atau Excel.</p>
        </div>

        {/* Filters */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex gap-4 mb-8 items-end">
          <div className="flex-1">
            <label className="text-xs font-semibold text-gray-400 uppercase mb-2 block">Periode</label>
            <div className="relative">
              <input type="text" className="w-full p-3 border rounded-lg bg-gray-50" defaultValue="Agustus 2023" />
              <Calendar className="absolute right-3 top-3 text-gray-400" size={18} />
            </div>
          </div>
          <div className="flex-1">
            <label className="text-xs font-semibold text-gray-400 uppercase mb-2 block">Wilayah</label>
            <div className="relative">
              <input type="text" className="w-full p-3 border rounded-lg bg-gray-50" defaultValue="Kec. Manggala" />
              <MapPin className="absolute right-3 top-3 text-gray-400" size={18} />
            </div>
          </div>
          <div className="flex-1">
            <label className="text-xs font-semibold text-gray-400 uppercase mb-2 block">Tipe Laporan</label>
            <div className="relative">
              <input type="text" className="w-full p-3 border rounded-lg bg-gray-50" defaultValue="Ringkasan" />
              <FileText className="absolute right-3 top-3 text-gray-400" size={18} />
            </div>
          </div>
          <button className="bg-green-800 text-white px-6 py-3 rounded-lg flex items-center gap-2 hover:bg-green-900 transition">
            <FileText size={18} />
            Generate Report
          </button>
        </div>

        {/* Content Section */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Preview */}
          <div className="lg:col-span-2 space-y-6">
            <div className="flex justify-between items-center">
              <h3 className="text-lg font-semibold">Preview Laporan</h3>
              <span className="bg-green-100 text-green-700 text-xs px-3 py-1 rounded-full flex items-center gap-1">
                <CheckCircle size={12} /> Data Mutakhir
              </span>
            </div>

            {/* Stats */}
            <div className="flex gap-4">
              <StatCard title="Total Diperiksa" value="1,248" sub="↗ +2% dari bulan lalu" icon={BarChart3} colorClass="text-blue-600" />
              <StatCard title="Risiko Sedang" value="84" sub="Anak perlu observasi" icon={AlertTriangle} colorClass="text-orange-600" />
              <StatCard title="Risiko Tinggi" value="12" sub="Intervensi segera" icon={AlertTriangle} colorClass="text-red-600" />
            </div>

            {/* Chart Placeholder */}
            <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm h-64 flex flex-col justify-end">
              <h4 className="text-sm font-semibold mb-4 text-gray-600">Distribusi Status Gizi Wilayah</h4>
              <div className="flex items-end gap-8 h-40">
                <div className="w-12 bg-green-700 rounded-t h-32"></div>
                <div className="w-12 bg-orange-300 rounded-t h-20"></div>
                <div className="w-12 bg-red-400 rounded-t h-8"></div>
                <div className="w-12 bg-green-700 rounded-t h-28"></div>
                <div className="w-12 bg-orange-300 rounded-t h-20"></div>
                <div className="w-12 bg-red-400 rounded-t h-12"></div>
              </div>
            </div>
          </div>

          {/* Export Sidebar */}
          <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm h-fit">
            <h3 className="text-lg font-semibold mb-4">Export Laporan</h3>
            <p className="text-sm text-gray-500 mb-6">Unduh laporan resmi sesuai format Kemenkes untuk keperluan arsip.</p>
            <div className="space-y-3">
              <button className="w-full border border-green-200 text-green-800 py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-green-50">
                <Download size={18} /> Download PDF
              </button>
              <button className="w-full border border-gray-200 text-gray-700 py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-gray-50">
                <FileText size={18} /> Export Excel
              </button>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default DashboardPage;