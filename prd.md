# 📋 PRD — StuntGuard Web Dashboard

> **Dokumen ini berfungsi sebagai Product Requirements Document (PRD) sekaligus progress tracker
> untuk pengembangan frontend web dashboard StuntGuard.**
>
> Terakhir diperbarui: **13 Agustus 2026**

---

## 1. Ringkasan Produk

**StuntGuard Web Dashboard** adalah platform monitoring stunting berbasis web yang digunakan oleh
**Petugas Puskesmas** dan **Admin Dinas Kesehatan** untuk:

- Monitoring real-time data stunting dari seluruh posyandu di wilayah kerja
- Visualisasi heatmap persebaran risiko per desa/kelurahan
- Manajemen data posyandu & kader
- Sistem alert otomatis untuk kasus risiko tinggi
- Ekspor laporan otomatis ke format Kemenkes (PDF/Excel)
- Analitik lanjutan: tren, perbandingan wilayah, proyeksi prevalensi

### Target Pengguna

| Role | Deskripsi | Akses |
|---|---|---|
| Petugas Puskesmas | Petugas kesehatan di level puskesmas | Lihat/edit data wilayah sendiri |
| Admin Dinas Kesehatan | Admin di level dinas kabupaten/kota | Full access, termasuk hapus posyandu |

> ⚠️ Dashboard ini **BUKAN** untuk kader posyandu atau orang tua balita.

---

## 2. Tech Stack

| Layer | Teknologi | Status |
|---|---|---|
| Framework | React 19 + TypeScript | ✅ Terinstall |
| Build Tool | Vite 8 | ✅ Terinstall |
| Styling | Tailwind CSS 4 | ✅ Terinstall |
| Routing | React Router DOM 7 | ✅ Terinstall |
| Icons | Lucide React | ✅ Terinstall |
| Visualisasi Chart | Recharts | ❌ Belum terinstall |
| Peta/Heatmap | Leaflet + heatmap plugin | ❌ Belum terinstall |
| State Management (Server) | TanStack Query | ❌ Belum terinstall |
| State Management (UI) | Zustand | ❌ Belum terinstall |
| HTTP Client | Axios | ❌ Belum terinstall |

---

## 3. Arsitektur Folder (Target vs Saat Ini)

### Target (sesuai agent.md §4)

```
src/
  app/
    routes.tsx              # routing utama + route guard berbasis role
    providers.tsx           # query client, auth provider, theme provider
  features/
    auth/                   # Login, token management
      components/ hooks/ api/
    dashboard-beranda/      # D-02 - Monitoring Real-Time
      components/ hooks/ api/
    peta-risiko/            # D-01 - Heatmap Wilayah
      components/ hooks/ api/
    manajemen-posyandu/     # D-03 - CRUD Posyandu & Kader
      components/ hooks/ api/
    alert/                  # D-04 - Sistem Notifikasi
      components/ hooks/ api/
    laporan/                # D-05 - Pelaporan Otomatis
      components/ hooks/ api/
    analitik/               # D-06 - Analitik Lanjutan
      components/ hooks/ api/
    data-anak/              # CRUD Balita (tabel, drill-down)
      components/ hooks/ api/
  shared/
    components/             # Sidebar, Header, Table, Pagination, ColorBadge
    hooks/
    lib/                    # axios instance, formatters, mockApi.ts
    types/
  styles/
```

### Saat Ini (existing)

```
src/
  assets/                   # hero.png, react.svg, vite.svg
  components/
    Sidebar.tsx             # ⚠️ Belum sesuai struktur target
    Topbar.tsx              # ⚠️ Belum sesuai struktur target
  layouts/
    Layout.tsx              # ⚠️ Layout dasar ada, belum ada route guard
  pages/
    DashboardPage.tsx       # ⚠️ Isinya halaman Laporan, bukan Dashboard Beranda
  routes/
    AdminRoutes.tsx         # ⚠️ Hanya 1 route (/dashboard-admin)
    Nakes.tsx               # ❌ File kosong
  App.tsx
  App.css
  main.tsx
```

