package service

import (
	"errors"
	"time"

	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/repositories"
	"golang.org/x/crypto/bcrypt"
)

type UserService struct {
	Repo *repositories.UserRepository
}
type BalitaService struct {
	Repo *repositories.BalitaRepository
}

func NewUserService(repo *repositories.UserRepository) *UserService {
	return &UserService{
		Repo: repo,
	}
}

func NewBalitaService(repo *repositories.BalitaRepository) *BalitaService {
	return &BalitaService{
		Repo: repo,
	}
}

type RegisterInput struct {
	Email          string `json:"email" binding:"required,email"`
	Password       string `json:"password" binding:"required"`
	Role           string `json:"role" binding:"required"` // kader / petugas_puskesmas / admin_dinas
	WilayahKerjaID uint   `json:"wilayah_kerja_id" binding:"required"`
}

type BalitaInput struct {
	NIK                string    `json:"nik"` // nullable, encrypted
	Nama               string    `json:"nama" binding:"required"` // encrypted
	TanggalLahir       time.Time `json:"tanggal_lahir" binding:"required"`
	JenisKelamin       string    `json:"jenis_kelamin" binding:"required"` // L / P
	NamaIbu            string    `json:"nama_ibu"` // encrypted
	Alamat             string    `json:"alamat"` // encrypted
	RiwayatBBLR        bool      `json:"riwayat_bblr"`
	DurasiAsiEksklusif string    `json:"durasi_asi_eksklusif"`
	UsiaMulaiMpasi     string    `json:"usia_mulai_mpasi"`
	PosyanduID         uint      `json:"posyandu_id" binding:"required"`
	SyncStatusOrigin   string    `json:"sync_status_origin"`
}

type FindBalitaNIKInput struct {
	NIK string `json:"nik" binding:"required"`
}

type LoginInput struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	Token string        `json:"token"`
	User  internal.User `json:"user"`
}

func (s *UserService) Register(input RegisterInput) (*internal.User, error) {
	existingUser, _ := s.Repo.FindByEmail(input.Email)
	if existingUser != nil {
		return nil, errors.New("email sudah terdaftar")
	}
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("gagal mengenkripsi password")
	}

	user := &internal.User{
		Email:          input.Email,
		PasswordHash:   string(hashedPassword),
		Role:           input.Role,
		WilayahKerjaID: input.WilayahKerjaID,
		StatusValidasi: "pending",
	}
	err = s.Repo.CreateUser(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (s *UserService) LoginPetugas(input LoginInput) (*internal.User, error) {
	user, err := s.Repo.FindByEmail(input.Email)
	if err != nil {
		return nil, errors.New("email atau password salah")
	}
	if user.Role != "petugas_puskesmas" && user.Role != "admin_dinas" {
		return nil, errors.New("akses ditolak: hak akses tidak diizinkan login ke portal ini")
	}
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(input.Password))
	if err != nil {
		return nil, errors.New("email atau password salah")
	}
	return user, nil
}

// ==================================    Balita  =============================================== 

func (s *BalitaService) GetAllBalita() ([]internal.Balita, error) {
	var balita []internal.Balita
	err := s.Repo.GetAllBalita(&balita)
	if err != nil {
		return nil, err
	}
	return balita, nil
}

func (s *BalitaService) CreateBalita(input BalitaInput) (*internal.Balita, error) {
	// Validasi NIK jika diisi
	if input.NIK != "" {
		existingBalita, err := s.Repo.FindNikBalita(input.NIK)
		if err == nil && existingBalita != nil {
			return nil, errors.New("NIK balita telah terdaftar")
		}
	}

	balita := &internal.Balita{
		NIK:                input.NIK,
		Nama:               input.Nama,
		TanggalLahir:       input.TanggalLahir,
		JenisKelamin:       input.JenisKelamin,
		NamaIbu:            input.NamaIbu,
		Alamat:             input.Alamat,
		RiwayatBBLR:        input.RiwayatBBLR,
		DurasiAsiEksklusif: input.DurasiAsiEksklusif,
		UsiaMulaiMpasi:     input.UsiaMulaiMpasi,
		PosyanduID:         input.PosyanduID,
		SyncStatusOrigin:   input.SyncStatusOrigin,
	}

	err := s.Repo.CreateBalita(balita)
	if err != nil {
		return nil, err
	}
	return balita, nil
}

func (s *BalitaService) FindBalitaNIK(nik string) (*internal.Balita, error) {
	balita, err := s.Repo.FindNikBalita(nik)
	if err != nil {
		return nil, errors.New("data balita tidak ditemukan")
	}
	return balita, nil
}

func (s *BalitaService) DeleteBalitaNIK(nik string) error {
	err := s.Repo.DeleteBalita(nik)
	if err != nil {
		return err
	}
	return nil
}

func (s *BalitaService) UpdateBalita(id string, input BalitaInput) (*internal.Balita, error) {
	existingBalita, err := s.Repo.FindIdBalita(id)
	if err != nil {
		return nil, err 
	}
	
	existingBalita.NIK = input.NIK
	existingBalita.Nama = input.Nama
	existingBalita.TanggalLahir = input.TanggalLahir
	existingBalita.JenisKelamin = input.JenisKelamin
	existingBalita.NamaIbu = input.NamaIbu
	existingBalita.Alamat = input.Alamat
	existingBalita.RiwayatBBLR = input.RiwayatBBLR
	existingBalita.DurasiAsiEksklusif = input.DurasiAsiEksklusif
	existingBalita.UsiaMulaiMpasi = input.UsiaMulaiMpasi
	existingBalita.PosyanduID = input.PosyanduID
	existingBalita.SyncStatusOrigin = input.SyncStatusOrigin

	err = s.Repo.UpdateBalita(existingBalita)
	if err != nil {
		return nil, err
	}

	return existingBalita, nil
}