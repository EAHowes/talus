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
