# AGENT.md — StuntGuard Web Dashboard

Dokumen ini adalah instruksi eksekusi untuk AI coding agent dalam membangun **web dashboard
StuntGuard** sesuai proposal "StuntGuard: Platform AI Multimodal untuk Deteksi Dini
Stunting". Dashboard ini dipakai oleh **petugas puskesmas** dan **admin dinas kesehatan**,
BUKAN oleh kader posyandu (yang memakai mobile app) maupun orang tua balita.

## 0. Peran Agent

Anda adalah agent pengembang frontend yang membangun web dashboard monitoring berbasis
React.js. Kerjakan secara bertahap sesuai bagian 6, dan pastikan setiap halaman terhubung
ke API backend sesuai kontrak di bagian 8 (lihat juga `agent.md` backend untuk detail
endpoint).

## 1. Ringkasan Produk

Web dashboard StuntGuard menyediakan:
- Monitoring real-time data stunting dari seluruh posyandu di wilayah kerja
- Visualisasi heatmap persebaran risiko per desa/kelurahan
- Manajemen data posyandu & kader
- Sistem alert otomatis untuk kasus risiko tinggi
- Ekspor laporan otomatis ke format Kemenkes (PDF/Excel)
- Analitik lanjutan: tren, perbandingan wilayah, proyeksi prevalensi

## 2. Batasan Wajib

- Browser target: **Google Chrome v90+ dan Mozilla Firefox v88+**, layar minimal
  **1280×720px**. Jangan optimalkan untuk mobile-first/responsive kecil — ini adalah tool
  kerja desktop untuk petugas kantor.
- Bahasa antarmuka: **Bahasa Indonesia saja**.
- Dua level akses wajib: **Petugas Puskesmas** dan **Admin Dinas Kesehatan**. Role-Based
  Access Control (RBAC) harus jelas dipisah di level UI maupun API call.
- Kapasitas yang diasumsikan: hingga 10.000 rekam balita aktif per instansi puskesmas dalam
  satu instance — desain pagination/virtualisasi tabel dengan asumsi ini, jangan fetch semua
  data sekaligus tanpa pagination.
- TIDAK ada integrasi BPJS/SatuSehat/SIMRS di fase ini.
- Dashboard ini TIDAK punya alur untuk kader posyandu atau orang tua balita — jangan
  tambahkan halaman/role untuk mereka di sini.

## 3. Tech Stack (Wajib Dipakai)

| Layer | Teknologi |
|---|---|
| Framework | React.js |
| Visualisasi data/chart | Recharts |
| Peta/Heatmap | Library GIS yang mendukung layer heatmap (mis. Leaflet + plugin heatmap, atau Mapbox GL JS) — pilih salah satu dan konsisten |
| State management | React Query / TanStack Query untuk data server, Zustand atau Context API untuk state UI lokal |
| Styling | Tailwind CSS (sesuai konvensi frontend-design environment ini jika dipakai sebagai artifact; untuk proyek standalone, boleh CSS modules/Tailwind) |
| HTTP client | `axios` atau `fetch` wrapper |
| Auth | JWT-based, simpan token di httpOnly cookie atau secure storage (jangan localStorage untuk token sensitif) |
| Export PDF/Excel | Panggil endpoint backend yang generate file (lihat bagian 8.5) — jangan generate PDF/Excel di sisi klien |

## 4. Arsitektur Frontend

```
src/
  app/
    routes.tsx            # routing utama + route guard berbasis role
    providers.tsx          # query client, auth provider, theme provider
  features/
    auth/
      components/ hooks/ api/
    dashboard-beranda/      # D-02
      components/ hooks/ api/
    peta-risiko/             # D-01
      components/ hooks/ api/
    manajemen-posyandu/       # D-03
      components/ hooks/ api/
    alert/                     # D-04
      components/ hooks/ api/
    laporan/                    # D-05
      components/ hooks/ api/
    analitik/                    # D-06
      components/ hooks/ api/
    data-anak/                    # CRUD balita level dashboard (read-mostly, koreksi data)
      components/ hooks/ api/
  shared/
    components/             # Sidebar, Header, Table, Pagination, ColorBadge (risiko)
    hooks/
    lib/                     # axios instance, formatters (tanggal, angka)
    types/
  styles/
```

