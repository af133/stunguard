# 🚀 StunGuard Backend API

Backend API untuk aplikasi **StunGuard** (Web & Mobile) yang dibangun menggunakan **Go (Golang)**, **Gin Gonic**, **GORM**, dan **PostgreSQL**.

Backend ini menerapkan **Layered Architecture** sehingga kode lebih terstruktur, mudah dipelihara, dan mudah dikembangkan.

---

## 🛠 Tech Stack

- Go 1.25+
- Gin Gonic
- GORM
- PostgreSQL

---

# 📋 Prasyarat

Pastikan perangkat telah terinstal:

- Go **v1.25** atau lebih baru
- PostgreSQL Server
- Git

---

# ⚙️ Konfigurasi Database

Buka file:

```text
internal/database.go
```

Kemudian sesuaikan konfigurasi PostgreSQL.

```go
host := "localhost"
user := "postgres"
password := "your_password"
port := "5432"
dbname := "stunguard"
```

| Variable | Keterangan |
|----------|------------|
| host | Host PostgreSQL (default: localhost) |
| user | Username PostgreSQL |
| password | Password PostgreSQL |
| port | Port PostgreSQL (default: 5432) |

> **Catatan**
>
> Database **tidak perlu dibuat secara manual**.
>
> Saat backend pertama kali dijalankan, sistem akan:
>
> - membuat database apabila belum tersedia
> - melakukan Auto Migration seluruh tabel menggunakan GORM

---

# ▶️ Menjalankan Backend

Masuk ke folder backend kemudian jalankan:

```bash
go mod tidy
```

Lalu:

```bash
go run ./cmd/api
```

Apabila berhasil, server akan berjalan pada:

```text
http://localhost:8080
```

---

# 📁 Struktur Project

```text
backend/
│
├── cmd/
│   └── api/
│       └── main.go
│
├── internal/
│   ├── database.go
│   ├── models.go
│   │
│   ├── handlers/
│   ├── services/
│   ├── repositories/
│   └── routes/
│
├── go.mod
└── go.sum
```

---

# 🏗 Arsitektur

Project ini menggunakan **Layered Architecture**.

## cmd/api/main.go

Merupakan entry point aplikasi.

Tugasnya:

- menjalankan koneksi database
- menjalankan Auto Migration
- menginisialisasi router
- menjalankan server Gin pada port 8080

---

## internal/database.go

Bertanggung jawab terhadap:

- koneksi PostgreSQL
- pembuatan database otomatis
- Auto Migration seluruh model menggunakan GORM

---

## internal/models.go

Berisi seluruh struktur model database dalam bentuk **Struct Go**.

Contoh:

- User
- Child
- History
- dll.

---

## internal/handlers

Layer **Presentation**.

Tugasnya:

- menerima HTTP Request
- membaca JSON dari frontend
- melakukan validasi request
- mengirim data ke Service

Handler tidak berisi logika bisnis.

---

## internal/services

Layer **Business Logic**.

Seluruh proses utama aplikasi berada di sini, misalnya:

- hashing password
- validasi data
- autentikasi
- proses perhitungan
- pengolahan data

Service tidak berhubungan langsung dengan HTTP maupun database.

---

## internal/repositories

Layer **Data Access**.

Berisi seluruh query database menggunakan GORM.

Contoh:

- Create()
- Find()
- First()
- Save()
- Delete()

Repository hanya bertugas mengambil atau menyimpan data.

---

## internal/routes

Tempat mendefinisikan seluruh endpoint API.

Contoh:

```go
POST   /api/register
POST   /api/login
GET    /api/profile
PUT    /api/profile
DELETE /api/profile
```

---

# 📌 API Endpoint

## Register User

| Method | Endpoint | Access |
|---------|----------|--------|
| POST | `/api/register` | Public |

Digunakan untuk mendaftarkan akun pengguna baru.

---

# 🚀 Cara Kerja Layer

```text
Frontend
    │
    ▼
Routes
    │
    ▼
Handlers
    │
    ▼
Services
    │
    ▼
Repositories
    │
    ▼
PostgreSQL
```

Setiap layer memiliki tanggung jawab masing-masing sehingga kode menjadi lebih bersih dan mudah dikembangkan.

---

# 📦 Dependencies

Project menggunakan beberapa package utama berikut:

- Gin Gonic
- GORM
- PostgreSQL Driver

Untuk mengunduh seluruh dependency jalankan:

```bash
go mod tidy
```

---

# 👨‍💻 Author

Developed for **StunGuard Cross Platform Project** using Go, Gin, GORM, and PostgreSQL.