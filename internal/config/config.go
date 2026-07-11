package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
    PostgresHost     string
    PostgresPort     int
    PostgresDB       string
    PostgresUser     string
    PostgresPassword string
    PostgresSSLMode  string
}

func Load() (*Config, error) {

	host := os.Getenv("POSTGRES_HOST")
	if host == "" {
		return nil, fmt.Errorf("POSTGRES_HOST is required but not set")
	}

	db := os.Getenv("POSTGRES_DB")
	if db == "" {
		return nil, fmt.Errorf("POSTGRES_DB is required but not set")
	}

	user := os.Getenv("POSTGRES_USER")
	if user == "" {
		return nil, fmt.Errorf("POSTGRES_USER is required but not set")
	}

	password := os.Getenv("POSTGRES_PASSWORD")
	if password == "" {
		return nil, fmt.Errorf("POSTGRES_PASSWORD is required but not set")
	}

	sslmode := os.Getenv("POSTGRES_SSLMODE")
	if sslmode == "" {
		return nil, fmt.Errorf("POSTGRES_SSLMODE is required but not set")
	}

	portStr := os.Getenv("POSTGRES_PORT")
	port, err := strconv.Atoi(portStr)
	if err != nil {
    		return nil, fmt.Errorf("POSTGRES_PORT must be a number: %w", err)
	}

	return &Config {
		PostgresHost:    host,
		PostgresPort:    port,
		PostgresDB:      db,
		PostgresUser:    user,
		PostgresPassword:password,
		PostgresSSLMode: sslmode,
	}, nil
}