## 5. Spesifikasi Fitur (Wajib, Mapping ke Bagian F.1.2 Proposal)

| ID | Fitur | Detail Implementasi |
|---|---|---|
| D-01 | Peta Risiko Wilayah | Heatmap interaktif persebaran kasus stunting per desa/kelurahan. Klik area → buka panel detail posyandu di wilayah itu (list balita risiko sedang/tinggi). Filter: rentang tanggal, kategori risiko. |
| D-02 | Monitoring Real-Time | Halaman beranda: kartu statistik (jumlah balita terdaftar, jumlah risiko sedang-tinggi, tren prevalensi bulan ini vs bulan lalu — gunakan komponen chart line/area dari Recharts). |
| D-03 | Manajemen Posyandu | CRUD data posyandu, kader, dan cakupan wilayah kerja. Tabel dengan pagination & search. Hanya Admin Dinas Kesehatan yang bisa hapus posyandu; Petugas Puskesmas hanya bisa lihat/edit wilayahnya. |
| D-04 | Sistem Alert | Notifikasi otomatis (ikon lonceng di header) saat ditemukan kasus risiko tinggi baru di wilayah kerja pengguna login. Juga dikirim via email (delegasi ke backend). Badge counter unread. |
| D-05 | Pelaporan Otomatis | Form pilih: jenis laporan (Bulanan/Triwulanan/Tahunan), rentang tanggal, cakupan wilayah, format (PDF template Kemenkes / Excel). Tombol "Generate Laporan" memanggil endpoint backend, tampilkan progress/loading state (proses 1-3 menit), lalu link download saat selesai. |
| D-06 | Analitik Lanjutan | Analisis tren historis, perbandingan antar wilayah (chart bar/line komparatif), proyeksi prevalensi (tampilkan sebagai chart dengan area confidence jika data dari backend menyediakannya). |
| (tambahan) Data Anak | Tabel data balita per posyandu/wilayah, dengan kolom status risiko berkode warna (hijau/kuning/merah), dapat di-drill-down ke detail riwayat pertumbuhan individual (grafik kurva WHO, sama prinsipnya dengan F-07 di mobile). |

## 6. Urutan Eksekusi (Fase Kerja untuk Agent)

1. **Setup project**: inisialisasi React (Vite disarankan), setup routing, layout dasar
   (Sidebar + Header + content area) sesuai mockup proposal bagian H.2 (skema warna
   biru-teal konsisten dengan mobile app).
2. **Auth & RBAC**: halaman login, penyimpanan token, route guard berdasarkan role
   (Petugas Puskesmas vs Admin Dinas Kesehatan). Redirect otomatis jika role tidak sesuai.
3. **D-02 Dashboard Beranda**: kartu statistik + chart tren ringkas. Ini halaman pertama
   yang dilihat user, prioritaskan agar terlihat solid lebih dulu.
4. **Data Anak (tabel balita)**: tabel dengan pagination, filter risiko, search, drill-down
   ke detail individual dengan grafik kurva pertumbuhan.
5. **D-01 Peta Risiko Wilayah**: integrasi library peta, layer heatmap dari data agregat
   backend per desa/kelurahan, filter tanggal & kategori risiko.
6. **D-03 Manajemen Posyandu**: CRUD posyandu & kader, dengan pembatasan akses sesuai role.
7. **D-04 Sistem Alert**: komponen notifikasi bell + badge, polling atau WebSocket ke
   backend (pilih sesuai kapabilitas backend — default ke polling interval jika WebSocket
   belum tersedia).
8. **D-05 Pelaporan Otomatis**: form generate laporan + status job (processing/ready) +
   link download.
