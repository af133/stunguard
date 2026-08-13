# AGENT.md — StuntGuard Backend API

Dokumen ini adalah instruksi eksekusi untuk AI coding agent dalam membangun **backend API
StuntGuard** sesuai proposal "StuntGuard: Platform AI Multimodal untuk Deteksi Dini
Stunting". Backend ini menjadi penghubung antara mobile app (kader posyandu, offline-first)
dan web dashboard (petugas puskesmas/dinas kesehatan), serta menjadi tempat penyimpanan
data terpusat dan logika sinkronisasi.

## 0. Peran Agent

Anda adalah agent pengembang backend yang membangun RESTful API menggunakan Golang.
Kerjakan secara bertahap sesuai bagian 6. Pastikan setiap endpoint memiliki test, validasi
input, dan penanganan error yang konsisten.

## 1. Ringkasan Tanggung Jawab Backend

- Menyimpan data terpusat: balita, pengukuran, kader, posyandu, log nutrisi, hasil deteksi
  risiko.
- Menyediakan API untuk sinkronisasi dari mobile app (push/pull, server-wins conflict
  resolution).
- Menyediakan API untuk web dashboard (statistik, heatmap, laporan, alert, analitik).
- Autentikasi & otorisasi multi-level: kader, petugas puskesmas, admin dinas kesehatan.
- Generate laporan otomatis format Kemenkes (PDF/Excel).
- Mengirim notifikasi/alert (in-app + email) saat kasus risiko tinggi terdeteksi.

Catatan: inferensi model AI (deteksi risiko, CV wajah, klasifikasi makanan) berjalan
**on-device** di mobile app (TFLite), BUKAN di backend. Backend hanya menerima dan
menyimpan **hasil** inferensi (skor, kategori, confidence) yang dikirim dari mobile saat
sinkronisasi. Jangan membangun endpoint inferensi ML kecuali diminta eksplisit sebagai
fase lanjutan (misal untuk re-training/monitoring drift).

## 2. Batasan Wajib

- Tidak ada integrasi BPJS Kesehatan, SatuSehat, atau SIMRS di fase ini. Desain skema data
  agar mudah diperluas dengan middleware integrasi nanti, tapi jangan implementasikan
  sekarang.
- Kapasitas yang diasumsikan: hingga 10.000 rekam balita aktif per instansi puskesmas per
  instance. Desain query dan index dengan asumsi skala ini sebagai baseline, bukan sebagai
  hard limit absolut.
- Keamanan data WAJIB:
  - Enkripsi data balita dengan **AES-256** saat disimpan (field-level encryption untuk
    data sensitif seperti NIK, nama, alamat).
  - **TLS 1.3** untuk semua transmisi data (konfigurasi di reverse proxy/load balancer,
    pastikan dokumentasi deployment menyebutkan ini).
  - Patuhi prinsip minimisasi data sesuai **UU PDP No. 27 Tahun 2022** — jangan menyimpan
    field yang tidak dibutuhkan, sediakan mekanisme penghapusan data jika diminta.
- Model AI belum bersertifikasi alat kesehatan (Permenkes IPAK). Backend harus menyimpan
  dan menampilkan disclaimer ini di response API yang relevan (misal field
  `disclaimer: "Bukan diagnosis medis, hanya alat bantu skrining"` pada response hasil
  deteksi risiko).

## 3. Tech Stack (Wajib Dipakai)

| Layer | Teknologi |
|---|---|
| Bahasa & framework | Golang (gunakan framework ringan seperti `chi`, `gin`, atau `echo` — pilih satu, konsisten) |
| Database utama | PostgreSQL (dengan ekstensi GIS, mis. PostGIS, untuk dukungan heatmap geografis) |
| Database lokal (referensi, bukan tanggung jawab backend langsung) | SQLite dipakai di sisi mobile — backend tidak perlu mengelola ini, hanya menerima sync dari sana |
| Auth | JWT, dengan refresh token, RBAC (kader / petugas_puskesmas / admin_dinas) |
| CI/CD | GitHub Actions + Docker |
| Hosting target | AWS EC2+S3 / Azure VM / VPS lokal Indonesia (desain agar tidak vendor-locked secara ekstrem) |
| Generate PDF/Excel | Gunakan library Go yang stabil (misal `gofpdf`/`maroto` untuk PDF, `excelize` untuk Excel) |
| Email/notifikasi | SMTP provider atau layanan transactional email (sediakan interface yang bisa diganti providernya) |

## 4. Arsitektur Backend (Layered: Handler → Usecase → Repository)

