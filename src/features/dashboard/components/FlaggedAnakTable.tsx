import { Eye, XCircle, AlertTriangle } from 'lucide-react';
import { flaggedAnak } from '../../../shared/data/mockData';

const statusConfig: Record<string, { bg: string; text: string; icon: typeof XCircle }> = {
  'Gizi Buruk': { bg: 'text-red-600', text: 'text-red-600', icon: XCircle },
  'Stunting': { bg: 'text-red-600', text: 'text-red-600', icon: XCircle },
  'Underweight': { bg: 'text-amber-600', text: 'text-amber-600', icon: AlertTriangle },
};

const FlaggedAnakTable = () => {
  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <h3 className="text-base font-semibold text-gray-800">Anak Risiko Tinggi (Flagged)</h3>
        <button className="text-green-600 text-sm font-medium hover:text-green-700 transition">
          Lihat Semua
        </button>
      </div>

      {/* Table Header */}
      <div className="grid grid-cols-[1fr_100px_80px_40px] gap-2 pb-3 border-b border-gray-100">
        <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Nama Anak</span>
        <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Posyandu</span>
        <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Status</span>
        <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Aksi</span>
      </div>

      {/* Rows */}
      <div className="divide-y divide-gray-50">
        {flaggedAnak.map((anak) => {
          const config = statusConfig[anak.status] || statusConfig['Underweight'];
          const Icon = config.icon;
          return (
            <div key={anak.id} className="grid grid-cols-[1fr_100px_80px_40px] gap-2 py-3.5 items-center">
              {/* Name with Avatar */}
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-full bg-green-100 text-green-700 flex items-center justify-center text-xs font-bold flex-shrink-0">
                  {anak.inisial}
                </div>
                <span className="text-sm font-medium text-gray-700 truncate">{anak.nama}</span>
              </div>

              {/* Posyandu */}
              <span className="text-sm text-gray-500">{anak.posyandu}</span>

              {/* Status */}
              <span className={`flex items-center gap-1 text-xs font-semibold ${config.text}`}>
                <Icon size={12} />
                {anak.status}
              </span>

              {/* Action */}
              <button className="p-1 text-gray-400 hover:text-green-600 transition" aria-label={`Lihat detail ${anak.nama}`}>
                <Eye size={16} />
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default FlaggedAnakTable;
