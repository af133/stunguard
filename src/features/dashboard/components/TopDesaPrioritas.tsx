import { ChevronRight } from 'lucide-react';
import { topDesaPrioritas } from '../../../shared/data/mockData';

const rankColors = [
  'bg-red-500',
  'bg-red-400',
  'bg-orange-400',
  'bg-amber-400',
  'bg-yellow-400',
];

const barColors = [
  'bg-red-500',
  'bg-red-400',
  'bg-orange-400',
  'bg-amber-400',
  'bg-yellow-400',
];

const TopDesaPrioritas = () => {
  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5 flex flex-col h-full">
      <h3 className="text-base font-semibold text-gray-800 mb-1">Top 5 Desa Prioritas</h3>
      <p className="text-xs text-gray-400 mb-5">Urutan risiko tertinggi bulan ini</p>

      <div className="space-y-4 flex-1">
        {topDesaPrioritas.map((desa, index) => (
          <div key={desa.rank} className="flex items-center gap-3 group cursor-pointer">
            {/* Rank Number */}
            <div
              className={`w-8 h-8 rounded-full ${rankColors[index]} flex items-center justify-center text-white text-xs font-bold flex-shrink-0`}
            >
              {desa.rank}
            </div>

            {/* Name + Bar */}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-700 mb-1 truncate">{desa.nama}</p>
              <div className="w-full bg-gray-100 rounded-full h-2">
                <div
                  className={`h-2 rounded-full ${barColors[index]} transition-all duration-500`}
                  style={{ width: `${desa.persen}%` }}
                />
              </div>
            </div>

            {/* Percentage */}
            <span className="text-sm font-semibold text-gray-600 flex-shrink-0 w-10 text-right">
              {desa.persen}%
            </span>

            {/* Arrow */}
            <ChevronRight size={14} className="text-gray-300 group-hover:text-gray-500 transition flex-shrink-0" />
          </div>
        ))}
      </div>

      {/* Footer Button */}
      <button className="mt-5 w-full py-2.5 border border-green-200 text-green-700 rounded-xl text-sm font-medium hover:bg-green-50 transition">
        Lihat Semua Laporan Desa
      </button>
    </div>
  );
};

export default TopDesaPrioritas;
