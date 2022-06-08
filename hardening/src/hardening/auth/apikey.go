package auth

import (
	"hardening/db"
	"hardening/utils"

	"github.com/gofiber/fiber/v2"
)

func IsValidApikey(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	apikey := c.Get("X-Apikey")

	if apikey == "" {
		return c.JSON(fiber.Map{"message": "invalid-apikey"})
	}

	rows, err := conn.Query("SELECT email FROM users WHERE apikey = $1", apikey)

	if err != nil {
		return utils.ServerError(c)
	}

	if !rows.Next() {
		return c.JSON(fiber.Map{"message": "invalid-apikey"})
	}

	var email string
	rows.Scan(&email)
	c.Locals("email", email)

	return c.Next()
}
