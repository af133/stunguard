import { CheckCircle, AlertTriangle, XCircle } from 'lucide-react';

type RiskLevel = 'Rendah' | 'Sedang' | 'Tinggi' | 'rendah' | 'sedang' | 'tinggi';

interface ColorBadgeProps {
  level: RiskLevel;
  size?: 'sm' | 'md';
}

const config = {
  rendah: {
    bg: 'bg-green-50',
    text: 'text-green-700',
    border: 'border-green-200',
    icon: CheckCircle,
    label: 'Rendah',
  },
  sedang: {
    bg: 'bg-amber-50',
    text: 'text-amber-700',
    border: 'border-amber-200',
    icon: AlertTriangle,
    label: 'Sedang',
  },
  tinggi: {
    bg: 'bg-red-50',
    text: 'text-red-600',
    border: 'border-red-200',
    icon: XCircle,
    label: 'Tinggi',
  },
};

const ColorBadge = ({ level, size = 'md' }: ColorBadgeProps) => {
  const key = level.toLowerCase() as 'rendah' | 'sedang' | 'tinggi';
  const c = config[key];
  const Icon = c.icon;

  const sizeClasses = size === 'sm'
    ? 'px-2 py-0.5 text-[10px] gap-1'
    : 'px-3 py-1 text-xs gap-1.5';

  return (
    <span
      className={`inline-flex items-center font-semibold rounded-full border ${c.bg} ${c.text} ${c.border} ${sizeClasses}`}
    >
      <Icon size={size === 'sm' ? 10 : 12} />
      {c.label}
    </span>
  );
};

export default ColorBadge;
