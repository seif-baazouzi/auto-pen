package handlers

import (
	"encoding/json"
	"fmt"
	"hardening/auth"
	"hardening/db"
	"hardening/models"
	"hardening/tests"
	"hardening/utils"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jakehl/goid"
)

// @Description login a user
// @Success 200 {object} token
// @router /user/login [post]
func UserLogin(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	var user models.User

	err := c.BodyParser(&user)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckUser(user)

	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT password as hash FROM users WHERE email = $1", user.Email)

	if err != nil {
		return utils.ServerError(c)
	}

	if !rows.Next() {
		return c.JSON(fiber.Map{"email": "This user do not exist"})
	}

	var hash string
	rows.Scan(&hash)

	if !utils.ComparePasswords(user.Password, hash) {
		return c.JSON(fiber.Map{"password": "Wrong password"})
	}

	token := auth.GenerateToken("email", user.Email)
	return c.JSON(fiber.Map{"token": token})
}

// @Description signup a user
// @Success 200 {object} token
// @router /user/signup [post]
func UserSignup(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	var user models.User

	err := c.BodyParser(&user)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "invalid-input"})
	}

	errors := tests.CheckUser(user)

	if errors != nil {
		return c.JSON(errors)
	}

	rows, err := conn.Query("SELECT 1 FROM users WHERE email = $1", user.Email)

	if err != nil {
		return utils.ServerError(c)
	}

	if rows.Next() {
		return c.JSON(fiber.Map{"email": "This email is already taken"})
	}

	hash := utils.Hash(user.Password)
	apikey := goid.NewV4UUID().String()

	_, err = conn.Exec(
		"INSERT INTO users VALUES($1, $2, $3)",
		user.Email,
		hash,
		apikey,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	token := auth.GenerateToken("email", user.Email)
	return c.Status(201).JSON(fiber.Map{"token": token})
}

// @Description get user apikey
// @Success 200 {object} apikey
// @router /user/apikey [get]
func GetApikey(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	email := c.Locals("email")
	rows, err := conn.Query("SELECT apikey FROM users WHERE email = $1", email)

	if err != nil {
		return utils.ServerError(c)
	}

	if rows.Next() {
		var apikey string
		rows.Scan(&apikey)
		return c.JSON(fiber.Map{"apikey": apikey})
	} else {
		return c.JSON(fiber.Map{"message": "user-not-found"})
	}
}

// @Description regenerate user apikey
// @Success 200 {object} apikey
// @router /user/apikey [patch]
func RegenerateApikey(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	email := c.Locals("email")
	apikey := goid.NewV4UUID().String()

	_, err := conn.Exec(
		"UPDATE users SET apikey = $1 WHERE email = $2",
		apikey,
		email,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	return c.JSON(fiber.Map{"apikey": apikey})
}

// @Description get user logs
// @Success 200 {array} Log
// @router /user/logs [get]
func GetLogs(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	page, err := strconv.Atoi(c.Query("page", "1"))

	if err != nil || page < 0 {
		return utils.ServerError(c)
	}

	limit := 20
	offset := 20 * (page - 1)

	email := c.Locals("email")

	row := conn.QueryRow("SELECT count(*) as pages FROM logs WHERE email = $1", email)

	var pages int
	row.Scan(&pages)
	pages = pages/limit + 1

	rows, err := conn.Query(
		"SELECT logID, query, logDate FROM logs WHERE email = $1 ORDER BY logID DESC LIMIT $2 OFFSET $3",
		email,
		limit,
		offset,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	logs := []models.Log{}

	for rows.Next() {
		var log models.Log
		rows.Scan(&log.LogID, &log.Query, &log.LogDate)
		logs = append(logs, log)
	}

	return c.JSON(fiber.Map{"pages": pages, "data": logs})
}

// @Description get user logs
// @Success 200 {array} Log
// @router /user/logs [get]
func GetStatistics(c *fiber.Ctx) error {
	conn := db.GetPool()
	defer db.ClosePool(conn)

	email := c.Locals("email")

	redisClient := db.Redis.Get()
	defer redisClient.Close()

	res, err := redisClient.Do("GET", email)

	if err != nil {
		fmt.Println(err)
		return utils.ServerError(c)
	}

	if res != nil {
		var result interface{}
		resStr := fmt.Sprintf("%s", res)
		json.Unmarshal([]byte(resStr), &result)

		return c.JSON(fiber.Map{"data": result})
	}

	rows, err := conn.Query(
		"SELECT technologie, count(*) as count FROM technologies_log T INNER JOIN logs L ON T.logID = L.logID AND L.email = $1 GROUP BY technologie ORDER BY count DESC",
		email,
	)

	if err != nil {
		return utils.ServerError(c)
	}

	statistics := []models.Statistic{}

	for rows.Next() {
		var statistic models.Statistic
		rows.Scan(&statistic.Technologie, &statistic.Count)
		statistics = append(statistics, statistic)
	}

	jsonResult, err := json.Marshal(statistics)

	if err != nil {
		return utils.ServerError(c)
	}

	redisClient.Do("SET", email, jsonResult, "EX", "60")

	return c.JSON(fiber.Map{"data": statistics})
}
