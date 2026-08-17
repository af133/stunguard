# DOKUMEN TEKNIS
# PANDUAN INSTALASI DAN PENGGUNAAN PERANGKAT LUNAK

---

## StuntGuard
### Platform AI Multimodal untuk Deteksi Dini Stunting

---

|  |  |
|---|---|
| **Nama Perangkat Lunak** | StuntGuard |
| **Versi** | 1.0.0 |
| **Tanggal Dokumen** | 17 Agustus 2026 |
| **Klasifikasi** | Dokumen Teknis — Untuk Keperluan Evaluasi |
| **Cakupan** | Web Dashboard · Backend API · Mobile Application |

---

## Daftar Isi

- [a) Latar Belakang](#a-latar-belakang)
- [b) Tujuan](#b-tujuan)
- [c) Nilai Inovasi dan Dampak Pemanfaatan](#c-nilai-inovasi-dan-dampak-pemanfaatan-perangkat-lunak)
- [d) Deskripsi Fungsional dan Detail Fitur](#d-deskripsi-fungsional-perangkat-lunak-dan-penjelasan-detail-fitur)
- [e) Screenshot Perangkat Lunak](#e-screenshot-perangkat-lunak)

---

## a) Latar Belakang

### a.1 Permasalahan Stunting di Indonesia

Stunting merupakan kondisi gagal tumbuh pada anak balita akibat kekurangan gizi kronis, ditandai dengan tinggi badan yang tidak sesuai usia. Berdasarkan data Survei Status Gizi Indonesia (SSGI) 2022, prevalensi stunting di Indonesia masih berada pada angka **21,6%**, jauh di atas ambang batas yang ditetapkan WHO sebesar 20%. Pemerintah Indonesia melalui **Perpres No. 72 Tahun 2021** menetapkan target penurunan angka stunting menjadi **14% pada tahun 2024**.

Dampak stunting tidak hanya bersifat jangka pendek berupa gangguan pertumbuhan fisik, tetapi juga berdampak jangka panjang pada:
- **Kognitif dan kecerdasan:** Penurunan kemampuan belajar dan produktivitas di masa dewasa.
- **Kesehatan:** Meningkatkan risiko penyakit kronis (diabetes, hipertensi, obesitas) di usia dewasa.
- **Ekonomi:** Diperkirakan menyebabkan kerugian ekonomi nasional hingga 2–3% GDP per tahun.

### a.2 Tantangan Deteksi Dini

Deteksi stunting yang efektif memerlukan pengukuran antropometri rutin di posyandu oleh kader terlatih. Namun, sistem pencatatan yang masih manual menimbulkan berbagai tantangan operasional:

1. **Keterbatasan akses internet di daerah:** Banyak posyandu berada di wilayah dengan konektivitas yang tidak stabil, sehingga sistem berbasis cloud penuh tidak dapat diandalkan.
2. **Proses pencatatan manual yang rentan kesalahan:** Kader posyandu mencatat data di buku register fisik, yang rawan hilang, rusak, dan sulit direkap secara cepat.
3. **Lambatnya alur pelaporan:** Data dari posyandu membutuhkan waktu berminggu-minggu untuk sampai ke tingkat puskesmas dan dinas kesehatan, sehingga respons intervensi terlambat.
4. **Keterbatasan kemampuan skrining:** Kader posyandu umumnya tidak memiliki kemampuan klinis untuk mengidentifikasi faktor risiko stunting secara komprehensif dari data antropometri saja.
5. **Tidak adanya sistem peringatan dini:** Kasus balita dengan risiko stunting tinggi sering tidak terdeteksi lebih awal karena tidak ada mekanisme alert otomatis berbasis data.

### a.3 Urgensi Solusi Teknologi

Kondisi di atas mendorong kebutuhan akan sebuah platform digital terintegrasi yang mampu:
- Beroperasi tanpa koneksi internet (offline-first) untuk mendukung kader di lapangan.
- Mengotomatiskan kalkulasi status gizi berdasarkan standar WHO secara instan.
- Menggunakan kecerdasan buatan (AI) untuk mendeteksi risiko stunting secara dini dan akurat.
- Menyajikan data secara real-time kepada pemangku kebijakan di tingkat puskesmas dan dinas kesehatan.

StuntGuard hadir sebagai jawaban atas tantangan-tantangan tersebut.

---

## b) Tujuan

### b.1 Tujuan Umum

Membangun platform teknologi terintegrasi berbasis kecerdasan buatan (AI) yang mendukung percepatan deteksi dini dan penanganan stunting di Indonesia, mulai dari tingkat posyandu hingga dinas kesehatan.

### b.2 Tujuan Khusus

| No. | Tujuan | Indikator Capaian |
|---|---|---|
| 1 | Mempercepat proses pencatatan data balita di posyandu | Waktu input data < 5 menit per balita |
| 2 | Mengotomatiskan kalkulasi z-score dan kategori status gizi berdasarkan standar WHO | Akurasi kalkulasi 100% sesuai tabel referensi WHO |
| 3 | Mendeteksi risiko stunting secara dini menggunakan model AI on-device | Latensi deteksi < 50ms tanpa koneksi internet |
| 4 | Menyediakan dashboard monitoring real-time bagi petugas puskesmas dan dinas kesehatan | Data tersedia dalam hitungan menit setelah sinkronisasi |
| 5 | Memfasilitasi pelaporan otomatis sesuai format Kemenkes | Laporan dapat di-generate dalam format PDF/Excel |
| 6 | Mendukung pengambilan keputusan intervensi berbasis data dan peta risiko wilayah | Visualisasi heatmap stunting per desa/kelurahan |

### b.3 Sasaran Pengguna

StuntGuard dirancang untuk tiga kelompok pengguna utama:

**1. Kader Posyandu**
- Pengguna aplikasi mobile Android.
- Bertugas mendata balita dan melakukan pengukuran rutin.
- Tidak memerlukan koneksi internet untuk menggunakan seluruh fitur inti.

**2. Petugas Puskesmas**
- Pengguna web dashboard pada komputer desktop.
- Memantau data stunting di wilayah kerja puskesmas.
- Mengelola data posyandu dan kader, menerima notifikasi alert kasus risiko tinggi.

**3. Admin Dinas Kesehatan**
- Pengguna web dashboard dengan akses lebih luas.
- Memantau dan membandingkan data stunting lintas wilayah.
- Men-generate laporan resmi dan menganalisis tren prevalensi stunting.

---

## c) Nilai Inovasi dan Dampak Pemanfaatan Perangkat Lunak

### c.1 Nilai Inovasi Teknologi

#### c.1.1 AI On-Device (Inferensi Tanpa Internet)

Inovasi utama StuntGuard terletak pada penerapan **kecerdasan buatan yang berjalan sepenuhnya di perangkat mobile (on-device inference)** menggunakan TensorFlow Lite. Tiga model AI dieksekusi langsung di smartphone kader posyandu:

- **Model Risiko Stunting** — Ensemble XGBoost + Random Forest (14 fitur input) yang mengintegrasikan data antropometri, riwayat kesehatan, dan faktor sosiodemografi untuk menghasilkan skor risiko komprehensif.
- **Model Analisis Wajah** — MobileNetV2 yang mengekstrak fitur visual dari foto wajah balita sebagai data pendukung skrining (supplementary feature, bukan penentu tunggal).
- **Model Klasifikasi Makanan** — EfficientNet-B0 yang mampu mengidentifikasi 50 kategori makanan MPASI dan makanan lokal dari foto, beserta estimasi nilai gizi otomatis.

#### c.1.2 Arsitektur Offline-First

StuntGuard mengimplementasikan **arsitektur offline-first** di mana seluruh operasi penulisan data selalu disimpan ke database lokal SQLite terlebih dahulu tanpa menunggu respons server. Data disinkronisasi secara otomatis saat koneksi tersedia, dengan mekanisme:
- **Exponential backoff** untuk retry otomatis saat sinkronisasi gagal.
- **Server-wins conflict resolution** untuk menangani data yang dimodifikasi dari lebih dari satu perangkat.
- **Sync queue persisten** yang bertahan meski aplikasi ditutup atau perangkat di-restart.

#### c.1.3 Kalkulasi Z-Score Standar WHO Otomatis

StuntGuard mengimplementasikan metode kalkulasi z-score **LMS (Lambda-Mu-Sigma) Cole & Green (1992)** secara akurat sesuai tabel referensi resmi WHO. Hasil kalkulasi tersedia secara instan setelah kader menyimpan data pengukuran, tanpa memerlukan koneksi internet maupun kemampuan perhitungan manual dari kader.

#### c.1.4 Pendekatan Multimodal

StuntGuard menggabungkan tiga sumber data yang berbeda dalam satu penilaian risiko komprehensif:
1. **Data antropometri** (TB, BB, LiLA, lingkar kepala → z-score WHO)
2. **Data riwayat kesehatan** (BBLR, ASI eksklusif, usia mulai MPASI)
3. **Data visual** (foto wajah balita sebagai fitur pendukung)

### c.2 Keunggulan Dibanding Solusi Eksisting

| Aspek | Pencatatan Manual | Aplikasi Gizi Konvensional | **StuntGuard** |
|---|---|---|---|
| Ketersediaan offline | Penuh | Terbatas | **Penuh (semua fitur inti)** |
| Deteksi risiko AI | Tidak ada | Tidak ada | **On-device, < 50ms** |
| Kalkulasi z-score otomatis | Manual | Sebagian | **Instan, standar WHO** |
| Log nutrisi via foto | Tidak ada | Tidak ada | **Klasifikasi 50 kategori** |
| Dashboard real-time | Tidak ada | Terbatas | **Heatmap + analitik** |
| Generate laporan Kemenkes | Manual | Sebagian | **PDF/Excel otomatis** |
| Sinkronisasi multi-perangkat | Tidak ada | Terbatas | **Dengan conflict resolution** |

### c.3 Dampak Pemanfaatan

#### c.3.1 Dampak pada Kader Posyandu
- **Efisiensi waktu:** Pengurangan waktu pencatatan dan kalkulasi manual dari 15–20 menit menjadi < 5 menit per balita.
- **Akurasi data:** Eliminasi kesalahan kalkulasi z-score yang umum terjadi pada pencatatan manual.
- **Peningkatan kapasitas skrining:** Kader dapat mengidentifikasi balita berisiko tinggi lebih awal melalui panduan AI, meski tidak memiliki latar belakang klinis.

#### c.3.2 Dampak pada Petugas Puskesmas & Dinas Kesehatan
- **Monitoring real-time:** Data dari seluruh posyandu di wilayah kerja tersedia di dashboard dalam hitungan menit setelah sinkronisasi.
- **Respons intervensi lebih cepat:** Sistem alert otomatis memberikan notifikasi saat kasus risiko tinggi baru terdeteksi.
- **Perencanaan berbasis data:** Heatmap risiko wilayah dan analitik tren membantu perencanaan program intervensi yang lebih tepat sasaran.
- **Efisiensi pelaporan:** Laporan bulanan/triwulanan/tahunan format Kemenkes dapat di-generate otomatis dalam hitungan menit.

#### c.3.3 Dampak Jangka Panjang
- **Percepatan penurunan prevalensi stunting:** Deteksi dini yang lebih akurat dan respons intervensi yang lebih cepat berkontribusi pada percepatan penurunan angka stunting menuju target nasional 14%.
- **Penguatan sistem data kesehatan:** Data digital yang terstruktur dapat menjadi basis riset epidemiologi dan evaluasi program gizi nasional.
- **Model percontohan digitalisasi posyandu:** Platform ini dapat menjadi referensi digitalisasi layanan posyandu di seluruh Indonesia.

### c.4 Kepatuhan dan Keamanan

- **Enkripsi AES-256** untuk data identitas sensitif (NIK, nama, alamat) sebelum disimpan di database.
- **TLS 1.3** untuk seluruh transmisi data antara perangkat dan server.
- **Kepatuhan UU PDP No. 27 Tahun 2022** — minimisasi data dan hak penghapusan data tersedia.
- **Disclaimer wajib** pada setiap output deteksi risiko: *"Bukan diagnosis medis, hanya alat bantu skrining"*.

---

## d) Deskripsi Fungsional Perangkat Lunak dan Penjelasan Detail Fitur

### d.1 Arsitektur Sistem

StuntGuard terdiri dari tiga komponen utama yang saling terintegrasi:

```
+------------------+         +--------------------------+
|  MOBILE APP      |         |     WEB DASHBOARD        |
|  Flutter/Dart    |         |  React.js + TypeScript   |
|  Android 8.0+    |         |  Chrome/Firefox Desktop  |
|                  |         |                          |
|  Kader Posyandu  |         |  Petugas Puskesmas /     |
|                  |         |  Admin Dinas Kesehatan   |
+--------+---------+         +-------------+------------+
         |                                 |
         |    REST API (HTTPS / TLS 1.3)   |
         v                                 v
+--------------------------------------------------------+
|                  BACKEND API                           |
|              Golang (Gin Framework)                    |
|                                                        |
|  Auth & RBAC | Sinkronisasi | Alert | Laporan          |
+----------------------------+---------------------------+
                             v
                  +---------------------+
                  |  PostgreSQL Database |
                  |  Data terpusat      |
                  +---------------------+
```

**Stack Teknologi:**

| Komponen | Teknologi |
|---|---|
| Mobile | Flutter (Dart), SQLite, TensorFlow Lite, Riverpod |
| Web Dashboard | React 19, Vite, TypeScript, Tailwind CSS, Leaflet, Recharts |
| Backend | Golang 1.25, Gin Framework, GORM, PostgreSQL, JWT |

---

### d.2 Mobile Application — Fitur Detail

Aplikasi mobile ditujukan untuk **kader posyandu**, beroperasi di **Android (API Level 26+)**, dan berjalan penuh tanpa koneksi internet.

#### d.2.1 Autentikasi Kader

Kader melakukan registrasi dengan data: nama, NIK (opsional), nomor telepon, nama posyandu, wilayah kerja. Akun berstatus *pending* hingga divalidasi oleh petugas puskesmas melalui web dashboard. Setelah tervalidasi, kader dapat login dan menggunakan seluruh fitur.

#### d.2.2 F-01: Manajemen Data Balita

**Tujuan:** Pendataan dan pengelolaan informasi balita usia 0–59 bulan.

**Data yang dicatat:**
- Identitas: Nama, NIK (opsional), tanggal lahir, jenis kelamin
- Informasi ibu: Nama ibu, alamat tempat tinggal
- Riwayat kesehatan: Riwayat BBLR, durasi ASI eksklusif (bulan), usia mulai MPASI (bulan)

**Fitur pendukung:**
- Pencarian nama balita secara real-time
- Filter berdasarkan jenis kelamin, status risiko, dan rentang usia
- Validasi input — sistem menolak usia di luar 0–59 bulan dan nilai fisiologis yang tidak wajar
- Semua operasi CRUD tersimpan lokal (SQLite) dan disinkronkan saat online

#### d.2.3 F-02 & F-03: Input Pengukuran dan Kalkulasi Z-Score Otomatis

**Tujuan:** Pencatatan hasil pengukuran antropometri dengan kalkulasi status gizi otomatis berbasis standar WHO.

| Parameter | Satuan | Keterangan |
|---|---|---|
| Tinggi Badan (TB) | cm | Wajib |
| Berat Badan (BB) | kg | Wajib |
| LiLA | cm | Opsional (usia 6–59 bulan) |
| Lingkar Kepala | cm | Opsional |

**Z-Score yang dihitung otomatis:**
- **TB/U** (Tinggi Badan / Umur) → deteksi stunting
- **BB/U** (Berat Badan / Umur) → deteksi underweight
- **BB/TB** (Berat Badan / Tinggi Badan) → deteksi wasting

**Kategori interpretasi WHO:**

| Indikator | Z-Score | Kategori |
|---|---|---|
| TB/U | z < −3 | Severely stunted (sangat pendek) |
| TB/U | −3 ≤ z < −2 | Stunted (pendek) |
| TB/U | z ≥ −2 | Normal |
| BB/U | z < −3 | Severely underweight (gizi buruk) |
| BB/U | −3 ≤ z < −2 | Underweight (gizi kurang) |
| BB/TB | z < −3 | Severely wasted |
| BB/TB | −3 ≤ z < −2 | Wasted |

Kalkulasi menggunakan metode **LMS (Lambda-Mu-Sigma)** dengan tabel referensi WHO yang tersimpan lokal di perangkat — hasil tersedia tanpa internet dalam hitungan milidetik.

#### d.2.4 F-04: Deteksi Risiko Stunting Berbasis AI

**Tujuan:** Menghasilkan skor risiko stunting komprehensif menggunakan model AI yang berjalan sepenuhnya di perangkat (on-device, tanpa internet).

**Model yang digunakan:** Ensemble XGBoost + Random Forest (dikonversi ke TFLite)

**Input model — 14 fitur:**

| Sumber Data | Fitur |
|---|---|
| Antropometri | Z-score TB/U, BB/U, BB/TB, nilai LiLA |
| Profil balita | Usia (bulan), jenis kelamin, urutan kelahiran, jarak kelahiran |
| Riwayat kesehatan | BBLR, durasi ASI eksklusif, usia mulai MPASI |
| Sosiodemografi | Pendidikan ibu, sumber air minum, akses sanitasi |

**Output:**
- **Skor risiko:** nilai 0–1 (semakin tinggi, semakin berisiko)
- **Kategori:** Rendah (hijau) / Sedang (kuning) / Tinggi (merah)
- **Confidence level:** tingkat keyakinan model

> Setiap halaman hasil deteksi wajib menampilkan: *"Bukan diagnosis medis. StuntGuard hanya merupakan alat bantu skrining untuk mendukung keputusan tenaga kesehatan."*

#### d.2.5 F-05: Analisis Wajah (Scan Wajah)

Fitur penunjang opsional menggunakan kamera untuk mengambil foto wajah balita. Model AI (MobileNetV2) mengekstrak fitur visual sebagai data pendukung skor risiko. Tombol **"Lewati Scan Wajah"** selalu tersedia dan tidak memblokir alur penggunaan.

#### d.2.6 F-06: Log Nutrisi Harian

**Via foto:** Kader memotret makanan → model EfficientNet-B0 mengidentifikasi dari 50 kategori MPASI/makanan lokal → sistem menampilkan estimasi kalori, protein, dan zat besi.

**Fallback manual:** Jika makanan tidak dikenali atau confidence < 0,5 → form input manual otomatis tersedia. Tidak ada dead-end.

#### d.2.7 F-07: Riwayat Pertumbuhan (Grafik Kurva WHO)

Menampilkan grafik pertumbuhan individual yang dioverlay dengan kurva standar WHO untuk tiga indikator: TB/U, BB/U, dan BB/TB. Garis referensi WHO (−3, −2, median, +2, +3 SD) ditampilkan bersama titik data aktual balita.

#### d.2.8 F-08: Rekomendasi Intervensi

Berdasarkan skor risiko dan profil balita, sistem menghasilkan rekomendasi gizi dan MPASI yang spesifik, termasuk saran kunjungan ke fasilitas kesehatan jika risiko tinggi.

#### d.2.9 F-09: Mode Offline dan Sinkronisasi

**Alur sinkronisasi:**
1. Setiap input data → disimpan di SQLite lokal dengan status `PENDING`
2. Saat koneksi terdeteksi → `SyncManager` mengirim semua record `PENDING` ke backend (batch)
3. Berhasil → status `SYNCED` | Gagal → retry dengan exponential backoff (jeda: 2ⁿ × 1–2 detik)
4. Setelah push → sistem menarik data terbaru dari server (pull)

**Penanganan konflik:** Strategi *server-wins* — versi server selalu menang, kader mendapat notifikasi.

**Manual sync:** Pengaturan → Sinkronisasi → "Paksa Sinkronisasi".

#### d.2.10 F-10: Notifikasi Jadwal

Local notification (tanpa internet) sebagai pengingat jadwal posyandu bulanan dan tindak lanjut balita risiko sedang/tinggi.

---

### d.3 Web Dashboard — Fitur Detail

Web dashboard diakses via browser desktop (Chrome v90+ / Firefox v88+, minimal 1280×720px) oleh **petugas puskesmas** dan **admin dinas kesehatan**.

#### d.3.1 Kontrol Akses Berbasis Role (RBAC)

| Role | Hak Akses |
|---|---|
| **Petugas Puskesmas** | Monitoring wilayah sendiri, edit posyandu & kader, laporan wilayah sendiri |
| **Admin Dinas Kesehatan** | Akses semua wilayah, CRUD penuh posyandu, laporan & analitik lintas wilayah |

#### d.3.2 D-02: Dashboard Beranda

**URL:** `/dashboard`

Menampilkan ringkasan statistik real-time:
- Kartu statistik: total balita, risiko tinggi, risiko sedang, prevalensi bulan ini vs. lalu
- Grafik tren prevalensi stunting 6–12 bulan (Recharts)

#### d.3.3 D-01: Peta Risiko Wilayah

**URL:** `/peta-risiko`

Heatmap interaktif (Leaflet.js) persebaran stunting per desa/kelurahan:
- Filter rentang tanggal dan kategori risiko
- Klik area → panel detail posyandu + daftar balita risiko di wilayah tersebut

#### d.3.4 Data Anak

**URL:** `/data-anak` dan `/data-anak/:id`

- Tabel terpaginasi (mendukung ≥10.000 baris), pencarian, filter risiko dan wilayah
- Kolom kategori risiko dengan `ColorBadge` (hijau/kuning/merah)
- Klik baris → halaman detail: profil balita, riwayat pengukuran, grafik kurva WHO

#### d.3.5 D-03: Manajemen Posyandu

**URL:** `/posyandu`

- CRUD data posyandu dan kader
- Validasi akun kader baru (ubah status `pending` → `validated`)
- Hapus posyandu: hanya Admin Dinas Kesehatan

#### d.3.6 D-04: Sistem Alert

**URL:** `/alert`

- Ikon lonceng di header dengan badge counter alert belum dibaca
- Alert otomatis dibuat saat deteksi risiko tinggi baru masuk via sinkronisasi mobile
- Notifikasi juga dikirim via email ke petugas terkait
- Tandai dibaca per alert atau semua sekaligus

#### d.3.7 D-05: Pelaporan Otomatis

**URL:** `/laporan`

Alur generate laporan:
1. Pilih jenis: Bulanan / Triwulanan / Tahunan
2. Tentukan rentang tanggal dan wilayah
3. Pilih format: PDF (template Kemenkes) atau Excel
4. Klik "Generate Laporan" → backend memproses secara asinkron (1–3 menit)
5. Link download tersedia saat laporan selesai

#### d.3.8 D-06: Analitik Lanjutan

**URL:** `/analitik`

- Tren historis prevalensi stunting (grafik garis, filter wilayah)
- Perbandingan antar wilayah (bar chart komparatif)
- Proyeksi prevalensi ke depan

---

### d.4 Panduan Instalasi

#### d.4.1 Prasyarat Sistem

| Komponen | Prasyarat |
|---|---|
| Backend | Go 1.21+, PostgreSQL 14+, Docker (opsional) |
| Frontend | Node.js 18+, npm 9+, browser Chrome/Firefox |
| Mobile | Flutter SDK 3.11.4+, Android Studio / VS Code, Android API 26+ |

#### d.4.2 Instalasi Backend

```bash
# 1. Masuk ke direktori backend
cd backend-worktree

# 2. Salin dan edit file konfigurasi
cp ".env copy" .env
# Edit .env: DATABASE_URL, JWT_SECRET, AES_ENCRYPTION_KEY

# 3. Install dependensi
go mod download

# 4. Jalankan server (auto-migrate database saat pertama kali)
go run ./cmd/api/main.go
# Server berjalan di http://localhost:8080

# Alternatif via Docker Compose
docker-compose up -d
```

#### d.4.3 Instalasi Web Dashboard

```bash
# 1. Masuk ke direktori frontend
cd stunguard

# 2. Install dependensi
npm install

# 3. Jalankan development server
npm run dev
# Dashboard tersedia di http://localhost:3000

# Untuk production build
npm run build
# Output siap deploy ada di folder dist/
```

#### d.4.4 Instalasi Mobile Application

```bash
# 1. Masuk ke direktori mobile
cd mobile-worktree

# 2. Install dependensi Flutter
flutter pub get

# 3. Jalankan ke perangkat/emulator Android
flutter run

# Untuk build APK release
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### d.4.5 Urutan Startup Sistem

```
1. Jalankan PostgreSQL
2. Jalankan Backend API   → http://localhost:8080
3. Jalankan Web Dashboard → http://localhost:3000
4. Install APK di perangkat Android
5. Kader registrasi di mobile → validasi akun di web dashboard
```

---

## e) Screenshot Perangkat Lunak

*[Screenshot akan dilampirkan secara manual]*

**Mobile Application — Halaman yang perlu didokumentasikan:**
1. Halaman login / registrasi kader
2. Beranda / daftar balita
3. Form tambah balita baru
4. Form input pengukuran antropometri
5. Halaman hasil deteksi risiko AI (dengan disclaimer)
6. Grafik riwayat pertumbuhan kurva WHO
7. Layar scan wajah dan log nutrisi
8. Halaman pengaturan sinkronisasi

**Web Dashboard — Halaman yang perlu didokumentasikan:**
1. Halaman login web dashboard
2. Dashboard beranda (kartu statistik + chart tren)
3. Peta risiko wilayah (heatmap)
4. Tabel data anak dengan badge risiko berwarna
5. Detail anak (grafik kurva pertumbuhan individual)
6. Manajemen posyandu & validasi kader
7. Halaman alert (notifikasi risiko tinggi)
8. Form generate laporan dan status download

---

*Dokumen teknis ini disiapkan untuk keperluan evaluasi perangkat lunak StuntGuard.*
*Versi: 1.0.0 | Tanggal: 17 Agustus 2026*
