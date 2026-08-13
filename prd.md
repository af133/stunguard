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

---

## 11. Design System & Panduan Visual

### 11.1 Palet Warna (Biru-Teal — Wajib)

Sesuai agent.md §6.1, seluruh skema warna **harus konsisten biru-teal** dengan mobile app.

| Token | Hex | Kegunaan |
|---|---|---|
| `--color-primary-50` | `#E6FBFA` | Background hover, highlight ringan |
| `--color-primary-100` | `#B3F2EF` | Background badge, chip |
| `--color-primary-200` | `#80E9E4` | Border aktif |
| `--color-primary-300` | `#4DD1CB` | Ikon sekunder |
| `--color-primary-400` | `#26B5AD` | Tombol sekunder |
| `--color-primary-500` | `#0D9488` | **Warna utama (primary)** — tombol, sidebar aktif |
| `--color-primary-600` | `#0B7D76` | Hover tombol utama |
| `--color-primary-700` | `#086660` | Teks heading aksen |
| `--color-primary-800` | `#054F4A` | Teks link, sidebar logo |
| `--color-primary-900` | `#033834` | Background gelap (dark accent) |

| Token | Hex | Kegunaan |
|---|---|---|
| `--color-risk-rendah` | `#22C55E` (green-500) | Badge & dot risiko **rendah** |
| `--color-risk-sedang` | `#F59E0B` (amber-500) | Badge & dot risiko **sedang** |
| `--color-risk-tinggi` | `#EF4444` (red-500) | Badge & dot risiko **tinggi** |

| Token | Hex | Kegunaan |
|---|---|---|
| `--color-neutral-50` | `#F9FAFB` | Background halaman |
| `--color-neutral-100` | `#F3F4F6` | Background kartu |
| `--color-neutral-200` | `#E5E7EB` | Border |
| `--color-neutral-500` | `#6B7280` | Teks sekunder |
| `--color-neutral-700` | `#374151` | Teks body |
| `--color-neutral-900` | `#111827` | Teks heading |

> ⚠️ **Warna hijau (green-700/800) yang saat ini ada di Sidebar.tsx dan DashboardPage.tsx HARUS diganti ke palet biru-teal di atas.**

### 11.2 Tipografi

| Elemen | Font | Weight | Size |
|---|---|---|---|
| Heading H1 | Inter | 700 (bold) | 28px / 1.75rem |
| Heading H2 | Inter | 600 (semibold) | 24px / 1.5rem |
| Heading H3 | Inter | 600 | 20px / 1.25rem |
| Body | Inter | 400 (regular) | 14px / 0.875rem |
| Caption / Label | Inter | 500 (medium) | 12px / 0.75rem |
| Stat Value | Inter | 700 | 32px / 2rem |

> Font Inter diload via Google Fonts di `index.html`.

### 11.3 Spacing & Radius

| Token | Value | Kegunaan |
|---|---|---|
| `--space-xs` | 4px | Gap ikon-teks kecil |
| `--space-sm` | 8px | Padding badge, gap kecil |
| `--space-md` | 16px | Padding kartu, gap standar |
| `--space-lg` | 24px | Padding section |
| `--space-xl` | 32px | Margin antar section |
| `--radius-sm` | 6px | Badge, chip |
| `--radius-md` | 12px | Kartu, input |
| `--radius-lg` | 16px | Modal, panel besar |
| `--radius-full` | 9999px | Avatar, dot |

### 11.4 Elevasi (Shadow)

| Level | CSS Value | Kegunaan |
|---|---|---|
| `shadow-card` | `0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` | Kartu statistik, panel |
| `shadow-dropdown` | `0 4px 12px rgba(0,0,0,0.10)` | Dropdown, popover |
| `shadow-modal` | `0 8px 24px rgba(0,0,0,0.15)` | Modal dialog |

### 11.5 Komponen UI Inti

