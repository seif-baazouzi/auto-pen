package routes

import (
	"hardening/auth"
	"hardening/handlers"

	"github.com/gofiber/fiber/v2"
)

func SetupUserRoutes(app *fiber.App) {
	app.Post("/user/login", handlers.UserLogin)
	app.Post("/user/signup", handlers.UserSignup)

	app.Get("/user/apikey", auth.IsUser, handlers.GetApikey)
	app.Patch("/user/apikey", auth.IsUser, handlers.RegenerateApikey)

	app.Get("/user/logs", auth.IsUser, handlers.GetLogs)
	app.Get("/user/statistics", auth.IsUser, handlers.GetStatistics)
}
