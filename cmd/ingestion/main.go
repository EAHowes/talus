// S1 main file

package main

import (
	"encoding/json"
	"log"
	"log/slog"
	"net/http"
	"os"

	"github.com/eahowes/talus/internal/config"
	"github.com/eahowes/talus/internal/telemetry"
	"github.com/eahowes/talus/internal/store"

)


func main() {

	// load config
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	// init logger
	logger := telemetry.NewLogger(cfg.LogLevel)
	logger.Info("starting ingestion service")

	// connect to db
	pool, err := store.Connect(cfg)
	if err != nil {
		logger.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	// run migrations
	err = store.RunMigrations(pool, "db/migrations")
	if err != nil {
		logger.Error("failed to run migrations", "error", err)
		os.Exit(1)
	}
	logger.Info("migrations complete")

	// start HTTP server
	http.HandleFunc("/dem", handleDem(pool, logger, cfg))
	http.HandleFunc("/routes", handleRoutes(pool, logger, cfg))
	http.HandleFunc("/geology", handleGeology(pool, logger, cfg))

	logger.Info("terrain service lisening", "port", cfg.S1ListenPort)
	err = http.ListenAndServe(":"+cfg.S1ListenPort, nil)
	if err != nil {
		logger.Error("server failed", "error", err)
		os.Exit(1)
	}
}
