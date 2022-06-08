package handlers

import (
	"fmt"
	"hardening/db"
	"hardening/models"
	"hardening/tests"
	"hardening/utils"
	"net/url"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// @Description Get all technologies
// @Success 200 {array} model.Technologie
// @router /technologies [get]
func GetTechnologies(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	rows, err := conn.Query("SELECT * FROM technologies")

	if err != nil {
		return utils.ServerError(c)
	}

	technologies := []models.Technologie{}

	for rows.Next() {
		var name string
		var hardening string

		rows.Scan(&name, &hardening)
		technologies = append(technologies, models.Technologie{Name: name, Hardening: hardening})
	}

	return c.JSON(fiber.Map{"data": technologies})
}

// @Description query technologies
// @Success 200 {array} model.Technologie
// @router /technologies/:query [get]
func QueryTechnologies(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	query, err := url.QueryUnescape(c.Params("query"))

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	names := strings.Split(query, ",")

	for i := 0; i < len(names); i++ {
		names[i] = strings.ToLower(strings.TrimSpace(names[i]))
	}

	names = utils.GetUniqList(names)

	technologies := []models.Technologie{}

	for _, name := range names {
		row := conn.QueryRow("SELECT * FROM technologies WHERE name = $1", name)

		var name string
		var hardening string

		err := row.Scan(&name, &hardening)

		if err == nil {
			technologies = append(technologies, models.Technologie{Name: name, Hardening: hardening})
		}
	}

	email := c.Locals("email")
	row := conn.QueryRow(
		"INSERT INTO logs (email, query) VALUES ($1, $2) RETURNING logID",
		email,
		query,
	)

	var logID int
	row.Scan(&logID)

	if err != nil {
		fmt.Println(err)
		return utils.ServerError(c)
	}

	for _, tech := range technologies {
		_, err = conn.Exec(
			"INSERT INTO technologies_log (logID, technologie) VALUES ($1, $2)",
			logID,
			tech.Name,
		)

		if err != nil {
			fmt.Println(err)
			return utils.ServerError(c)
		}
	}

	return c.JSON(fiber.Map{"data": technologies})
}

// @Description add a new technologie
// @Success 200 {object} message
// @router /technologies [post]
func CreateTechnologie(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	var technologie models.Technologie

	err := c.BodyParser(&technologie)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckTechnologie(technologie)
	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT * FROM technologies WHERE name = $1", technologie.Name)

	if err != nil {
		return utils.ServerError(c)
	}

	if rows.Next() {
		return c.Status(201).JSON(fiber.Map{"name": "This technologie is already exists"})
	}

	_, err = conn.Exec(
		"INSERT INTO technologies VALUES($1, $2)",
		technologie.Name,
		technologie.Hardening,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	return c.Status(201).JSON(fiber.Map{"message": "success"})
}

// @Description edit a technologie by name
// @Success 200 {object} message
// @router /technologies/:name [put]
func EditTechnologie(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	name, err := url.QueryUnescape(c.Params("name"))

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	var technologie models.Technologie
	err = c.BodyParser(&technologie)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckTechnologie(technologie)
	if errors != nil {
		return c.JSON(errors)
	}

	_, err = conn.Exec(
		"UPDATE technologies SET name = $1, hardening = $2 WHERE name = $3",
		technologie.Name,
		technologie.Hardening,
		name,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	return c.Status(201).JSON(fiber.Map{"message": "success"})
}

// @Description delete all technologies
// @Success 200 {object} message
// @router /technologies [delete]
func DeleteTechnologies(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	_, err := conn.Exec("DELETE FROM technologies")

	if err != nil {
		return utils.ServerError(c)
	}

	return c.JSON(fiber.Map{"message": "success"})
}

// @Description delete one technologie by name
// @Success 200 {object} message
// @router /technologies/:name [delete]
func DeleteTechnologie(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	name, err := url.QueryUnescape(c.Params("name"))

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	_, err = conn.Exec("DELETE FROM technologies WHERE name = $1", name)

	if err != nil {
		return utils.ServerError(c)
	}

	return c.JSON(fiber.Map{"message": "success"})
}
