package repositories

import (
	"github.com/af133/stunguard/internal"
	"gorm.io/gorm"
)

type UserRepository struct {
	DB *gorm.DB
}

func NewUserRepository() *UserRepository {
	return &UserRepository{
		DB: internal.DB,
	}
}

func (r *UserRepository) CreateUser(user *internal.User) error {
	result := r.DB.Create(user)
	return result.Error
}
func (r *UserRepository) FindByNIK(nik string) (*internal.User, error) {
	var user internal.User
	result := r.DB.Where("nik = ?", nik).First(&user)
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