```
cmd/
  api/
    main.go
internal/
  config/
  middleware/        # auth, RBAC guard, logging, rate limiting
  handler/            # HTTP handlers per domain (balita, pengukuran, posyandu, auth, laporan, alert, analitik, sync)
  usecase/             # business logic per domain
  repository/           # akses database (PostgreSQL), interface + implementasi
  entity/                # struct domain (Balita, Pengukuran, Kader, Posyandu, HasilDeteksi, LogNutrisi, Alert)
  encryption/             # wrapper AES-256 untuk field sensitif
  report/                  # generator PDF/Excel format Kemenkes
  notification/             # wrapper email/in-app alert
pkg/
  validator/
  response/                  # format response standar (success/error envelope)
migrations/                   # SQL migration files (gunakan golang-migrate atau goose)
test/
  (mirror struktur internal/ untuk unit & integration test)
```

## 5. Skema Data Inti (Minimal, Wajib Ada)

Desain tabel berikut (boleh menambah kolom sesuai kebutuhan teknis, tapi field di bawah
WAJIB ada karena dipakai langsung oleh mobile & web sesuai proposal):

**balita**: id, nik (nullable, encrypted), nama (encrypted), tanggal_lahir, jenis_kelamin,
nama_ibu (encrypted), alamat (encrypted), riwayat_bblr, durasi_asi_eksklusif,
usia_mulai_mpasi, posyandu_id, created_at, updated_at, sync_status_origin (info dari mana
data ini berasal — untuk audit sinkronisasi).

**pengukuran**: id, balita_id, tanggal, tinggi_badan, berat_badan, lila (nullable), lingkar_kepala
(nullable), zscore_tbu, zscore_bbu, zscore_bbtb, kategori_tbu, kategori_bbu, kategori_bbtb,
kader_id, created_at.

**hasil_deteksi_risiko**: id, balita_id, pengukuran_id, skor, kategori (rendah/sedang/tinggi),
confidence, rekomendasi_intervensi (text), face_cv_used (boolean), created_at. WAJIB
menyimpan field disclaimer/metadata bahwa ini bukan diagnosis klinis (bisa di level aplikasi,
tidak harus kolom DB, tapi harus konsisten muncul di response API).

**log_nutrisi**: id, balita_id, tanggal, jenis_input (foto/manual), kategori_makanan,
estimasi_porsi, kalori, protein, zat_besi, created_at.

**kader**: id, nama, nik (encrypted), no_telepon, posyandu_id, status_validasi
(pending/validated), created_at.

**posyandu**: id, nama, wilayah_kerja (desa/kelurahan/kecamatan), koordinat_lat,
koordinat_lng, puskesmas_id, created_at.

**puskesmas** / **dinas_kesehatan**: struktur hierarki wilayah untuk RBAC dan agregasi
heatmap.

**alert**: id, balita_id, kategori_risiko, wilayah_kerja, status (unread/read), created_at.

**laporan_job**: id, jenis (bulanan/triwulanan/tahunan), wilayah, periode_from, periode_to,
format (pdf/excel), status (processing/ready/failed), file_url, requested_by, created_at.

**users** (auth): id, email, password_hash, role (kader/petugas_puskesmas/admin_dinas),
wilayah_kerja_id, created_at.

Tambahkan kolom `sync_status` dan `updated_at` di tabel yang disinkronkan dari mobile
(balita, pengukuran, hasil_deteksi_risiko, log_nutrisi) untuk mendukung mekanisme
server-wins conflict resolution.

## 6. Urutan Eksekusi (Fase Kerja untuk Agent)

1. **Setup project**: inisialisasi modul Go, struktur folder bagian 4, koneksi PostgreSQL,
   setup migration tool, setup Docker + docker-compose untuk dev lokal (Postgres + API).
2. **Auth & RBAC**: endpoint register kader (status pending → divalidasi koordinator),
   login (kader/petugas/admin), middleware JWT + role guard. Implementasikan field
   enkripsi AES-256 untuk data sensitif sejak awal (jangan ditunda, karena migrasi data
   terenkripsi belakangan jauh lebih mahal).
3. **CRUD dasar**: posyandu, kader (validasi akun), balita. Sertakan validasi input sesuai
   batasan domain (usia 0-59 bulan, dsb — replikasi validasi yang sama dengan mobile sebagai
   defense in depth, jangan percaya validasi client saja).
4. **Endpoint sinkronisasi mobile** (`/api/sync/push`, `/api/sync/pull`): ini fitur paling
   kritis karena F-09 di mobile bergantung total pada endpoint ini.
   - `push`: terima batch record dari mobile (balita/pengukuran/hasil_deteksi/log_nutrisi)
     dengan `syncStatus` dan `updated_at` dari client, terapkan upsert, balas status per
     record (sukses/gagal+alasan).
   - `pull`: terima `lastSyncTimestamp` dari client, balas semua record yang berubah di
     server sejak timestamp itu, dibatasi oleh wilayah kerja kader yang melakukan request.
   - Implementasikan **server-wins**: jika ada konflik `updated_at` yang lebih baru di
     server vs yang dikirim client untuk record yang sama, versi server tetap yang disimpan
     dan dikirim balik ke client (bukan ditolak diam-diam — beri info di response).
