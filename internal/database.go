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

type User struct {
	gorm.Model
	NamaLengkap    string `gorm:"size:100;not null"`
	NIK            string `gorm:"size:16;unique"`
	NomorTelepon   string `gorm:"size:20"`
	NamaPosyandu   string `gorm:"size:100"`
	WilayahKerja   string `gorm:"size:100"`
	Password       string `gorm:"size:255;not null"`
	Role           string `gorm:"size:50"`                 
	StatusValidasi string `gorm:"size:20;default:'pending'"`
}

type Balita struct {
	gorm.Model
	KaderID            	uint
	NamaLengkap        	string    `gorm:"size:100;not null"`
	NIKBalita          	string    `gorm:"size:16"`
	TanggalLahir       	time.Time `gorm:"type:date"`
	JenisKelamin       	string    `gorm:"size:1"` 
	NamaIbu            	string    `gorm:"size:100"`
	Provinsi           	string    `gorm:"type:text"`
	Kecamatan         	string    `gorm:"type:text"`
	Kelurahan          	string    `gorm:"type:text"`
	Desa             	string    `gorm:"type:text"`
	BBLR               	bool      `gorm:"default:false"`
	DurasiAsiEksklusif 	string    `gorm:"size:50"`
	UsiaMulaiMpasi     	string    `gorm:"size:50"`
}
type NutrisiHarian struct {
	gorm.Model
	BalitaID    uint      `gorm:"not null"` 
	Tanggal     time.Time `gorm:"type:date;not null"`
	MetodeInput string    `gorm:"size:50"` 
	NamaMakanan string    `gorm:"size:150"`
	Porsi       string    `gorm:"size:100"`
	Kalori      float64   
	Protein     float64   
	ZatBesi     float64   
}

type Pengukuran struct {
	gorm.Model
	BalitaID              uint
	KaderID               uint
	TanggalPengukuran     time.Time `gorm:"type:date"`
	TinggiBadan           float64
	BeratBadan            float64
	LingkarLenganAtas     float64
	LingkarKepala         float64
	InterpretasiStatus    string `gorm:"size:50"` 
	AISkorRisiko          string `gorm:"size:50"` 
	AIFotoPath            string `gorm:"size:255"`
	RekomendasiIntervensi string `gorm:"type:text"`
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

	// 5. Auto Migrate (Tanpa DropTable!)
	fmt.Println("Menjalankan Auto Migrate tabel...")
	err = DB.AutoMigrate(
		&User{},
		&Balita{},
		&Pengukuran{},
		&NutrisiHarian{},
	)
	if err != nil {
		log.Fatal("Gagal melakukan auto migration:", err)
	}

	fmt.Println("Auto Migrate berhasil!")

	return DB
}