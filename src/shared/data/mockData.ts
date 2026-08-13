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
  { id: '1', nama: 'Kecamatan Caringin', lat: -6.72, lng: 106.85, risikoPersen: 74, totalAnak: 154, posyanduList: ['Mawar I', 'Mawar II', 'Melati I'] },
  { id: '2', nama: 'Kecamatan Manggala', lat: -6.74, lng: 106.87, risikoPersen: 62, totalAnak: 198, posyanduList: ['Anggrek I', 'Anggrek II'] },
  { id: '3', nama: 'Kecamatan Sukabumi', lat: -6.70, lng: 106.83, risikoPersen: 45, totalAnak: 132, posyanduList: ['Dahlia I', 'Dahlia II'] },
  { id: '4', nama: 'Kecamatan Ciomas', lat: -6.73, lng: 106.80, risikoPersen: 38, totalAnak: 167, posyanduList: ['Kenanga I', 'Kenanga II'] },
  { id: '5', nama: 'Kecamatan Dramaga', lat: -6.71, lng: 106.82, risikoPersen: 55, totalAnak: 143, posyanduList: ['Flamboyan I', 'Flamboyan II'] },
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
  namaIbu?: string;
  beratBadan?: number;
  tinggiBadan?: number;
}

export const dataAnak: AnakData[] = [
  {
    id: '1', inisial: 'AR', nama: 'Aditya Rizky', nik: '3201234567890001',
    usiaBulan: 14, kelamin: 'Laki-laki', posyandu: 'Mawar I',
    statusRisiko: 'Tinggi', tanggalKunjungan: '10 Okt 2024',
    statusKunjungan: 'SUDAH TIMBANG', statusKunjunganColor: 'green',
    namaIbu: 'Siti Rahma', beratBadan: 8.2, tinggiBadan: 71.5,
  },
  {
    id: '2', inisial: 'SF', nama: 'Siti Fatimah', nik: '3201234567890002',
    usiaBulan: 28, kelamin: 'Perempuan', posyandu: 'Melati III',
    statusRisiko: 'Sedang', tanggalKunjungan: '08 Okt 2024',
    statusKunjungan: 'PERLU PANTAU', statusKunjunganColor: 'amber',
    namaIbu: 'Nur Hasanah', beratBadan: 10.5, tinggiBadan: 82.0,
  },
  {
    id: '3', inisial: 'BK', nama: 'Budi Kusuma', nik: '3201234567890003',
    usiaBulan: 6, kelamin: 'Laki-laki', posyandu: 'Mawar II',
    statusRisiko: 'Rendah', tanggalKunjungan: '12 Okt 2024',
    statusKunjungan: 'NORMAL', statusKunjunganColor: 'green',
    namaIbu: 'Dewi Kartika', beratBadan: 7.4, tinggiBadan: 66.0,
  },
  {
    id: '4', inisial: 'DA', nama: 'Dina Amalia', nik: '3201234567890004',
    usiaBulan: 42, kelamin: 'Perempuan', posyandu: 'Anggrek V',
    statusRisiko: 'Rendah', tanggalKunjungan: '05 Okt 2024',
    statusKunjungan: 'SELESAI', statusKunjunganColor: 'gray',
    namaIbu: 'Rina Wijaya', beratBadan: 14.1, tinggiBadan: 97.2,
  },
];

export const dataAnakStats = {
  totalAnak: 1248,
  risikoTinggi: 42,
  perluRujukan: 18,
  sudahTimbang: 88,
};

