package repositories

import (
	"errors"
	"time"

	"github.com/af133/stunguard/internal"
	"gorm.io/gorm"
)

// =================== Repository Structs ===================

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

type KaderRepository struct {
	DB *gorm.DB
}

type PengukuranRepository struct {
	DB *gorm.DB
}

type HasilDeteksiRepository struct {
	DB *gorm.DB
}

type LogNutrisiRepository struct {
	DB *gorm.DB
}

type AlertRepository struct {
	DB *gorm.DB
}

type LaporanJobRepository struct {
	DB *gorm.DB
}

// =================== Constructors ===================

func NewUserRepository() *UserRepository {
	return &UserRepository{DB: internal.DB}
}

func NewBalitaRepository() *BalitaRepository {
	return &BalitaRepository{DB: internal.DB}
}

func NewPosyanduRepository() *PosyanduRepository {
	return &PosyanduRepository{DB: internal.DB}
}

func NewPuskesmasRepository() *PuskesmasRepository {
	return &PuskesmasRepository{DB: internal.DB}
}

func NewDinasKesehatanRepository() *DinasKesehatanRepository {
	return &DinasKesehatanRepository{DB: internal.DB}
}

func NewKaderRepository() *KaderRepository {
	return &KaderRepository{DB: internal.DB}
}

func NewPengukuranRepository() *PengukuranRepository {
	return &PengukuranRepository{DB: internal.DB}
}

func NewHasilDeteksiRepository() *HasilDeteksiRepository {
	return &HasilDeteksiRepository{DB: internal.DB}
}

func NewLogNutrisiRepository() *LogNutrisiRepository {
	return &LogNutrisiRepository{DB: internal.DB}
}

func NewAlertRepository() *AlertRepository {
	return &AlertRepository{DB: internal.DB}
}

func NewLaporanJobRepository() *LaporanJobRepository {
	return &LaporanJobRepository{DB: internal.DB}
}

// =================== User Repository ===================

func (r *UserRepository) CreateUser(user *internal.User) error {
	return r.DB.Create(user).Error
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

func (r *UserRepository) UpdateUser(user *internal.User) error {
	return r.DB.Save(user).Error
}

// =================== Balita Repository ===================

func (r *BalitaRepository) GetAllBalita(balita *[]internal.Balita) error {
	return r.DB.Find(balita).Error
}

func (r *BalitaRepository) GetBalitaPaginated(page, limit int, search, kategoriRisiko, wilayah string) ([]internal.Balita, int64, error) {
	var balita []internal.Balita
	var total int64

	query := r.DB.Model(&internal.Balita{})

	if search != "" {
		query = query.Where("nama ILIKE ? OR nik ILIKE ?", "%"+search+"%", "%"+search+"%")
	}
	if wilayah != "" {
		query = query.Joins("JOIN posyandus ON posyandus.id = balitas.posyandu_id").
			Where("posyandus.wilayah_kerja ILIKE ?", "%"+wilayah+"%")
	}
	if kategoriRisiko != "" {
		query = query.Where("id IN (?)",
			r.DB.Model(&internal.HasilDeteksiRisiko{}).
				Select("balita_id").
				Where("kategori = ?", kategoriRisiko).
				Group("balita_id"),
		)
	}

	query.Count(&total)

	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&balita).Error
	return balita, total, err
}

func (r *BalitaRepository) CreateBalita(balita *internal.Balita) error {
	return r.DB.Create(balita).Error
}

