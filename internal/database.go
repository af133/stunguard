package internal

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

type DinasKesehatan struct {
	gorm.Model
	Nama           string `gorm:"size:150;not null"`
	WilayahKerja   string `gorm:"size:100"`
	PuskesmasList  []Puskesmas `gorm:"foreignKey:DinasID"`
}
type Puskesmas struct {
	gorm.Model
	Nama          string `gorm:"size:150;not null"`
	WilayahKerja  string `gorm:"size:100"`
	DinasID       uint
	PosyanduList  []Posyandu `gorm:"foreignKey:PuskesmasID"`
}
type Posyandu struct {
	gorm.Model
	Nama          string  `gorm:"size:150;not null"`
	WilayahKerja  string  `gorm:"size:100"` 
	KoordinatLat  float64 `gorm:"type:decimal(10,8)"`
	KoordinatLng  float64 `gorm:"type:decimal(11,8)"`
	PuskesmasID   uint    `gorm:"not null"`
}
type User struct {
	gorm.Model
	Email              string `gorm:"size:150;unique;not null"`
	PasswordHash       string `gorm:"size:255;not null"`
	Role               string `gorm:"size:50;not null"`
	WilayahKerjaID     uint  
	StatusValidasi     string `gorm:"size:20;default:'pending'"` 
}

type Kader struct {
	gorm.Model
	Nama           string `gorm:"size:100;not null"`
	NIK            string `gorm:"size:255;unique"`
	NoTelepon      string `gorm:"size:20"`
	PosyanduID     uint   `gorm:"not null"`
	StatusValidasi string `gorm:"size:20;default:'pending'"`
}
type Balita struct {
	gorm.Model
	NIK                 string    `gorm:"size:255"` 
	Nama                string    `gorm:"size:150;not null"`
	TanggalLahir        time.Time `gorm:"type:date;not null"`
	JenisKelamin        string    `gorm:"size:1;not null"`
	NamaIbu             string    `gorm:"size:150"`       
	Alamat              string    `gorm:"type:text"`      
	RiwayatBBLR         bool      `gorm:"default:false"`
	DurasiAsiEksklusif  string    `gorm:"size:50"`
	UsiaMulaiMpasi      string    `gorm:"size:50"`
	PosyanduID          uint      `gorm:"not null"`
	SyncStatusOrigin    string    `gorm:"size:100"`       
}
type Pengukuran struct {
	gorm.Model
	BalitaID        uint      `gorm:"not null"`
	Tanggal         time.Time `gorm:"type:date;not null"`
	TinggiBadan     float64   `gorm:"not null"`
	BeratBadan      float64   `gorm:"not null"`
	Lila            *float64  
	LingkarKepala   *float64  
	ZScoreTBU       float64
	ZScoreBBU       float64
	ZScoreBBTB      float64
	KategoriTBU     string    `gorm:"size:50"`
	KategoriBBU     string    `gorm:"size:50"`
	KategoriBBTB    string    `gorm:"size:50"`
	KaderID         uint      `gorm:"not null"`
}

type HasilDeteksiRisiko struct {
	gorm.Model
	BalitaID              uint    `gorm:"not null"`
	PengukuranID          uint    `gorm:"not null"`
	Skor                  float64
	Kategori              string  `gorm:"size:20"`
	Confidence            float64
	RekomendasiIntervensi string  `gorm:"type:text"`
	FaceCvUsed            bool    `gorm:"default:false"`
}
type LogNutrisi struct {
	gorm.Model
	BalitaID        uint      `gorm:"not null"`
	Tanggal         time.Time `gorm:"type:date;not null"`
	JenisInput      string    `gorm:"size:20"`
	KategoriMakanan string    `gorm:"size:100"`
	EstimasiPorsi   string    `gorm:"size:100"`
	Kalori          float64
	Protein         float64
	ZatBesi         float64
}
type Alert struct {
	gorm.Model
	BalitaID        uint   `gorm:"not null"`
	KategoriRisiko  string `gorm:"size:50"`
	WilayahKerja    string `gorm:"size:100"`
	Status          string `gorm:"size:20;default:'unread'"`
}
type LaporanJob struct {
	gorm.Model
	Jenis        string `gorm:"size:50"` 
	Wilayah      string `gorm:"size:100"`
	PeriodeFrom  time.Time `gorm:"type:date"`
	PeriodeTo    time.Time `gorm:"type:date"`
	Format       string `gorm:"size:10"`
	Status       string `gorm:"size:20;default:'processing'"`
	FileURL      string `gorm:"size:255"`
	RequestedBy  uint
}
func ConnectDB() *gorm.DB {
    _ = godotenv.Load()
    dsn := os.Getenv("DATABASE_URL")
    
    if dsn == "" {
        host := "localhost"
        user := "postgres"
        password := "1234"
        dbName := "stunguard"
        port := "5432"
        dsn = fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
            host, user, password, dbName, port)
        fmt.Println("Warning: DATABASE_URL tidak ditemukan, menggunakan konfigurasi lokal default.")
    }

    var err error
    DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatal("Gagal terkoneksi ke database:", err)
    }

    fmt.Println("Berhasil terhubung ke PostgreSQL!")

    // SELALU DROP SEMUA TABEL DARI NOL (Berlaku Lokal maupun Render)
    fmt.Println("Melakukan reset total schema database (Drop & Recreate)...")
    err = DB.Exec("DROP SCHEMA public CASCADE; CREATE SCHEMA public;").Error
    if err != nil {
        log.Fatal("Gagal mereset schema database:", err)
    }
    fmt.Println("Database berhasil dibersihkan total dari nol.")

    fmt.Println("Menjalankan Auto Migrate tabel...")
    err = DB.AutoMigrate(
        &DinasKesehatan{},
        &Puskesmas{},
        &Posyandu{},
        &User{},
        &Kader{},
        &Balita{},
        &Pengukuran{},
        &HasilDeteksiRisiko{},
        &LogNutrisi{},
        &Alert{},
        &LaporanJob{},
    )
    if err != nil {
        log.Fatal("Gagal melakukan auto migration:", err)
    }

    fmt.Println("Auto Migrate berhasil!")

    return DB
}