// ----- Detail Balita & Kurva WHO -----
export const detailBalitaDemo = {
  id: '1',
  nama: 'Aditya Rizky',
  nik: '3201234567890001',
  tanggalLahir: '15 Agustus 2023',
  usiaBulan: 14,
  jenisKelamin: 'Laki-laki',
  namaIbu: 'Siti Rahma',
  noHpIbu: '081234567890',
  posyandu: 'Mawar I',
  kecamatan: 'Kecamatan Caringin',
  statusRisiko: 'Tinggi' as const,
  bbTerakhir: 8.2,
  tbTerakhir: 71.5,
  zscoreTB_U: -2.8,
  zscoreBB_U: -2.1,
  riwayatPertumbuhan: [
    { bulan: 6, tb: 63.0, bb: 6.8, date: 'Feb 2024', zscore: -1.2 },
    { bulan: 8, tb: 65.5, bb: 7.1, date: 'Apr 2024', zscore: -1.8 },
    { bulan: 10, tb: 67.2, bb: 7.5, date: 'Jun 2024', zscore: -2.1 },
    { bulan: 12, tb: 69.0, bb: 7.9, date: 'Agu 2024', zscore: -2.5 },
    { bulan: 14, tb: 71.5, bb: 8.2, date: 'Okt 2024', zscore: -2.8 },
  ],
  whoCurveData: [
    { bulan: 0, minus3SD: 44.2, minus2SD: 46.1, median: 49.9, plus2SD: 53.7, plus3SD: 55.6, anak: 49.0 },
    { bulan: 3, minus3SD: 55.3, minus2SD: 57.3, median: 61.4, plus2SD: 65.5, plus3SD: 67.6, anak: 59.5 },
    { bulan: 6, minus3SD: 61.2, minus2SD: 63.3, median: 67.6, plus2SD: 71.9, plus3SD: 74.0, anak: 63.0 },
    { bulan: 9, minus3SD: 65.2, minus2SD: 67.5, median: 72.0, plus2SD: 76.5, plus3SD: 78.7, anak: 66.3 },
    { bulan: 12, minus3SD: 68.6, minus2SD: 71.0, median: 75.7, plus2SD: 80.5, plus3SD: 82.9, anak: 69.0 },
    { bulan: 15, minus3SD: 71.6, minus2SD: 74.1, median: 79.1, plus2SD: 84.1, plus3SD: 86.6, anak: 71.5 },
  ],
  prediksiAI: {
    skorRisiko: 88,
    kategori: 'Tinggi',
    confidence: 0.94,
    faktorRisiko: [
      'Pertumbuhan tinggi badan di bawah -2.5 SD berturut-turut 3 bulan',
      'Asupan protein dan zat besi terindikasi kurang dari ambang batas',
      'Riwayat ISPA berulang dalam 6 bulan terakhir',
    ],
    rekomendasi: [
      'Pemberian Makanan Tambahan (PMT) berbahan protein hewani tinggi (Telur/Daging/Ikan)',
      'Rujukan segera ke Puskesmas Caringin untuk konsultasi Dokter Spesialis Anak',
      'Suplementasi Zinc dan Taburia harian selama 90 hari',
    ],
  },
};

// ----- Manajemen Posyandu & Kader (D-03) -----
export interface PosyanduData {
  id: string;
  nama: string;
  alamat: string;
  kelurahan: string;
  kecamatan: string;
  jumlahBalita: number;
  jumlahKader: number;
  status: 'Aktif' | 'Non-Aktif';
}

export interface KaderData {
  id: string;
  nama: string;
  posyandu: string;
  noHp: string;
  peran: string;
  status: 'Aktif' | 'Non-Aktif';
}

export const listPosyandu: PosyanduData[] = [
  { id: 'P01', nama: 'Posyandu Mawar I', alamat: 'Jl. Raya Caringin No. 12', kelurahan: 'Mekar Jaya', kecamatan: 'Caringin', jumlahBalita: 112, jumlahKader: 5, status: 'Aktif' },
  { id: 'P02', nama: 'Posyandu Melati III', alamat: 'Jl. Pemuda No. 45', kelurahan: 'Sukamaju', kecamatan: 'Caringin', jumlahBalita: 98, jumlahKader: 4, status: 'Aktif' },
  { id: 'P03', nama: 'Posyandu Anggrek V', alamat: 'Jl. Garuda No. 8', kelurahan: 'Bojongloa', kecamatan: 'Manggala', jumlahBalita: 135, jumlahKader: 6, status: 'Aktif' },
  { id: 'P04', nama: 'Posyandu Dahlia IV', alamat: 'Jl. Melati No. 23', kelurahan: 'Pasir Putih', kecamatan: 'Sukabumi', jumlahBalita: 84, jumlahKader: 4, status: 'Aktif' },
  { id: 'P05', nama: 'Posyandu Kenanga II', alamat: 'Jl. Mawar No. 17', kelurahan: 'Cihideung', kecamatan: 'Ciomas', jumlahBalita: 106, jumlahKader: 5, status: 'Aktif' },
];

