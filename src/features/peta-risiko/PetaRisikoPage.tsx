import { useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import { Filter, Calendar, MapPin, X, Building2, Users, AlertTriangle } from 'lucide-react';
import Layout from '../../shared/components/Layout';
import ColorBadge from '../../shared/components/ColorBadge';
import { heatmapPoints } from '../../shared/data/mockData';

const redDotIcon = L.divIcon({
  className: 'custom-marker',
  html: '<div style="width:16px;height:16px;background:#ef4444;border-radius:50%;border:3px solid #fff;box-shadow:0 3px 6px rgba(0,0,0,0.3)"></div>',
  iconSize: [16, 16],
  iconAnchor: [8, 8],
});

const PetaRisikoPage = () => {
  const [selectedPoint, setSelectedPoint] = useState<typeof heatmapPoints[0] | null>(null);
  const center: [number, number] = [-6.72, 106.83];

  return (
    <Layout>
      <div className="max-w-[1200px] mx-auto space-y-6">
        {/* Page Header */}
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Peta Risiko Wilayah (Heatmap)</h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Visualisasi pemetaan tingkat kerentanan stunting per kecamatan dan posyandu
            </p>
          </div>

          <div className="flex items-center gap-3 bg-white p-1.5 border border-gray-200 rounded-xl">
            <span className="text-xs text-gray-500 font-medium px-2">Indikator:</span>
            <div className="flex items-center gap-1.5 text-xs font-semibold px-2 py-1 bg-green-50 text-green-700 rounded-lg">
              <span className="w-2 h-2 rounded-full bg-green-500" />
              Rendah (&lt;30%)
            </div>
            <div className="flex items-center gap-1.5 text-xs font-semibold px-2 py-1 bg-amber-50 text-amber-700 rounded-lg">
              <span className="w-2 h-2 rounded-full bg-amber-500" />
              Sedang (30-60%)
            </div>
            <div className="flex items-center gap-1.5 text-xs font-semibold px-2 py-1 bg-red-50 text-red-600 rounded-lg">
              <span className="w-2 h-2 rounded-full bg-red-500" />
              Tinggi (&gt;60%)
            </div>
          </div>
        </div>

        {/* Filter Bar */}
        <div className="bg-white p-4 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="flex items-center gap-2 text-sm text-gray-500 font-medium">
            <Filter size={16} />
            <span>Filter Peta:</span>
          </div>

          <div className="relative">
            <input
              type="text"
              defaultValue="Periode: Okt 2024"
              className="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium text-gray-700"
              readOnly
            />
            <Calendar size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          </div>

          <div className="relative">
            <input
              type="text"
              defaultValue="Semua Kecamatan"
              className="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium text-gray-700"
              readOnly
            />
            <MapPin size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          </div>

          <button className="text-xs font-semibold text-green-700 hover:text-green-800 ml-auto">
            Reset Filter
          </button>
        </div>

        {/* Map Container + Detail Drawer Layout */}
        <div className="relative bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden h-[540px]">
          <MapContainer
            center={center}
            zoom={12}
            scrollWheelZoom={true}
            style={{ height: '100%', width: '100%' }}
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            {heatmapPoints.map((point) => (
              <Marker
                key={point.id}
                position={[point.lat, point.lng]}
                icon={redDotIcon}
                eventHandlers={{
                  click: () => setSelectedPoint(point),
                }}
              >
                <Popup>
                  <div className="p-1 font-sans">
                    <p className="font-bold text-sm text-gray-800">{point.nama}</p>
                    <p className="text-xs text-red-600 font-semibold mt-1">
                      Risiko Tinggi: {point.risikoPersen}%
                    </p>
                    <button
                      onClick={() => setSelectedPoint(point)}
                      className="mt-2 text-xs bg-green-800 text-white px-2.5 py-1 rounded-md font-medium"
                    >
                      Buka Detail Posyandu
                    </button>
                  </div>
                </Popup>
              </Marker>
            ))}
          </MapContainer>

          {/* Drawer Detail Posyandu Overlay */}
          {selectedPoint && (
            <div className="absolute top-0 right-0 w-[360px] h-full bg-white border-l border-gray-200 shadow-2xl p-6 z-20 flex flex-col justify-between overflow-y-auto">
              <div>
                <div className="flex items-center justify-between pb-4 border-b border-gray-100 mb-4">
                  <div>
                    <h3 className="text-base font-bold text-gray-800">{selectedPoint.nama}</h3>
                    <p className="text-xs text-gray-400">Detail Cakupan Wilayah</p>
                  </div>
                  <button
                    onClick={() => setSelectedPoint(null)}
                    className="p-1.5 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100"
                  >
                    <X size={18} />
                  </button>
                </div>

                {/* Summary Cards */}
                <div className="grid grid-cols-2 gap-3 mb-6">
                  <div className="bg-red-50 p-3 rounded-xl border border-red-100">
                    <div className="flex items-center gap-1.5 text-red-600 mb-1">
                      <AlertTriangle size={14} />
                      <span className="text-[10px] font-bold uppercase">Tingkat Risiko</span>
                    </div>
                    <p className="text-2xl font-bold text-red-600">{selectedPoint.risikoPersen}%</p>
                  </div>

                  <div className="bg-blue-50 p-3 rounded-xl border border-blue-100">
                    <div className="flex items-center gap-1.5 text-blue-600 mb-1">
                      <Users size={14} />
                      <span className="text-[10px] font-bold uppercase">Total Balita</span>
                    </div>
                    <p className="text-2xl font-bold text-blue-800">{selectedPoint.totalAnak}</p>
                  </div>
                </div>

                {/* Posyandu List in this District */}
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">
                  Daftar Posyandu Terdaftar
                </h4>
                <div className="space-y-2.5">
                  {selectedPoint.posyanduList.map((pos, idx) => (
                    <div
                      key={idx}
                      className="p-3 bg-gray-50 border border-gray-100 rounded-xl flex items-center justify-between"
                    >
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-lg bg-green-100 text-green-700 flex items-center justify-center">
                          <Building2 size={16} />
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-gray-800">{pos}</p>
                          <p className="text-[10px] text-gray-400">Aktif • 5 Kader</p>
                        </div>
                      </div>
                      <ColorBadge level="tinggi" size="sm" />
                    </div>
                  ))}
                </div>
              </div>

              <div className="pt-4 border-t border-gray-100">
                <button
                  onClick={() => setSelectedPoint(null)}
                  className="w-full py-2.5 bg-gray-100 text-gray-700 text-xs font-semibold rounded-xl hover:bg-gray-200"
                >
                  Tutup Panel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
};

export default PetaRisikoPage;
