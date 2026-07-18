package main

import (
	"log"
	"net/http"
	"os"

	"github.com/eahowes/talus/internal/config"
	"github.com/eahowes/talus/internal/store"
	"github.com/eahowes/talus/internal/telemetry"
)

func main() {

	// load config
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	// init logger
	logger := telemetry.NewLogger(cfg.LogLevel)
	logger.Info("starting terrain service")

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

	// start an HTTP server to listen to service 1
	http.HandleFunc("/tile", handleTile(pool, logger, cfg))
	logger.Info("terrain service lisening", "port", cfg.S2ListenPort)
	err = http.ListenAndServe(":"+cfg.S2ListenPort, nil)
	if err != nil {
		logger.Error("server failed", "error", err)
		os.Exit(1)
	}
}
