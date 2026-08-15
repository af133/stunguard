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
func PosyanduRoute(r *gin.Engine) {
    posyanduRepo := repositories.NewPosyanduRepository()
    posyanduService := service.NewPosyanduService(posyanduRepo)
    puskesmasRepo := repositories.NewPuskesmasRepository()
    puskesmasService := service.NewPuskesmasService(puskesmasRepo)
    posyanduHandler := &handlers.PosyanduHandler{
        PosyanduService:  posyanduService,
        PuskesmasService: puskesmasService,
    }

    api := r.Group("/api/v1/posyandu")
    {
        authenticated := api.Group("/")
        authenticated.Use(middleware.AuthMiddleware())
        {
            authenticated.GET("/get-all", posyanduHandler.GetAllPosyandu)
            authenticated.POST("/create", posyanduHandler.CreatePosyandu)
            authenticated.GET("/:id", posyanduHandler.FindPosyandu)
            authenticated.PUT("/:id/update", posyanduHandler.UpdatePosyandu)
            authenticated.DELETE("/:id/delete", posyanduHandler.DeletePosyandu)
        }
    }
}
func PuskesmasRoute(r *gin.Engine) {
    PuskesmasRepo := repositories.NewPuskesmasRepository()
    PuskesmasServices := service.NewPuskesmasService(PuskesmasRepo)
    dinasRepo := repositories.NewDinasKesehatanRepository()
    dinasServices := service.NewDinasKesehatanService(dinasRepo)
    puskesmasHandler := &handlers.PuskesmasHandler{
        PuskesmasService: PuskesmasServices,
        DinasService:     dinasServices, 
    }

    api := r.Group("/api/v1/puskesmas")
    {
        authenticated := api.Group("/")
        authenticated.Use(middleware.AuthMiddleware())
        {
            authenticated.GET("/get-all", puskesmasHandler.GetAllPuskesmas)
            authenticated.POST("/create", puskesmasHandler.CreatePuskesmas)
            authenticated.GET("/:id", puskesmasHandler.FindPuskesmas)
            authenticated.PUT("/:id/update", puskesmasHandler.UpdatePuskesmas)
            authenticated.DELETE("/:id/delete", puskesmasHandler.DeletePuskesmas)
        }
    }
}

func DinasKesehatanRoute(r *gin.Engine) {
	dinasRepo := repositories.NewDinasKesehatanRepository()
	dinasServices := service.NewDinasKesehatanService(dinasRepo)
	dinasHandler := handlers.NewDinasKesehatanHandler(dinasServices)
	api := r.Group("/api/v1/dinas-kesehatan")
	{
		authenticated := api.Group("/")
		authenticated.Use(middleware.AuthMiddleware())
		{
			authenticated.GET("/get-all", dinasHandler.GetAllDinasKesehatan)
			authenticated.POST("/create", dinasHandler.CreateDinasKesehatan)
			authenticated.GET("/:id", dinasHandler.FindDinasKesehatan)
			authenticated.PUT("/:id/update", dinasHandler.UpdateDinasKesehatan)
			authenticated.DELETE("/:id/delete", dinasHandler.DeleteDinasKesehatan)
		}
	}
}
