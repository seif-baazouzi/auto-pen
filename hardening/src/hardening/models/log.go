package models

import "time"

type Log struct {
	LogID   int       `json:"logID"`
	Query   string    `json:"query"`
	LogDate time.Time `json:"logDate"`
}

type Statistic struct {
	Technologie string `json:"technologie"`
	Count       int    `json:"count"`
}
