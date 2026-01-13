.PHONY: help up down build rebuild logs logs-backend logs-frontend shell-backend shell-frontend clean dev dev-backend dev-frontend stop ps backup restore

# Default target
help:
	@echo "Drop Go Files - Available Commands"
	@echo ""
	@echo "=== Docker Commands ==="
	@echo "  make up          - Start all services (build if needed)"
	@echo "  make down        - Stop and remove all services"
	@echo "  make build       - Build all Docker images"
	@echo "  make rebuild     - Force rebuild all images and restart"
	@echo "  make stop        - Stop services without removing"
	@echo "  make ps          - Show running containers"
	@echo ""
	@echo "=== Logs ==="
	@echo "  make logs        - Follow logs from all services"
	@echo "  make logs-backend  - Follow backend logs only"
	@echo "  make logs-frontend - Follow frontend logs only"
	@echo ""
	@echo "=== Shell Access ==="
	@echo "  make shell-backend  - Open shell in backend container"
	@echo "  make shell-frontend - Open shell in frontend container"
	@echo ""
	@echo "=== Data Management ==="
	@echo "  make backup      - Backup uploads to backup.tar.gz"
	@echo "  make restore     - Restore uploads from backup.tar.gz"
	@echo ""
	@echo "=== Development ==="
	@echo "  make dev         - Run both services locally (no Docker)"
	@echo "  make dev-backend - Run backend locally"
	@echo "  make dev-frontend - Run frontend locally"
	@echo ""
	@echo "=== Cleanup ==="
	@echo "  make clean       - Remove containers, images (keeps uploads)"

# ============ Docker Commands ============

# Start all services
up:
	docker-compose up -d
	@echo ""
	@echo "Services started! Access the app at http://localhost:8080"

# Stop and remove services
down:
	docker-compose down

# Build images
build:
	docker-compose build

# Force rebuild and restart
rebuild:
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo ""
	@echo "Services rebuilt and started! Access the app at http://localhost:8080"

# Stop without removing
stop:
	docker-compose stop

# Show running containers
ps:
	docker-compose ps

# ============ Logs ============

logs:
	docker-compose logs -f

logs-backend:
	docker-compose logs -f backend

logs-frontend:
	docker-compose logs -f frontend

# ============ Shell Access ============

shell-backend:
	docker-compose exec backend sh

shell-frontend:
	docker-compose exec frontend sh

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
	docker-compose down --rmi all
	@echo "Cleaned up containers and images (uploads preserved in ./data/uploads)"

clean-all:
	docker-compose down --rmi all
	rm -rf data/uploads/*
	@echo "Cleaned up everything including uploads"
