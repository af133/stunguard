package internal

import (
	"fmt"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB() *gorm.DB {
	host := "localhost"
	user := "postgres"    
	password := "1234"   // sesuaikan passwordmu
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
		log.Fatal("Gagal terkoneksi ke database utama 'stunguard':", err)
	}

	fmt.Println("Berhasil terhubung ke PostgreSQL (Database: stunguard)!")
	return DB
}