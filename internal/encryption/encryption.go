package encryption

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"io"
	"os"
	"sync"
)

var (
	aesKey  []byte
	once    sync.Once
	initErr error
)

// initKey loads the AES-256 key from env var (32 bytes = 64 hex chars)
func initKey() {
	once.Do(func() {
		keyHex := os.Getenv("AES_KEY")
		if keyHex == "" {
			// Fallback for development — NEVER use in production
			keyHex = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
		}
		var err error
		aesKey, err = hex.DecodeString(keyHex)
		if err != nil {
			initErr = errors.New("AES_KEY harus berupa hex string yang valid (64 karakter untuk AES-256)")
			return
		}
		if len(aesKey) != 32 {
			initErr = errors.New("AES_KEY harus 32 bytes (64 hex karakter) untuk AES-256")
			return
		}
	})
}

// Encrypt encrypts plaintext using AES-256-GCM
// Returns hex-encoded ciphertext (nonce prepended)
func Encrypt(plaintext string) (string, error) {
	if plaintext == "" {
		return "", nil
	}

	initKey()
	if initErr != nil {
		return "", initErr
	}

	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return "", err
	}

	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonce := make([]byte, aesGCM.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}

	ciphertext := aesGCM.Seal(nonce, nonce, []byte(plaintext), nil)
	return hex.EncodeToString(ciphertext), nil
}

// Decrypt decrypts hex-encoded ciphertext using AES-256-GCM
func Decrypt(ciphertextHex string) (string, error) {
	if ciphertextHex == "" {
		return "", nil
	}

	initKey()
	if initErr != nil {
		return "", initErr
	}

	ciphertext, err := hex.DecodeString(ciphertextHex)
	if err != nil {
		return "", errors.New("ciphertext bukan format hex yang valid")
	}

	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return "", err
	}

	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonceSize := aesGCM.NonceSize()
	if len(ciphertext) < nonceSize {
		return "", errors.New("ciphertext terlalu pendek")
	}

	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]
	plaintext, err := aesGCM.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", errors.New("gagal mendekripsi data")
	}

	return string(plaintext), nil
}
