package service

import (
	"fmt"
	"time"

	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/repositories"
)

// =================== Sync Service ===================

type SyncService struct {
	BalitaRepo      *repositories.BalitaRepository
	PengukuranRepo  *repositories.PengukuranRepository
	HasilDeteksiRepo *repositories.HasilDeteksiRepository
	LogNutrisiRepo  *repositories.LogNutrisiRepository
	AlertRepo       *repositories.AlertRepository
	PosyanduRepo    *repositories.PosyanduRepository
}

func NewSyncService(
	balitaRepo *repositories.BalitaRepository,
	pengukuranRepo *repositories.PengukuranRepository,
	hasilDeteksiRepo *repositories.HasilDeteksiRepository,
	logNutrisiRepo *repositories.LogNutrisiRepository,
	alertRepo *repositories.AlertRepository,
	posyanduRepo *repositories.PosyanduRepository,
) *SyncService {
	return &SyncService{
		BalitaRepo: balitaRepo, PengukuranRepo: pengukuranRepo,
		HasilDeteksiRepo: hasilDeteksiRepo, LogNutrisiRepo: logNutrisiRepo,
		AlertRepo: alertRepo, PosyanduRepo: posyanduRepo,
	}
}

type SyncPushInput struct {
	Balita        []internal.Balita              `json:"balita"`
	Pengukuran    []internal.Pengukuran          `json:"pengukuran"`
	HasilDeteksi  []internal.HasilDeteksiRisiko  `json:"hasil_deteksi"`
	LogNutrisi    []internal.LogNutrisi          `json:"log_nutrisi"`
}

type SyncRecordResult struct {
	Type    string `json:"type"`
	ID      uint   `json:"id"`
	Status  string `json:"status"`
	Reason  string `json:"reason,omitempty"`
	Action  string `json:"action"`
}

type SyncPushResponse struct {
	Results    []SyncRecordResult `json:"results"`
	TotalOK    int                `json:"total_ok"`
	TotalFail  int                `json:"total_fail"`
}

func (s *SyncService) Push(input SyncPushInput) (*SyncPushResponse, error) {
	resp := &SyncPushResponse{}

	for _, b := range input.Balita {
		b.SyncStatus = "synced"
		err := s.BalitaRepo.UpsertBalita(&b)
		result := SyncRecordResult{Type: "balita", ID: b.ID, Action: "upsert"}
		if err != nil {
			result.Status = "gagal"
			result.Reason = err.Error()
			resp.TotalFail++
		} else {
			result.Status = "sukses"
			resp.TotalOK++
		}
		resp.Results = append(resp.Results, result)
	}

	for _, p := range input.Pengukuran {
		p.SyncStatus = "synced"
		err := s.PengukuranRepo.Upsert(&p)
		result := SyncRecordResult{Type: "pengukuran", ID: p.ID, Action: "upsert"}
		if err != nil {
			result.Status = "gagal"
			result.Reason = err.Error()
			resp.TotalFail++
		} else {
			result.Status = "sukses"
			resp.TotalOK++
		}
		resp.Results = append(resp.Results, result)
	}

	for _, h := range input.HasilDeteksi {
		h.SyncStatus = "synced"
		err := s.HasilDeteksiRepo.Upsert(&h)
		result := SyncRecordResult{Type: "hasil_deteksi", ID: h.ID, Action: "upsert"}
		if err != nil {
			result.Status = "gagal"
			result.Reason = err.Error()
			resp.TotalFail++
		} else {
			result.Status = "sukses"
			resp.TotalOK++
			// Trigger alert for high risk (§6.6)
			if h.Kategori == "tinggi" {
				wilayah := s.getWilayahForBalita(h.BalitaID)
				alert := &internal.Alert{
					BalitaID:       h.BalitaID,
					KategoriRisiko: h.Kategori,
					WilayahKerja:   wilayah,
					Status:         "unread",
				}
				_ = s.AlertRepo.Create(alert)
			}
		}
		resp.Results = append(resp.Results, result)
	}

	// Process Log Nutrisi
	for _, l := range input.LogNutrisi {
		l.SyncStatus = "synced"
		err := s.LogNutrisiRepo.Upsert(&l)
		result := SyncRecordResult{Type: "log_nutrisi", ID: l.ID, Action: "upsert"}
		if err != nil {
			result.Status = "gagal"
			result.Reason = err.Error()
			resp.TotalFail++
		} else {
			result.Status = "sukses"
			resp.TotalOK++
		}
		resp.Results = append(resp.Results, result)
	}

	return resp, nil
}

func (s *SyncService) getWilayahForBalita(balitaID uint) string {
	balita, err := s.BalitaRepo.FindByID(balitaID)
	if err != nil {
		return ""
	}
	posyanduID := fmt.Sprintf("%d", balita.PosyanduID)
	posyandu, err := s.PosyanduRepo.FindPosyanduId(posyanduID)
	if err != nil {
		return ""
	}
	return posyandu.WilayahKerja
}

type SyncPullResponse struct {
	Balita       []internal.Balita              `json:"balita"`
	Pengukuran   []internal.Pengukuran          `json:"pengukuran"`
	HasilDeteksi []internal.HasilDeteksiRisiko  `json:"hasil_deteksi"`
	LogNutrisi   []internal.LogNutrisi          `json:"log_nutrisi"`
	ServerTime   time.Time                      `json:"server_time"`
}

