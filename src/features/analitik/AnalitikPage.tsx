import {
  TrendingDown, BarChart3, Download, Sparkles,
} from 'lucide-react';
import {
  BarChart, Bar, Line, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, ComposedChart,
} from 'recharts';
import Layout from '../../shared/components/Layout';
import { analitikKomparatif, proyeksiPrevalensi } from '../../shared/data/mockData';

const AnalitikPage = () => {

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Analitik Lanjutan & Proyeksi AI</h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Analisis komparatif antar wilayah dan estimasi penurunan prevalensi stunting berbasis machine learning
            </p>
          </div>

          <div className="flex items-center gap-3">
            <button className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-50 shadow-sm">
              <Download size={14} />
              Export Laporan Analitik
            </button>
          </div>
        </div>

        {/* Top Summary Banner */}
        <div className="grid grid-cols-3 gap-5">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <div className="flex items-center gap-2 text-green-700 mb-2">
              <TrendingDown size={18} />
              <span className="text-xs font-bold uppercase tracking-wider">Laju Penurunan Prevalensi</span>
            </div>
            <h3 className="text-3xl font-extrabold text-gray-800">-2.4%</h3>
            <p className="text-xs text-green-600 mt-1 font-medium">↗ Sesuai target tahunan Kemenkes</p>
          </div>

          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <div className="flex items-center gap-2 text-blue-600 mb-2">
              <BarChart3 size={18} />
              <span className="text-xs font-bold uppercase tracking-wider">Wilayah Prevalensi Terendah</span>
            </div>
            <h3 className="text-3xl font-extrabold text-gray-800">8.9%</h3>
            <p className="text-xs text-gray-400 mt-1">Desa Cihideung (26 Kasus)</p>
          </div>

          <div className="bg-gradient-to-br from-green-800 to-green-900 text-white rounded-2xl p-5 shadow-lg relative overflow-hidden">
            <div className="flex items-center gap-2 mb-2 text-green-200">
              <Sparkles size={18} className="text-green-300" />
              <span className="text-xs font-bold uppercase tracking-wider">Estimasi Maret 2025</span>
            </div>
            <h3 className="text-3xl font-extrabold text-white">9.5%</h3>
            <p className="text-xs text-green-200 mt-1">AI Confidence Bound: 8.1% - 11.0%</p>
          </div>
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-2 gap-6">
          {/* Chart 1: Proyeksi Prevalensi (Line + Shaded Confidence Area) */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-base font-bold text-gray-800">Proyeksi Prevalensi Stunting (6 Bulan Ahead)</h3>
                <p className="text-xs text-gray-400">Model Prediksi Time-Series AI dengan Confidence Interval 95%</p>
              </div>
            </div>

            <div className="h-[280px]">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={proyeksiPrevalensi} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="bulan" tick={{ fontSize: 11, fill: '#9ca3af' }} />
                  <YAxis unit="%" tick={{ fontSize: 11, fill: '#9ca3af' }} domain={[5, 18]} />
                  <Tooltip contentStyle={{ borderRadius: '8px', fontSize: '12px' }} />
                  <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }} />

                  {/* Confidence Interval Band */}
                  <Area
                    type="monotone"
                    dataKey="upperBound"
                    name="Batas Atas CI"
                    stroke="none"
                    fill="#bbf7d0"
                    fillOpacity={0.4}
                  />
                  <Area
                    type="monotone"
                    dataKey="lowerBound"
                    name="Batas Bawah CI"
                    stroke="none"
                    fill="#ffffff"
                    fillOpacity={1}
                  />

                  {/* Lines */}
                  <Line
                    type="monotone"
                    dataKey="historis"
                    name="Historis (%)"
                    stroke="#15803d"
                    strokeWidth={2.5}
                    dot={{ r: 4 }}
                  />
                  <Line
                    type="monotone"
                    dataKey="proyeksi"
                    name="Proyeksi AI (%)"
                    stroke="#0d9488"
                    strokeWidth={2.5}
                    strokeDasharray="4 4"
                    dot={{ r: 4, fill: '#0d9488' }}
                  />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Chart 2: Komparatif Per Wilayah */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-base font-bold text-gray-800">Komparasi Prevalensi Antar Wilayah</h3>
                <p className="text-xs text-gray-400">Persentase Balita Stunting per Kelurahan/Desa</p>
              </div>
            </div>

            <div className="h-[280px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analitikKomparatif} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="wilayah" tick={{ fontSize: 10, fill: '#9ca3af' }} />
                  <YAxis unit="%" tick={{ fontSize: 11, fill: '#9ca3af' }} />
                  <Tooltip contentStyle={{ borderRadius: '8px', fontSize: '12px' }} />
                  <Bar dataKey="prevalensi" name="Prevalensi (%)" fill="#15803d" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Detailed Breakdown Table */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <h3 className="text-base font-bold text-gray-800 mb-4">Tabel Rincian Prevalensi per Wilayah</h3>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50/50 border-b border-gray-100 text-[10px] font-bold uppercase text-gray-400">
                <tr>
                  <th className="py-3 px-4">Kelurahan / Desa</th>
                  <th className="py-3 px-4">Total Balita Terdaftar</th>
                  <th className="py-3 px-4">Kasus Stunting</th>
                  <th className="py-3 px-4">Prevalensi (%)</th>
                  <th className="py-3 px-4">Status Prioritas</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {analitikKomparatif.map((row, idx) => (
                  <tr key={idx} className="hover:bg-gray-50/50">
                    <td className="py-3.5 px-4 font-semibold text-gray-800">{row.wilayah}</td>
                    <td className="py-3.5 px-4 text-gray-600">{row.totalAnak} Balita</td>
                    <td className="py-3.5 px-4 font-bold text-red-600">{row.kasusStunting} Anak</td>
                    <td className="py-3.5 px-4 font-mono font-bold text-gray-800">{row.prevalensi}%</td>
                    <td className="py-3.5 px-4">
                      <span
                        className={`text-xs font-semibold px-2.5 py-0.5 rounded-full ${
                          row.prevalensi > 20
                            ? 'bg-red-50 text-red-600 border border-red-200'
                            : row.prevalensi > 12
                            ? 'bg-amber-50 text-amber-700 border border-amber-200'
                            : 'bg-green-50 text-green-700 border border-green-200'
                        }`}
                      >
                        {row.prevalensi > 20 ? 'Prioritas 1 (Tinggi)' : row.prevalensi > 12 ? 'Prioritas 2 (Sedang)' : 'Prioritas 3 (Normal)'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default AnalitikPage;
