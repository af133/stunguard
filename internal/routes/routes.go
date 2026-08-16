package routes

import (
    "time"
    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
    r.Use(cors.New(cors.Config{
        AllowAllOrigins:  true,
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
    
    BalitaRoute(r)
    RegisterOrLoginPosyanduRoutes(r)
    PosyanduRoute(r)
    DinasKesehatanRoute(r)
    PuskesmasRoute(r)
}