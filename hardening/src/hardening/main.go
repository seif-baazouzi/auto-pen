package main

import (
	"hardening/db"
	"hardening/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func main() {
	app := fiber.New()
	app.Use(cors.New())

	db.Init()
	defer db.Close()

	db.InitRedis()
	defer db.Redis.Close()

	routes.SetupUserRoutes(app)
	routes.SetupAdminRoutes(app)
	routes.SetupTechnologiesRoutes(app)

	app.Listen(":5000")
}