func (s *SyncService) Pull(since time.Time, posyanduIDs []uint) (*SyncPullResponse, error) {
	balita, err := s.BalitaRepo.GetBalitaByPosyanduIDs(posyanduIDs, since)
	if err != nil {
		return nil, err
	}
	pengukuran, err := s.PengukuranRepo.GetByPosyanduIDsSince(posyanduIDs, since)
	if err != nil {
		return nil, err
	}
	hasilDeteksi, err := s.HasilDeteksiRepo.GetByPosyanduIDsSince(posyanduIDs, since)
	if err != nil {
		return nil, err
	}
	logNutrisi, err := s.LogNutrisiRepo.GetByPosyanduIDsSince(posyanduIDs, since)
	if err != nil {
		return nil, err
	}
	return &SyncPullResponse{
		Balita: balita, Pengukuran: pengukuran,
		HasilDeteksi: hasilDeteksi, LogNutrisi: logNutrisi,
		ServerTime: time.Now(),
	}, nil
}

// =================== Dashboard Service ===================

type DashboardService struct {
	BalitaRepo       *repositories.BalitaRepository
	HasilDeteksiRepo *repositories.HasilDeteksiRepository
	PosyanduRepo     *repositories.PosyanduRepository
}

func NewDashboardService(
	balitaRepo *repositories.BalitaRepository,
	hasilDeteksiRepo *repositories.HasilDeteksiRepository,
	posyanduRepo *repositories.PosyanduRepository,
) *DashboardService {
	return &DashboardService{
		BalitaRepo: balitaRepo, HasilDeteksiRepo: hasilDeteksiRepo,
		PosyanduRepo: posyanduRepo,
	}
}

type DashboardSummary struct {
	TotalBalita      int64            `json:"total_balita"`
	DistribusiRisiko map[string]int64 `json:"distribusi_risiko"`
}

func (s *DashboardService) GetSummary(wilayah string) (*DashboardSummary, error) {
	var balitaList []internal.Balita
	err := s.BalitaRepo.GetAllBalita(&balitaList)
	if err != nil {
		return nil, err
	}
	distribusi, err := s.HasilDeteksiRepo.CountByKategoriAndWilayah(wilayah)
	if err != nil {
		return nil, err
	}
	return &DashboardSummary{
		TotalBalita:      int64(len(balitaList)),
		DistribusiRisiko: distribusi,
	}, nil
}

func (s *DashboardService) GetHeatmap(from, to time.Time, kategori string) ([]map[string]interface{}, error) {
	return s.HasilDeteksiRepo.GetHeatmapData(from, to, kategori)
}

// =================== Analitik Service ===================

type AnalitikService struct {
	HasilDeteksiRepo *repositories.HasilDeteksiRepository
}

func NewAnalitikService(hasilDeteksiRepo *repositories.HasilDeteksiRepository) *AnalitikService {
	return &AnalitikService{HasilDeteksiRepo: hasilDeteksiRepo}
}

func (s *AnalitikService) GetTrend(wilayah, periode string) ([]map[string]interface{}, error) {
	return s.HasilDeteksiRepo.GetTrend(wilayah, periode)
}

func (s *AnalitikService) GetProyeksi(wilayah string) (map[string]interface{}, error) {
	trend, err := s.HasilDeteksiRepo.GetTrend(wilayah, "bulanan")
	if err != nil {
		return nil, err
	}
	return map[string]interface{}{
		"trend_historis": trend,
		"catatan":        "Proyeksi berdasarkan tren historis. Data ini bersifat estimasi.",
	}, nil
}

// =================== Laporan Service ===================

type LaporanService struct {
	Repo *repositories.LaporanJobRepository
}

func NewLaporanService(repo *repositories.LaporanJobRepository) *LaporanService {
	return &LaporanService{Repo: repo}
}

type LaporanInput struct {
	Jenis       string    `json:"jenis" binding:"required"`
	Wilayah     string    `json:"wilayah" binding:"required"`
	PeriodeFrom time.Time `json:"periode_from" binding:"required"`
	PeriodeTo   time.Time `json:"periode_to" binding:"required"`
	Format      string    `json:"format" binding:"required"`
}

func (s *LaporanService) CreateJob(input LaporanInput, requestedBy uint) (*internal.LaporanJob, error) {
	validFormats := map[string]bool{"pdf": true, "excel": true}
	if !validFormats[input.Format] {
		return nil, fmt.Errorf("format harus 'pdf' atau 'excel'")
	}
	job := &internal.LaporanJob{
		Jenis: input.Jenis, Wilayah: input.Wilayah,
		PeriodeFrom: input.PeriodeFrom, PeriodeTo: input.PeriodeTo,
		Format: input.Format, Status: "processing", RequestedBy: requestedBy,
	}
	err := s.Repo.Create(job)
	if err != nil {
		return nil, err
	}
	// Run report generation async
	go s.generateReport(job)
	return job, nil
}

func (s *LaporanService) GetJobStatus(jobID string) (*internal.LaporanJob, error) {
	return s.Repo.FindByID(jobID)
}

func (s *LaporanService) generateReport(job *internal.LaporanJob) {
	// Placeholder: actual PDF/Excel generation would go here
	time.Sleep(3 * time.Second)
	fileURL := fmt.Sprintf("/reports/%s_laporan_%d.%s", job.Jenis, job.ID, job.Format)
	_ = s.Repo.UpdateStatus(job.ID, "ready", fileURL)
}

// =================== Alert Service ===================

type AlertService struct {
	Repo *repositories.AlertRepository
}

func NewAlertService(repo *repositories.AlertRepository) *AlertService {
	return &AlertService{Repo: repo}
}

func (s *AlertService) GetAlerts(unreadOnly bool, wilayah string, page, limit int) ([]internal.Alert, int64, error) {
	if page < 1 { page = 1 }
	if limit < 1 || limit > 100 { limit = 20 }
	return s.Repo.GetAlerts(unreadOnly, wilayah, page, limit)
}

func (s *AlertService) MarkAsRead(id string) error {
	return s.Repo.MarkAsRead(id)
}
