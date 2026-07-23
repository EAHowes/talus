package handlers

import (
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"time"

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


// queries db for alerts and returns json from the table
func (h *Handlers) HandleGetAlerts(w http.ResponseWriter, r *http.Request) {
	rows, err := h.Pool.Query(r.Context(), `SELECT id, route_id, risk_score, summary, triggered_at FROM alert_events ORDER BY triggered_at DESC`)
	if err != nil {
		h.Logger.Error("query failed", "error", err)
		http.Error(w, "database error", http.StatusInternalServerError)
		return
    	}
    	defer rows.Close()

	var events []map[string]interface{}
	for rows.Next() {
		var id, routeID int
		var riskScore float64
		var summary string
		var triggeredAt time.Time
		rows.Scan(&id, &routeID, &riskScore, &summary, &triggeredAt)
		events = append(events, map[string]interface{}{
			"id": 		id,
			"route_id": 	routeID,
			"risk_score": 	riskScore,
			"summary": 	summary,
			"triggered_at": triggeredAt,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(events)
}