export const listKader: KaderData[] = [
  { id: 'K01', nama: 'Sri Wahyuni', posyandu: 'Posyandu Mawar I', noHp: '081299887766', peran: 'Ketua Kader', status: 'Aktif' },
  { id: 'K02', nama: 'Endang Susilowati', posyandu: 'Posyandu Mawar I', noHp: '081377665544', peran: 'Kader Pengukur', status: 'Aktif' },
  { id: 'K03', nama: 'Mariana', posyandu: 'Posyandu Melati III', noHp: '085211223344', peran: 'Ketua Kader', status: 'Aktif' },
  { id: 'K04', nama: 'Titi Rahayu', posyandu: 'Posyandu Anggrek V', noHp: '087844556677', peran: 'Kader Pencatat', status: 'Aktif' },
  { id: 'K05', nama: 'Dewi Lestari', posyandu: 'Posyandu Dahlia IV', noHp: '089633221100', peran: 'Ketua Kader', status: 'Aktif' },
];

// ----- Sistem Alert (D-04) -----
export interface AlertData {
  id: string;
  judul: string;
  pesan: string;
  waktu: string;
  kategori: 'risiko_tinggi' | 'anomali' | 'laporan';
  read: boolean;
  balitaId?: string;
}

export const listAlerts: AlertData[] = [
  { id: 'A01', judul: 'Kasus Risiko Tinggi Baru', pesan: 'Balita Aditya Rizky (Mawar I) terdeteksi stunting berat (Z-Score TB/U -2.8).', waktu: '10 Menit yang lalu', kategori: 'risiko_tinggi', read: false, balitaId: '1' },
  { id: 'A02', judul: 'Penurunan Berat Badan Kritis', pesan: 'Balita Nisa Larasati mengalami penurunan BB >10% dalam 2 bulan berturut-turut.', waktu: '2 Jam yang lalu', kategori: 'risiko_tinggi', read: false, balitaId: '2' },
  { id: 'A03', judul: 'Laporan Bulanan Selesai', pesan: 'Laporan Rekapitulasi Gizi Kecamatan Caringin Oktober 2024 siap diunduh.', waktu: '1 Hari yang lalu', kategori: 'laporan', read: true },
  { id: 'A04', judul: 'Anomali Data Pengukuran', pesan: 'Pengisian tinggi badan 120cm pada balita usia 12 bulan di Posyandu Anggrek V terindikasi typo.', waktu: '2 Hari yang lalu', kategori: 'anomali', read: true },
];

// ----- Analitik Lanjutan (D-06) -----
export const analitikKomparatif = [
  { wilayah: 'Desa Mekar Jaya', prevalensi: 24.5, totalAnak: 420, kasusStunting: 103 },
  { wilayah: 'Desa Sukamaju', prevalensi: 19.8, totalAnak: 380, kasusStunting: 75 },
  { wilayah: 'Desa Bojongloa', prevalensi: 15.2, totalAnak: 510, kasusStunting: 78 },
  { wilayah: 'Desa Pasir Putih', prevalensi: 11.4, totalAnak: 310, kasusStunting: 35 },
  { wilayah: 'Desa Cihideung', prevalensi: 8.9, totalAnak: 290, kasusStunting: 26 },
];

export const proyeksiPrevalensi = [
  { bulan: 'Mei 24', historis: 15.2 },
  { bulan: 'Jun 24', historis: 15.0 },
  { bulan: 'Jul 24', historis: 14.3 },
  { bulan: 'Agu 24', historis: 14.5 },
  { bulan: 'Sep 24', historis: 13.4 },
  { bulan: 'Okt 24', historis: 12.8, proyeksi: 12.8, lowerBound: 12.8, upperBound: 12.8 },
  { bulan: 'Nov 24', proyeksi: 12.1, lowerBound: 11.4, upperBound: 12.9 },
  { bulan: 'Des 24', proyeksi: 11.5, lowerBound: 10.6, upperBound: 12.4 },
  { bulan: 'Jan 25', proyeksi: 10.8, lowerBound: 9.7, upperBound: 11.9 },
  { bulan: 'Feb 25', proyeksi: 10.2, lowerBound: 8.9, upperBound: 11.5 },
  { bulan: 'Mar 25', proyeksi: 9.5, lowerBound: 8.1, upperBound: 11.0 },
];

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
