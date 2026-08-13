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
    NamaLengkap  string `json:"nama_lengkap" binding:"required"`
    NIK          string `json:"nik" binding:"required"`
    NomorTelepon string `json:"nomor_telepon"`
    NamaPosyandu string `json:"nama_posyandu"`
    WilayahKerja string `json:"wilayah_kerja"`
    Role         string `json:"role" binding:"required"`
    Password     string `json:"password" binding:"required"`
}

type BalitaInput struct {
    KaderID             uint      `json:"kader_id" binding:"required"`
    NamaLengkap         string    `json:"nama_lengkap" binding:"required"`
    NIK                 string    `json:"nik_balita" binding:"required"`
    TanggalLahir        time.Time `json:"tanggal_lahir" binding:"required"`
    JenisKelamin        string    `json:"jenis_kelamin"`
    NamaIbu             string    `json:"nama_ibu"`
    Provinsi            string    `json:"provinsi"`
    Kecamatan           string    `json:"kecamatan"`
    Kelurahan           string    `json:"kelurahan"`
    Desa                string    `json:"desa"`
    BBLR                bool      `json:"bblr"`
    DurasiAsiEksklusif  string    `json:"durasi_asi_eksklusif"`
    UsiaMulaiMpasi      string    `json:"usia_mulai_mpasi"`
}

type FindBalitaNIKInput struct {
    NIKBalita string `json:"nik" binding:"required"`
}

type LoginInput struct {
    NIK      string `json:"nik" binding:"required"`
    Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
    Token string        `json:"token"`
    User  internal.User `json:"user"`
}

// ==================================    User Posyandu  ===============================================
func (s *UserService) Register(input RegisterInput) (*internal.User, error) {
    existingUser, _ := s.Repo.FindByNIK(input.NIK)
    if existingUser != nil {
        return nil, errors.New("NIK sudah terdaftar")
    }
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, errors.New("gagal mengenkripsi password")
    }

    user := &internal.User{
        NamaLengkap:    input.NamaLengkap,
        NIK:            input.NIK,
        NomorTelepon:   input.NomorTelepon,
        NamaPosyandu:   input.NamaPosyandu,
        WilayahKerja:   input.WilayahKerja,
        Role:           input.Role,
        Password:       string(hashedPassword),
        StatusValidasi: "pending",
    }
    err = s.Repo.CreateUser(user)
    if err != nil {
        return nil, err
    }

    return user, nil
}

func (s *UserService) LoginPetugas(input LoginInput) (*internal.User, error) {
    user, err := s.Repo.FindByNIK(input.NIK)
    if err != nil {
        return nil, errors.New("NIK atau password salah")
    }
    if user.Role != "petugas_puskesmas" {
        return nil, errors.New("akses ditolak: hanya petugas puskesmas yang diizinkan login")
    }
    err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password))
    if err != nil {
        return nil, errors.New("NIK atau password salah")
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
    existingBalita, err := s.Repo.FindNikBalita(input.NIK)
    if err == nil && existingBalita != nil {
        return nil, errors.New("NIK telah terdaftar")
    }
    balita := &internal.Balita{
        KaderID:            input.KaderID,
        NamaLengkap:        input.NamaLengkap,
        NIKBalita:          input.NIK,
        TanggalLahir:       input.TanggalLahir,
        JenisKelamin:       input.JenisKelamin,
        NamaIbu:            input.NamaIbu,
        Provinsi:           input.Provinsi,
        Kecamatan:          input.Kecamatan,
        Kelurahan:          input.Kelurahan,
        Desa:               input.Desa,
        BBLR:               input.BBLR,
        DurasiAsiEksklusif: input.DurasiAsiEksklusif,
        UsiaMulaiMpasi:     input.UsiaMulaiMpasi,
    }

    err = s.Repo.CreateBalita(balita)
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
func (s *BalitaService) UpdateBalita(id string,input BalitaInput) (*internal.Balita, error) {
    existingBalita, err := s.Repo.FindIdBalita(id)
    if err != nil {
        return nil, err 
    }
    existingBalita.KaderID = input.KaderID
    existingBalita.NamaLengkap = input.NamaLengkap
    existingBalita.NIKBalita = input.NIK
    existingBalita.TanggalLahir = input.TanggalLahir
    existingBalita.JenisKelamin = input.JenisKelamin
    existingBalita.NamaIbu = input.NamaIbu
    existingBalita.Provinsi = input.Provinsi
    existingBalita.Kecamatan = input.Kecamatan
    existingBalita.Kelurahan = input.Kelurahan
    existingBalita.Desa = input.Desa
    existingBalita.BBLR = input.BBLR
    existingBalita.DurasiAsiEksklusif = input.DurasiAsiEksklusif
    existingBalita.UsiaMulaiMpasi = input.UsiaMulaiMpasi
    err = s.Repo.UpdateBalita(existingBalita)
    if err != nil {
        return nil, err
    }

    return existingBalita, nil
}