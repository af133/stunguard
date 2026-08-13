import { useParams, Link } from 'react-router-dom';
import {
  ArrowLeft, Calendar, User, Phone, MapPin, AlertTriangle,
  Brain, FileSpreadsheet, CheckCircle, TrendingDown,
} from 'lucide-react';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import Layout from '../../shared/components/Layout';
import ColorBadge from '../../shared/components/ColorBadge';
import { detailBalitaDemo } from '../../shared/data/mockData';

const DetailAnakPage = () => {
  const { id } = useParams();
  const balita = detailBalitaDemo; // Using demo detailed child data

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Top Back Nav */}
        <div className="flex items-center gap-3">
          <Link
            to="/data-anak"
            className="flex items-center gap-1.5 px-3 py-1.5 bg-white border border-gray-200 rounded-xl text-xs font-semibold text-gray-600 hover:bg-gray-50 transition"
          >
            <ArrowLeft size={14} />
            Kembali ke Data Anak
          </Link>
          <span className="text-gray-300">/</span>
          <span className="text-xs text-gray-500 font-medium">Detail Individual #{id || '1'}</span>
        </div>

        {/* Profile Card Header */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex items-start justify-between">
          <div className="flex items-start gap-5">
            <div className="w-16 h-16 rounded-2xl bg-red-100 text-red-700 flex items-center justify-center text-xl font-bold border border-red-200 shadow-sm">
              AR
            </div>
            <div>
              <div className="flex items-center gap-3 mb-1">
                <h1 className="text-2xl font-bold text-gray-800">{balita.nama}</h1>
                <ColorBadge level={balita.statusRisiko} />
              </div>
              <p className="text-xs text-gray-400 font-mono mb-3">NIK: {balita.nik}</p>

              <div className="flex items-center gap-6 text-xs text-gray-600">
                <span className="flex items-center gap-1.5">
                  <User size={14} className="text-gray-400" />
                  Ibu: <strong className="text-gray-800">{balita.namaIbu}</strong>
                </span>
                <span className="flex items-center gap-1.5">
                  <Phone size={14} className="text-gray-400" />
                  {balita.noHpIbu}
                </span>
                <span className="flex items-center gap-1.5">
                  <MapPin size={14} className="text-gray-400" />
                  {balita.posyandu} ({balita.kecamatan})
                </span>
                <span className="flex items-center gap-1.5">
                  <Calendar size={14} className="text-gray-400" />
                  Lahir: {balita.tanggalLahir} ({balita.usiaBulan} Bulan)
                </span>
              </div>
            </div>
          </div>

          <div className="text-right bg-red-50 p-4 rounded-xl border border-red-100">
            <p className="text-[10px] font-bold text-red-600 uppercase tracking-wider mb-1">Z-Score TB/U</p>
            <p className="text-3xl font-extrabold text-red-600">{balita.zscoreTB_U} SD</p>
            <p className="text-[10px] text-red-500 font-medium mt-1">Kategori: Stunting Berat</p>
          </div>
        </div>

        {/* Growth Measurements & WHO Chart Section */}
        <div className="grid grid-cols-3 gap-6">
          {/* Main Chart Column — 2/3 */}
          <div className="col-span-2 space-y-6">
            {/* WHO Height-for-Age Chart */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-base font-bold text-gray-800">Kurva Pertumbuhan WHO (TB / Usia)</h3>
                  <p className="text-xs text-gray-400">
                    Standar Z-Score WHO (Anak Laki-Laki 0-24 Bulan)
                  </p>
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-red-600 bg-red-50 px-3 py-1 rounded-full border border-red-200">
                  <TrendingDown size={14} />
                  Di bawah -2 SD
                </div>
              </div>

              <div className="h-[280px]">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={balita.whoCurveData} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis
                      dataKey="bulan"
                      unit=" bln"
                      tick={{ fontSize: 11, fill: '#9ca3af' }}
                      axisLine={{ stroke: '#e5e7eb' }}
                    />
                    <YAxis
                      unit=" cm"
                      tick={{ fontSize: 11, fill: '#9ca3af' }}
                      domain={[40, 90]}
                      axisLine={false}
                    />
                    <Tooltip contentStyle={{ borderRadius: '8px', fontSize: '12px' }} />
                    <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }} />

                    {/* WHO Standard Lines */}
                    <Line type="monotone" dataKey="plus3SD" name="+3 SD" stroke="#86efac" strokeDasharray="3 3" dot={false} />
                    <Line type="monotone" dataKey="plus2SD" name="+2 SD" stroke="#22c55e" strokeDasharray="3 3" dot={false} />
                    <Line type="monotone" dataKey="median" name="Median (0 SD)" stroke="#15803d" strokeWidth={2} dot={false} />
                    <Line type="monotone" dataKey="minus2SD" name="-2 SD (Batas Stunting)" stroke="#f59e0b" strokeWidth={2} dot={false} />
                    <Line type="monotone" dataKey="minus3SD" name="-3 SD (Stunting Berat)" stroke="#ef4444" strokeWidth={2} dot={false} />

                    {/* Actual Child Measurement Line */}
                    <Line
                      type="monotone"
                      dataKey="anak"
                      name={`Pertumbuhan ${balita.nama}`}
                      stroke="#dc2626"
                      strokeWidth={3.5}
                      dot={{ r: 5, fill: '#dc2626', stroke: '#fff', strokeWidth: 2 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Measurement History Table */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h3 className="text-base font-bold text-gray-800 mb-4">Riwayat Penimbangan & Pengukuran</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm">
                  <thead>
                    <tr className="border-b border-gray-100 text-[10px] uppercase font-bold text-gray-400">
                      <th className="pb-3">Tanggal / Bulan</th>
                      <th className="pb-3">Usia</th>
                      <th className="pb-3">Tinggi (cm)</th>
                      <th className="pb-3">Berat (kg)</th>
                      <th className="pb-3">Z-Score TB/U</th>
                      <th className="pb-3">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {balita.riwayatPertumbuhan.map((r, i) => (
                      <tr key={i} className="hover:bg-gray-50/50">
                        <td className="py-3 font-medium text-gray-800">{r.date}</td>
                        <td className="py-3 text-gray-600">{r.bulan} Bulan</td>
                        <td className="py-3 font-semibold text-gray-800">{r.tb} cm</td>
                        <td className="py-3 font-semibold text-gray-800">{r.bb} kg</td>
                        <td className="py-3 font-mono font-bold text-red-600">{r.zscore} SD</td>
                        <td className="py-3">
                          <ColorBadge level={r.zscore < -2 ? 'tinggi' : 'sedang'} size="sm" />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          {/* AI Prediction & Recommendations Sidebar — 1/3 */}
          <div className="col-span-1 space-y-6">
            {/* AI Analysis Panel */}
            <div className="bg-gradient-to-br from-green-900 to-green-800 text-white rounded-2xl p-6 shadow-xl relative overflow-hidden">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center">
                  <Brain size={18} className="text-green-300" />
                </div>
                <div>
                  <h3 className="text-sm font-bold">Analisis AI Multimodal</h3>
                  <p className="text-[10px] text-green-200">StuntGuard AI Engine v2.4</p>
                </div>
              </div>

              <div className="bg-white/10 backdrop-blur-md rounded-xl p-4 mb-5 border border-white/10">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-green-200">Skor Kerentanan AI</span>
                  <span className="text-xs font-bold text-red-300 bg-red-500/20 px-2 py-0.5 rounded-md">
                    {balita.prediksiAI.skorRisiko}% Risk
                  </span>
                </div>
                <div className="w-full bg-white/20 rounded-full h-2">
                  <div
                    className="bg-red-400 h-2 rounded-full"
                    style={{ width: `${balita.prediksiAI.skorRisiko}%` }}
                  />
                </div>
                <p className="text-[10px] text-green-300 mt-1.5 text-right font-mono">
                  Confidence: {(balita.prediksiAI.confidence * 100).toFixed(0)}%
                </p>
              </div>

              <h4 className="text-xs font-bold text-green-200 uppercase tracking-wider mb-2">
                Faktor Risiko Terdeteksi
              </h4>
              <ul className="space-y-2 mb-5">
                {balita.prediksiAI.faktorRisiko.map((f, i) => (
                  <li key={i} className="flex items-start gap-2 text-xs text-green-100 leading-snug">
                    <AlertTriangle size={14} className="text-amber-300 flex-shrink-0 mt-0.5" />
                    {f}
                  </li>
                ))}
              </ul>

              <h4 className="text-xs font-bold text-green-200 uppercase tracking-wider mb-2">
                Rekomendasi Intervensi
              </h4>
              <ul className="space-y-2">
                {balita.prediksiAI.rekomendasi.map((r, i) => (
                  <li key={i} className="flex items-start gap-2 text-xs text-green-100 leading-snug">
                    <CheckCircle size={14} className="text-green-300 flex-shrink-0 mt-0.5" />
                    {r}
                  </li>
                ))}
              </ul>
            </div>

            {/* Actions Card */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-3">
              <button className="w-full py-3 bg-green-800 text-white font-semibold text-xs rounded-xl hover:bg-green-900 transition flex items-center justify-center gap-2">
                <FileSpreadsheet size={16} />
                Cetak Lembar Rekam Medis
              </button>
              <button className="w-full py-3 border border-gray-200 text-gray-700 font-semibold text-xs rounded-xl hover:bg-gray-50 transition">
                Jadwalkan Kunjungan Rumah
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default DetailAnakPage;
