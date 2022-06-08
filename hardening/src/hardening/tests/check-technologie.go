package tests

import (
	"hardening/models"
	"net/url"

	"github.com/gofiber/fiber/v2"
)

func isValidUrl(u string) bool {
	_, err := url.ParseRequestURI(u)
	return err == nil
}

func CheckTechnologie(technologie models.Technologie) fiber.Map {
	errors := make(fiber.Map)

	if technologie.Name == "" {
		errors["name"] = "Must not be empty"
	}

	if technologie.Hardening == "" {
		errors["hardening"] = "Must not be empty"
	}

	if len(errors) != 0 {
		return errors
	}

	return nil
}
