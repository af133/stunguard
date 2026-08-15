package service

import (
	"errors"
	"time"

	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/repositories"
	"golang.org/x/crypto/bcrypt"
)


// =========================================== || ==========================================


type UserService struct {
	Repo *repositories.UserRepository
}
type BalitaService struct {
	Repo *repositories.BalitaRepository
}
type RegisterInput struct {
	Email          string `json:"email" binding:"required,email"`
	Password       string `json:"password" binding:"required"`
	Role           string `json:"role" binding:"required"`
	WilayahKerjaID uint   `json:"wilayah_kerja_id" binding:"required"`
}
type BalitaInput struct {
	NIK                string    `json:"nik"` 
	Nama               string    `json:"nama" binding:"required"`
	TanggalLahir       time.Time `json:"tanggal_lahir" binding:"required"`
	JenisKelamin       string    `json:"jenis_kelamin" binding:"required"`
	NamaIbu            string    `json:"nama_ibu"` 
	Alamat             string    `json:"alamat"` 
	RiwayatBBLR        bool      `json:"riwayat_bblr"`
	DurasiAsiEksklusif string    `json:"durasi_asi_eksklusif"`
	UsiaMulaiMpasi     string    `json:"usia_mulai_mpasi"`
	PosyanduID         uint      `json:"posyandu_id" binding:"required"`
	SyncStatusOrigin   string    `json:"sync_status_origin"`
}
type PosyanduInput struct {
    Nama         string  `json:"nama" binding:"required"`
    WilayahKerja string  `json:"wilayah_kerja"`
    KoordinatLat float64 `json:"koordinat_lat"`
    KoordinatLng float64 `json:"koordinat_lng"`
    PuskesmasID  uint    `json:"puskesmas_id" binding:"required"`
}
type PosyanduService struct {
	Repo *repositories.PosyanduRepository
}