| Komponen | Lokasi Target | Deskripsi |
|---|---|---|
| `ColorBadge` | `shared/components/ColorBadge.tsx` | Badge 3-state risiko (rendah/sedang/tinggi). **WAJIB** dipakai di semua halaman. |
| `StatCard` | `shared/components/StatCard.tsx` | Kartu statistik dengan ikon, value, sub-teks, dan warna aksen. |
| `DataTable` | `shared/components/DataTable.tsx` | Tabel generic dengan sorting, pagination, dan kolom konfigurabel. |
| `Pagination` | `shared/components/Pagination.tsx` | Komponen navigasi halaman (prev/next/page numbers). |
| `SearchInput` | `shared/components/SearchInput.tsx` | Input pencarian dengan debounce 300ms. |
| `EmptyState` | `shared/components/EmptyState.tsx` | Placeholder saat data kosong (ikon + pesan kontekstual). |
| `LoadingSkeleton` | `shared/components/LoadingSkeleton.tsx` | Skeleton shimmer untuk loading state per-komponen. |
| `Modal` | `shared/components/Modal.tsx` | Dialog modal dengan overlay, close button, dan keyboard trap. |
| `Sidebar` | `shared/components/Sidebar.tsx` | Navigasi samping kiri dengan menu D-01 s.d D-06 + Data Anak. |
| `Header` | `shared/components/Header.tsx` | Top bar: judul halaman, notifikasi bell + badge, profil user dinamis. |
| `FilterBar` | `shared/components/FilterBar.tsx` | Kombinasi filter (date range, dropdown wilayah, kategori risiko). |

---

## 12. Data Models (TypeScript Interfaces)

### 12.1 Auth

```typescript
interface LoginRequest {
  username: string;
  password: string;
}

interface LoginResponse {
  token: string;
  role: 'petugas_puskesmas' | 'admin_dinkes';
  nama: string;
  wilayah_kerja: string;
}

interface AuthState {
  user: LoginResponse | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
```

### 12.2 Dashboard Summary (D-02)

```typescript
interface DashboardSummary {
  total_balita: number;
  total_risiko_rendah: number;
  total_risiko_sedang: number;
  total_risiko_tinggi: number;
  tren_prevalensi: TrenItem[];
  perubahan_bulan: {
    total_balita_delta: number;      // persentase perubahan
    risiko_sedang_delta: number;
    risiko_tinggi_delta: number;
  };
}

interface TrenItem {
  bulan: string;       // "2026-01", "2026-02", dst.
  prevalensi: number;  // persentase (0–100)
  total_kasus: number;
}
```

### 12.3 Data Anak (Balita)

```typescript
interface Balita {
  id: string;
  nama: string;
  tanggal_lahir: string;  // ISO 8601
  jenis_kelamin: 'L' | 'P';
  nama_ibu: string;
  posyandu_id: string;
  posyandu_nama: string;
  wilayah: string;
  kategori_risiko: 'rendah' | 'sedang' | 'tinggi';
  berat_badan_terakhir: number;   // kg
  tinggi_badan_terakhir: number;  // cm
  z_score_bb_u: number;           // Z-score BB/U
  z_score_tb_u: number;           // Z-score TB/U
  z_score_bb_tb: number;          // Z-score BB/TB
  tanggal_pengukuran_terakhir: string;
}

interface BalitaListResponse {
  data: Balita[];
  pagination: {
    page: number;
    limit: number;
    total_data: number;
    total_pages: number;
  };
}

interface BalitaDetail extends Balita {
  riwayat_pertumbuhan: PertumbuhanRecord[];
  riwayat_prediksi: PrediksiRecord[];
}

interface PertumbuhanRecord {
  tanggal: string;
  berat_badan: number;
  tinggi_badan: number;
  z_score_bb_u: number;
  z_score_tb_u: number;
  z_score_bb_tb: number;
  kategori_risiko: 'rendah' | 'sedang' | 'tinggi';
}

interface PrediksiRecord {
  tanggal_prediksi: string;
  model_version: string;
  skor_risiko: number;          // 0.0–1.0
  kategori_prediksi: 'rendah' | 'sedang' | 'tinggi';
  confidence: number;           // 0.0–1.0
}
```

