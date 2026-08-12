package routes

import (
	"github.com/af133/stunguard/internal/handlers"
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
func BalitaRoute( r *gin.Engine){
	balitaRepo := repositories.NewBalitaRepository();
	balitaService := service.NewBalitaService(balitaRepo);
	balitaHandler := handlers.NewBalitaHandler(balitaService);
	api := r.Group("/api")
	{
		api.GET("/balita",balitaHandler.GetAllBalita);
	}
}