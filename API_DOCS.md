# 🚀 Dokumentasi API StunGuard

Dokumentasi ini menjelaskan endpoint-endpoint API yang tersedia pada sistem backend StunGuard, cara mengaksesnya, serta contoh format request dan response.

## 📌 Standar Response Envelope
Seluruh endpoint (kecuali jika ada error tingkat server/routing) menggunakan standar format response (Envelope) berikut:

### Sukses (200 OK / 201 Created)
```json
{
  "success": true,
  "data": { ... }
}
```

### Error / Gagal (400 / 401 / 404 / 500)
```json
{
  "success": false,
  "error": "Pesan error atau deskripsi kegagalan"
}
```

## 🔐 Autentikasi (Bearer Token)
Untuk endpoint yang membutuhkan autentikasi (dilindungi oleh `AuthMiddleware`), pastikan untuk menyertakan token JWT pada header HTTP:
```text
Authorization: Bearer <TOKEN_JWT_ANDA>
```

---

## 1. 🛡️ Modul Autentikasi (`/api/auth`)

### 1.1 Register Pengguna Baru (Kader)
Mendaftarkan kader baru. Akun yang baru didaftarkan akan berstatus `pending` hingga divalidasi oleh koordinator.
- **URL**: `/api/auth/register`
- **Method**: `POST`
- **Body**:
```json
{
  "nama": "Siti Aminah",
  "email": "siti.aminah@gmail.com",
  "password": "Password123!",
  "role": "kader",
  "posyandu_id": 1,
  "nik": "3201234567890001",
  "no_telepon": "081234567890"
}
```
- **Response**:
```json
{
  "success": true,
  "data": {
    "message": "Registrasi berhasil",
    "user": { ... }
  }
}
```

### 1.2 Login Kader
- **URL**: `/api/auth/login`
- **Method**: `POST`
- **Body**:
```json
{
  "email": "siti.aminah@gmail.com",
  "password": "Password123!"
}
```
- **Response**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbG...",
    "refresh_token": "eyJhbG...",
    "user": {
      "id": 1,
      "email": "siti.aminah@gmail.com",
      "role": "kader"
    }
  }
}
```

### 1.3 Refresh Token
- **URL**: `/api/auth/refresh`
- **Method**: `POST`
- **Body**:
```json
{
  "refresh_token": "eyJhbG..."
}
```
- **Response**: Mengembalikan token & refresh_token yang baru.

---

## 2. 👶 Modul Balita (`/api/v1/balita`)

*Endpoint ini memerlukan Autentikasi Token.*

### 2.1 Get Semua Data Balita (Paginated & Filter)
- **URL**: `/api/v1/balita?page=1&limit=20&search=Nama&kategori_risiko=tinggi&wilayah=Wilayah1`
- **Method**: `GET`
- **Response**:
```json
{
  "success": true,
  "data": {
    "balita": [
      {
        "id": 1,
        "nik": "321...",
        "nama": "Budi",
        "tanggal_lahir": "2023-01-01T00:00:00Z"
      }
    ],
    "limit": 20,
    "page": 1,
    "total": 100
  }
}
```

### 2.2 Tambah Balita Baru
- **URL**: `/api/v1/balita/create`
- **Method**: `POST`
- **Body**:
```json
{
  "nik": "3201234500001111",
  "nama": "Ahmad",
  "tanggal_lahir": "2023-05-10T00:00:00Z",
  "jenis_kelamin": "L",
  "nama_ibu": "Rina",
  "alamat": "Jl. Mawar No 10",
  "riwayat_bblr": false,
  "durasi_asi_eksklusif": 6,
  "posyandu_id": 1
}
```
*Catatan: Data sensitif seperti NIK, Nama, Nama Ibu, dan Alamat akan dienkripsi otomatis (AES-256) saat disimpan ke database.*

---

## 3. 📏 Modul Pengukuran (`/api/v1/pengukuran`)

*Endpoint ini memerlukan Autentikasi Token.*

### 3.1 Input Data Pengukuran
- **URL**: `/api/v1/pengukuran/create`
- **Method**: `POST`
- **Body**:
```json
{
  "balita_id": 1,
  "tanggal": "2024-02-01T00:00:00Z",
  "tinggi_badan": 85.5,
  "berat_badan": 12.3,
  "lila": 15.0,
  "lingkar_kepala": 48.0,
  "kader_id": 1
}
```

---

## 4. 🔄 Modul Sinkronisasi Mobile (`/api/v1/sync`)

### 4.1 Push Sinkronisasi (Dari Mobile ke Server)
Digunakan untuk mengirim data hasil pekerjaan offline dari aplikasi mobile ke server pusat. Konflik akan diselesaikan menggunakan metode **Server-Wins**.

- **URL**: `/api/v1/sync/push`
- **Method**: `POST`
- **Body**:
```json
{
  "balita": [ ... array data balita ... ],
  "pengukuran": [ ... array data pengukuran ... ],
  "hasil_deteksi": [ ... array data deteksi ... ],
  "log_nutrisi": [ ... array log nutrisi ... ]
}
```
- **Response**: Mengembalikan total data yang sukses masuk dan yang gagal.

### 4.2 Pull Sinkronisasi (Dari Server ke Mobile)
- **URL**: `/api/v1/sync/pull?since=2024-01-01T00:00:00Z&posyandu_ids=1&posyandu_ids=2`
- **Method**: `GET`
- **Response**: Akan mengembalikan array data `balita`, `pengukuran`, `hasil_deteksi`, dan `log_nutrisi` yang dimodifikasi semenjak waktu `since`.

---

## 5. 📊 Modul Dashboard & Analitik (`/api/v1/dashboard` & `/api/v1/analitik`)

### 5.1 Dashboard Summary
- **URL**: `/api/v1/dashboard/summary?wilayah=Sukamaju`
- **Method**: `GET`
- **Response**:
```json
{
  "success": true,
  "data": {
    "total_balita": 150,
    "distribusi_risiko": {
      "rendah": 100,
      "sedang": 30,
      "tinggi": 20
    }
  }
}
```

### 5.2 Heatmap Risiko
- **URL**: `/api/v1/dashboard/heatmap?kategori=tinggi&from=2024-01-01&to=2024-02-01`
- **Method**: `GET`

### 5.3 Tren Gizi (Analitik)
- **URL**: `/api/v1/analitik/tren?periode=bulanan`
- **Method**: `GET`

---

## 6. 🚨 Modul Alert Notifikasi (`/api/v1/alert`)

### 6.1 Ambil Semua Alert
- **URL**: `/api/v1/alert?unread=true`
- **Method**: `GET`

### 6.2 Tandai Alert Dibaca
- **URL**: `/api/v1/alert/1/read`
- **Method**: `POST`

---

## 7. 📄 Modul Laporan (`/api/v1/laporan`)

### 7.1 Generate Laporan
Membuat permintaan pembuatan laporan PDF / Excel.
- **URL**: `/api/v1/laporan/generate`
- **Method**: `POST`
- **Body**:
```json
{
  "jenis": "bulanan",
  "wilayah": "Kecamatan Sukamaju",
  "periode_from": "2024-01-01T00:00:00Z",
  "periode_to": "2024-01-31T23:59:59Z",
  "format": "pdf"
}
```
- **Response**: Mengembalikan ID Job `job_id` yang bisa dicek di endpoint status.

### 7.2 Cek Status Laporan
- **URL**: `/api/v1/laporan/status/<job_id>`
- **Method**: `GET`
- **Response**: Menampilkan file laporan apabila status sudah `ready`.