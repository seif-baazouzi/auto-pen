package handlers

import (
	"hardening/auth"
	"hardening/db"
	"hardening/models"
	"hardening/tests"
	"hardening/utils"

	"github.com/gofiber/fiber/v2"
)

// @Description admin login
// @Success 200 {object} token
// @router /admin/login [post]
func AdminLogin(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	var admin models.Admin

	err := c.BodyParser(&admin)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckAdmin(admin)

	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT password as hash FROM admins WHERE username = $1", admin.Username)

	if err != nil {
		return utils.ServerError(c)
	}

	if !rows.Next() {
		return c.JSON(fiber.Map{"username": "This admin do not exist"})
	}

	var hash string
	rows.Scan(&hash)

	if !utils.ComparePasswords(admin.Password, hash) {
		return c.JSON(fiber.Map{"password": "Wrong password"})
	}

	token := auth.GenerateToken("admin", admin.Username)
	return c.JSON(fiber.Map{"token": token})
}

// @Description update admin password
// @Success 200 {object} message
// @router /admin/settings/update-password [post]
func UpdatePassword(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	admin := c.Locals("admin")

	payload := struct {
		OldPassword string `json:"oldpwd"`
		NewPassword string `json:"newpwd"`
	}{}

	err := c.BodyParser(&payload)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckUpdatePassword(payload.OldPassword, payload.NewPassword)

	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT password as hash FROM admins WHERE username = $1", admin)

	if err != nil {
		return utils.ServerError(c)
	}

	if !rows.Next() {
		return c.JSON(fiber.Map{"username": "This admin do not exist"})
	}

	var hash string
	rows.Scan(&hash)

	if !utils.ComparePasswords(payload.OldPassword, hash) {
		return c.JSON(fiber.Map{"oldpwd": "Wrong password"})
	}

	if payload.OldPassword == payload.NewPassword {
		return c.JSON(fiber.Map{"newpwd": "Must not be the same"})
	}

	newPasswordHash := utils.Hash(payload.NewPassword)

	_, err = conn.Exec("UPDATE admins SET password = $1 WHERE username = $2", newPasswordHash, admin)

	if err != nil {
		return utils.ServerError(c)
	}

	return c.JSON(fiber.Map{"message": "success"})
}

// @Description update admin password
// @Success 200 {object} message
// @router /admin/settings/update-username [post]
func UpdateUsername(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	oldUsername := c.Locals("admin")

	var admin models.Admin

	err := c.BodyParser(&admin)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckAdmin(admin)

	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT password as hash FROM admins WHERE username = $1", oldUsername)

	if err != nil {
		return utils.ServerError(c)
	}

	if !rows.Next() {
		return c.JSON(fiber.Map{"username": "This admin do not exist"})
	}

	var hash string
	rows.Scan(&hash)

	if !utils.ComparePasswords(admin.Password, hash) {
		return c.JSON(fiber.Map{"password": "Wrong password"})
	}

	if admin.Username == oldUsername {
		return c.JSON(fiber.Map{"username": "Must not be the same as the old one"})
	}

	_, err = conn.Exec("UPDATE admins SET username = $1 WHERE username = $2", admin.Username, oldUsername)

	if err != nil {
		return utils.ServerError(c)
	}

	newToken := auth.GenerateToken("admin", admin.Username)

	return c.JSON(fiber.Map{"token": newToken})
}
