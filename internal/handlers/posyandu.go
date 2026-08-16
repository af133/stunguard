package handlers

import (
	"net/http"
	"strconv"

	"github.com/af133/stunguard/internal/service"
	"github.com/af133/stunguard/internal/utils"
	"github.com/af133/stunguard/pkg/response"
	"github.com/gin-gonic/gin"
)

// =================== Handler Structs ===================

type UserHandler struct{ UserService *service.UserService }
type BalitaHandler struct{ BalitaService *service.BalitaService }
type PosyanduHandler struct {
	PosyanduService  *service.PosyanduService
	PuskesmasService *service.PuskesmasService
}
type PuskesmasHandler struct {
	PuskesmasService *service.PuskesmasService
	DinasService     *service.DinasKesahatanService
}
type DinasKesehatanHandler struct{ DinasKesehatanService *service.DinasKesahatanService }
type KaderHandler struct{ KaderService *service.KaderService }
type PengukuranHandler struct{ PengukuranService *service.PengukuranService }

// =================== Constructors ===================

func NewUserHandler(s *service.UserService) *UserHandler { return &UserHandler{UserService: s} }
func NewBalitaHandler(s *service.BalitaService) *BalitaHandler { return &BalitaHandler{BalitaService: s} }
func NewPosyanduHandler(s *service.PosyanduService) *PosyanduHandler {
	return &PosyanduHandler{PosyanduService: s}
}
func NewPuskesmasHandler(s *service.PuskesmasService) *PuskesmasHandler {
	return &PuskesmasHandler{PuskesmasService: s}
}
func NewDinasKesehatanHandler(s *service.DinasKesahatanService) *DinasKesehatanHandler {
	return &DinasKesehatanHandler{DinasKesehatanService: s}
}
func NewKaderHandler(s *service.KaderService) *KaderHandler { return &KaderHandler{KaderService: s} }
func NewPengukuranHandler(s *service.PengukuranService) *PengukuranHandler {
	return &PengukuranHandler{PengukuranService: s}
}

// =================== Auth Handlers ===================

func (h *UserHandler) Register(ctx *gin.Context) {
	var input service.RegisterInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	user, err := h.UserService.Register(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, gin.H{
		"message": "Registrasi berhasil",
		"user":    user,
	})
}

func (h *UserHandler) Login(ctx *gin.Context) {
	var input service.LoginInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	user, err := h.UserService.Login(input)
	if err != nil {
		response.Unauthorized(ctx, err.Error())
		return
	}
	token, err := utils.GenerateToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	if err != nil {
		response.InternalError(ctx, "Gagal menghasilkan token")
		return
	}
	refreshToken, err := utils.GenerateRefreshToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	if err != nil {
		response.InternalError(ctx, "Gagal menghasilkan refresh token")
		return
	}
	_ = h.UserService.UpdateRefreshToken(user.ID, refreshToken)
	response.Success(ctx, http.StatusOK, gin.H{
		"token":         token,
		"refresh_token": refreshToken,
		"user":          user,
	})
}

func (h *UserHandler) LoginPetugas(ctx *gin.Context) {
	var input service.LoginInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	user, err := h.UserService.LoginPetugas(input)
	if err != nil {
		response.Unauthorized(ctx, err.Error())
		return
	}
	token, err := utils.GenerateToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	if err != nil {
		response.InternalError(ctx, "Gagal menghasilkan token")
		return
	}
	refreshToken, err := utils.GenerateRefreshToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	if err != nil {
		response.InternalError(ctx, "Gagal menghasilkan refresh token")
		return
	}
	_ = h.UserService.UpdateRefreshToken(user.ID, refreshToken)
	response.Success(ctx, http.StatusOK, gin.H{
		"token":         token,
		"refresh_token": refreshToken,
		"user":          user,
	})
}

func (h *UserHandler) RefreshToken(ctx *gin.Context) {
	var body struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}
	if err := ctx.ShouldBindJSON(&body); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	claims, err := utils.ParseToken(body.RefreshToken)
	if err != nil {
		response.Unauthorized(ctx, "Refresh token tidak valid atau kedaluwarsa")
		return
	}
	user, err := h.UserService.FindByID(claims.ID)
	if err != nil {
		response.Unauthorized(ctx, "User tidak ditemukan")
		return
	}
	if user.RefreshToken != body.RefreshToken {
		response.Unauthorized(ctx, "Refresh token tidak cocok")
		return
	}
	newToken, _ := utils.GenerateToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	newRefresh, _ := utils.GenerateRefreshToken(user.ID, user.Email, user.Role, user.WilayahKerjaID)
	_ = h.UserService.UpdateRefreshToken(user.ID, newRefresh)
	response.Success(ctx, http.StatusOK, gin.H{
		"token":         newToken,
		"refresh_token": newRefresh,
	})
}

