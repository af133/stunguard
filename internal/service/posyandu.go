package service

import (
	"errors"
	"time"

	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/repositories"
	"golang.org/x/crypto/bcrypt"
)

// =================== Structs & Inputs ===================

type UserService struct{ Repo *repositories.UserRepository }
type BalitaService struct{ Repo *repositories.BalitaRepository }
type PosyanduService struct{ Repo *repositories.PosyanduRepository }
type PuskesmasService struct{ Repo *repositories.PuskesmasRepository }
type DinasKesahatanService struct{ Repo *repositories.DinasKesehatanRepository }
type KaderService struct{ Repo *repositories.KaderRepository }
type PengukuranService struct{ Repo *repositories.PengukuranRepository }

type RegisterInput struct {
	Email          string `json:"email" binding:"required,email"`
	Password       string `json:"password" binding:"required,min=6"`
	Role           string `json:"role" binding:"required"`
	WilayahKerjaID uint   `json:"wilayah_kerja_id" binding:"required"`
	// Kader-specific fields (optional, filled when role=kader)
	Nama       string `json:"nama"`
	NIK        string `json:"nik"`
	NoTelepon  string `json:"no_telepon"`
	PosyanduID uint   `json:"posyandu_id"`
}

type LoginInput struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
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

type PuskesmasInput struct {
	Nama         string `json:"nama" binding:"required"`
	WilayahKerja string `json:"wilayah_kerja"`
	DinasID      uint   `json:"dinas_id" binding:"required"`
}

type DinasKesehatanInput struct {
	Nama         string `json:"nama" binding:"required"`
	WilayahKerja string `json:"wilayah_kerja"`
}

type KaderInput struct {
	Nama       string `json:"nama" binding:"required"`
	NIK        string `json:"nik"`
	NoTelepon  string `json:"no_telepon"`
	PosyanduID uint   `json:"posyandu_id" binding:"required"`
}

type PengukuranInput struct {
	BalitaID      uint      `json:"balita_id" binding:"required"`
	Tanggal       time.Time `json:"tanggal" binding:"required"`
	TinggiBadan   float64   `json:"tinggi_badan" binding:"required"`
	BeratBadan    float64   `json:"berat_badan" binding:"required"`
	Lila          *float64  `json:"lila"`
	LingkarKepala *float64  `json:"lingkar_kepala"`
	ZScoreTBU     float64   `json:"zscore_tbu"`
	ZScoreBBU     float64   `json:"zscore_bbu"`
	ZScoreBBTB    float64   `json:"zscore_bbtb"`
	KategoriTBU   string    `json:"kategori_tbu"`
	KategoriBBU   string    `json:"kategori_bbu"`
	KategoriBBTB  string    `json:"kategori_bbtb"`
	KaderID       uint      `json:"kader_id" binding:"required"`
}

type LoginResponse struct {
	Token        string        `json:"token"`
	RefreshToken string        `json:"refresh_token"`
	User         internal.User `json:"user"`
}

// =================== Constructors ===================

func NewUserService(repo *repositories.UserRepository) *UserService {
	return &UserService{Repo: repo}
}
func NewBalitaService(repo *repositories.BalitaRepository) *BalitaService {
	return &BalitaService{Repo: repo}
}
func NewPosyanduService(repo *repositories.PosyanduRepository) *PosyanduService {
	return &PosyanduService{Repo: repo}
}
func NewPuskesmasService(repo *repositories.PuskesmasRepository) *PuskesmasService {
	return &PuskesmasService{Repo: repo}
}
func NewDinasKesehatanService(repo *repositories.DinasKesehatanRepository) *DinasKesahatanService {
	return &DinasKesahatanService{Repo: repo}
}
func NewKaderService(repo *repositories.KaderRepository) *KaderService {
	return &KaderService{Repo: repo}
}
func NewPengukuranService(repo *repositories.PengukuranRepository) *PengukuranService {
	return &PengukuranService{Repo: repo}
}

// =================== User Service ===================

