package handlers

import (
	"net/http"

	"github.com/af133/stunguard/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/af133/stunguard/internal/utils"
)

type UserHandler struct {
	UserService *service.UserService
}

type BalitaHandler struct {
    BalitaService *service.BalitaService
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
func (h *UserHandler) Register(ctx *gin.Context) {
	var input service.RegisterInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"success":false,
		})
		return
	}

	user, err := h.UserService.Register(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"success":false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    user,
		"success":true,
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
	token, err := utils.GenerateToken(user.ID, user.NIK, user.Role)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghasilkan token"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil",
		"token":   token,
		"data":    user,
		"success":true,
	})
}

func (h *BalitaHandler) GetAllBalita(ctx *gin.Context) {
    balita, err := h.BalitaService.GetAllBalita()
    if err != nil {
        ctx.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
			"success":false,
			},
		)
        return
    }

    ctx.JSON(http.StatusOK, gin.H{
        "message": "Berhasil mengambil data balita",
        "data":    balita,
		"success":true,
    })
}
func (h *BalitaHandler)  CreateBalita(ctx *gin.Context){
	var input service.BalitaInput
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"success":false,
		})
		return
	}
	balita, err := h.BalitaService.CreateBalita(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"success":false,
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    balita,
		"success":true,
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
    updatedBalita, err := h.BalitaService.UpdateBalita(id,input)
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