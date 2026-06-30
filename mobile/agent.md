# AGENT.md — StuntGuard Mobile Application

Dokumen ini adalah instruksi eksekusi untuk AI coding agent (Claude Code atau sejenis)
dalam membangun **aplikasi mobile StuntGuard** sesuai proposal "StuntGuard: Platform AI
Multimodal untuk Deteksi Dini Stunting". Ikuti dokumen ini sebagai sumber kebenaran utama
untuk scope, arsitektur, dan urutan kerja. Jangan menambah fitur di luar scope tanpa
konfirmasi eksplisit dari pengguna.

## 0. Peran Agent

Anda adalah agent pengembang mobile yang bertugas membangun aplikasi Android
offline-first untuk kader posyandu. Kerjakan secara bertahap per fase (lihat bagian 6),
commit per fitur, dan selalu validasi build setelah setiap perubahan signifikan.

## 1. Ringkasan Produk

StuntGuard Mobile adalah aplikasi yang dipakai **kader posyandu** untuk:
- Mendata balita (0–59 bulan)
- Mencatat pengukuran antropometri (TB, BB, LiLA, lingkar kepala)
- Menghitung z-score WHO secara otomatis
- Menjalankan deteksi risiko stunting berbasis ML (on-device)
- Mengambil foto wajah balita untuk analisis CV pendukung (supplementary, bukan dasar
  diagnosis tunggal)
- Mencatat asupan makanan harian via foto (klasifikasi 50 kategori MPASI/makanan lokal)
- Beroperasi **penuh secara offline**, lalu sinkronisasi otomatis saat online

Orang tua balita HANYA menerima ringkasan hasil via notifikasi/share (WhatsApp), TIDAK
memiliki akun penuh di app ini pada versi awal.

## 2. Batasan Wajib (Jangan Dilanggar)

- Target platform: **Android API level 26+ (Android 8.0+)** saja. iOS di luar scope fase ini.
- Bahasa antarmuka: **Bahasa Indonesia saja**. Jangan buat i18n multi-bahasa di fase ini.
- Usia balita yang didukung: **0–59 bulan**. Validasi input harus menolak di luar rentang ini.
- Output sistem adalah **skor risiko (rendah/sedang/tinggi) + rekomendasi**, BUKAN diagnosis
  medis klinis. Setiap layar hasil deteksi WAJIB menampilkan disclaimer ini.
- Fitur CV wajah adalah **fitur penunjang**, jika gagal/dilewati, skor risiko tetap dihitung
  dari data antropometri saja (jangan blocking).
- Foto makanan yang tidak dikenali harus jatuh ke **input manual**, jangan biarkan dead-end.
- Penyimpanan lokal minimum yang diasumsikan tersedia: 200MB (model AI ~80MB diunduh saat
  login pertama via WiFi).
- TIDAK ada integrasi BPJS/SatuSehat/SIMRS di fase ini.
- Tidak membuat fitur yang memerlukan koneksi internet sebagai syarat wajib untuk fitur inti
  (F-01 s.d. F-08 di bawah).

## 3. Tech Stack (Wajib Dipakai, Jangan Diganti Tanpa Alasan Kuat)

| Layer | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| Target | Android, minSdkVersion 26 |
| On-device AI inference | TensorFlow Lite (TFLite) |
| Database lokal | SQLite (gunakan `sqflite` atau `drift`) |
| State management | Bloc atau Riverpod (pilih satu, konsisten di seluruh app) |
| HTTP client | `dio` (untuk sinkronisasi ke backend) |
| Kamera | `camera` plugin Flutter |
| Background sync | `workmanager` atau equivalent untuk retry otomatis |

Jangan memilih React Native, native Kotlin/Java murni, atau framework lain — proposal secara
eksplisit menetapkan Flutter+Dart dengan alasan multi-platform dan dukungan komunitas.

## 4. Arsitektur Kode (Feature-First + Clean Architecture)

Strukturkan project sebagai berikut. Setiap fitur memiliki tiga layer: `data`, `domain`,
`presentation`.

