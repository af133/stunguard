package utils

import (
	"time"

	"github.com/golang-jwt/jwt/v5"
)
var jwtSecret = []byte("stunguard_super_secret_key_2026")
type JWTClaim struct {
	ID   uint   `json:"id"`
	Email  string `json:"email"`
	Role string `json:"role"`
	jwt.RegisteredClaims
}
func GenerateToken(id uint, email string, role string) (string, error) {
	claims := JWTClaim{
		ID:   id,
		Email:  email,
		Role: role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtSecret)
	return tokenString, err
}