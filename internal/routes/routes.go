package routes

import (
    "time"
    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
    r.Use(cors.New(cors.Config{
        AllowOriginFunc: func(origin string) bool {
            return true
        },
        AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
        MaxAge:           12 * time.Hour,
    }))

    r.GET("/", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": "Hello StunGuard",
        })
    })
    
    AuthRoutes(r)
    BalitaRoute(r)
    PosyanduRoute(r)
    DinasKesehatanRoute(r)
    PuskesmasRoute(r)
    KaderRoute(r)
    PengukuranRoute(r)
    SyncRoute(r)
    DashboardRoute(r)
    AnalitikRoute(r)
    LaporanRoute(r)
    AlertRoute(r)
}