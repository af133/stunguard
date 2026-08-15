package handlers

import (
	"net/http"
	"strconv"

	"github.com/af133/stunguard/internal/service"
	"github.com/af133/stunguard/internal/utils"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	UserService *service.UserService
}

type BalitaHandler struct {
	BalitaService *service.BalitaService
}
type PosyanduHandler struct {
	PosyanduService  *service.PosyanduService
	PuskesmasService *service.PuskesmasService
}
type PuskesmasHandler struct {
	PuskesmasService *service.PuskesmasService
	DinasService     *service.DinasKesahatanService
}

type DinasKesehatanHandler struct {
	DinasKesehatanService *service.DinasKesahatanService
}

func NewPuskesmasHandler(puskesmasService *service.PuskesmasService) *PuskesmasHandler {
	return &PuskesmasHandler{
		PuskesmasService: puskesmasService,
	}
}
func NewUserHandler(userService *service.UserService) *UserHandler {
	return &UserHandler{
		UserService: userService,
	}
}
func NewBalitaHandler(balitaService *service.BalitaService) *BalitaHandler {
	return &BalitaHandler{
		BalitaService: balitaService,
	}
}
func NewPosyanduHandler(posyanduService *service.PosyanduService) *PosyanduHandler {
	return &PosyanduHandler{
		PosyanduService: posyanduService,
	}
}
func NewDinasKesehatanHandler(dinasService *service.DinasKesahatanService) *DinasKesehatanHandler {
	return &DinasKesehatanHandler{
		DinasKesehatanService: dinasService,
	}
}

// User Handler ======================================================================
func (h *UserHandler) Register(ctx *gin.Context) {
	var input service.RegisterInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	user, err := h.UserService.Register(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    user,
		"success": true,
	})
}

func (h *UserHandler) LoginPetugas(ctx *gin.Context) {
	var input service.LoginInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := h.UserService.LoginPetugas(input)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}
	token, err := utils.GenerateToken(user.ID, user.Email, user.Role)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghasilkan token"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil",
		"token":   token,
		"data":    user,
		"success": true,
	})
}

// Balita Handler ==========================================================================
func (h *BalitaHandler) GetAllBalita(ctx *gin.Context) {
	balita, err := h.BalitaService.GetAllBalita()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error":   err.Error(),
			"success": false,
		},
		)
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data balita",
		"data":    balita,
		"success": true,
	})
}
func (h *BalitaHandler) CreateBalita(ctx *gin.Context) {
	var input service.BalitaInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	balita, err := h.BalitaService.CreateBalita(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    balita,
		"success": true,
	})
}
func (h *BalitaHandler) FindBalitaNIK(ctx *gin.Context) {
	nik := ctx.Param("nik")
	balita, err := h.BalitaService.FindBalitaNIK(nik)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Data balita tidak ditemukan"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil",
		"data":    balita,
		"success": true,
	})
}
func (h *BalitaHandler) DeleteBalita(ctx *gin.Context) {
	nik := ctx.Param("nik")
	err := h.BalitaService.DeleteBalitaNIK(nik)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Data balita berhasil dihapus",
		"success": true,
	})
}
func (h *BalitaHandler) UpdateBalita(ctx *gin.Context) {
	var input service.BalitaInput
	id := ctx.Param("id")
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	updatedBalita, err := h.BalitaService.UpdateBalita(id, input)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Data balita berhasil diperbarui",
		"data":    updatedBalita,
	})
}

//  Posyandu Handler ===============================================

func (h *PosyanduHandler) CreatePosyandu(ctx *gin.Context) {
	var input service.PosyanduInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	id := strconv.FormatUint(uint64(input.PuskesmasID), 10)
	_, error_ := h.PuskesmasService.FindPuskesmas(id)
	if error_ != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   "Puskesmas tidak ditemukan",
			"success": false,
		})
		return
	}
	posyandu, err := h.PosyanduService.CreatePosyandu(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    posyandu,
		"success": true,
	})
}

func (h *PosyanduHandler) UpdatePosyandu(ctx *gin.Context) {

	id := ctx.Param("id")

	var input service.PosyanduInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	idPosyandu := strconv.FormatUint(uint64(input.PuskesmasID), 10)
	_, error_ := h.PuskesmasService.FindPuskesmas(idPosyandu)
	if error_ != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   "Puskesmas tidak ada",
			"success": false,
		})
		return
	}
	updatedPosyandu, err := h.PosyanduService.UpdatePosyandu(id, input)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Data posyandu berhasil diperbarui",
		"data":    updatedPosyandu,
	})
}

