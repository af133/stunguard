package middleware

import (
	"strings"

	"github.com/af133/stunguard/internal/utils"
	"github.com/af133/stunguard/pkg/response"
	"github.com/gin-gonic/gin"
)
// AuthMiddleware validates JWT tokens from the Authorization header
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			response.Unauthorized(c, "Token tidak ditemukan")
			c.Abort()
			return
		}
		tokenParts := strings.Split(authHeader, " ")
		if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
			response.Unauthorized(c, "Format token salah, gunakan: Bearer <token>")
			c.Abort()
			return
		}

		claims, err := utils.ParseToken(tokenParts[1])
		if err != nil {
			response.Unauthorized(c, "Token tidak valid atau sudah kedaluwarsa")
			c.Abort()
			return
		}

		c.Set("currentUser", claims)
		c.Set("userID", claims.ID)
		c.Set("userRole", claims.Role)
		c.Set("userWilayahKerjaID", claims.WilayahKerjaID)

		c.Next()
	}
}

// RBACMiddleware restricts access to specified roles
func RBACMiddleware(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		role, exists := c.Get("userRole")
		if !exists {
			response.Unauthorized(c, "Informasi role tidak ditemukan")
			c.Abort()
			return
		}

		roleStr, ok := role.(string)
		if !ok {
			response.InternalError(c, "Format role tidak valid")
			c.Abort()
			return
		}

		for _, allowed := range allowedRoles {
			if roleStr == allowed {
				c.Next()
				return
			}
		}

		response.Forbidden(c, "Anda tidak memiliki akses ke resource ini. Role yang diizinkan: "+strings.Join(allowedRoles, ", "))
		c.Abort()
	}
}