---

## 4. Progress Tracking — Fase Eksekusi

Berdasarkan agent.md §6, berikut adalah 10 fase kerja dan status masing-masing:

### Fase 1: Setup Project ⚠️ SEBAGIAN

| Item | Status | Catatan |
|---|---|---|
| Inisialisasi React + Vite + TypeScript | ✅ Selesai | Vite 8, React 19, TS 6 |
| Setup Tailwind CSS | ✅ Selesai | Tailwind v4 via @tailwindcss/vite |
| Setup React Router DOM | ✅ Selesai | v7.18.1 |
| Layout dasar (Sidebar + Header + Content) | ⚠️ Parsial | Ada tapi belum mengikuti arsitektur target |
| Skema warna biru-teal konsisten | ❌ Belum | Saat ini menggunakan hijau (green-700/800) |
| Instalasi dependency wajib (Recharts, Leaflet, TanStack Query, Zustand, Axios) | ❌ Belum | Belum ada di package.json |
| Restrukturisasi folder sesuai arsitektur target (§4) | ❌ Belum | Masih pakai struktur pages/components/routes lama |
| Setup mockApi.ts untuk development tanpa backend | ❌ Belum | — |

### Fase 2: Auth & RBAC ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Halaman Login | ❌ Belum | — |
| Penyimpanan token (httpOnly cookie / secure storage) | ❌ Belum | — |
| Auth Provider / Context | ❌ Belum | — |
| Route Guard berdasarkan role (Petugas Puskesmas vs Admin Dinkes) | ❌ Belum | — |
| Redirect otomatis jika role tidak sesuai | ❌ Belum | — |
| API: `POST /api/auth/login` | ❌ Belum | — |

### Fase 3: D-02 Dashboard Beranda ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Kartu statistik (total balita, risiko sedang-tinggi) | ⚠️ Parsial | Ada StatCard di DashboardPage.tsx tapi isinya data laporan, bukan dashboard beranda |
| Chart tren prevalensi (line/area, Recharts) | ❌ Belum | Hanya ada placeholder bar chart statis (div) |
| Tren bulan ini vs bulan lalu | ❌ Belum | — |
| Loading state & empty state | ❌ Belum | — |
| API: `GET /api/dashboard/summary` | ❌ Belum | — |

### Fase 4: Data Anak (Tabel Balita) ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Tabel balita dengan pagination | ❌ Belum | — |
| Filter risiko (hijau/kuning/merah) | ❌ Belum | — |
| Search balita | ❌ Belum | — |
| Drill-down ke detail individual | ❌ Belum | — |
| Grafik kurva pertumbuhan WHO | ❌ Belum | — |
| Komponen ColorBadge risiko | ❌ Belum | — |
| Loading state & empty state | ❌ Belum | — |
| API: `GET /api/balita?page=&limit=&search=&kategori_risiko=&wilayah=` | ❌ Belum | — |

### Fase 5: D-01 Peta Risiko Wilayah ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Integrasi library peta (Leaflet) | ❌ Belum | — |
| Layer heatmap interaktif | ❌ Belum | — |
| Klik area → panel detail posyandu | ❌ Belum | — |
| Filter: rentang tanggal, kategori risiko | ❌ Belum | — |
| Loading state & empty state | ❌ Belum | — |
| API: `GET /api/risiko/heatmap` | ❌ Belum | — |

### Fase 6: D-03 Manajemen Posyandu ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| CRUD data posyandu | ❌ Belum | — |
| CRUD data kader | ❌ Belum | — |
| Tabel dengan pagination & search | ❌ Belum | — |
| Pembatasan akses sesuai role | ❌ Belum | — |
| Loading state & empty state | ❌ Belum | — |
| API: `GET/POST/PUT/DELETE /api/posyandu` | ❌ Belum | — |

