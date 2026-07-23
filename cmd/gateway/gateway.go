package main

import (
	"log"
	"net/http"
	"os"

	"github.com/ethan-howes/talus/internal/config"
	"github.com/ethan-howes/talus/internal/gateway/handlers"
	"github.com/ethan-howes/talus/internal/gateway/middleware"
	"github.com/ethan-howes/talus/internal/store"
	"github.com/ethan-howes/talus/internal/telemetry"
)

func main() {
	// load config
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	// init logger
	logger := telemetry.NewLogger(cfg.LogLevel)
	logger.Info("starting gateway service")

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

	// register handlers
	h := &handlers.Handlers{Pool: pool, Logger: logger, Cfg: cfg}

	mux := http.NewServeMux()
	mux.HandleFunc("/dem", h.HandleDem)
	mux.HandleFunc("/routes", h.HandleRoutes)
	mux.HandleFunc("/analyze", h.HandleAnalyze)
	mux.HandleFunc("/routes/1/risk", h.HandleGetRouteRisk)
	mux.HandleFunc("/freeze-thaw", h.HandleGetFreezeThaw)
	mux.HandleFunc("/terrain/metrics", h.HandleGetTerrainMetrics)
	mux.HandleFunc("/alerts/config", h.HandlePostAlertConfig)
	mux.HandleFunc("/alerts", h.HandleGetAlerts)

	mux.Handle("/", http.FileServer(http.Dir(cfg.WebStaticDir)))
	logged := middleware.Logging(logger, mux)

	logger.Info("gateway service listening", "port", cfg.S5ListenPort)
	err = http.ListenAndServe(":"+cfg.S5ListenPort, logged)
	if err != nil {
		logger.Error("server failed", "error", err)
		os.Exit(1)
		return
	}
}
