package service

import (
	"errors"

	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/repositories"
	"golang.org/x/crypto/bcrypt"
)

type UserService struct {
	Repo *repositories.UserRepository
}

func NewUserService(repo *repositories.UserRepository) *UserService {
	return &UserService{
		Repo: repo,
	}
}

// Input struct untuk Register
type RegisterInput struct {
	NamaLengkap  string `json:"nama_lengkap" binding:"required"`
	NIK          string `json:"nik" binding:"required"`
	NomorTelepon string `json:"nomor_telepon"`
	NamaPosyandu string `json:"nama_posyandu"`
	WilayahKerja string `json:"wilayah_kerja"`
	Role         string `json:"role" binding:"required"`
	Password     string `json:"password" binding:"required"`
}

type LoginInput struct {
	NIK      string `json:"nik" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	Token string         `json:"token"`
	User  internal.User  `json:"user"` 
}

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