package internal

import (
	"fmt"
	"log"
	"time"

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
	Role           string `gorm:"size:50"`                 
	StatusValidasi string `gorm:"size:20;default:'pending'"`
}

type Balita struct {
	gorm.Model
	KaderID            uint
	NamaLengkap        string    `gorm:"size:100;not null"`
	NIKBalita          string    `gorm:"size:16"`
	TanggalLahir       time.Time `gorm:"type:date"`
	JenisKelamin       string    `gorm:"size:1"` 
	NamaIbu            string    `gorm:"size:100"`
	Alamat             string    `gorm:"type:text"`
	BBLR               bool      `gorm:"default:false"`
	DurasiAsiEksklusif string    `gorm:"size:50"`
	UsiaMulaiMpasi     string    `gorm:"size:50"`
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
	host := "localhost"
	user := "postgres"
	password := "1234"
	dbName := "stunguard"
	port := "5432"
	dsnDefault := fmt.Sprintf("host=%s user=%s password=%s dbname=postgres port=%s sslmode=disable TimeZone=Asia/Jakarta",
		host, user, password, port)

	dbDefault, err := gorm.Open(postgres.Open(dsnDefault), &gorm.Config{})
	if err != nil {
		log.Fatal("Gagal koneksi ke database utama 'postgres':", err)
	}

	var exists int
	query := fmt.Sprintf("SELECT 1 FROM pg_database WHERE datname = '%s'", dbName)
	dbDefault.Raw(query).Scan(&exists)

	if exists != 1 {
		fmt.Printf("Database '%s' tidak ditemukan. Membuat database baru...\n", dbName)
		err := dbDefault.Exec(fmt.Sprintf("CREATE DATABASE %s", dbName)).Error
		if err != nil {
			log.Fatal("Gagal membuat database otomatis:", err)
		}
		fmt.Printf("Database '%s' berhasil dibuat!\n", dbName)
	}
	dsnMain := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		host, user, password, dbName, port)
	DB, err = gorm.Open(postgres.Open(dsnMain), &gorm.Config{})
	if err != nil {
		log.Fatal("Gagal terkoneksi ke database 'stunguard':", err)
	}
	fmt.Println("Berhasil terhubung ke PostgreSQL (Database: stunguard)!")
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
	fmt.Println("Auto migration tabel berhasil!")

	return DB
}