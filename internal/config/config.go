package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	PostgresHost     	string
	PostgresPort     	int
	PostgresDB       	string
	PostgresUser     	string
	PostgresPassword 	string
	PostgresSSLMode  	string
	LogLevel 	 	string
	S2ListenPort 	 	string
	CudaTerrainBinaryPath 	string
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

	logLevel := os.Getenv("LOG_LEVEL")
	if logLevel == "" {
		logLevel = "info"
	}

	s2Port := os.Getenv("S2_LISTEN_PORT")
	if s2Port == "" {
		return nil, fmt.Errorf("S2_LISTEN_PORT is required but not set")
	}

	cudaBinary := os.Getenv("CUDA_TERRAIN_BINARY_PATH")
	if cudaBinary == "" {
		return nil, fmt.Errorf("CUDA_TERRAIN_BINARY_PATH is required but not set")
	}

	return &Config {
		PostgresHost:    	host,
		PostgresPort:    	port,
		PostgresDB:      	db,
		PostgresUser:    	user,
		PostgresPassword: 	password,
		PostgresSSLMode: 	sslmode,
		LogLevel: 	 	logLevel,
		S2ListenPort: 	 	s2Port,
		CudaTerrainBinaryPath: 	cudaBinary,
	}, nil
}
