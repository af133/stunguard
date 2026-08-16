package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// ErrorDetail represents the error object in the envelope
type ErrorDetail struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// Envelope is the standard API response format (§7 agent.md)
type Envelope struct {
	Success bool         `json:"success"`
	Data    interface{}  `json:"data"`
	Error   *ErrorDetail `json:"error"`
}

// Success sends a successful response with data
func Success(c *gin.Context, statusCode int, data interface{}) {
	c.JSON(statusCode, Envelope{
		Success: true,
		Data:    data,
		Error:   nil,
	})
}

// Error sends an error response
func Error(c *gin.Context, statusCode int, code string, message string) {
	c.JSON(statusCode, Envelope{
		Success: false,
		Data:    nil,
		Error: &ErrorDetail{
			Code:    code,
			Message: message,
		},
	})
}

// Common error helpers

func BadRequest(c *gin.Context, message string) {
	Error(c, http.StatusBadRequest, "BAD_REQUEST", message)
}

func ValidationError(c *gin.Context, message string) {
	Error(c, http.StatusBadRequest, "VALIDATION_ERROR", message)
}

func Unauthorized(c *gin.Context, message string) {
	Error(c, http.StatusUnauthorized, "UNAUTHORIZED", message)
}

func Forbidden(c *gin.Context, message string) {
	Error(c, http.StatusForbidden, "FORBIDDEN", message)
}

func NotFound(c *gin.Context, message string) {
	Error(c, http.StatusNotFound, "NOT_FOUND", message)
}

func InternalError(c *gin.Context, message string) {
	Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", message)
}

func Conflict(c *gin.Context, message string) {
	Error(c, http.StatusConflict, "CONFLICT", message)
}