### 12.4 Heatmap / Peta Risiko (D-01)

```typescript
interface HeatmapDataPoint {
  wilayah_id: string;
  nama_wilayah: string;
  latitude: number;
  longitude: number;
  skor_agregat: number;         // 0.0–1.0 (intensitas heatmap)
  total_balita: number;
  total_risiko_tinggi: number;
  total_risiko_sedang: number;
}

interface HeatmapResponse {
  data: HeatmapDataPoint[];
  bounding_box: {
    north: number;
    south: number;
    east: number;
    west: number;
  };
}
```

### 12.5 Posyandu & Kader (D-03)

```typescript
interface Posyandu {
  id: string;
  nama: string;
  alamat: string;
  kelurahan: string;
  kecamatan: string;
  latitude: number;
  longitude: number;
  jumlah_balita: number;
  jumlah_kader: number;
  status_aktif: boolean;
}

interface Kader {
  id: string;
  nama: string;
  no_telepon: string;
  posyandu_id: string;
  posyandu_nama: string;
  status_aktif: boolean;
  tanggal_bergabung: string;
}
```

### 12.6 Alert (D-04)

```typescript
interface Alert {
  id: string;
  tipe: 'risiko_tinggi_baru' | 'kasus_kritis' | 'data_anomali' | 'laporan_selesai';
  judul: string;
  pesan: string;
  wilayah: string;
  balita_id?: string;
  balita_nama?: string;
  dibaca: boolean;
  dibuat_pada: string;   // ISO 8601
}

interface AlertListResponse {
  data: Alert[];
  total_unread: number;
}
```

### 12.7 Laporan (D-05)

```typescript
interface LaporanRequest {
  jenis: 'bulanan' | 'triwulanan' | 'tahunan';
  from: string;            // ISO 8601 date
  to: string;
  wilayah: string;
  format: 'pdf' | 'excel';
}

interface LaporanJob {
  job_id: string;
  status: 'processing' | 'completed' | 'failed';
  progress_persen: number;   // 0–100
  download_url?: string;     // tersedia saat status = completed
  error_message?: string;    // tersedia saat status = failed
  dibuat_pada: string;
}
```

### 12.8 Analitik (D-06)

```typescript
interface TrenAnalitik {
  wilayah: string;
  periode: string;
  data: {
    label: string;           // "Jan 2026", "Feb 2026", dst.
    prevalensi: number;
    total_kasus: number;
    total_balita: number;
  }[];
}

interface ProyeksiPrevalensi {
  wilayah: string;
  data_historis: { bulan: string; prevalensi: number }[];
  data_proyeksi: {
    bulan: string;
    prevalensi_prediksi: number;
    batas_atas: number;      // confidence interval upper
    batas_bawah: number;     // confidence interval lower
  }[];
}
```

---

## 13. Spesifikasi Mock Data

Selama backend belum tersedia, semua API call harus di-intercept oleh `src/shared/lib/mockApi.ts` dengan data dummy berikut:

### 13.1 Volume Data Mock

| Entitas | Jumlah Record | Catatan |
|---|---|---|
| Balita | 500 | Spread across 5 posyandu, 3 kelurahan |
| Posyandu | 5 | Masing-masing 80–120 balita |
| Kader | 15 | 3 kader per posyandu |
| Alert | 25 | Mix dibaca/belum dibaca |
| Tren Dashboard | 12 bulan | Data bulanan Jan–Des 2026 |
| Heatmap Points | 15 titik | Koordinat area Makassar (sample) |

### 13.2 Distribusi Risiko Mock

| Kategori | Persentase |
|---|---|
| Rendah | 70% |
| Sedang | 20% |
| Tinggi | 10% |

### 13.3 Aturan Mock