func (s *UserService) Register(input RegisterInput) (*internal.User, error) {
	existingUser, _ := s.Repo.FindByEmail(input.Email)
	if existingUser != nil {
		return nil, errors.New("email sudah terdaftar")
	}
	validRoles := map[string]bool{"kader": true, "petugas_puskesmas": true, "admin_dinas": true}
	if !validRoles[input.Role] {
		return nil, errors.New("role harus salah satu dari: kader, petugas_puskesmas, admin_dinas")
	}
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("gagal mengenkripsi password")
	}
	status := "validated"
	if input.Role == "kader" {
		status = "pending"
	}
	user := &internal.User{
		Email:          input.Email,
		PasswordHash:   string(hashedPassword),
		Role:           input.Role,
		WilayahKerjaID: input.WilayahKerjaID,
		StatusValidasi: status,
	}
	err = s.Repo.CreateUser(user)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (s *UserService) Login(input LoginInput) (*internal.User, error) {
	user, err := s.Repo.FindByEmail(input.Email)
	if err != nil {
		return nil, errors.New("email atau password salah")
	}
	if user.StatusValidasi == "pending" {
		return nil, errors.New("akun belum divalidasi oleh koordinator")
	}
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(input.Password))
	if err != nil {
		return nil, errors.New("email atau password salah")
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

func (s *UserService) UpdateRefreshToken(userID uint, refreshToken string) error {
	user, err := s.Repo.FindById(userID)
	if err != nil {
		return err
	}
	user.RefreshToken = refreshToken
	return s.Repo.UpdateUser(user)
}

func (s *UserService) FindByID(id uint) (*internal.User, error) {
	return s.Repo.FindById(id)
}

// =================== Balita Service ===================

func (s *BalitaService) GetAllBalita() ([]internal.Balita, error) {
	var balita []internal.Balita
	err := s.Repo.GetAllBalita(&balita)
	return balita, err
}

func (s *BalitaService) GetBalitaPaginated(page, limit int, search, kategoriRisiko, wilayah string) ([]internal.Balita, int64, error) {
	if page < 1 { page = 1 }
	if limit < 1 || limit > 100 { limit = 20 }
	return s.Repo.GetBalitaPaginated(page, limit, search, kategoriRisiko, wilayah)
}

func (s *BalitaService) CreateBalita(input BalitaInput) (*internal.Balita, error) {
	if input.NIK != "" {
		existing, err := s.Repo.FindNikBalita(input.NIK)
		if err == nil && existing != nil {
			return nil, errors.New("NIK balita telah terdaftar")
		}
	}
	balita := &internal.Balita{
		NIK: input.NIK, Nama: input.Nama, TanggalLahir: input.TanggalLahir,
		JenisKelamin: input.JenisKelamin, NamaIbu: input.NamaIbu, Alamat: input.Alamat,
		RiwayatBBLR: input.RiwayatBBLR, DurasiAsiEksklusif: input.DurasiAsiEksklusif,
		UsiaMulaiMpasi: input.UsiaMulaiMpasi, PosyanduID: input.PosyanduID,
		SyncStatusOrigin: input.SyncStatusOrigin, SyncStatus: "synced",
	}
	err := s.Repo.CreateBalita(balita)
	if err != nil { return nil, err }
	return balita, nil
}

func (s *BalitaService) FindBalitaNIK(nik string) (*internal.Balita, error) {
	return s.Repo.FindNikBalita(nik)
}

func (s *BalitaService) DeleteBalitaNIK(nik string) error {
	return s.Repo.DeleteBalita(nik)
}

func (s *BalitaService) UpdateBalita(id string, input BalitaInput) (*internal.Balita, error) {
	existing, err := s.Repo.FindIdBalita(id)
	if err != nil { return nil, err }
	existing.NIK = input.NIK
	existing.Nama = input.Nama
	existing.TanggalLahir = input.TanggalLahir
	existing.JenisKelamin = input.JenisKelamin
	existing.NamaIbu = input.NamaIbu
	existing.Alamat = input.Alamat
	existing.RiwayatBBLR = input.RiwayatBBLR
	existing.DurasiAsiEksklusif = input.DurasiAsiEksklusif
	existing.UsiaMulaiMpasi = input.UsiaMulaiMpasi
	existing.PosyanduID = input.PosyanduID
	existing.SyncStatusOrigin = input.SyncStatusOrigin
	err = s.Repo.UpdateBalita(existing)
	if err != nil { return nil, err }
	return existing, nil
}

func (s *BalitaService) GetRiwayat(balitaID string) (map[string]interface{}, error) {
	balita, err := s.Repo.FindIdBalita(balitaID)
	if err != nil { return nil, errors.New("balita tidak ditemukan") }
	return map[string]interface{}{"balita": balita}, nil
}

// =================== Posyandu Service ===================

func (s *PosyanduService) CreatePosyandu(input PosyanduInput) (*internal.Posyandu, error) {
	posyandu := internal.Posyandu{
		Nama: input.Nama, WilayahKerja: input.WilayahKerja,
		KoordinatLat: input.KoordinatLat, KoordinatLng: input.KoordinatLng,
		PuskesmasID: input.PuskesmasID,
	}
	err := s.Repo.CreatePosyandu(&posyandu)
	if err != nil { return nil, err }
	return &posyandu, nil
}

func (s *PosyanduService) FindPosyandu(id string) (*internal.Posyandu, error) {
	return s.Repo.FindPosyanduId(id)
}

func (s *PosyanduService) DeletePosyandu(id string) error {
	return s.Repo.DeletePosyanduId(id)
}

func (s *PosyanduService) GetAllPosyandu() ([]internal.Posyandu, error) {
	var posyandu []internal.Posyandu
	err := s.Repo.GetAllPosyandu(&posyandu)
	return posyandu, err
}

func (s *PosyanduService) UpdatePosyandu(id string, input PosyanduInput) (*internal.Posyandu, error) {
	existing, err := s.Repo.FindPosyanduId(id)
	if err != nil { return nil, errors.New("data posyandu tidak ditemukan") }
	existing.Nama = input.Nama
	existing.WilayahKerja = input.WilayahKerja
	existing.KoordinatLat = input.KoordinatLat
	existing.KoordinatLng = input.KoordinatLng
	existing.PuskesmasID = input.PuskesmasID
	err = s.Repo.UpdatePosyandu(id, existing)
	if err != nil { return nil, err }
	return existing, nil
}

// =================== Puskesmas Service ===================

func (s *PuskesmasService) CreatePuskesmas(input PuskesmasInput) (*internal.Puskesmas, error) {
	p := internal.Puskesmas{Nama: input.Nama, WilayahKerja: input.WilayahKerja, DinasID: input.DinasID}
	err := s.Repo.CreatePuskesmas(&p)
	if err != nil { return nil, err }
	return &p, nil
}

func (s *PuskesmasService) FindPuskesmas(id string) (*internal.Puskesmas, error) {
	return s.Repo.FindPuskesmasId(id)
}

func (s *PuskesmasService) DeletePuskesmas(id string) error {
	return s.Repo.DeletePuskesmasId(id)
}

func (s *PuskesmasService) GetAllPuskesmas() ([]internal.Puskesmas, error) {
	var list []internal.Puskesmas
	err := s.Repo.GetAllPuskesmas(&list)
	return list, err
}

func (s *PuskesmasService) UpdatePuskesmas(id string, input PuskesmasInput) (*internal.Puskesmas, error) {
	existing, err := s.Repo.FindPuskesmasId(id)
	if err != nil { return nil, errors.New("data puskesmas tidak ditemukan") }
	existing.Nama = input.Nama
	existing.WilayahKerja = input.WilayahKerja
	existing.DinasID = input.DinasID
	err = s.Repo.UpdatePuskesmas(id, existing)
	if err != nil { return nil, err }
	return existing, nil
}

// =================== Dinas Kesehatan Service ===================

func (s *DinasKesahatanService) CreateDinasKesehatan(input DinasKesehatanInput) (*internal.DinasKesehatan, error) {
	d := internal.DinasKesehatan{Nama: input.Nama, WilayahKerja: input.WilayahKerja}
	err := s.Repo.CreateDinasKesehatan(&d)
	if err != nil { return nil, err }
	return &d, nil
}

func (s *DinasKesahatanService) FindDinasKesehatan(id string) (*internal.DinasKesehatan, error) {
	return s.Repo.FindDinasKesehatanId(id)
}

func (s *DinasKesahatanService) DeleteDinasKesehatan(id string) error {
	return s.Repo.DeleteDinasKesehatanId(id)
}

func (s *DinasKesahatanService) GetAllDinasKesehatan() ([]internal.DinasKesehatan, error) {
	var list []internal.DinasKesehatan
	err := s.Repo.GetAllDinasKesehatan(&list)
	return list, err
}

func (s *DinasKesahatanService) UpdateDinasKesehatan(id string, input DinasKesehatanInput) (*internal.DinasKesehatan, error) {
	existing, err := s.Repo.FindDinasKesehatanId(id)
	if err != nil { return nil, errors.New("data dinas kesehatan tidak ditemukan") }
	existing.Nama = input.Nama
	existing.WilayahKerja = input.WilayahKerja
	err = s.Repo.UpdateDinasKesehatan(id, existing)
	if err != nil { return nil, err }
	return existing, nil
}

// =================== Kader Service ===================

func (s *KaderService) CreateKader(input KaderInput, userID uint) (*internal.Kader, error) {
	if input.NIK != "" {
		existing, _ := s.Repo.FindByNIK(input.NIK)
		if existing != nil { return nil, errors.New("NIK kader sudah terdaftar") }
	}
	kader := &internal.Kader{
		Nama: input.Nama, NIK: input.NIK, NoTelepon: input.NoTelepon,
		PosyanduID: input.PosyanduID, UserID: userID, StatusValidasi: "pending",
	}
	err := s.Repo.CreateKader(kader)
	if err != nil { return nil, err }
	return kader, nil
}

func (s *KaderService) GetAllKader(page, limit int, posyanduID uint) ([]internal.Kader, int64, error) {
	if page < 1 { page = 1 }
	if limit < 1 || limit > 100 { limit = 20 }
	return s.Repo.GetAllKader(page, limit, posyanduID)
}

func (s *KaderService) FindKader(id string) (*internal.Kader, error) {
	return s.Repo.FindByID(id)
}

func (s *KaderService) UpdateKader(id string, input KaderInput) (*internal.Kader, error) {
	existing, err := s.Repo.FindByID(id)
	if err != nil { return nil, errors.New("kader tidak ditemukan") }
	existing.Nama = input.Nama
	existing.NIK = input.NIK
	existing.NoTelepon = input.NoTelepon
	existing.PosyanduID = input.PosyanduID
	err = s.Repo.UpdateKader(existing)
	if err != nil { return nil, err }
	return existing, nil
}

func (s *KaderService) ValidateKader(id string) (*internal.Kader, error) {
	existing, err := s.Repo.FindByID(id)
	if err != nil { return nil, errors.New("kader tidak ditemukan") }
	existing.StatusValidasi = "validated"
	err = s.Repo.UpdateKader(existing)
	if err != nil { return nil, err }
	return existing, nil
}

// =================== Pengukuran Service ===================

func (s *PengukuranService) Create(input PengukuranInput) (*internal.Pengukuran, error) {
	p := &internal.Pengukuran{
		BalitaID: input.BalitaID, Tanggal: input.Tanggal,
		TinggiBadan: input.TinggiBadan, BeratBadan: input.BeratBadan,
		Lila: input.Lila, LingkarKepala: input.LingkarKepala,
		ZScoreTBU: input.ZScoreTBU, ZScoreBBU: input.ZScoreBBU, ZScoreBBTB: input.ZScoreBBTB,
		KategoriTBU: input.KategoriTBU, KategoriBBU: input.KategoriBBU, KategoriBBTB: input.KategoriBBTB,
		KaderID: input.KaderID, SyncStatus: "synced",
	}
	err := s.Repo.Create(p)
	if err != nil { return nil, err }
	return p, nil
}

func (s *PengukuranService) GetByBalitaID(balitaID string) ([]internal.Pengukuran, error) {
	return s.Repo.GetByBalitaID(balitaID)
}

func (s *PengukuranService) Update(id string, input PengukuranInput) (*internal.Pengukuran, error) {
	existing, err := s.Repo.FindByID(id)
	if err != nil { return nil, errors.New("pengukuran tidak ditemukan") }
	existing.BalitaID = input.BalitaID
	existing.Tanggal = input.Tanggal
	existing.TinggiBadan = input.TinggiBadan
	existing.BeratBadan = input.BeratBadan
	existing.Lila = input.Lila
	existing.LingkarKepala = input.LingkarKepala
	existing.ZScoreTBU = input.ZScoreTBU
	existing.ZScoreBBU = input.ZScoreBBU
	existing.ZScoreBBTB = input.ZScoreBBTB
	existing.KategoriTBU = input.KategoriTBU
	existing.KategoriBBU = input.KategoriBBU
	existing.KategoriBBTB = input.KategoriBBTB
	existing.KaderID = input.KaderID
	err = s.Repo.Update(existing)
	if err != nil { return nil, err }
	return existing, nil
}

func (s *PengukuranService) Delete(id string) error {
	return s.Repo.Delete(id)
}