func (r *BalitaRepository) DeleteBalita(nikBalita string) error {
	result := r.DB.Where("nik = ?", nikBalita).Delete(&internal.Balita{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data balita dengan NIK tersebut tidak ditemukan")
	}
	return nil
}

func (r *BalitaRepository) FindNikBalita(nikBalita string) (*internal.Balita, error) {
	var balita internal.Balita
	result := r.DB.Where("nik = ?", nikBalita).First(&balita)
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

func (r *BalitaRepository) FindByID(id uint) (*internal.Balita, error) {
	var balita internal.Balita
	result := r.DB.First(&balita, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &balita, nil
}

func (r *BalitaRepository) UpdateBalita(balita *internal.Balita) error {
	return r.DB.Save(balita).Error
}

func (r *BalitaRepository) UpsertBalita(balita *internal.Balita) error {
	var existing internal.Balita
	result := r.DB.Where("id = ?", balita.ID).First(&existing)
	if result.Error != nil {
		return r.DB.Create(balita).Error
	}
	return r.DB.Save(balita).Error
}

func (r *BalitaRepository) GetBalitaByPosyanduIDs(posyanduIDs []uint, since time.Time) ([]internal.Balita, error) {
	var balita []internal.Balita
	err := r.DB.Where("posyandu_id IN ? AND updated_at > ?", posyanduIDs, since).Find(&balita).Error
	return balita, err
}

func (r *BalitaRepository) DeleteBalitaByID(id string) error {
	result := r.DB.Where("id = ?", id).Delete(&internal.Balita{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data balita tidak ditemukan")
	}
	return nil
}

// =================== Posyandu Repository ===================

func (r *PosyanduRepository) CreatePosyandu(posyandu *internal.Posyandu) error {
	return r.DB.Create(posyandu).Error
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
	return r.DB.Where("id = ?", id).Delete(&internal.Posyandu{}).Error
}

func (r *PosyanduRepository) UpdatePosyandu(id string, posyandu *internal.Posyandu) error {
	return r.DB.Model(&internal.Posyandu{}).Where("id = ?", id).Updates(posyandu).Error
}

func (r *PosyanduRepository) GetAllPosyandu(posyandu *[]internal.Posyandu) error {
	return r.DB.Find(posyandu).Error
}

func (r *PosyanduRepository) GetPosyanduByPuskesmasID(puskesmasID uint) ([]internal.Posyandu, error) {
	var posyandu []internal.Posyandu
	err := r.DB.Where("puskesmas_id = ?", puskesmasID).Find(&posyandu).Error
	return posyandu, err
}

func (r *PosyanduRepository) GetPosyanduByWilayah(wilayah string) ([]internal.Posyandu, error) {
	var posyandu []internal.Posyandu
	err := r.DB.Where("wilayah_kerja ILIKE ?", "%"+wilayah+"%").Find(&posyandu).Error
	return posyandu, err
}

func (r *PosyanduRepository) GetPosyanduIDs(posyanduIDs []uint) ([]internal.Posyandu, error) {
	var posyandu []internal.Posyandu
	err := r.DB.Where("id IN ?", posyanduIDs).Find(&posyandu).Error
	return posyandu, err
}

// =================== Puskesmas Repository ===================

func (r *PuskesmasRepository) GetAllPuskesmas(puskesmas *[]internal.Puskesmas) error {
	return r.DB.Find(puskesmas).Error
}

func (r *PuskesmasRepository) CreatePuskesmas(puskesmas *internal.Puskesmas) error {
	return r.DB.Create(puskesmas).Error
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
	return r.DB.Model(&internal.Puskesmas{}).Where("id = ?", id).Updates(puskesmas).Error
}

func (r *PuskesmasRepository) DeletePuskesmasId(id string) error {
	return r.DB.Where("id = ?", id).Delete(&internal.Puskesmas{}).Error
}

// =================== Dinas Kesehatan Repository ===================

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
	return r.DB.Where("id = ?", id).Delete(&internal.DinasKesehatan{}).Error
}

// =================== Kader Repository ===================

func (r *KaderRepository) CreateKader(kader *internal.Kader) error {
	return r.DB.Create(kader).Error
}

func (r *KaderRepository) FindByID(id string) (*internal.Kader, error) {
	var kader internal.Kader
	err := r.DB.Where("id = ?", id).First(&kader).Error
	if err != nil {
		return nil, err
	}
	return &kader, nil
}

func (r *KaderRepository) FindByUserID(userID uint) (*internal.Kader, error) {
	var kader internal.Kader
	err := r.DB.Where("user_id = ?", userID).First(&kader).Error
	if err != nil {
		return nil, err
	}
	return &kader, nil
}

func (r *KaderRepository) FindByNIK(nik string) (*internal.Kader, error) {
	var kader internal.Kader
	err := r.DB.Where("nik = ?", nik).First(&kader).Error
	if err != nil {
		return nil, err
	}
	return &kader, nil
}

func (r *KaderRepository) GetAllKader(page, limit int, posyanduID uint) ([]internal.Kader, int64, error) {
	var kaderList []internal.Kader
	var total int64

	query := r.DB.Model(&internal.Kader{})
	if posyanduID > 0 {
		query = query.Where("posyandu_id = ?", posyanduID)
	}

	query.Count(&total)

	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&kaderList).Error
	return kaderList, total, err
}

func (r *KaderRepository) UpdateKader(kader *internal.Kader) error {
	return r.DB.Save(kader).Error
}

func (r *KaderRepository) DeleteKader(id string) error {
	result := r.DB.Where("id = ?", id).Delete(&internal.Kader{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data kader tidak ditemukan")
	}
	return nil
}

// =================== Pengukuran Repository ===================

func (r *PengukuranRepository) Create(p *internal.Pengukuran) error {
	return r.DB.Create(p).Error
}

func (r *PengukuranRepository) FindByID(id string) (*internal.Pengukuran, error) {
	var p internal.Pengukuran
	err := r.DB.Where("id = ?", id).First(&p).Error
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *PengukuranRepository) GetByBalitaID(balitaID string) ([]internal.Pengukuran, error) {
	var list []internal.Pengukuran
	err := r.DB.Where("balita_id = ?", balitaID).Order("tanggal ASC").Find(&list).Error
	return list, err
}

func (r *PengukuranRepository) Update(p *internal.Pengukuran) error {
	return r.DB.Save(p).Error
}

func (r *PengukuranRepository) Delete(id string) error {
	result := r.DB.Where("id = ?", id).Delete(&internal.Pengukuran{})
	if result.RowsAffected == 0 {
		return errors.New("data pengukuran tidak ditemukan")
	}
	return result.Error
}

func (r *PengukuranRepository) Upsert(p *internal.Pengukuran) error {
	var existing internal.Pengukuran
	result := r.DB.Where("id = ?", p.ID).First(&existing)
	if result.Error != nil {
		return r.DB.Create(p).Error
	}
	return r.DB.Save(p).Error
}

func (r *PengukuranRepository) GetByPosyanduIDsSince(posyanduIDs []uint, since time.Time) ([]internal.Pengukuran, error) {
	var list []internal.Pengukuran
	err := r.DB.Joins("JOIN balitas ON balitas.id = pengukurans.balita_id").
		Where("balitas.posyandu_id IN ? AND pengukurans.updated_at > ?", posyanduIDs, since).
		Find(&list).Error
	return list, err
}

// =================== Hasil Deteksi Repository ===================

func (r *HasilDeteksiRepository) Create(h *internal.HasilDeteksiRisiko) error {
	return r.DB.Create(h).Error
}

func (r *HasilDeteksiRepository) FindByID(id string) (*internal.HasilDeteksiRisiko, error) {
	var h internal.HasilDeteksiRisiko
	err := r.DB.Where("id = ?", id).First(&h).Error
	if err != nil {
		return nil, err
	}
	return &h, nil
}

func (r *HasilDeteksiRepository) GetByBalitaID(balitaID string) ([]internal.HasilDeteksiRisiko, error) {
	var list []internal.HasilDeteksiRisiko
	err := r.DB.Where("balita_id = ?", balitaID).Order("created_at DESC").Find(&list).Error
	return list, err
}

func (r *HasilDeteksiRepository) Upsert(h *internal.HasilDeteksiRisiko) error {
	var existing internal.HasilDeteksiRisiko
	result := r.DB.Where("id = ?", h.ID).First(&existing)
	if result.Error != nil {
		return r.DB.Create(h).Error
	}
	return r.DB.Save(h).Error
}

func (r *HasilDeteksiRepository) GetByPosyanduIDsSince(posyanduIDs []uint, since time.Time) ([]internal.HasilDeteksiRisiko, error) {
	var list []internal.HasilDeteksiRisiko
	err := r.DB.Joins("JOIN balitas ON balitas.id = hasil_deteksi_risikos.balita_id").
		Where("balitas.posyandu_id IN ? AND hasil_deteksi_risikos.updated_at > ?", posyanduIDs, since).
		Find(&list).Error
	return list, err
}

func (r *HasilDeteksiRepository) CountByKategoriAndWilayah(wilayah string) (map[string]int64, error) {
	type Result struct {
		Kategori string
		Count    int64
	}
	var results []Result

	query := r.DB.Model(&internal.HasilDeteksiRisiko{}).
		Select("kategori, COUNT(*) as count")

	if wilayah != "" {
		query = query.Joins("JOIN balitas ON balitas.id = hasil_deteksi_risikos.balita_id").
			Joins("JOIN posyandus ON posyandus.id = balitas.posyandu_id").
			Where("posyandus.wilayah_kerja ILIKE ?", "%"+wilayah+"%")
	}

	err := query.Group("kategori").Scan(&results).Error
	if err != nil {
		return nil, err
	}

	m := make(map[string]int64)
	for _, r := range results {
		m[r.Kategori] = r.Count
	}
	return m, nil
}

func (r *HasilDeteksiRepository) GetHeatmapData(from, to time.Time, kategori string) ([]map[string]interface{}, error) {
	var results []map[string]interface{}

	query := r.DB.Model(&internal.HasilDeteksiRisiko{}).
		Select("posyandus.id as posyandu_id, posyandus.nama as posyandu_nama, posyandus.koordinat_lat, posyandus.koordinat_lng, posyandus.wilayah_kerja, hasil_deteksi_risikos.kategori, COUNT(*) as jumlah").
		Joins("JOIN balitas ON balitas.id = hasil_deteksi_risikos.balita_id").
		Joins("JOIN posyandus ON posyandus.id = balitas.posyandu_id").
		Where("hasil_deteksi_risikos.created_at BETWEEN ? AND ?", from, to)

	if kategori != "" {
		query = query.Where("hasil_deteksi_risikos.kategori = ?", kategori)
	}

	err := query.Group("posyandus.id, posyandus.nama, posyandus.koordinat_lat, posyandus.koordinat_lng, posyandus.wilayah_kerja, hasil_deteksi_risikos.kategori").
		Scan(&results).Error

	return results, err
}

func (r *HasilDeteksiRepository) GetTrend(wilayah, periode string) ([]map[string]interface{}, error) {
	var results []map[string]interface{}

	dateFormat := "YYYY-MM"
	if periode == "triwulanan" {
		dateFormat = "YYYY-\"Q\"Q"
	} else if periode == "tahunan" {
		dateFormat = "YYYY"
	}

	query := r.DB.Model(&internal.HasilDeteksiRisiko{}).
		Select("TO_CHAR(hasil_deteksi_risikos.created_at, ?) as periode, kategori, COUNT(*) as jumlah", dateFormat).
		Joins("JOIN balitas ON balitas.id = hasil_deteksi_risikos.balita_id").
		Joins("JOIN posyandus ON posyandus.id = balitas.posyandu_id")

	if wilayah != "" {
		query = query.Where("posyandus.wilayah_kerja ILIKE ?", "%"+wilayah+"%")
	}

	err := query.Group("periode, kategori").Order("periode ASC").Scan(&results).Error
	return results, err
}

// =================== Log Nutrisi Repository ===================

func (r *LogNutrisiRepository) Create(l *internal.LogNutrisi) error {
	return r.DB.Create(l).Error
}

func (r *LogNutrisiRepository) Upsert(l *internal.LogNutrisi) error {
	var existing internal.LogNutrisi
	result := r.DB.Where("id = ?", l.ID).First(&existing)
	if result.Error != nil {
		return r.DB.Create(l).Error
	}
	return r.DB.Save(l).Error
}

func (r *LogNutrisiRepository) GetByPosyanduIDsSince(posyanduIDs []uint, since time.Time) ([]internal.LogNutrisi, error) {
	var list []internal.LogNutrisi
	err := r.DB.Joins("JOIN balitas ON balitas.id = log_nutritis.balita_id").
		Where("balitas.posyandu_id IN ? AND log_nutritis.updated_at > ?", posyanduIDs, since).
		Find(&list).Error
	return list, err
}

// =================== Alert Repository ===================

func (r *AlertRepository) Create(alert *internal.Alert) error {
	return r.DB.Create(alert).Error
}

func (r *AlertRepository) GetAlerts(unreadOnly bool, wilayah string, page, limit int) ([]internal.Alert, int64, error) {
	var alerts []internal.Alert
	var total int64

	query := r.DB.Model(&internal.Alert{})

	if unreadOnly {
		query = query.Where("status = ?", "unread")
	}
	if wilayah != "" {
		query = query.Where("wilayah_kerja ILIKE ?", "%"+wilayah+"%")
	}

	query.Count(&total)

	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&alerts).Error
	return alerts, total, err
}

func (r *AlertRepository) MarkAsRead(id string) error {
	result := r.DB.Model(&internal.Alert{}).Where("id = ?", id).Update("status", "read")
	if result.RowsAffected == 0 {
		return errors.New("alert tidak ditemukan")
	}
	return result.Error
}

func (r *AlertRepository) FindByID(id string) (*internal.Alert, error) {
	var alert internal.Alert
	err := r.DB.Where("id = ?", id).First(&alert).Error
	if err != nil {
		return nil, err
	}
	return &alert, nil
}

// =================== Laporan Job Repository ===================

func (r *LaporanJobRepository) Create(job *internal.LaporanJob) error {
	return r.DB.Create(job).Error
}

func (r *LaporanJobRepository) FindByID(id string) (*internal.LaporanJob, error) {
	var job internal.LaporanJob
	err := r.DB.Where("id = ?", id).First(&job).Error
	if err != nil {
		return nil, err
	}
	return &job, nil
}

func (r *LaporanJobRepository) UpdateStatus(id uint, status, fileURL string) error {
	updates := map[string]interface{}{
		"status": status,
	}
	if fileURL != "" {
		updates["file_url"] = fileURL
	}
	return r.DB.Model(&internal.LaporanJob{}).Where("id = ?", id).Updates(updates).Error
}