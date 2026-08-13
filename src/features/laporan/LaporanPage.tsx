import {
  Calendar, MapPin, FileText, RefreshCw, Download,
  BarChart3, AlertTriangle, CheckCircle,
} from 'lucide-react';
import Layout from '../../shared/components/Layout';
import DistribusiChart from './components/DistribusiChart';
import { laporanStats } from '../../shared/data/mockData';

const LaporanPage = () => {
  const stats = laporanStats;

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Page Header */}
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Laporan Bulanan</h2>
          <p className="text-sm text-gray-500 mt-1 max-w-2xl">
            Pilih periode dan wilayah untuk menghasilkan laporan ringkasan kesehatan anak. Laporan ini dapat diunduh dalam format PDF atau Excel.
          </p>
        </div>

        {/* Filters Row */}
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex gap-4 items-end">
          <div className="flex-1">
            <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-2 block">
              Periode
            </label>
            <div className="relative">
              <input
                type="text"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-white text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                defaultValue="Agustus 2023"
                readOnly
              />
              <Calendar className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
            </div>
          </div>
          <div className="flex-1">
            <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-2 block">
              Wilayah
            </label>
            <div className="relative">
              <input
                type="text"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-white text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                defaultValue="Kec. Manggala"
                readOnly
              />
              <MapPin className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
            </div>
          </div>
          <div className="flex-1">
            <label className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider mb-2 block">
              Tipe Laporan
            </label>
            <div className="relative">
              <input
                type="text"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-white text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
                defaultValue="Ringkasan"
                readOnly
              />
              <FileText className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
            </div>
          </div>
          <button className="bg-green-800 text-white px-6 py-2.5 rounded-lg flex items-center gap-2 hover:bg-green-900 transition text-sm font-medium shadow-sm flex-shrink-0">
            <RefreshCw size={16} />
            Generate Report
          </button>
        </div>

        {/* Content Grid: Preview + Export */}
        <div className="grid grid-cols-3 gap-6">
          {/* Main Preview — 2/3 */}
          <div className="col-span-2 space-y-5">
            {/* Preview Header */}
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-800">Preview Laporan</h3>
              <span className="bg-green-50 text-green-600 text-xs font-medium px-3 py-1 rounded-full flex items-center gap-1.5 border border-green-200">
                <CheckCircle size={12} />
                Data Mutakhir
              </span>
            </div>

            {/* Stat Cards */}
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5">
                <div className="flex items-center gap-2 mb-3">
                  <BarChart3 size={16} className="text-blue-600" />
                  <span className="text-xs font-semibold text-blue-600">Total Diperiksa</span>
                </div>
                <h3 className="text-3xl font-bold text-gray-800">{stats.totalDiperiksa.toLocaleString('id-ID')}</h3>
                <p className="text-xs text-green-600 mt-1 font-medium">↗ +12% dari bulan lalu</p>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5">
                <div className="flex items-center gap-2 mb-3">
                  <AlertTriangle size={16} className="text-amber-500" />
                  <span className="text-xs font-semibold text-amber-500">Risiko Sedang</span>
                </div>
                <h3 className="text-3xl font-bold text-gray-800">{stats.risikoSedang}</h3>
                <p className="text-xs text-gray-400 mt-1">Anak perlu observasi</p>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5">
                <div className="flex items-center gap-2 mb-3">
                  <AlertTriangle size={16} className="text-red-500" />
                  <span className="text-xs font-semibold text-red-500">Risiko Tinggi</span>
                </div>
                <h3 className="text-3xl font-bold text-gray-800">{stats.risikoTinggi}</h3>
                <p className="text-xs text-red-500 mt-1 font-medium">! Intervensi segera</p>
              </div>
            </div>

            {/* Distribution Chart */}
            <DistribusiChart />
          </div>

          {/* Export Sidebar — 1/3 */}
          <div className="col-span-1">
            <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 sticky top-24">
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Export Laporan</h3>
              <p className="text-sm text-gray-400 mb-6">
                Unduh laporan resmi sesuai format Kemenkes untuk keperluan arsip.
              </p>
              <div className="space-y-3">
                <button className="w-full border border-green-200 text-green-800 py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-green-50 transition text-sm font-medium">
                  <Download size={16} />
                  Download PDF
                </button>
                <button className="w-full border border-gray-200 text-gray-600 py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-gray-50 transition text-sm font-medium">
                  <FileText size={16} />
                  Export Excel
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default LaporanPage;
