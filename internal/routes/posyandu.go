package routes

import (
    "github.com/af133/stunguard/internal/handlers"
    "github.com/af133/stunguard/internal/middleware" 
    "github.com/af133/stunguard/internal/repositories"
    "github.com/af133/stunguard/internal/service"
    "github.com/gin-gonic/gin"
)

func RegisterOrLoginPosyanduRoutes(r *gin.Engine) {
    userRepo := repositories.NewUserRepository()
    userService := service.NewUserService(userRepo)
    userHandler := handlers.NewUserHandler(userService)
    
    api := r.Group("/api")
    {
        api.POST("/register", userHandler.Register)
        api.POST("/login/petugas", userHandler.LoginPetugas)
    }
}

func BalitaRoute(r *gin.Engine) {
    balitaRepo := repositories.NewBalitaRepository()
    balitaService := service.NewBalitaService(balitaRepo)
    balitaHandler := handlers.NewBalitaHandler(balitaService)

    api := r.Group("/api/v1")
    {
        authenticated := api.Group("/")
        authenticated.Use(middleware.AuthMiddleware()) 
        {
            authenticated.GET("/balita", balitaHandler.GetAllBalita)
            authenticated.POST("/balita/create", balitaHandler.CreateBalita)
			authenticated.GET("/balita/:nik", balitaHandler.FindBalitaNIK)
			authenticated.DELETE("/balita/:nik", balitaHandler.DeleteBalita)
            authenticated.PUT("/balita/:id/update", balitaHandler.UpdateBalita)
        }
    }
}