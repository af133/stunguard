package main

import (
	"github.com/af133/stunguard/internal"
	"github.com/af133/stunguard/internal/routes"
	"github.com/gin-gonic/gin"
)

func main() {
	internal.ConnectDB()
	r := gin.Default()

	routes.SetupRoutes(r)

	r.Run(":8080")
}