package repositories

import (
	"errors"

	"github.com/af133/stunguard/internal"
	"gorm.io/gorm"
)

type UserRepository struct {
	DB *gorm.DB
}
type BalitaRepository struct {
	DB *gorm.DB
}

func NewBalitaRepository() *BalitaRepository{
	return &BalitaRepository{
		DB: internal.DB,
	}
}
func NewUserRepository() *UserRepository {
	return &UserRepository{
		DB: internal.DB,
	}
}
// Balita ====================================================================
func (r *BalitaRepository) GetAllBalita(balita *[]internal.Balita) error {
    result := r.DB.Find(balita)
    return result.Error        
}

func (r *BalitaRepository) CreateBalita(balita *internal.Balita) error {
    result := r.DB.Create(balita)
    return result.Error        
}
func (r *BalitaRepository) DeleteBalita(nikBalita string) error {
    result := r.DB.Where("nik_balita = ?", nikBalita).Delete(&internal.Balita{})
    if result.Error != nil {
        return result.Error
    }
    if result.RowsAffected == 0 {
        return errors.New("data balita dengan NIK tersebut tidak ditemukan")
    }
    return nil
}
func (r *BalitaRepository) FindNikBalita(NikBalita string) (*internal.Balita, error) {
    var balita internal.Balita
    result := r.DB.Where("nik_balita = ?", NikBalita).First(&balita)
    if result.Error != nil {
        return nil, result.Error 
    }
    return &balita, nil
}
func (r *BalitaRepository) FindIdBalita(id string) (*internal.Balita, error) {
    var balita internal.Balita
    result := r.DB.Where("id = ?", id).First(&balita)
    if result.Error != nil {
        return nil, result.Error 
    }
    return &balita, nil
}

func (r *BalitaRepository) UpdateBalita(balita *internal.Balita) error {
    result := r.DB.Save(balita)
    return result.Error
}

// User ====================================================================
func (r *UserRepository) CreateUser(user *internal.User) error {
	result := r.DB.Create(user)
	return result.Error
}
func (r *UserRepository) FindByEmail(email string) (*internal.User, error) {
	var user internal.User
	result := r.DB.Where("email = ?", email).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

func (r *UserRepository) FindById(id uint) (*internal.User, error) {
	var user internal.User
	result := r.DB.First(&user, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