- Semua fungsi mock **WAJIB** menggunakan `async/await` dengan `setTimeout` simulasi delay (300–800ms) agar loading state terlihat.
- Setiap fungsi mock **WAJIB** diberi komentar `// TODO: replace mock with real API once backend ready`.
- Pagination harus benar-benar berfungsi (slice array berdasarkan `page` dan `limit`).
- Search/filter harus benar-benar memfilter data di memori.
- Mock data menggunakan nama-nama Indonesia yang realistis (bukan "John Doe").

### 13.4 Akun Login Mock

| Username | Password | Role | Wilayah |
|---|---|---|---|
| `petugas01` | `pass123` | `petugas_puskesmas` | Kec. Manggala |
| `admin01` | `admin123` | `admin_dinkes` | Kota Makassar (semua kecamatan) |

---

## 14. Peta Routing Lengkap

### 14.1 Definisi Route

| Path | Nama Halaman | Komponen | Guard |
|---|---|---|---|
| `/login` | Login | `features/auth/components/LoginPage.tsx` | Publik (redirect ke `/` jika sudah login) |
| `/` | Dashboard Beranda (D-02) | `features/dashboard-beranda/components/BerandaPage.tsx` | Auth required |
| `/peta-risiko` | Peta Risiko (D-01) | `features/peta-risiko/components/PetaRisikoPage.tsx` | Auth required |
| `/data-anak` | Data Anak | `features/data-anak/components/DataAnakPage.tsx` | Auth required |
| `/data-anak/:id` | Detail Anak | `features/data-anak/components/DetailAnakPage.tsx` | Auth required |
| `/posyandu` | Manajemen Posyandu (D-03) | `features/manajemen-posyandu/components/PosyanduPage.tsx` | Auth required |
| `/posyandu/:id` | Detail Posyandu | `features/manajemen-posyandu/components/DetailPosyanduPage.tsx` | Auth required |
| `/alert` | Sistem Alert (D-04) | `features/alert/components/AlertPage.tsx` | Auth required |
| `/laporan` | Pelaporan (D-05) | `features/laporan/components/LaporanPage.tsx` | Auth required |
| `/analitik` | Analitik Lanjutan (D-06) | `features/analitik/components/AnalitikPage.tsx` | Auth required |
| `*` | 404 Not Found | `shared/components/NotFoundPage.tsx` | — |

### 14.2 Menu Sidebar (Urutan Tampilan)

| # | Label | Ikon (Lucide) | Path | Badge |
|---|---|---|---|---|
| 1 | Dashboard | `LayoutDashboard` | `/` | — |
| 2 | Peta Risiko | `Map` | `/peta-risiko` | — |
| 3 | Data Anak | `Baby` | `/data-anak` | — |
| 4 | Posyandu | `Building2` | `/posyandu` | — |
| 5 | Alert | `Bell` | `/alert` | `{unread_count}` (dinamis) |
| 6 | Laporan | `FileBarChart` | `/laporan` | — |
| 7 | Analitik | `TrendingUp` | `/analitik` | — |

### 14.3 Pembatasan Akses per Role

| Fitur | Petugas Puskesmas | Admin Dinkes |
|---|---|---|
| Dashboard Beranda | ✅ Data wilayah sendiri | ✅ Data semua wilayah |
| Peta Risiko | ✅ Wilayah sendiri | ✅ Semua wilayah |
| Data Anak | ✅ Wilayah sendiri | ✅ Semua wilayah |
| Posyandu — Lihat | ✅ Wilayah sendiri | ✅ Semua |
| Posyandu — Tambah/Edit | ✅ Wilayah sendiri | ✅ Semua |
| Posyandu — Hapus | ❌ | ✅ |
| Alert | ✅ Wilayah sendiri | ✅ Semua |
| Laporan | ✅ Wilayah sendiri | ✅ Semua + lintas wilayah |
| Analitik | ✅ Wilayah sendiri | ✅ Semua + komparasi wilayah |

---

## 15. Aksesibilitas & Performa

### 15.1 Persyaratan Aksesibilitas (Minimum)