type PuskesmasService struct {
    Repo *repositories.PuskesmasRepository
}
type DinasKesahatanService struct{
	Repo *repositories.DinasKesehatanRepository
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
type DinasKesehatanInput struct {
    Nama         string `json:"nama" binding:"required"`
    WilayahKerja string `json:"wilayah_kerja"`
}
type PuskesmasInput struct {
    Nama         string `json:"nama" binding:"required"`
    WilayahKerja string `json:"wilayah_kerja"`
    DinasID      uint   `json:"dinas_id" binding:"required"`
}


// =========================================== || ==========================================


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

func NewPosyanduService(posyanduRepo *repositories.PosyanduRepository) *PosyanduService {
	return &PosyanduService{
		Repo: posyanduRepo,
	}
}

func NewPuskesmasService(puskesmasRepo *repositories.PuskesmasRepository) *PuskesmasService{
	return  &PuskesmasService{
		Repo: puskesmasRepo,
	}
}
func NewDinasKesehatanService(dinasKesahatanRepo *repositories.DinasKesehatanRepository) *DinasKesahatanService{
	return &DinasKesahatanService{
		Repo: dinasKesahatanRepo,
	}
}


// =========================================== || ==========================================


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

//  Posyandu ===============================================================================

func (s *PosyanduService) CreatePosyandu(input PosyanduInput) (*internal.Posyandu, error) {
    
	posyandu := internal.Posyandu{
        Nama:         input.Nama,
        WilayahKerja: input.WilayahKerja,
        KoordinatLat: input.KoordinatLat,
        KoordinatLng: input.KoordinatLng,
        PuskesmasID:  input.PuskesmasID,
    }
	
	
    err := s.Repo.CreatePosyandu(&posyandu)
    if err != nil {
        return nil, err
    }
    return &posyandu, nil
}

func (s *PosyanduService) FindPosyandu(id string) (*internal.Posyandu, error) {
    posyandu, err := s.Repo.FindPosyanduId(id)
    if err != nil {
        return nil, errors.New("data posyandu tidak ditemukan")
    }
    return posyandu, nil
}

func (s * PosyanduService) DeletePosyandu(id string) error{
	err := s.Repo.DeletePosyanduId(id)
	
	if err != nil {
		return err
	}
	return nil	
}

func (s *PosyanduService) GetAllPosyandu() ([]internal.Posyandu, error) {
	var posyandu []internal.Posyandu
	err := s.Repo.GetAllPosyandu(&posyandu)
	if err != nil {
		return nil, err
	}
	return posyandu, nil
}

func (s *PosyanduService) UpdatePosyandu(id string, input PosyanduInput) (*internal.Posyandu, error) {
    existingPosyandu, err := s.Repo.FindPosyanduId(id)
    if err != nil {
        return nil, errors.New("data posyandu tidak ditemukan")
    }
    existingPosyandu.Nama = input.Nama
    existingPosyandu.WilayahKerja = input.WilayahKerja
    existingPosyandu.KoordinatLat = input.KoordinatLat
    existingPosyandu.KoordinatLng = input.KoordinatLng
    existingPosyandu.PuskesmasID = input.PuskesmasID
    err = s.Repo.UpdatePosyandu(id, existingPosyandu)
    if err != nil {
        return nil, err
    }	
    return existingPosyandu, nil
}


// Puskesmas =====================================

func (s *PuskesmasService) CreatePuskesmas(input PuskesmasInput) (*internal.Puskesmas, error) {
    puskesmas := internal.Puskesmas{
        Nama:         input.Nama,
        WilayahKerja: input.WilayahKerja,
        DinasID:      input.DinasID,
    }
    err := s.Repo.CreatePuskesmas(&puskesmas)
    if err != nil {
        return nil, err
    }
    return &puskesmas, nil
}

func (s *PuskesmasService) FindPuskesmas(id string) (*internal.Puskesmas, error) {
    puskesmas, err := s.Repo.FindPuskesmasId(id)
    if err != nil {
        return nil, errors.New("data puskesmas tidak ditemukan")
    }
    return puskesmas, nil
}

func (s *PuskesmasService) DeletePuskesmas(id string) error {
    err := s.Repo.DeletePuskesmasId(id)
    if err != nil {
        return err
    }
    return nil  
}

func (s *PuskesmasService) GetAllPuskesmas() ([]internal.Puskesmas, error) {
    var puskesmas []internal.Puskesmas
    err := s.Repo.GetAllPuskesmas(&puskesmas)
    if err != nil {
        return nil, err
    }
    return puskesmas, nil
}

func (s *PuskesmasService) UpdatePuskesmas(id string, input PuskesmasInput) (*internal.Puskesmas, error) {
    existingPuskesmas, err := s.Repo.FindPuskesmasId(id)
    if err != nil {
        return nil, errors.New("data puskesmas tidak ditemukan")
    }
    
    existingPuskesmas.Nama = input.Nama
    existingPuskesmas.WilayahKerja = input.WilayahKerja
    existingPuskesmas.DinasID = input.DinasID
    err = s.Repo.UpdatePuskesmas(id, existingPuskesmas)
    if err != nil {
        return nil, err
    }   
    return existingPuskesmas, nil
}


// Dinas Kesehatan =====================================

func (s *DinasKesahatanService) CreateDinasKesehatan(input DinasKesehatanInput) (*internal.DinasKesehatan, error) {
    dinas := internal.DinasKesehatan{
        Nama:         input.Nama,
        WilayahKerja: input.WilayahKerja,
    }
	
    err := s.Repo.CreateDinasKesehatan(&dinas)
    if err != nil {
        return nil, err
    }
    return &dinas, nil
}

func (s *DinasKesahatanService) FindDinasKesehatan(id string) (*internal.DinasKesehatan, error) {
    dinas, err := s.Repo.FindDinasKesehatanId(id)
    if err != nil {
        return nil, errors.New("data dinas kesehatan tidak ditemukan")
    }
    return dinas, nil
}

func (s *DinasKesahatanService) DeleteDinasKesehatan(id string) error {
    err := s.Repo.DeleteDinasKesehatanId(id)
    if err != nil {
        return err
    }
    return nil  
}

func (s *DinasKesahatanService) GetAllDinasKesehatan() ([]internal.DinasKesehatan, error) {
    var dinas []internal.DinasKesehatan
    err := s.Repo.GetAllDinasKesehatan(&dinas)
    if err != nil {
        return nil, err
    }
    return dinas, nil
}

func (s *DinasKesahatanService) UpdateDinasKesehatan(id string, input DinasKesehatanInput) (*internal.DinasKesehatan, error) {
    existingDinas, err := s.Repo.FindDinasKesehatanId(id)
    if err != nil {
        return nil, errors.New("data dinas kesehatan tidak ditemukan")
    }
    
    existingDinas.Nama = input.Nama
    existingDinas.WilayahKerja = input.WilayahKerja
    
    err = s.Repo.UpdateDinasKesehatan(id, existingDinas)
    if err != nil {
        return nil, err
    }   
    return existingDinas, nil
}