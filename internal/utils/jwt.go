package utils

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func getJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "stunguard_super_secret_key_2026"
	}
	return []byte(secret)
}

type JWTClaim struct {
	ID             uint   `json:"id"`
	Email          string `json:"email"`
	Role           string `json:"role"`
	WilayahKerjaID uint   `json:"wilayah_kerja_id"`
	jwt.RegisteredClaims
}
func GenerateToken(id uint, email string, role string, wilayahKerjaID uint) (string, error) {
	claims := JWTClaim{
		ID:             id,
		Email:          email,
		Role:           role,
		WilayahKerjaID: wilayahKerjaID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(getJWTSecret())
	return tokenString, err
}
func GenerateRefreshToken(id uint, email string, role string, wilayahKerjaID uint) (string, error) {
	claims := JWTClaim{
		ID:             id,
		Email:          email,
		Role:           role,
		WilayahKerjaID: wilayahKerjaID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(getJWTSecret())
	return tokenString, err
}

func ParseToken(tokenString string) (*JWTClaim, error) {
	claims := &JWTClaim{}
	_, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return getJWTSecret(), nil
	})
	if err != nil {
		return nil, err
	}
	return claims, nil
}