```
lib/
  core/
    constants/
    theme/
    utils/            # kalkulasi z-score WHO, validators
    network/          # dio client, interceptors
    database/          # sqlite setup, migrations
    ai/                # wrapper TFLite (load model, run inference)
  features/
    balita/
      data/            # models, local datasource (sqlite), remote datasource
      domain/          # entities, repository interface, usecases
      presentation/    # pages, widgets, state (bloc/riverpod)
    pengukuran/
      data/ domain/ presentation/
    deteksi_risiko/     # F-04, wrapper ke model ensemble XGBoost+RF (TFLite)
      data/ domain/ presentation/
    scan_wajah/          # F-05, wrapper ke model MobileNetV2 (TFLite)
      data/ domain/ presentation/
    log_nutrisi/          # F-06, wrapper ke model EfficientNet-B0 (TFLite)
      data/ domain/ presentation/
    riwayat_pertumbuhan/   # F-07, grafik kurva WHO
      data/ domain/ presentation/
    rekomendasi/            # F-08
      data/ domain/ presentation/
    sync/                    # F-09, mekanisme offline-first
      data/ domain/ presentation/
    notifikasi/               # F-10
      data/ domain/ presentation/
    auth/                       # registrasi & login kader
      data/ domain/ presentation/
  app.dart
  main.dart
assets/
  models/                # file .tflite (stunting_risk.tflite, face_cv.tflite, food_cls.tflite)
  who_tables/             # tabel LMS WHO (JSON/CSV) per indikator & jenis kelamin
test/
  (mirror struktur lib/ untuk unit test)
```

## 5. Spesifikasi Fitur (Wajib Diimplementasikan — Mapping ke Tabel F.1.1 Proposal)

Implementasikan SEMUA fitur berikut. Prioritas "Tinggi" dikerjakan lebih dulu.

| ID | Fitur | Prioritas | Detail Implementasi |
|---|---|---|---|
| F-01 | Manajemen Data Balita | Tinggi | CRUD: nama, NIK (opsional), tgl lahir, jenis kelamin, nama ibu, alamat, riwayat BBLR, durasi ASI eksklusif, usia mulai MPASI. Search + filter di list. |
| F-02 | Input Pengukuran Rutin | Tinggi | Form TB(cm), BB(kg), LiLA(cm, opsional, 6-59 bulan), lingkar kepala(cm, opsional). Validasi rentang nilai (tolak input fisiologis tidak wajar, mis. TB < 30cm atau > 130cm). |
| F-03 | Kalkulasi Z-Score Otomatis | Tinggi | Implementasikan metode LMS persis sesuai rumus di bagian 7. Real-time setelah input pengukuran disimpan. |
| F-04 | Deteksi Risiko AI | Tinggi | Jalankan model TFLite ensemble (14 fitur input, lihat bagian 8). Output: skor + kategori + confidence level. Latensi target < 50ms on-device. |
| F-05 | Scan Wajah CV | Sedang | Ambil foto via kamera dengan bingkai oval guide. Jalankan TFLite MobileNetV2. Tombol "Lewati Scan Wajah" WAJIB ada dan tidak memblokir alur. Validasi pencahayaan minimal sebelum capture jika memungkinkan (cek brightness histogram). |
| F-06 | Log Nutrisi Harian | Sedang | Foto makanan -> klasifikasi 50 kategori via TFLite EfficientNet-B0. Tampilkan estimasi kalori/protein/zat besi + opsi koreksi manual. Kategori tak dikenal -> fallback input manual nama makanan + estimasi porsi manual. |
| F-07 | Riwayat Pertumbuhan | Tinggi | Grafik garis (gunakan `fl_chart` atau `syncfusion_flutter_charts`) overlay kurva WHO vs data aktual balita, untuk TB/U, BB/U, BB/TB. |
| F-08 | Rekomendasi Intervensi | Tinggi | Berdasarkan skor risiko + profil balita, tampilkan rekomendasi gizi/MPASI spesifik (rule-based engine atau output model, lihat bagian 8). |
| F-09 | Mode Offline | Tinggi | SEMUA fitur F-01 s.d F-08 harus berjalan 100% tanpa koneksi internet. Lihat bagian 9 untuk mekanisme sync. |
| F-10 | Notifikasi Jadwal | Rendah | Local notification reminder posyandu bulanan + follow-up otomatis untuk balita risiko sedang/tinggi (gunakan `flutter_local_notifications`). |

## 6. Urutan Eksekusi (Fase Kerja untuk Agent)

Kerjakan secara berurutan. Setelah setiap fase, jalankan `flutter analyze` dan
`flutter test`, perbaiki error sebelum lanjut ke fase berikutnya.

1. **Setup project**: inisialisasi Flutter project, setup struktur folder (bagian 4),
   konfigurasi `pubspec.yaml` dengan semua dependency yang dibutuhkan, setup tema warna
   biru-teal (sesuai mockup proposal bagian H.1).
2. **Core utilities**: implementasikan kalkulasi z-score WHO (bagian 7) lebih dulu — ini
   dependency untuk semua fitur lain. Tulis unit test dengan minimal 10 kasus uji (termasuk
   edge case z > 3 dan z < -3).
