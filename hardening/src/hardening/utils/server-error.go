package utils

import "github.com/gofiber/fiber/v2"

func ServerError(c *fiber.Ctx) error {
	return c.Status(500).JSON(fiber.Map{"message": "server-error"})
}
