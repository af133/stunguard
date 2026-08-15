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

type PosyanduRepository struct {
    DB *gorm.DB 
}

type PuskesmasRepository struct {
    DB *gorm.DB 
}
type DinasKesehatanRepository struct {
    DB *gorm.DB 
}
func NewPosyanduRepository() *PosyanduRepository {
    return &PosyanduRepository{
        DB: internal.DB,
    }
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
func NewPuskesmasRepository() *PuskesmasRepository {
	return &PuskesmasRepository{
		DB: internal.DB,
	}
}
func NewDinasKesehatanRepository() *DinasKesehatanRepository {
    return &DinasKesehatanRepository{
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

// Posyandu =====================================================

func (r *PosyanduRepository) CreatePosyandu(posyandu *internal.Posyandu) error {
	result := r.DB.Create(posyandu)
	if result.Error != nil {
		return result.Error
	}
	return nil
}
func (r *PosyanduRepository) FindPosyanduId(id string) (*internal.Posyandu, error) {
    var posyandu internal.Posyandu
    err := r.DB.Where("id = ?", id).First(&posyandu).Error
    if err != nil {
        return nil, err 
    }
    
    return &posyandu, nil
}
func (r *PosyanduRepository) DeletePosyanduId(id string) error {
    var posyandu internal.Posyandu
    err := r.DB.Where("id = ?", id).Delete(&posyandu).Error
    if err != nil {
        return err
    }
    return nil
}

func (r *PosyanduRepository) UpdatePosyandu(id string, posyandu *internal.Posyandu) error {
    return r.DB.Model(&internal.Posyandu{}).Where("id = ?", id).Updates(posyandu).Error
}

func (r *PosyanduRepository) GetAllPosyandu(posyandu *[]internal.Posyandu) error {
    result := r.DB.Find(posyandu)
    return result.Error        
}

// Puskesmas =========================================================================

func (r *PuskesmasRepository) GetAllPuskesmas(puskesmas *[]internal.Puskesmas) error{
    resulst := r.DB.Find(puskesmas)
    return resulst.Error
}

func (r *PuskesmasRepository) CreatePuskesmas(puskesmas *internal.Puskesmas) error {
	result := r.DB.Create(puskesmas)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r *PuskesmasRepository) FindPuskesmasId(id string) (*internal.Puskesmas, error) {
    var puskesmas internal.Puskesmas
    err := r.DB.Where("id = ?", id).First(&puskesmas).Error
    if err != nil {
        return nil, err 
    }    
    return &puskesmas, nil
}

func (r *PuskesmasRepository) UpdatePuskesmas(id string, puskesmas *internal.Puskesmas) error {
    return r.DB.Model(&internal.Posyandu{}).Where("id = ?", id).Updates(puskesmas).Error
}

func (r *PuskesmasRepository) DeletePuskesmasId(id string) error {
    var puskesmas internal.Puskesmas
    err := r.DB.Where("id = ?", id).Delete(&puskesmas).Error
    if err != nil {
        return err
    }
    return nil
}

// Dinas Kesehatan =========================================================================


func (r *DinasKesehatanRepository) GetAllDinasKesehatan(dinas *[]internal.DinasKesehatan) error {
    return r.DB.Find(dinas).Error
}

func (r *DinasKesehatanRepository) CreateDinasKesehatan(dinas *internal.DinasKesehatan) error {
    return r.DB.Create(dinas).Error
}

func (r *DinasKesehatanRepository) FindDinasKesehatanId(id string) (*internal.DinasKesehatan, error) {
    var dinas internal.DinasKesehatan
    err := r.DB.Where("id = ?", id).First(&dinas).Error
    if err != nil {
        return nil, err
    }
    return &dinas, nil
}

func (r *DinasKesehatanRepository) UpdateDinasKesehatan(id string, dinas *internal.DinasKesehatan) error {
    return r.DB.Model(&internal.DinasKesehatan{}).Where("id = ?", id).Updates(dinas).Error
}

func (r *DinasKesehatanRepository) DeleteDinasKesehatanId(id string) error {
    var dinas internal.DinasKesehatan
    return r.DB.Where("id = ?", id).Delete(&dinas).Error
}