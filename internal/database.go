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

// =================== Entity Definitions ===================

type DinasKesehatan struct {
	gorm.Model
	Nama          string      `gorm:"size:150;not null" json:"nama"`
	WilayahKerja  string      `gorm:"size:100" json:"wilayah_kerja"`
	PuskesmasList []Puskesmas `gorm:"foreignKey:DinasID" json:"puskesmas_list,omitempty"`
}

type Puskesmas struct {
	gorm.Model
	Nama         string     `gorm:"size:150;not null" json:"nama"`
	WilayahKerja string     `gorm:"size:100" json:"wilayah_kerja"`
	DinasID      uint       `json:"dinas_id"`
	PosyanduList []Posyandu `gorm:"foreignKey:PuskesmasID" json:"posyandu_list,omitempty"`
}

type Posyandu struct {
	gorm.Model
	Nama         string  `gorm:"size:150;not null" json:"nama"`
	WilayahKerja string  `gorm:"size:100;index" json:"wilayah_kerja"`
	KoordinatLat float64 `gorm:"type:decimal(10,8)" json:"koordinat_lat"`
	KoordinatLng float64 `gorm:"type:decimal(11,8)" json:"koordinat_lng"`
	PuskesmasID  uint    `gorm:"not null;index" json:"puskesmas_id"`
}

type User struct {
	gorm.Model
	Email          string `gorm:"size:150;unique;not null" json:"email"`
	PasswordHash   string `gorm:"size:255;not null" json:"-"`
	Role           string `gorm:"size:50;not null;index" json:"role"`
	WilayahKerjaID uint   `gorm:"index" json:"wilayah_kerja_id"`
	StatusValidasi string `gorm:"size:20;default:'pending'" json:"status_validasi"`
	RefreshToken   string `gorm:"size:500" json:"-"`
}

type Kader struct {
	gorm.Model
	Nama           string `gorm:"size:100;not null" json:"nama"`
	NIK            string `gorm:"size:255;unique" json:"nik"`
	NoTelepon      string `gorm:"size:20" json:"no_telepon"`
	PosyanduID     uint   `gorm:"not null;index" json:"posyandu_id"`
	UserID         uint   `gorm:"index" json:"user_id"`
	StatusValidasi string `gorm:"size:20;default:'pending'" json:"status_validasi"`
}

type Balita struct {
	gorm.Model
	NIK                string    `gorm:"size:255" json:"nik"`
	Nama               string    `gorm:"size:150;not null" json:"nama"`
	TanggalLahir       time.Time `gorm:"type:date;not null" json:"tanggal_lahir"`
	JenisKelamin       string    `gorm:"size:1;not null" json:"jenis_kelamin"`
	NamaIbu            string    `gorm:"size:150" json:"nama_ibu"`
	Alamat             string    `gorm:"type:text" json:"alamat"`
	RiwayatBBLR        bool      `gorm:"default:false" json:"riwayat_bblr"`
	DurasiAsiEksklusif string    `gorm:"size:50" json:"durasi_asi_eksklusif"`
	UsiaMulaiMpasi     string    `gorm:"size:50" json:"usia_mulai_mpasi"`
	PosyanduID         uint      `gorm:"not null;index" json:"posyandu_id"`
	SyncStatusOrigin   string    `gorm:"size:100" json:"sync_status_origin"`
	SyncStatus         string    `gorm:"size:20;default:'synced';index" json:"sync_status"`
	UpdatedAt          time.Time `gorm:"autoUpdateTime;index" json:"updated_at"`
}

type Pengukuran struct {
	gorm.Model
	BalitaID       uint      `gorm:"not null;index" json:"balita_id"`
	Tanggal        time.Time `gorm:"type:date;not null;index" json:"tanggal"`
	TinggiBadan    float64   `gorm:"not null" json:"tinggi_badan"`
	BeratBadan     float64   `gorm:"not null" json:"berat_badan"`
	Lila           *float64  `json:"lila"`
	LingkarKepala  *float64  `json:"lingkar_kepala"`
	ZScoreTBU      float64   `json:"zscore_tbu"`
	ZScoreBBU      float64   `json:"zscore_bbu"`
	ZScoreBBTB     float64   `json:"zscore_bbtb"`
	KategoriTBU    string    `gorm:"size:50" json:"kategori_tbu"`
	KategoriBBU    string    `gorm:"size:50" json:"kategori_bbu"`
	KategoriBBTB   string    `gorm:"size:50" json:"kategori_bbtb"`
	KaderID        uint      `gorm:"not null;index" json:"kader_id"`
	SyncStatus     string    `gorm:"size:20;default:'synced';index" json:"sync_status"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime;index" json:"updated_at"`
}

