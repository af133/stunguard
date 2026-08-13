import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { distribusiGizi } from '../../../shared/data/mockData';

const DistribusiChart = () => {
  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
      <h4 className="text-sm font-semibold text-gray-700 mb-5">Distribusi Status Gizi Wilayah</h4>
      <div className="h-[240px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={distribusiGizi} barGap={6} barCategoryGap="30%">
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" vertical={false} />
            <XAxis
              dataKey="wilayah"
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={{ stroke: '#e5e7eb' }}
              tickLine={false}
            />
            <YAxis
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={false}
              tickLine={false}
            />
            <Tooltip
              contentStyle={{
                borderRadius: '8px',
                border: '1px solid #e5e7eb',
                boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                fontSize: '12px',
              }}
            />
            <Legend
              iconType="circle"
              iconSize={8}
              wrapperStyle={{ fontSize: '12px', paddingTop: '8px' }}
            />
            <Bar dataKey="normal" name="Normal" fill="#15803d" radius={[4, 4, 0, 0]} />
            <Bar dataKey="sedang" name="Risiko Sedang" fill="#d97706" radius={[4, 4, 0, 0]} />
            <Bar dataKey="tinggi" name="Risiko Tinggi" fill="#ef4444" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default DistribusiChart;