5. **Endpoint dashboard read** (D-02 summary, D-01 heatmap, data anak dengan pagination):
   prioritaskan performa query (index pada `posyandu_id`, `wilayah_kerja`, `tanggal`,
   `kategori_risiko`).
6. **Sistem alert**: trigger otomatis insert ke tabel `alert` saat `hasil_deteksi_risiko`
   baru masuk dengan kategori "tinggi" (lewat hook di usecase saat proses sync push), kirim
   email via `notification` package, expose endpoint list & mark-as-read untuk dashboard.
7. **Generate laporan** (D-05): endpoint `POST /api/laporan/generate` membuat job
   asinkron (gunakan goroutine + job table, atau queue sederhana jika scope memungkinkan),
   endpoint `GET /api/laporan/status/:jobId` untuk polling. Generator PDF mengikuti template
   format Kemenkes (jika template resmi belum ada, buat layout placeholder yang jelas
   terstruktur — judul, tabel rekap per indikator, total balita per kategori risiko — dan
   tandai sebagai draft template untuk divalidasi nanti oleh pihak Kemenkes/dinas).
8. **Analitik lanjutan** (D-06): endpoint agregasi tren & perbandingan wilayah berbasis query
   historis dari tabel pengukuran/hasil_deteksi.
9. **Hardening & test**: tulis integration test untuk seluruh endpoint kritis (auth, sync
   push/pull dengan skenario konflik, alert trigger), load test ringan untuk endpoint
   pagination data anak dengan data dummy ~10.000 baris.
10. **CI/CD**: setup GitHub Actions pipeline (lint, test, build, build docker image), siapkan
    dokumentasi deployment minimal (env vars yang dibutuhkan, langkah migrasi DB).

## 7. Format Response Standar

Gunakan envelope response yang konsisten di semua endpoint:

```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```
Saat error:
```json
{
  "success": false,
  "data": null,
  "error": { "code": "VALIDATION_ERROR", "message": "Usia balita harus 0-59 bulan" }
}
```

## 8. Daftar Endpoint Minimal (Kontrak dengan Mobile & Web)

Selaraskan persis dengan yang diasumsikan oleh `agent.md` mobile dan web. Jika ada
perbedaan kebutuhan, backend boleh menambah endpoint, tapi JANGAN menghapus/mengubah
signature endpoint yang sudah disepakati tanpa update juga ke kedua agent lain.

- `POST /api/auth/register` (kader)
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/forgot-password`
- `GET/POST/PUT/DELETE /api/posyandu`
- `GET/POST/PUT /api/kader` (+ endpoint validasi akun oleh koordinator)
- `POST /api/sync/push`
- `GET /api/sync/pull?since=`
- `GET /api/dashboard/summary?wilayah=`
- `GET /api/risiko/heatmap?from=&to=&kategori=`
- `GET /api/balita?page=&limit=&search=&kategori_risiko=&wilayah=`
- `GET /api/balita/:id/riwayat` (untuk grafik kurva pertumbuhan individual)
- `POST /api/laporan/generate`
- `GET /api/laporan/status/:jobId`
- `GET /api/alert?unread=true`
- `POST /api/alert/:id/read`
- `GET /api/analitik/tren?wilayah=&periode=`
- `GET /api/analitik/proyeksi?wilayah=`

## 9. Definition of Done

Sebuah endpoint/fitur dianggap selesai jika:
- Mengikuti struktur layered (handler → usecase → repository), tidak ada query DB langsung
  di handler.
- Validasi input ada di level backend (tidak hanya bergantung pada validasi client).
- Field sensitif (NIK, nama, alamat) terenkripsi AES-256 sebelum disimpan.
- Memiliki minimal satu integration test yang mencakup happy path dan satu error path.
- Response mengikuti format envelope standar (bagian 7).
- RBAC diterapkan dan diuji untuk role yang relevan.

## 10. Yang TIDAK Boleh Dilakukan Agent

- Jangan membangun endpoint inferensi ML/CV — inferensi berjalan on-device di mobile.
- Jangan mengintegrasikan BPJS/SatuSehat/SIMRS di fase ini.
- Jangan menyimpan data sensitif (NIK, nama, alamat) tanpa enkripsi.
- Jangan membuat conflict resolution selain **server-wins** tanpa persetujuan eksplisit,
  karena mobile app didesain mengasumsikan strategi ini.
- Jangan menghapus atau mengubah signature endpoint di bagian 8 tanpa mengoordinasikan
  perubahan ke `agent.md` mobile dan web.