9. **D-06 Analitik Lanjutan**: chart perbandingan & proyeksi, bagian ini bisa paling akhir
   karena bergantung pada ketersediaan endpoint analitik backend yang lebih kompleks.
10. **QA pass**: cek semua role guard, cek tabel besar (≥10.000 baris dummy) tidak nge-lag
    (pastikan pagination/virtualization bekerja), cek semua chart re-render benar saat
    filter berubah.

## 7. Komponen UI Wajib (Konsistensi Visual)

- **ColorBadge Risiko**: komponen badge dengan 3 state warna standar — hijau (rendah),
  kuning (sedang), merah (tinggi). Gunakan komponen yang SAMA di semua halaman (tabel,
  detail, peta legend) agar konsisten.
- **Sidebar navigasi**: item menu sesuai D-01 s.d D-06 + Data Anak, ikon konsisten dengan
  mobile app (skema biru-teal, ikon intuitif sesuai mockup bagian H.2.1).
- **Empty state & loading state**: setiap halaman data wajib punya state kosong yang jelas
  (misal "Belum ada data risiko tinggi di wilayah ini") dan loading skeleton, jangan
  spinner generik tanpa konteks.

## 8. Kontrak API yang Diharapkan dari Backend

Frontend mengasumsikan backend menyediakan endpoint berikut (selaraskan dengan
`agent.md` backend; jika ada perbedaan, frontend agent harus menyesuaikan, bukan
sebaliknya, karena backend adalah sumber kebenaran data):

8.1. `POST /api/auth/login` → `{ token, role, nama, wilayah_kerja }`
8.2. `GET /api/dashboard/summary?wilayah=` → statistik ringkas untuk D-02
8.3. `GET /api/risiko/heatmap?from=&to=&kategori=` → data agregat per desa/kelurahan untuk
     D-01 (format GeoJSON atau array koordinat + skor agregat)
8.4. `GET /api/balita?page=&limit=&search=&kategori_risiko=&wilayah=` → list balita dengan
     pagination untuk Data Anak
8.5. `POST /api/laporan/generate` body `{ jenis, from, to, wilayah, format }` → job id, lalu
     `GET /api/laporan/status/:jobId` untuk polling status dan link download saat selesai
8.6. `GET /api/posyandu` / `POST` / `PUT` / `DELETE` → CRUD D-03
8.7. `GET /api/alert?unread=true` + endpoint mark-as-read → D-04
8.8. `GET /api/analitik/tren?wilayah=&periode=` dan `GET /api/analitik/proyeksi?wilayah=` →
     D-06

Jika endpoint belum tersedia saat development frontend dimulai, buat mock service layer
(`src/shared/lib/mockApi.ts`) dengan data dummy yang mengikuti skema di atas persis, beri
komentar `// TODO: replace mock with real API once backend ready`, agar mudah di-swap nanti.

## 9. Definition of Done

Sebuah fitur dianggap selesai jika:
- Mengikuti struktur folder bagian 4.
- RBAC diterapkan dan diuji untuk kedua role (Petugas Puskesmas, Admin Dinas Kesehatan).
- Tabel besar memakai pagination/virtualization, tidak fetch semua data sekaligus.
- Semua state warna risiko konsisten menggunakan komponen `ColorBadge` yang sama.
- Empty state dan loading state ada di setiap halaman data.
- Tidak ada hardcoded data di luar mock layer yang sudah ditandai TODO.

## 10. Yang TIDAK Boleh Dilakukan Agent

- Jangan membuat halaman/akses untuk kader posyandu atau orang tua balita di dashboard ini.
- Jangan generate PDF/Excel di sisi klien — selalu delegasikan ke backend.
- Jangan simpan token JWT di localStorage tanpa pertimbangan keamanan (gunakan httpOnly
  cookie jika backend mendukung, atau minimal dokumentasikan trade-off jika terpaksa pakai
  localStorage di tahap awal).
- Jangan optimalkan untuk layar di bawah 1280px — ini bukan target platform fase ini.