3. **Auth & registrasi kader** (F dasar, prasyarat sebelum fitur lain): registrasi kader baru
   (nama, NIK, no telepon, nama posyandu, wilayah kerja), login, status validasi.
4. **F-01 Manajemen Data Balita** + database lokal SQLite.
5. **F-02 Input Pengukuran** + **F-03 Kalkulasi Z-Score** (terhubung langsung).
6. **F-07 Riwayat Pertumbuhan** (bisa dikerjakan begitu F-02/F-03 selesai karena hanya
   visualisasi data yang sudah ada).
7. **F-04 Deteksi Risiko AI**: integrasikan model TFLite. Jika model belum tersedia,
   buat *stub/mock* yang mengembalikan skor dummy konsisten dengan skema output, beri TODO
   jelas untuk model produksi (lihat bagian 8 untuk skema).
8. **F-08 Rekomendasi Intervensi**: rule-based mapping dari skor risiko + profil ke teks
   rekomendasi.
9. **F-05 Scan Wajah CV** (stub model sama seperti F-04 jika model belum ada).
10. **F-06 Log Nutrisi Harian** (stub model sama seperti F-04 jika model belum ada).
11. **F-09 Mode Offline & Sinkronisasi**: implementasikan mekanisme penuh sesuai bagian 9.
12. **F-10 Notifikasi Jadwal**.
13. **Polish UI/UX**: sesuaikan dengan mockup di proposal bagian H.1.1 dan H.1.2 (beranda +
    daftar balita, layar pengukuran + hasil deteksi AI dengan visualisasi gauge dan kode
    warna risiko).
14. **QA pass**: skenario troubleshooting di bagian 10 harus semua tertangani di UI (pesan
    error yang jelas, tombol retry, dll).

## 7. Spesifikasi Kalkulasi Z-Score (WAJIB Akurat)

Gunakan metode LMS (Lambda-Mu-Sigma), Cole & Green (1992), sesuai tabel referensi WHO
per jenis kelamin dan usia (bulan). Simpan tabel L(t), M(t), S(t) di `assets/who_tables/`
sebagai JSON, dipisah per indikator (TB/U, BB/U, BB/TB) dan jenis kelamin.

Rumus dasar:
- Jika L(t) ≠ 0: `z = (((y / M(t)) ** L(t)) - 1) / (L(t) * S(t))`
- Jika L(t) = 0 (khusus TB/U): `z = ln(y / M(t)) / S(t)`

Koreksi nilai ekstrem (hanya untuk indikator berbasis berat badan, karena distribusi
right-skewed):
- Jika `z > 3`: hitung `SD3pos = M(t) * (1 + L(t)*S(t)*3) ** (1/L(t))`, lalu
  `SD23pos = SD3pos - M(t) * (1 + L(t)*S(t)*3) ** (1/L(t))` *(catatan: gunakan rumus persis
  dari dokumen sumber WHO MGRS untuk SD2 dan SD3, validasikan ulang terhadap implementasi
  referensi WHO Anthro sebelum produksi — proposal memberi formula ringkas yang harus
  divalidasi numerik)*, lalu `z* = 3 + (y - SD3pos) / SD23pos`.
- Jika `z < -3`: gunakan rumus simetris dengan SD3neg/SD23neg.

Kategori interpretasi standar WHO (gunakan ini, jangan buat skala sendiri):
- TB/U: z < -3 → severely stunted, -3 ≤ z < -2 → stunted, z ≥ -2 → normal
- BB/U: z < -3 → severely underweight, -3 ≤ z < -2 → underweight, z ≥ -2 → normal
- BB/TB: z < -3 → severely wasted, -3 ≤ z < -2 → wasted, z ≥ -2 → normal

Tulis fungsi ini sebagai pure function yang dapat ditest secara unit tanpa dependency UI.

## 8. Skema Model AI (Interface yang Harus Disediakan Agent)

Karena model ML/CV dilatih secara terpisah (lihat agent backend-ml jika ada, atau tim data
science), agent mobile WAJIB membungkus pemanggilan model dengan interface yang stabil agar
model dapat diganti tanpa mengubah kode aplikasi.

### 8.1 Model Risiko Stunting (Ensemble XGBoost+RF → dikonversi ke TFLite)
Input (14 fitur, urutan harus exact match dengan training):
```
[zscore_tbu, zscore_bbu, zscore_bbtb, lila,
 usia_bulan, jenis_kelamin, urutan_kelahiran, jarak_kelahiran,
 riwayat_bblr, durasi_asi_eksklusif, usia_mulai_mpasi,
 pendidikan_ibu, sumber_air_minum, akses_sanitasi]
```
Output: `{ skor: float (0-1), kategori: "rendah"|"sedang"|"tinggi", confidence: float }`