type HasilDeteksiRisiko struct {
	gorm.Model
	BalitaID              uint    `gorm:"not null;index" json:"balita_id"`
	PengukuranID          uint    `gorm:"not null" json:"pengukuran_id"`
	Skor                  float64 `json:"skor"`
	Kategori              string  `gorm:"size:20;index" json:"kategori"`
	Confidence            float64 `json:"confidence"`
	RekomendasiIntervensi string  `gorm:"type:text" json:"rekomendasi_intervensi"`
	FaceCvUsed            bool    `gorm:"default:false" json:"face_cv_used"`
	SyncStatus            string  `gorm:"size:20;default:'synced';index" json:"sync_status"`
	UpdatedAt             time.Time `gorm:"autoUpdateTime;index" json:"updated_at"`
}

type LogNutrisi struct {
	gorm.Model
	BalitaID        uint      `gorm:"not null;index" json:"balita_id"`
	Tanggal         time.Time `gorm:"type:date;not null" json:"tanggal"`
	JenisInput      string    `gorm:"size:20" json:"jenis_input"`
	KategoriMakanan string    `gorm:"size:100" json:"kategori_makanan"`
	EstimasiPorsi   string    `gorm:"size:100" json:"estimasi_porsi"`
	Kalori          float64   `json:"kalori"`
	Protein         float64   `json:"protein"`
	ZatBesi         float64   `json:"zat_besi"`
	SyncStatus      string    `gorm:"size:20;default:'synced';index" json:"sync_status"`
	UpdatedAt       time.Time `gorm:"autoUpdateTime;index" json:"updated_at"`
}

type Alert struct {
	gorm.Model
	BalitaID       uint   `gorm:"not null;index" json:"balita_id"`
	KategoriRisiko string `gorm:"size:50;index" json:"kategori_risiko"`
	WilayahKerja   string `gorm:"size:100;index" json:"wilayah_kerja"`
	Status         string `gorm:"size:20;default:'unread';index" json:"status"`
}

type LaporanJob struct {
	gorm.Model
	Jenis       string    `gorm:"size:50" json:"jenis"`
	Wilayah     string    `gorm:"size:100" json:"wilayah"`
	PeriodeFrom time.Time `gorm:"type:date" json:"periode_from"`
	PeriodeTo   time.Time `gorm:"type:date" json:"periode_to"`
	Format      string    `gorm:"size:10" json:"format"`
	Status      string    `gorm:"size:20;default:'processing'" json:"status"`
	FileURL     string    `gorm:"size:255" json:"file_url"`
	RequestedBy uint      `json:"requested_by"`
}

// =================== Config ===================

type Config struct {
	DatabaseURL string
	JWTSecret   string
	AESKey      string
	SMTPHost    string
	SMTPPort    string
	SMTPUser    string
	SMTPPass    string
	SMTPFrom    string
	Port        string
}

func LoadConfig() *Config {
	_ = godotenv.Load()

	cfg := &Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		JWTSecret:   os.Getenv("JWT_SECRET"),
		AESKey:      os.Getenv("AES_KEY"),
		SMTPHost:    os.Getenv("SMTP_HOST"),
		SMTPPort:    os.Getenv("SMTP_PORT"),
		SMTPUser:    os.Getenv("SMTP_USER"),
		SMTPPass:    os.Getenv("SMTP_PASS"),
		SMTPFrom:    os.Getenv("SMTP_FROM"),
		Port:        os.Getenv("PORT"),
	}

	if cfg.JWTSecret == "" {
		cfg.JWTSecret = "stunguard_super_secret_key_2026"
		fmt.Println("Warning: JWT_SECRET tidak ditemukan, menggunakan default key.")
	}
	if cfg.Port == "" {
		cfg.Port = "8080"
	}

	return cfg
}

// =================== Database Connection ===================

func ConnectDB() *gorm.DB {
	cfg := LoadConfig()
	dsn := cfg.DatabaseURL

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

	fmt.Println("Koneksi database dan Auto Migrate berhasil!")

	return DB
}