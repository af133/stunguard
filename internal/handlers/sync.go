package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/af133/stunguard/internal/service"
	"github.com/af133/stunguard/pkg/response"
	"github.com/gin-gonic/gin"
)

// =================== Handler Structs ===================

type SyncHandler struct{ SyncService *service.SyncService }
type DashboardHandler struct{ DashboardService *service.DashboardService }
type AnalitikHandler struct{ AnalitikService *service.AnalitikService }
type LaporanHandler struct{ LaporanService *service.LaporanService }
type AlertHandler struct{ AlertService *service.AlertService }

// =================== Constructors ===================

func NewSyncHandler(s *service.SyncService) *SyncHandler { return &SyncHandler{SyncService: s} }
func NewDashboardHandler(s *service.DashboardService) *DashboardHandler {
	return &DashboardHandler{DashboardService: s}
}
func NewAnalitikHandler(s *service.AnalitikService) *AnalitikHandler {
	return &AnalitikHandler{AnalitikService: s}
}
func NewLaporanHandler(s *service.LaporanService) *LaporanHandler {
	return &LaporanHandler{LaporanService: s}
}
func NewAlertHandler(s *service.AlertService) *AlertHandler { return &AlertHandler{AlertService: s} }

// =================== Sync Handlers ===================

func (h *SyncHandler) Push(ctx *gin.Context) {
	var input service.SyncPushInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	resp, err := h.SyncService.Push(input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, resp)
}

func (h *SyncHandler) Pull(ctx *gin.Context) {
	sinceStr := ctx.Query("since")
	since, err := time.Parse(time.RFC3339, sinceStr)
	if err != nil {
		since = time.Time{} 
	}
	posyanduIDsParam := ctx.QueryArray("posyandu_ids")
	var posyanduIDs []uint
	for _, pidStr := range posyanduIDsParam {
		pid, err := strconv.ParseUint(pidStr, 10, 32)
		if err == nil {
			posyanduIDs = append(posyanduIDs, uint(pid))
		}
	}
	userRole, _ := ctx.Get("userRole")
	if userRole == "kader" {
		userWilayah, _ := ctx.Get("userWilayahKerjaID")
		if userWilayah != nil {
			posyanduIDs = []uint{userWilayah.(uint)}
		}
	}

	resp, err := h.SyncService.Pull(since, posyanduIDs)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, resp)
}

// =================== Dashboard Handlers ===================

func (h *DashboardHandler) GetSummary(ctx *gin.Context) {
	wilayah := ctx.Query("wilayah")
	summary, err := h.DashboardService.GetSummary(wilayah)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, summary)
}

func (h *DashboardHandler) GetHeatmap(ctx *gin.Context) {
	fromStr := ctx.Query("from")
	toStr := ctx.Query("to")
	kategori := ctx.Query("kategori")

	from, err := time.Parse("2006-01-02", fromStr)
	if err != nil {
		from = time.Now().AddDate(0, -1, 0)
	}
	to, err := time.Parse("2006-01-02", toStr)
	if err != nil {
		to = time.Now()
	}

	heatmap, err := h.DashboardService.GetHeatmap(from, to, kategori)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, heatmap)
}

// =================== Analitik Handlers ===================

func (h *AnalitikHandler) GetTrend(ctx *gin.Context) {
	wilayah := ctx.Query("wilayah")
	periode := ctx.DefaultQuery("periode", "bulanan")

	trend, err := h.AnalitikService.GetTrend(wilayah, periode)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, trend)
}

func (h *AnalitikHandler) GetProyeksi(ctx *gin.Context) {
	wilayah := ctx.Query("wilayah")

	proyeksi, err := h.AnalitikService.GetProyeksi(wilayah)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, proyeksi)
}

// =================== Laporan Handlers ===================

func (h *LaporanHandler) Generate(ctx *gin.Context) {
	var input service.LaporanInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	userID, _ := ctx.Get("userID")
	job, err := h.LaporanService.CreateJob(input, userID.(uint))
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusAccepted, gin.H{
		"message": "Pembuatan laporan sedang diproses",
		"job":     job,
	})
}

func (h *LaporanHandler) GetStatus(ctx *gin.Context) {
	jobID := ctx.Param("jobId")
	job, err := h.LaporanService.GetJobStatus(jobID)
	if err != nil {
		response.NotFound(ctx, "Job laporan tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, job)
}

// =================== Alert Handlers ===================

func (h *AlertHandler) GetAlerts(ctx *gin.Context) {
	unreadOnly := ctx.Query("unread") == "true"
	wilayah := ctx.Query("wilayah")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "20"))

	alerts, total, err := h.AlertService.GetAlerts(unreadOnly, wilayah, page, limit)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{
		"alerts": alerts,
		"total":  total,
		"page":   page,
		"limit":  limit,
	})
}

func (h *AlertHandler) MarkAsRead(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.AlertService.MarkAsRead(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Alert ditandai sudah dibaca"})
}
