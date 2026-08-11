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

func NewUserHandler(userService *service.UserService) *UserHandler {
	return &UserHandler{
		UserService: userService,
	}
}
func (h *UserHandler) Register(ctx *gin.Context) {
	var input service.RegisterInput

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.UserService.Register(input)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
		"data":    user,
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
	})
}