func (h *PosyanduHandler) GetAllPosyandu(ctx *gin.Context) {
	posyandu, err := h.PosyanduService.GetAllPosyandu()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error":   err.Error(),
			"success": false,
		},
		)
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data posyandu",
		"data":    posyandu,
		"success": true,
	})
}

func (h *PosyanduHandler) FindPosyandu(ctx *gin.Context) {
	id := ctx.Param("id")
	posyandu, err := h.PosyanduService.FindPosyandu(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Data posyandu tidak ditemukan"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil",
		"data":    posyandu,
		"success": true,
	})
}

func (h *PosyanduHandler) DeletePosyandu(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.PosyanduService.DeletePosyandu(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Data posyandu berhasil dihapus",
		"success": true,
	})
}

// Posyandu Handler ===============================================
func (h *PuskesmasHandler) CreatePuskesmas(ctx *gin.Context) {
	var input service.PuskesmasInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	id := strconv.FormatUint(uint64(input.DinasID), 10)
	_, err := h.DinasService.FindDinasKesehatan(id)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   "Dinas Kesehatan dengan ID tersebut tidak ditemukan",
			"success": false,
		})
		return
	}
	puskesmas, err := h.PuskesmasService.CreatePuskesmas(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Puskesmas berhasil ditambahkan",
		"data":    puskesmas,
		"success": true,
	})
}

func (h *PuskesmasHandler) UpdatePuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.PuskesmasInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	idDinas := strconv.FormatUint(uint64(input.DinasID), 10)
	_, err := h.DinasService.FindDinasKesehatan(idDinas)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err,
			"success": false,
		})
		return
	}
	updatedPuskesmas, err := h.PuskesmasService.UpdatePuskesmas(id, input)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Data puskesmas berhasil diperbarui",
		"data":    updatedPuskesmas,
	})
}

func (h *PuskesmasHandler) GetAllPuskesmas(ctx *gin.Context) {
	puskesmas, err := h.PuskesmasService.GetAllPuskesmas()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data puskesmas",
		"data":    puskesmas,
		"success": true,
	})
}

func (h *PuskesmasHandler) FindPuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	puskesmas, err := h.PuskesmasService.FindPuskesmas(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   "Data puskesmas tidak ditemukan",
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil",
		"data":    puskesmas,
		"success": true,
	})
}

func (h *PuskesmasHandler) DeletePuskesmas(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.PuskesmasService.DeletePuskesmas(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Data puskesmas berhasil dihapus",
		"success": true,
	})
}

//  Dinas Kesehatan Handler ===============================================

func (h *DinasKesehatanHandler) CreateDinasKesehatan(ctx *gin.Context) {
	var input service.DinasKesehatanInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	dinas, err := h.DinasKesehatanService.CreateDinasKesehatan(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Dinas Kesehatan berhasil ditambahkan",
		"data":    dinas,
		"success": true,
	})
}

func (h *DinasKesehatanHandler) UpdateDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	var input service.DinasKesehatanInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	updatedDinas, err := h.DinasKesehatanService.UpdateDinasKesehatan(id, input)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Data dinas kesehatan berhasil diperbarui",
		"data":    updatedDinas,
	})
}

func (h *DinasKesehatanHandler) GetAllDinasKesehatan(ctx *gin.Context) {
	dinas, err := h.DinasKesehatanService.GetAllDinasKesehatan()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data dinas kesehatan",
		"data":    dinas,
		"success": true,
	})
}

func (h *DinasKesehatanHandler) FindDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	dinas, err := h.DinasKesehatanService.FindDinasKesehatan(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   "Data dinas kesehatan tidak ditemukan",
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Berhasil",
		"data":    dinas,
		"success": true,
	})
}

func (h *DinasKesehatanHandler) DeleteDinasKesehatan(ctx *gin.Context) {
	id := ctx.Param("id")
	err := h.DinasKesehatanService.DeleteDinasKesehatan(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error":   err.Error(),
			"success": false,
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Data dinas kesehatan berhasil dihapus",
		"success": true,
	})
}
