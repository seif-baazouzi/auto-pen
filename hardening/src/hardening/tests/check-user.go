package tests

import (
	"hardening/models"
	"net/mail"

	"github.com/gofiber/fiber/v2"
)

func isValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

func CheckUser(user models.User) fiber.Map {
	errors := make(fiber.Map)

	if user.Email == "" {
		errors["email"] = "Must not be empty"
	} else if !isValidEmail(user.Email) {
		errors["email"] = "Must be a valid email address"
	}

	if user.Password == "" {
		errors["password"] = "Must not be empty"
	}

	if len(errors) != 0 {
		return errors
	}

	return nil
}
