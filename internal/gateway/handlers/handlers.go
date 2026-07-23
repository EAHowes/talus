package handlers

import (
	"io"
	"log/slog"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/ethan-howes/talus/internal/config"
)


type Handlers struct {
	Pool   *pgxpool.Pool
    	Logger *slog.Logger
    	Cfg    *config.Config
}


// /dem to s1
func (h *Handlers) HandleDem(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Post(h.Cfg.S1IngestionEndpoint+"/dem", "application/json", r.Body)
	if err != nil {
		h.Logger.Error("service 1 unavailable", "error", err)
		http.Error(w, "upstream service unavailable", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}


// /routes to s1
func (h *Handlers) HandleRoutes(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Post(h.Cfg.S1IngestionEndpoint+"/routes", "application/json", r.Body)
	if err != nil {
		h.Logger.Error("service 1 unavailable", "error", err)
		http.Error(w, "upstream service unavailable", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}


// /analyze to s4
func (h *Handlers) HandleAnalyze(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Post(h.Cfg.S4HazardEndpoint+"/analyze", "application/json", r.Body)
	if err != nil {
		h.Logger.Error("service 4 unavailable", "error", err)
		http.Error(w, "upstream service unavailable", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}
