import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import { heatmapPoints } from '../../../shared/data/mockData';
import { Filter } from 'lucide-react';

// Custom red dot icon for markers
const redDotIcon = L.divIcon({
  className: 'custom-marker',
  html: '<div style="width:12px;height:12px;background:#ef4444;border-radius:50%;border:2px solid #fff;box-shadow:0 2px 4px rgba(0,0,0,0.3)"></div>',
  iconSize: [12, 12],
  iconAnchor: [6, 6],
});

const RiskMap = () => {
  const center: [number, number] = [-6.72, 106.83];

  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-5">
      {/* Header */}
      <div className="flex items-center justify-between mb-3">
        <div>
          <h3 className="text-base font-semibold text-gray-800">Peta Sebaran Risiko Stunting</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            Wilayah Kabupaten - Diperbaharui Terakhir: 12 Okt 2023
          </p>
        </div>
        <div className="flex items-center gap-3">
          {/* Legend */}
          <div className="flex items-center gap-2 text-[10px] text-gray-500">
            <span className="flex items-center gap-1">
              <span className="w-8 h-2 rounded-full bg-gradient-to-r from-green-400 to-green-500" />
              Aman
            </span>
            <span className="w-12 h-2 rounded-full bg-gradient-to-r from-yellow-400 via-orange-400 to-red-500" />
            <span>Bahaya</span>
          </div>
          <button className="p-2 border border-gray-200 rounded-lg hover:bg-gray-50 transition" aria-label="Filter peta">
            <Filter size={14} className="text-gray-500" />
          </button>
        </div>
      </div>

      {/* Map Container */}
      <div className="h-[320px] rounded-xl overflow-hidden border border-gray-200">
        <MapContainer
          center={center}
          zoom={12}
          scrollWheelZoom={true}
          style={{ height: '100%', width: '100%' }}
          zoomControl={true}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {heatmapPoints.map((point) => (
            <Marker key={point.id} position={[point.lat, point.lng]} icon={redDotIcon}>
              <Popup>
                <div className="font-sans p-1">
                  <p className="font-semibold text-sm text-gray-800">{point.nama}</p>
                  <div className="flex gap-4 mt-1.5 text-xs">
                    <div>
                      <span className="text-gray-400">RISIKO</span>
                      <p className="text-red-600 font-semibold">Tinggi ({point.risikoPersen}%)</p>
                    </div>
                    <div>
                      <span className="text-gray-400">ANAK</span>
                      <p className="text-gray-800 font-semibold">{point.totalAnak} Jiwa</p>
                    </div>
                  </div>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
    </div>
  );
};

export default RiskMap;