func (h *UserHandler) ForgotPassword(ctx *gin.Context) {
	var body struct {
		Email string `json:"email" binding:"required,email"`
	}
	if err := ctx.ShouldBindJSON(&body); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{
		"message": "Jika email terdaftar, link reset password telah dikirim",
	})
}

// =================== Balita Handlers ===================

func (h *BalitaHandler) GetAllBalita(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "20"))
	search := ctx.Query("search")
	kategoriRisiko := ctx.Query("kategori_risiko")
	wilayah := ctx.Query("wilayah")

	balita, total, err := h.BalitaService.GetBalitaPaginated(page, limit, search, kategoriRisiko, wilayah)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{
		"balita": balita, "total": total, "page": page, "limit": limit,
	})
}

func (h *BalitaHandler) CreateBalita(ctx *gin.Context) {
	var input service.BalitaInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	balita, err := h.BalitaService.CreateBalita(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, balita)
}

func (h *BalitaHandler) FindBalitaNIK(ctx *gin.Context) {
	nik := ctx.Param("nik")
	balita, err := h.BalitaService.FindBalitaNIK(nik)
	if err != nil {
		response.NotFound(ctx, "Data balita tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, balita)
}

func (h *BalitaHandler) DeleteBalita(ctx *gin.Context) {
	nik := ctx.Param("nik")
	err := h.BalitaService.DeleteBalitaNIK(nik)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Data balita berhasil dihapus"})
}

func (h *BalitaHandler) UpdateBalita(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.BalitaInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	updated, err := h.BalitaService.UpdateBalita(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *BalitaHandler) GetRiwayat(ctx *gin.Context) {
	id := ctx.Param("id")
	data, err := h.BalitaService.GetRiwayat(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, data)
}

// =================== Posyandu Handlers ===================

func (h *PosyanduHandler) CreatePosyandu(ctx *gin.Context) {
	var input service.PosyanduInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	id := strconv.FormatUint(uint64(input.PuskesmasID), 10)
	_, err := h.PuskesmasService.FindPuskesmas(id)
	if err != nil {
		response.BadRequest(ctx, "Puskesmas tidak ditemukan")
		return
	}
	posyandu, err := h.PosyanduService.CreatePosyandu(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, posyandu)
}

func (h *PosyanduHandler) UpdatePosyandu(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.PosyanduInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	pID := strconv.FormatUint(uint64(input.PuskesmasID), 10)
	_, err := h.PuskesmasService.FindPuskesmas(pID)
	if err != nil {
		response.BadRequest(ctx, "Puskesmas tidak ada")
		return
	}
	updated, err := h.PosyanduService.UpdatePosyandu(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *PosyanduHandler) GetAllPosyandu(ctx *gin.Context) {
	posyandu, err := h.PosyanduService.GetAllPosyandu()
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, posyandu)
}

func (h *PosyanduHandler) FindPosyandu(ctx *gin.Context) {
	id := ctx.Param("id")
	posyandu, err := h.PosyanduService.FindPosyandu(id)
	if err != nil {
		response.NotFound(ctx, "Data posyandu tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, posyandu)
}

func (h *PosyanduHandler) DeletePosyandu(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.PosyanduService.DeletePosyandu(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Data posyandu berhasil dihapus"})
}

// =================== Puskesmas Handlers ===================

func (h *PuskesmasHandler) CreatePuskesmas(ctx *gin.Context) {
	var input service.PuskesmasInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	id := strconv.FormatUint(uint64(input.DinasID), 10)
	_, err := h.DinasService.FindDinasKesehatan(id)
	if err != nil {
		response.BadRequest(ctx, "Dinas Kesehatan tidak ditemukan")
		return
	}
	puskesmas, err := h.PuskesmasService.CreatePuskesmas(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, puskesmas)
}

func (h *PuskesmasHandler) UpdatePuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.PuskesmasInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	dID := strconv.FormatUint(uint64(input.DinasID), 10)
	_, err := h.DinasService.FindDinasKesehatan(dID)
	if err != nil {
		response.BadRequest(ctx, "Dinas Kesehatan tidak ditemukan")
		return
	}
	updated, err := h.PuskesmasService.UpdatePuskesmas(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *PuskesmasHandler) GetAllPuskesmas(ctx *gin.Context) {
	puskesmas, err := h.PuskesmasService.GetAllPuskesmas()
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, puskesmas)
}

func (h *PuskesmasHandler) FindPuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	puskesmas, err := h.PuskesmasService.FindPuskesmas(id)
	if err != nil {
		response.NotFound(ctx, "Data puskesmas tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, puskesmas)
}

func (h *PuskesmasHandler) DeletePuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.PuskesmasService.DeletePuskesmas(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Data puskesmas berhasil dihapus"})
}

// =================== Dinas Kesehatan Handlers ===================

func (h *DinasKesehatanHandler) CreateDinasKesehatan(ctx *gin.Context) {
	var input service.DinasKesehatanInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	dinas, err := h.DinasKesehatanService.CreateDinasKesehatan(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, dinas)
}

func (h *DinasKesehatanHandler) UpdateDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.DinasKesehatanInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	updated, err := h.DinasKesehatanService.UpdateDinasKesehatan(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *DinasKesehatanHandler) GetAllDinasKesehatan(ctx *gin.Context) {
	dinas, err := h.DinasKesehatanService.GetAllDinasKesehatan()
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, dinas)
}

func (h *DinasKesehatanHandler) FindDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	dinas, err := h.DinasKesehatanService.FindDinasKesehatan(id)
	if err != nil {
		response.NotFound(ctx, "Data dinas kesehatan tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, dinas)
}

func (h *DinasKesehatanHandler) DeleteDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.DinasKesehatanService.DeleteDinasKesehatan(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Data dinas kesehatan berhasil dihapus"})
}

// =================== Kader Handlers ===================

func (h *KaderHandler) CreateKader(ctx *gin.Context) {
	var input service.KaderInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	userID, _ := ctx.Get("userID")
	kader, err := h.KaderService.CreateKader(input, userID.(uint))
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, kader)
}

func (h *KaderHandler) GetAllKader(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "20"))
	posyanduID, _ := strconv.Atoi(ctx.DefaultQuery("posyandu_id", "0"))
	kaderList, total, err := h.KaderService.GetAllKader(page, limit, uint(posyanduID))
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{
		"kader": kaderList, "total": total, "page": page, "limit": limit,
	})
}

func (h *KaderHandler) FindKader(ctx *gin.Context) {
	id := ctx.Param("id")
	kader, err := h.KaderService.FindKader(id)
	if err != nil {
		response.NotFound(ctx, "Data kader tidak ditemukan")
		return
	}
	response.Success(ctx, http.StatusOK, kader)
}

func (h *KaderHandler) UpdateKader(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.KaderInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	updated, err := h.KaderService.UpdateKader(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *KaderHandler) ValidateKader(ctx *gin.Context) {
	id := ctx.Param("id")
	validated, err := h.KaderService.ValidateKader(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{
		"message": "Kader berhasil divalidasi",
		"kader":   validated,
	})
}

// =================== Pengukuran Handlers ===================

func (h *PengukuranHandler) Create(ctx *gin.Context) {
	var input service.PengukuranInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	p, err := h.PengukuranService.Create(input)
	if err != nil {
		response.BadRequest(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusCreated, p)
}

func (h *PengukuranHandler) GetByBalitaID(ctx *gin.Context) {
	balitaID := ctx.Param("balita_id")
	list, err := h.PengukuranService.GetByBalitaID(balitaID)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, list)
}

func (h *PengukuranHandler) Update(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.PengukuranInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		response.ValidationError(ctx, err.Error())
		return
	}
	updated, err := h.PengukuranService.Update(id, input)
	if err != nil {
		response.InternalError(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, updated)
}

func (h *PengukuranHandler) Delete(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.PengukuranService.Delete(id)
	if err != nil {
		response.NotFound(ctx, err.Error())
		return
	}
	response.Success(ctx, http.StatusOK, gin.H{"message": "Data pengukuran berhasil dihapus"})
}
