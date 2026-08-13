import { useState } from 'react';
import {
  Search, Upload, Plus, SlidersHorizontal, Eye, Pencil,
  Users, AlertTriangle, ArrowUpRight, CheckCircle, ChevronDown,
} from 'lucide-react';
import Layout from '../../shared/components/Layout';
import StatCard from '../../shared/components/StatCard';
import ColorBadge from '../../shared/components/ColorBadge';
import Pagination from '../../shared/components/Pagination';
import { dataAnak, dataAnakStats } from '../../shared/data/mockData';

const DataAnakPage = () => {
  const [currentPage, setCurrentPage] = useState(1);
  const stats = dataAnakStats;

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Search Bar + Actions */}
        <div className="flex items-center gap-4">
          <div className="flex-1 relative">
            <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Cari Nama Anak atau NIK..."
              className="w-full max-w-[480px] pl-11 pr-4 py-3 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-200 focus:border-green-400 transition"
            />
          </div>
          <button className="flex items-center gap-2 px-5 py-3 border border-gray-200 rounded-xl text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition">
            <Upload size={16} />
            Export
          </button>
          <button className="flex items-center gap-2 px-5 py-3 bg-green-800 text-white rounded-xl text-sm font-medium hover:bg-green-900 transition shadow-sm">
            <Plus size={16} />
            Tambah Anak
          </button>
        </div>

        {/* Stat Cards */}
        <div className="grid grid-cols-4 gap-4">
          <StatCard
            title="Total Anak"
            value={stats.totalAnak.toLocaleString('id-ID')}
            icon={Users}
            iconBgColor="bg-blue-50"
            iconColor="text-blue-600"
          />
          <StatCard
            title="Risiko Tinggi"
            value={stats.risikoTinggi}
            icon={AlertTriangle}
            iconBgColor="bg-red-50"
            iconColor="text-red-500"
          />
          <StatCard
            title="Perlu Rujukan"
            value={stats.perluRujukan}
            icon={ArrowUpRight}
            iconBgColor="bg-amber-50"
            iconColor="text-amber-600"
          />
          <StatCard
            title="Sudah Timbang"
            value={`${stats.sudahTimbang}%`}
            icon={CheckCircle}
            iconBgColor="bg-green-50"
            iconColor="text-green-600"
          />
        </div>

        {/* Filters */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 text-sm text-gray-500">
            <SlidersHorizontal size={14} />
            <span className="font-medium">Filter:</span>
          </div>
          {['Semua Wilayah', 'Rentang Usia', 'Level Risiko', 'Status Tindak Lanjut'].map((filter) => (
            <button
              key={filter}
              className="flex items-center gap-1.5 px-4 py-2 bg-white border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-50 transition"
            >
              {filter}
              <ChevronDown size={14} />
            </button>
          ))}
          <button className="text-sm font-semibold text-green-700 hover:text-green-800 ml-auto transition">
            Reset Filter
          </button>
        </div>

        {/* Data Table */}
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
          {/* Table Header */}
          <div className="grid grid-cols-[2fr_1fr_1fr_1fr_1fr_80px] gap-4 px-6 py-3.5 border-b border-gray-100 bg-gray-50/50">
            {['Nama Anak / NIK', 'Usia & Kelamin', 'Posyandu', 'Status Risiko', 'Kunjungan', 'Aksi'].map((h) => (
              <span key={h} className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">{h}</span>
            ))}
          </div>

          {/* Table Rows */}
          <div className="divide-y divide-gray-50">
            {dataAnak.map((anak) => (
              <div
                key={anak.id}
                className="grid grid-cols-[2fr_1fr_1fr_1fr_1fr_80px] gap-4 px-6 py-4 items-center hover:bg-gray-50/50 transition"
              >
                {/* Name + NIK */}
                <div className="flex items-center gap-3">
                  <div className={`w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 ${
                    anak.statusRisiko === 'Tinggi' ? 'bg-red-100 text-red-700' :
                    anak.statusRisiko === 'Sedang' ? 'bg-amber-100 text-amber-700' :
                    'bg-green-100 text-green-700'
                  }`}>
                    {anak.inisial}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-semibold text-gray-800 truncate">{anak.nama}</p>
                    <p className="text-xs text-gray-400">{anak.nik}</p>
                  </div>
                </div>

                {/* Age + Gender */}
                <div>
                  <p className="text-sm text-gray-700">{anak.usiaBulan} Bulan</p>
                  <p className="text-xs text-gray-400">{anak.kelamin}</p>
                </div>

                {/* Posyandu */}
                <span className="text-sm text-gray-600">{anak.posyandu}</span>

                {/* Risk Status */}
                <div>
                  <ColorBadge level={anak.statusRisiko} />
                </div>

                {/* Last Visit */}
                <div>
                  <p className="text-sm text-gray-700">{anak.tanggalKunjungan}</p>
                  <p className={`text-[10px] font-semibold uppercase tracking-wider ${
                    anak.statusKunjunganColor === 'green' ? 'text-green-600' :
                    anak.statusKunjunganColor === 'amber' ? 'text-amber-600' :
                    'text-gray-400'
                  }`}>
                    {anak.statusKunjungan}
                  </p>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-2">
                  <button className="p-1.5 text-gray-400 hover:text-green-600 transition rounded-lg hover:bg-green-50" aria-label={`Lihat detail ${anak.nama}`}>
                    <Eye size={16} />
                  </button>
                  <button className="p-1.5 text-gray-400 hover:text-green-600 transition rounded-lg hover:bg-green-50" aria-label={`Edit ${anak.nama}`}>
                    <Pencil size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Pagination */}
          <div className="px-6 py-4 border-t border-gray-100">
            <Pagination
              currentPage={currentPage}
              totalPages={312}
              totalData={stats.totalAnak}
              itemsPerPage={4}
              onPageChange={setCurrentPage}
            />
          </div>
        </div>

        {/* CTA Banner */}
        <div className="bg-green-800 rounded-2xl px-8 py-6 flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-white mb-1">Ingin memantau pertumbuhan masal?</h3>
            <p className="text-sm text-green-200">
              Unduh template Excel untuk input data anak secara kolektif dari Posyandu wilayah Anda.
            </p>
          </div>
          <button className="bg-white text-green-800 px-6 py-3 rounded-xl text-sm font-semibold hover:bg-green-50 transition shadow-sm flex-shrink-0">
            Unduh Template Batch
          </button>
        </div>
      </div>
    </Layout>
  );
};

export default DataAnakPage;
