.PHONY: help up down build rebuild logs logs-backend logs-frontend logs-tunnel \
        shell-backend shell-frontend shell-tunnel clean clean-all dev dev-backend dev-frontend \
        stop ps backup restore tunnel-restart tunnel-status

COMPOSE ?= docker compose

help:
	@echo "Drop Go Files - Available Commands"
	@echo ""
	@echo "=== Docker Commands ==="
	@echo "  make up            - Start all services (build if needed)"
	@echo "  make down          - Stop and remove all services"
	@echo "  make build         - Build all Docker images"
	@echo "  make rebuild       - Force rebuild all images and restart"
	@echo "  make stop          - Stop services without removing"
	@echo "  make ps            - Show running containers"
	@echo ""
	@echo "=== Logs ==="
	@echo "  make logs          - Follow logs from all services"
	@echo "  make logs-backend  - Follow backend logs only"
	@echo "  make logs-frontend - Follow frontend logs only"
	@echo "  make logs-tunnel   - Follow Cloudflare Tunnel logs only"
	@echo ""
	@echo "=== Shell Access ==="
	@echo "  make shell-backend  - Open shell in backend container"
	@echo "  make shell-frontend - Open shell in frontend container"
	@echo "  make shell-tunnel   - Open shell in cloudflared container"
	@echo ""
	@echo "=== Tunnel ==="
	@echo "  make tunnel-status  - Show tunnel container status"
	@echo "  make tunnel-restart - Restart tunnel container"
	@echo ""
	@echo "=== Data Management ==="
	@echo "  make backup        - Backup uploads to backup.tar.gz"
	@echo "  make restore       - Restore uploads from backup.tar.gz"
	@echo ""
	@echo "=== Development ==="
	@echo "  make dev           - Run both services locally (no Docker)"
	@echo "  make dev-backend   - Run backend locally"
	@echo "  make dev-frontend  - Run frontend locally"
	@echo ""
	@echo "=== Cleanup ==="
	@echo "  make clean         - Remove containers, images (keeps uploads)"
	@echo "  make clean-all     - Remove everything including uploads"

# ============ Docker Commands ============

up:
	$(COMPOSE) up -d
	@echo ""
	@echo "Services started!"
	@echo "If ports are exposed: http://localhost:8080"
	@echo "If using Cloudflare Tunnel: https://go.odatly.uz"

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

rebuild:
	$(COMPOSE) down
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d
	@echo ""
	@echo "Services rebuilt and started!"
	@echo "If ports are exposed: http://localhost:8080"
	@echo "If using Cloudflare Tunnel: https://go.odatly.uz"

stop:
	$(COMPOSE) stop

ps:
	$(COMPOSE) ps

# ============ Logs ============

logs:
	$(COMPOSE) logs -f

logs-backend:
	$(COMPOSE) logs -f backend

logs-frontend:
	$(COMPOSE) logs -f frontend

logs-tunnel:
	$(COMPOSE) logs -f cloudflared

# ============ Shell Access ============

shell-backend:
	$(COMPOSE) exec backend sh

shell-frontend:
	$(COMPOSE) exec frontend sh

shell-tunnel:
	$(COMPOSE) exec cloudflared sh

# ============ Tunnel Helpers ============

tunnel-status:
	$(COMPOSE) ps cloudflared

tunnel-restart:
	$(COMPOSE) restart cloudflared
	@echo "Tunnel restarted."

# ============ Development (Local) ============

dev:
	@echo "Starting backend and frontend locally..."
	@echo "Backend: http://localhost:1080"
	@echo "Frontend: http://localhost:8080"
	@make -j2 dev-backend dev-frontend

dev-backend:
	cd backend && go run cmd/server/main.go

dev-frontend:
	cd frontend && npm run dev

# ============ Data Management ============

backup:
	@echo "Creating backup of uploads..."
	tar -czvf backup.tar.gz -C data uploads
	@echo "Backup saved to backup.tar.gz"

restore:
	@if [ -f backup.tar.gz ]; then \
		echo "Restoring uploads from backup..."; \
		mkdir -p data; \
		tar -xzvf backup.tar.gz -C data; \
		echo "Restore complete!"; \
	else \
		echo "Error: backup.tar.gz not found"; \
		exit 1; \
	fi

# ============ Cleanup ============

clean:
	$(COMPOSE) down --rmi all
	@echo "Cleaned up containers and images (uploads preserved in ./data/uploads)"

clean-all:
	$(COMPOSE) down --rmi all
	rm -rf data/uploads/*
	@echo "Cleaned up everything including uploads"