### 8.2 Model Face CV (MobileNetV2)
Input: foto wajah balita (preprocessing: crop wajah, resize sesuai spec model).
Output: feature vector / skor tambahan yang dikombinasikan ke skor akhir sebagai *modifier*,
BUKAN pengganti skor antropometri.

### 8.3 Model Food Classification (EfficientNet-B0)
Input: foto makanan.
Output: `{ kategori: string (1 dari 50 kategori MPASI/lokal), confidence: float,
estimasi_porsi: float, kalori: float, protein: float, zat_besi: float }`
Jika `confidence` di bawah threshold (tentukan, mis. 0.5), tampilkan prompt input manual.

Letakkan file `.tflite` di `assets/models/`. Jika belum tersedia saat development, buat
implementasi stub yang mengikuti interface ini persis, beri komentar `// TODO: replace stub
with production TFLite model` agar mudah ditemukan dan diganti nanti.

## 9. Mekanisme Offline-First & Sinkronisasi (F-09, Wajib Detail)

1. Setiap operasi tulis (balita baru, pengukuran, log nutrisi) **selalu** ditulis ke SQLite
   lokal dulu, tidak menunggu server. Tambahkan kolom `syncStatus` (`PENDING`|`SYNCED`) dan
   `retryCount` (default 0) di setiap tabel yang disinkronkan.
2. **Fase Push**: saat `NetworkCallback`/connectivity listener mendeteksi koneksi tersedia,
   `SyncManager` membaca semua record `PENDING`, kirim via `upsertRecord()` ke backend API.
   Sukses → ubah jadi `SYNCED`. Gagal → exponential backoff: `delay = 2^retryCount *
   base_delay` (base_delay disarankan 1-2 detik), increment `retryCount`.
3. **Fase Pull**: setelah push selesai, ambil data terbaru dari server berdasarkan
   `lastSyncTimestamp`. Terapkan **strategi server-wins** untuk konflik: jika record yang
   sama berubah di lebih dari satu device, versi server menang.
4. Implementasikan ini di `features/sync/` sebagai service terpisah yang dipanggil dari
   background task (`workmanager`) dan juga bisa dipicu manual via tombol "Paksa
   Sinkronisasi" di Pengaturan (lihat troubleshooting bagian 10).
5. Tulis unit test untuk: push sukses, push gagal+retry, pull dengan konflik server-wins.

## 10. Skenario Troubleshooting yang Harus Tertangani di UI

Pastikan setiap kondisi ini punya pesan error yang jelas dan jalan keluar di UI (bukan hanya
crash atau diam):

| Kondisi | Penanganan UI yang Wajib Ada |
|---|---|
| Foto wajah gagal terdeteksi / akurasi rendah | Pesan saran (pencahayaan, lensa, posisi) + tombol "Lewati Scan Wajah" |
| Data tidak tersinkronisasi | Menu Pengaturan > Sinkronisasi > tombol "Paksa Sinkronisasi", tampilkan kode error jika persisten |
| Ruang penyimpanan < 200MB | Peringatan proaktif sebelum unduh model AI |
| Makanan tidak dikenali AI | Fallback otomatis ke input manual, tanpa dead-end |
| Lupa password | Alur reset password via email (delegasi ke backend endpoint) |

## 11. Definition of Done

Sebuah fitur dianggap selesai jika:
- Kode mengikuti struktur folder bagian 4 (data/domain/presentation terpisah).
- Lulus `flutter analyze` tanpa error.
- Memiliki unit test untuk logika domain (terutama z-score, sync, dan mapping skor risiko).
- Berfungsi 100% offline untuk fitur F-01 s.d F-08.
- Disclaimer "bukan diagnosis medis" tampil di setiap layar hasil deteksi risiko.
- UI menggunakan bahasa Indonesia dan skema warna biru-teal konsisten.

## 12. Yang TIDAK Boleh Dilakukan Agent

- Jangan mengganti Flutter dengan framework lain.
- Jangan menambahkan dukungan iOS di fase ini.
- Jangan membuat skor risiko hanya dari satu model (selalu kombinasi sesuai bagian 8).
- Jangan membuat fitur inti bergantung pada koneksi internet.
- Jangan mengklaim aplikasi ini sebagai alat diagnostik resmi — selalu posisikan sebagai
  *decision support tool*.
