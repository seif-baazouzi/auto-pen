package routes

import (
	"hardening/auth"
	"hardening/handlers"

	"github.com/gofiber/fiber/v2"
)

func SetupAdminRoutes(app *fiber.App) {
	app.Post("/admin/login", handlers.AdminLogin)

	app.Patch("/admin/settings/update-username", auth.IsAdmin, handlers.UpdateUsername)
	app.Patch("/admin/settings/update-password", auth.IsAdmin, handlers.UpdatePassword)
}
