import { Users, AlertTriangle, Building2, CheckCircle } from 'lucide-react';
import Layout from '../../shared/components/Layout';
import StatCard from '../../shared/components/StatCard';
import TrenRisikoChart from './components/TrenRisikoChart';
import RiskMap from './components/RiskMap';
import TopDesaPrioritas from './components/TopDesaPrioritas';
import FlaggedAnakTable from './components/FlaggedAnakTable';
import { dashboardSummary } from '../../shared/data/mockData';

const DashboardPage = () => {
  const s = dashboardSummary;

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Stat Cards Row */}
        <div className="grid grid-cols-4 gap-4">
          <StatCard
            title="Total Anak Terdata"
            value={s.totalAnakTerdata.toLocaleString('id-ID')}
            icon={Users}
            iconBgColor="bg-blue-50"
            iconColor="text-blue-600"
            badge={
              <span className="bg-green-100 text-green-700 text-[10px] font-semibold px-2 py-0.5 rounded-full">
                +{s.deltaTotal}%
              </span>
            }
          />
          <StatCard
            title="Risiko Tinggi"
            value={s.risikoTinggi.toLocaleString('id-ID')}
            icon={AlertTriangle}
            iconBgColor="bg-red-50"
            iconColor="text-red-500"
            badge={
              <span className="bg-red-100 text-red-600 text-[10px] font-semibold px-2 py-0.5 rounded-full">
                Kritis
              </span>
            }
          />
          <StatCard
            title="Posyandu Aktif"
            value={s.posyanduAktif}
            icon={Building2}
            iconBgColor="bg-amber-50"
            iconColor="text-amber-600"
            badge={
              <span className="bg-amber-100 text-amber-700 text-[10px] font-semibold px-2 py-0.5 rounded-full">
                Aktif
              </span>
            }
          />
          <StatCard
            title="Cakupan Bulan Ini"
            value={`${s.cakupanBulanIni}%`}
            icon={CheckCircle}
            iconBgColor="bg-green-50"
            iconColor="text-green-600"
            badge={
              <span className="bg-green-100 text-green-700 text-[10px] font-semibold px-2 py-0.5 rounded-full">
                Target 95%
              </span>
            }
          />
        </div>

        {/* Map + Top Desa */}
        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-2">
            <RiskMap />
          </div>
          <div className="col-span-1">
            <TopDesaPrioritas />
          </div>
        </div>

        {/* Tren + Flagged Table */}
        <div className="grid grid-cols-2 gap-6">
          <TrenRisikoChart />
          <FlaggedAnakTable />
        </div>
      </div>
    </Layout>
  );
};

export default DashboardPage;
