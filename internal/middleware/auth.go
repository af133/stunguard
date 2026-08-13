package middleware

import (
    "net/http"
    "strings"

    "github.com/af133/stunguard/internal/utils" 
    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
)

var jwtSecret = []byte("stunguard_super_secret_key_2026")
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: Token tidak ditemukan"})
            c.Abort()
            return
        }
        tokenParts := strings.Split(authHeader, " ")
        if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: Format token salah"})
            c.Abort()
            return
        }
        tokenString := tokenParts[1]
        claims := &utils.JWTClaim{}
        token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
            return jwtSecret, nil
        })
        if err != nil || !token.Valid {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: Token tidak valid atau sudah kedaluwarsa"})
            c.Abort()
            return
        }
        c.Set("currentUser", claims)

        c.Next()
    }
}