### Fase 7: D-04 Sistem Alert ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Komponen notifikasi bell di header | ❌ Belum | — |
| Badge counter unread | ❌ Belum | — |
| Polling / WebSocket ke backend | ❌ Belum | — |
| Panel daftar alert | ❌ Belum | — |
| Mark as read | ❌ Belum | — |
| API: `GET /api/alert?unread=true` | ❌ Belum | — |

### Fase 8: D-05 Pelaporan Otomatis ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Form pilih jenis laporan | ⚠️ Parsial | Ada form di DashboardPage.tsx tapi belum fungsional |
| Pilih format (PDF/Excel) | ⚠️ Parsial | Ada tombol download tapi belum terhubung API |
| Progress/loading state saat generate | ❌ Belum | — |
| Link download saat selesai | ❌ Belum | — |
| API: `POST /api/laporan/generate` + polling status | ❌ Belum | — |

### Fase 9: D-06 Analitik Lanjutan ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Chart tren historis | ❌ Belum | — |
| Perbandingan antar wilayah (bar/line komparatif) | ❌ Belum | — |
| Proyeksi prevalensi (area + confidence) | ❌ Belum | — |
| Loading state & empty state | ❌ Belum | — |
| API: `GET /api/analitik/tren` + `GET /api/analitik/proyeksi` | ❌ Belum | — |

### Fase 10: QA Pass ❌ BELUM

| Item | Status | Catatan |
|---|---|---|
| Cek semua role guard (kedua role) | ❌ Belum | — |
| Cek tabel besar (≥10.000 baris dummy) | ❌ Belum | — |
| Pagination/virtualization bekerja | ❌ Belum | — |
| Chart re-render benar saat filter berubah | ❌ Belum | — |
| Konsistensi ColorBadge di semua halaman | ❌ Belum | — |
| Empty state & loading state di setiap halaman | ❌ Belum | — |

---

## 5. Ringkasan Progress Keseluruhan

```
██░░░░░░░░░░░░░░░░░░  ~10%
```

| Fase | Nama | Status | Progres |
|---|---|---|---|
| 1 | Setup Project | ⚠️ Sebagian | ~40% |
| 2 | Auth & RBAC | ❌ Belum | 0% |
| 3 | D-02 Dashboard Beranda | ❌ Belum | ~5% |
| 4 | Data Anak (Tabel Balita) | ❌ Belum | 0% |
| 5 | D-01 Peta Risiko Wilayah | ❌ Belum | 0% |
| 6 | D-03 Manajemen Posyandu | ❌ Belum | 0% |
| 7 | D-04 Sistem Alert | ❌ Belum | 0% |
| 8 | D-05 Pelaporan Otomatis | ❌ Belum | ~10% |
| 9 | D-06 Analitik Lanjutan | ❌ Belum | 0% |
| 10 | QA Pass | ❌ Belum | 0% |

---

## 6. Temuan & Isu dari Audit Kode Saat Ini

### 🔴 Isu Kritis

1. **Struktur folder tidak sesuai arsitektur target** — Masih menggunakan `pages/`, `components/`, `routes/` flat alih-alih `app/`, `features/`, `shared/` sesuai agent.md §4.

2. **DashboardPage.tsx isinya halaman Laporan** — File bernama "DashboardPage" tapi kontennya adalah halaman generate laporan (D-05), bukan Dashboard Beranda (D-02). Ini harus dipindah/direname.

3. **Skema warna salah** — Agent.md §6.1 mewajibkan skema warna **biru-teal** konsisten dengan mobile app. Saat ini menggunakan **hijau (green-700/800)**. Harus diganti.

4. **Tidak ada Auth/RBAC sama sekali** — Tidak ada login page, token storage, route guard, maupun role differentiation.

5. **Dependency kritis belum terinstall** — Recharts, Leaflet, TanStack Query, Zustand, dan Axios belum ada di package.json.

### 🟡 Isu Sedang

