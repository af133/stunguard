package routes

import (
	"github.com/af133/stunguard/internal/handlers"
	"github.com/af133/stunguard/internal/middleware"
	"github.com/af133/stunguard/internal/repositories"
	"github.com/af133/stunguard/internal/service"
	"github.com/gin-gonic/gin"
)

func AuthRoutes(r *gin.Engine) {
	userRepo := repositories.NewUserRepository()
	userService := service.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userService)

	api := r.Group("/api/auth")
	{
		api.POST("/register", userHandler.Register)
		api.POST("/login", userHandler.Login)
		api.POST("/login/petugas", userHandler.LoginPetugas)
		api.POST("/refresh", userHandler.RefreshToken)
		api.POST("/forgot-password", userHandler.ForgotPassword)
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
			authenticated.GET("/balita/:id/riwayat", balitaHandler.GetRiwayat)
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
		api.GET("/get-all", posyanduHandler.GetAllPosyandu)
		authenticated := api.Group("/")
		authenticated.Use(middleware.AuthMiddleware())
		{
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

func KaderRoute(r *gin.Engine) {
	kaderRepo := repositories.NewKaderRepository()
	kaderService := service.NewKaderService(kaderRepo)
	kaderHandler := handlers.NewKaderHandler(kaderService)

	api := r.Group("/api/v1/kader")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/get-all", kaderHandler.GetAllKader)
		api.POST("/create", kaderHandler.CreateKader)
		api.GET("/:id", kaderHandler.FindKader)
		api.PUT("/:id/update", kaderHandler.UpdateKader)
		api.PUT("/:id/validate", middleware.RBACMiddleware("petugas_puskesmas", "admin_dinas"), kaderHandler.ValidateKader)
	}
}

func PengukuranRoute(r *gin.Engine) {
	pengukuranRepo := repositories.NewPengukuranRepository()
	pengukuranService := service.NewPengukuranService(pengukuranRepo)
	pengukuranHandler := handlers.NewPengukuranHandler(pengukuranService)

	api := r.Group("/api/v1/pengukuran")
	api.Use(middleware.AuthMiddleware())
	{
		api.POST("/create", pengukuranHandler.Create)
		api.GET("/balita/:balita_id", pengukuranHandler.GetByBalitaID)
		api.PUT("/:id/update", pengukuranHandler.Update)
		api.DELETE("/:id/delete", pengukuranHandler.Delete)
	}
}

func SyncRoute(r *gin.Engine) {
	balitaRepo := repositories.NewBalitaRepository()
	pengukuranRepo := repositories.NewPengukuranRepository()
	hasilDeteksiRepo := repositories.NewHasilDeteksiRepository()
	logNutrisiRepo := repositories.NewLogNutrisiRepository()
	alertRepo := repositories.NewAlertRepository()
	posyanduRepo := repositories.NewPosyanduRepository()

	syncService := service.NewSyncService(balitaRepo, pengukuranRepo, hasilDeteksiRepo, logNutrisiRepo, alertRepo, posyanduRepo)
	syncHandler := handlers.NewSyncHandler(syncService)

	api := r.Group("/api/v1/sync")
	api.Use(middleware.AuthMiddleware())
	{
		api.POST("/push", syncHandler.Push)
		api.GET("/pull", syncHandler.Pull)
	}
}

func DashboardRoute(r *gin.Engine) {
	balitaRepo := repositories.NewBalitaRepository()
	hasilDeteksiRepo := repositories.NewHasilDeteksiRepository()
	posyanduRepo := repositories.NewPosyanduRepository()

	dashboardService := service.NewDashboardService(balitaRepo, hasilDeteksiRepo, posyanduRepo)
	dashboardHandler := handlers.NewDashboardHandler(dashboardService)

	api := r.Group("/api/v1/dashboard")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/summary", dashboardHandler.GetSummary)
		api.GET("/heatmap", dashboardHandler.GetHeatmap)
	}
}

func AnalitikRoute(r *gin.Engine) {
	hasilDeteksiRepo := repositories.NewHasilDeteksiRepository()
	analitikService := service.NewAnalitikService(hasilDeteksiRepo)
	analitikHandler := handlers.NewAnalitikHandler(analitikService)

	api := r.Group("/api/v1/analitik")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/tren", analitikHandler.GetTrend)
		api.GET("/proyeksi", analitikHandler.GetProyeksi)
	}
}

func LaporanRoute(r *gin.Engine) {
	laporanRepo := repositories.NewLaporanJobRepository()
	laporanService := service.NewLaporanService(laporanRepo)
	laporanHandler := handlers.NewLaporanHandler(laporanService)

	api := r.Group("/api/v1/laporan")
	api.Use(middleware.AuthMiddleware())
	{
		api.POST("/generate", laporanHandler.Generate)
		api.GET("/status/:jobId", laporanHandler.GetStatus)
	}
}

func AlertRoute(r *gin.Engine) {
	alertRepo := repositories.NewAlertRepository()
	alertService := service.NewAlertService(alertRepo)
	alertHandler := handlers.NewAlertHandler(alertService)

	api := r.Group("/api/v1/alert")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/", alertHandler.GetAlerts)
		api.POST("/:id/read", alertHandler.MarkAsRead)
	}
}
