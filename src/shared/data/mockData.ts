// ===== Mock Data untuk StuntGuard Dashboard =====
// TODO: replace mock with real API once backend ready

// ----- Dashboard Summary -----
export const dashboardSummary = {
  totalAnakTerdata: 12842,
  risikoTinggi: 412,
  posyanduAktif: 86,
  cakupanBulanIni: 92.4,
  deltaTotal: 12,
};

// ----- Top 5 Desa Prioritas -----
export const topDesaPrioritas = [
  { rank: 1, nama: 'Desa Mekar Jaya', persen: 92 },
  { rank: 2, nama: 'Desa Sukamaju', persen: 84 },
  { rank: 3, nama: 'Desa Bojongloa', persen: 68 },
  { rank: 4, nama: 'Desa Pasir Putih', persen: 52 },
  { rank: 5, nama: 'Desa Cihideung', persen: 45 },
];

// ----- Tren Tingkat Risiko (6 Bulan) -----
export const trenRisiko = [
  { bulan: 'Mei', stunting: 15.2, wasting: 8.1 },
  { bulan: 'Jun', stunting: 15.0, wasting: 7.8 },
  { bulan: 'Jul', stunting: 14.3, wasting: 7.5 },
  { bulan: 'Agu', stunting: 14.5, wasting: 7.2 },
  { bulan: 'Sep', stunting: 13.4, wasting: 6.9 },
  { bulan: 'Okt', stunting: 12.8, wasting: 6.5 },
];

// ----- Anak Risiko Tinggi (Flagged) -----
export const flaggedAnak = [
  { id: '1', inisial: 'AS', nama: 'Adit Saputra', posyandu: 'Mawar I', status: 'Gizi Buruk', statusType: 'tinggi' as const },
  { id: '2', inisial: 'NL', nama: 'Nisa Larasati', posyandu: 'Dahlia IV', status: 'Stunting', statusType: 'tinggi' as const },
  { id: '3', inisial: 'RA', nama: 'Rian Ardiansyah', posyandu: 'Anggrek II', status: 'Underweight', statusType: 'sedang' as const },
];

// ----- Heatmap Points (Peta) -----
export const heatmapPoints = [
  { id: '1', nama: 'Kecamatan Caringin', lat: -6.72, lng: 106.85, risikoPersen: 74, totalAnak: 154 },
  { id: '2', nama: 'Kecamatan Manggala', lat: -6.74, lng: 106.87, risikoPersen: 62, totalAnak: 198 },
  { id: '3', nama: 'Kecamatan Sukabumi', lat: -6.70, lng: 106.83, risikoPersen: 45, totalAnak: 132 },
  { id: '4', nama: 'Kecamatan Ciomas', lat: -6.73, lng: 106.80, risikoPersen: 38, totalAnak: 167 },
  { id: '5', nama: 'Kecamatan Dramaga', lat: -6.71, lng: 106.82, risikoPersen: 55, totalAnak: 143 },
];

// ----- Data Anak (Tabel) -----
export interface AnakData {
  id: string;
  inisial: string;
  nama: string;
  nik: string;
  usiaBulan: number;
  kelamin: 'Laki-laki' | 'Perempuan';
  posyandu: string;
  statusRisiko: 'Rendah' | 'Sedang' | 'Tinggi';
  tanggalKunjungan: string;
  statusKunjungan: string;
  statusKunjunganColor: 'green' | 'amber' | 'blue' | 'gray';
}

export const dataAnak: AnakData[] = [
  {
    id: '1', inisial: 'AR', nama: 'Aditya Rizky', nik: '3201234567890001',
    usiaBulan: 14, kelamin: 'Laki-laki', posyandu: 'Mawar I',
    statusRisiko: 'Tinggi', tanggalKunjungan: '10 Okt 2024',
    statusKunjungan: 'SUDAH TIMBANG', statusKunjunganColor: 'green',
  },
  {
    id: '2', inisial: 'SF', nama: 'Siti Fatimah', nik: '3201234567890002',
    usiaBulan: 28, kelamin: 'Perempuan', posyandu: 'Melati III',
    statusRisiko: 'Sedang', tanggalKunjungan: '08 Okt 2024',
    statusKunjungan: 'PERLU PANTAU', statusKunjunganColor: 'amber',
  },
  {
    id: '3', inisial: 'BK', nama: 'Budi Kusuma', nik: '3201234567890003',
    usiaBulan: 6, kelamin: 'Laki-laki', posyandu: 'Mawar II',
    statusRisiko: 'Rendah', tanggalKunjungan: '12 Okt 2024',
    statusKunjungan: 'NORMAL', statusKunjunganColor: 'green',
  },
  {
    id: '4', inisial: 'DA', nama: 'Dina Amalia', nik: '3201234567890004',
    usiaBulan: 42, kelamin: 'Perempuan', posyandu: 'Anggrek V',
    statusRisiko: 'Rendah', tanggalKunjungan: '05 Okt 2024',
    statusKunjungan: 'SELESAI', statusKunjunganColor: 'gray',
  },
];

export const dataAnakStats = {
  totalAnak: 1248,
  risikoTinggi: 42,
  perluRujukan: 18,
  sudahTimbang: 88,
};

// ----- Laporan -----
export const laporanStats = {
  totalDiperiksa: 1248,
  risikoSedang: 84,
  risikoTinggi: 12,
};

export const distribusiGizi = [
  { wilayah: 'Kel. A', normal: 320, sedang: 80, tinggi: 20 },
  { wilayah: 'Kel. B', normal: 280, sedang: 95, tinggi: 35 },
];