6. **Sidebar navigasi tidak lengkap** — Hanya ada 4 menu (Dashboard, Data Anak, Laporan, Pengaturan). Seharusnya ada menu untuk D-01 s.d D-06 + Data Anak sesuai agent.md §7.

7. **Topbar hardcoded** — Nama user ("Dr. Siti Aminah") dan role ("Kepala Puskesmas") di-hardcode, seharusnya dinamis dari auth state.

8. **Nakes.tsx kosong** — File route kosong, tidak ada implementasi.

9. **Routing minimal** — Hanya ada 1 route (`/dashboard-admin`). Belum ada route untuk halaman lain.

10. **Tidak ada empty state & loading state** — Semua data di-hardcode langsung tanpa loading skeleton atau empty state.

### 🟢 Yang Sudah Baik

11. Layout dasar (Sidebar + Topbar + Content area) sudah ada dan fungsional.
12. Vite + React + TypeScript sudah ter-setup dengan benar.
13. Tailwind CSS v4 sudah berjalan.
14. Komponen StatCard bisa di-reuse untuk dashboard.

---

## 7. Rencana Aksi Selanjutnya

Berdasarkan audit di atas, pekerjaan harus dimulai dari **Fase 1 (Setup Project)** yang perlu dilengkapi, kemudian lanjut ke **Fase 2 (Auth & RBAC)**.

### Urutan prioritas:

1. **Install dependency yang kurang** (Recharts, Leaflet, TanStack Query, Zustand, Axios)
2. **Restrukturisasi folder** sesuai arsitektur target agent.md §4
3. **Ganti skema warna** ke biru-teal
4. **Buat mockApi.ts** untuk development tanpa backend
5. **Implementasi Auth & RBAC** (Login page, token management, route guard)
6. **Bangun D-02 Dashboard Beranda** (halaman pertama yang dilihat user)
7. Lanjut fase berikutnya secara berurutan

---

## 8. Kontrak API (Referensi)

| ID | Endpoint | Method | Kegunaan |
|---|---|---|---|
| 8.1 | `/api/auth/login` | POST | Login, return token + role |
| 8.2 | `/api/dashboard/summary?wilayah=` | GET | Statistik ringkas D-02 |
| 8.3 | `/api/risiko/heatmap?from=&to=&kategori=` | GET | Data heatmap D-01 |
| 8.4 | `/api/balita?page=&limit=&search=&kategori_risiko=&wilayah=` | GET | List balita + pagination |
| 8.5 | `/api/laporan/generate` | POST | Generate laporan |
| 8.5b | `/api/laporan/status/:jobId` | GET | Polling status laporan |
| 8.6 | `/api/posyandu` | CRUD | Manajemen posyandu D-03 |
| 8.7 | `/api/alert?unread=true` | GET | Alert D-04 |
| 8.8 | `/api/analitik/tren?wilayah=&periode=` | GET | Tren analitik D-06 |
| 8.8b | `/api/analitik/proyeksi?wilayah=` | GET | Proyeksi D-06 |

---

## 9. Definition of Done (per Fitur)

Sebuah fitur dianggap selesai jika:

- [ ] Mengikuti struktur folder arsitektur target (§4 agent.md)
- [ ] RBAC diterapkan dan diuji untuk kedua role
- [ ] Tabel besar memakai pagination/virtualization
- [ ] Semua state warna risiko konsisten menggunakan komponen `ColorBadge` yang sama
- [ ] Empty state dan loading state ada di setiap halaman data
- [ ] Tidak ada hardcoded data di luar mock layer yang sudah ditandai `// TODO`
- [ ] Skema warna biru-teal konsisten

---

## 10. Yang TIDAK Boleh Dilakukan

- ❌ Membuat halaman/akses untuk kader posyandu atau orang tua balita
- ❌ Generate PDF/Excel di sisi klien
- ❌ Simpan token JWT di localStorage
- ❌ Optimalkan untuk layar di bawah 1280px
- ❌ Integrasi BPJS/SatuSehat/SIMRS di fase ini
