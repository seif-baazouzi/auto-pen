package routes

import (
	"hardening/auth"
	"hardening/handlers"

	"github.com/gofiber/fiber/v2"
)

func SetupTechnologiesRoutes(app *fiber.App) {
	app.Get("/technologies", auth.IsAdmin, handlers.GetTechnologies)
	app.Get("/technologies/:query", auth.IsValidApikey, handlers.QueryTechnologies)
	app.Post("/technologies", auth.IsAdmin, handlers.CreateTechnologie)
	app.Put("/technologies/:name", auth.IsAdmin, handlers.EditTechnologie)
	app.Delete("/technologies", auth.IsAdmin, handlers.DeleteTechnologies)
	app.Delete("/technologies/:name", auth.IsAdmin, handlers.DeleteTechnologie)
}
