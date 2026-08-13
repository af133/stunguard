import { useState } from 'react';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';
import { trenRisiko } from '../../../shared/data/mockData';

const TrenRisikoChart = () => {
  const [activeType, setActiveType] = useState<'stunting' | 'wasting'>('stunting');

  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-base font-semibold text-gray-800">Tren Tingkat Risiko (6 Bulan)</h3>
        <div className="flex gap-2">
          <button
            onClick={() => setActiveType('stunting')}
            className={`px-3 py-1 rounded-full text-xs font-medium transition ${
              activeType === 'stunting'
                ? 'bg-green-100 text-green-700 border border-green-300'
                : 'bg-gray-100 text-gray-500 border border-gray-200'
            }`}
          >
            Stunting
          </button>
          <button
            onClick={() => setActiveType('wasting')}
            className={`px-3 py-1 rounded-full text-xs font-medium transition ${
              activeType === 'wasting'
                ? 'bg-green-100 text-green-700 border border-green-300'
                : 'bg-gray-100 text-gray-500 border border-gray-200'
            }`}
          >
            Wasting
          </button>
        </div>
      </div>

      {/* Chart */}
      <div className="h-[220px]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={trenRisiko} margin={{ top: 5, right: 10, left: -10, bottom: 5 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis
              dataKey="bulan"
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={{ stroke: '#e5e7eb' }}
              tickLine={false}
            />
            <YAxis
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v) => `${v}%`}
              domain={[10, 16]}
            />
            <Tooltip
              contentStyle={{
                borderRadius: '8px',
                border: '1px solid #e5e7eb',
                boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                fontSize: '12px',
              }}
              formatter={(value: unknown) => [`${value}%`, activeType === 'stunting' ? 'Stunting' : 'Wasting']}
            />
            <Line
              type="monotone"
              dataKey={activeType}
              stroke="#0d9488"
              strokeWidth={2.5}
              dot={{ r: 4, fill: '#0d9488', stroke: '#fff', strokeWidth: 2 }}
              activeDot={{ r: 6, fill: '#0d9488', stroke: '#fff', strokeWidth: 2 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default TrenRisikoChart;