| Item | Standar | Catatan |
|---|---|---|
| Kontras warna | WCAG 2.1 AA (4.5:1 teks biasa) | Pastikan teks di atas background biru-teal memenuhi rasio |
| Keyboard navigation | Tab order logis | Semua elemen interaktif harus reachable via keyboard |
| ARIA labels | Pada ikon-only buttons | Bell notifikasi, tombol close modal, dsb. |
| Focus visible | Ring focus terlihat | Jangan `outline: none` tanpa replacement |
| Alt text | Pada semua `<img>` | Avatar, logo, chart fallback |
| Form labels | `<label>` terhubung ke input | Semua field di form login, filter, generate laporan |

### 15.2 Target Performa

| Metrik | Target | Catatan |
|---|---|---|
| First Contentful Paint (FCP) | < 1.5 detik | Halaman dashboard beranda |
| Largest Contentful Paint (LCP) | < 2.5 detik | Halaman dengan chart/peta |
| Time to Interactive (TTI) | < 3.0 detik | Setelah login |
| Bundle size (gzipped) | < 500 KB (initial) | Gunakan code splitting per route |
| Tabel 10.000 baris | Scroll lancar, < 1s render | Wajib pagination, opsional virtualisasi |
| API response mock delay | 300–800ms | Simulasi realistis saat development |

### 15.3 Strategi Code Splitting

```typescript
// Di routes.tsx — lazy load per fitur
const BerandaPage = lazy(() => import('../features/dashboard-beranda/components/BerandaPage'));
const PetaRisikoPage = lazy(() => import('../features/peta-risiko/components/PetaRisikoPage'));
const DataAnakPage = lazy(() => import('../features/data-anak/components/DataAnakPage'));
const PosyanduPage = lazy(() => import('../features/manajemen-posyandu/components/PosyanduPage'));
const AlertPage = lazy(() => import('../features/alert/components/AlertPage'));
const LaporanPage = lazy(() => import('../features/laporan/components/LaporanPage'));
const AnalitikPage = lazy(() => import('../features/analitik/components/AnalitikPage'));
```

> Leaflet dan Recharts cukup besar — pastikan hanya di-import di route yang membutuhkannya, bukan di entry bundle.

---

## 16. Deployment & Environment

### 16.1 Environment Variables

| Variable | Contoh Nilai | Kegunaan |
|---|---|---|
| `VITE_API_BASE_URL` | `http://localhost:8000/api` | Base URL backend API |
| `VITE_USE_MOCK` | `true` / `false` | Toggle antara mock data dan real API |
| `VITE_MAP_TILE_URL` | `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png` | URL tile peta (default OSM) |
| `VITE_MAP_DEFAULT_CENTER` | `-5.1477,119.4327` | Koordinat default peta (Makassar) |
| `VITE_MAP_DEFAULT_ZOOM` | `12` | Zoom level default peta |

### 16.2 Build Commands

| Command | Kegunaan |
|---|---|
| `npm run dev` | Development server (Vite HMR) |
| `npm run build` | Production build (`dist/`) |
| `npm run preview` | Preview production build lokal |
| `npm run lint` | ESLint check |

### 16.3 Browser Support

| Browser | Versi Minimum |
|---|---|
| Google Chrome | 90+ |
| Mozilla Firefox | 88+ |
| Microsoft Edge | 90+ (Chromium-based) |

> Layar minimum: **1280 × 720px**. Tidak ada optimasi mobile/responsive kecil.

---

## 17. Changelog Dokumen

| Tanggal | Versi | Perubahan |
|---|---|---|
| 13 Agustus 2026 | 1.0 | Dokumen PRD awal — audit kode, progress tracking, temuan isu |
| 13 Agustus 2026 | 1.1 | Tambah §11 Design System, §12 Data Models, §13 Mock Data Spec, §14 Routing Map, §15 Aksesibilitas & Performa, §16 Deployment, §17 Changelog |

---

> 📌 **Dokumen ini adalah living document.** Update progress tracking (§4–§5) setiap kali sebuah item selesai dikerjakan. Update changelog (§17) setiap kali ada revisi signifikan.
