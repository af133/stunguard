import type { LucideIcon } from 'lucide-react';
import type { ReactNode } from 'react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  iconBgColor?: string;
  iconColor?: string;
  sub?: string;
  subColor?: string;
  badge?: ReactNode;
}

const StatCard = ({
  title,
  value,
  icon: Icon,
  iconBgColor = 'bg-blue-50',
  iconColor = 'text-blue-600',
  sub,
  subColor = 'text-green-600',
  badge,
}: StatCardProps) => {
  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5 flex-1 min-w-0">
      <div className="flex items-start justify-between mb-3">
        <div className={`w-10 h-10 rounded-xl ${iconBgColor} flex items-center justify-center`}>
          <Icon size={20} className={iconColor} />
        </div>
        {badge && <div>{badge}</div>}
      </div>
      <p className="text-xs text-gray-400 font-semibold uppercase tracking-wider mb-1">{title}</p>
      <h3 className="text-3xl font-bold text-gray-800 leading-none">{value}</h3>
      {sub && (
        <p className={`text-xs mt-1.5 font-medium ${subColor}`}>{sub}</p>
      )}
    </div>
  );
};

export default StatCard;
