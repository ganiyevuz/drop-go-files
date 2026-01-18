# Drop Go Files

A simple **drop-and-go file upload and download system** with resumable uploads, crash recovery, and media preview — securely exposed to the internet using **Cloudflare Tunnel**.

---

## ✨ Features

* **Resumable Uploads** – pause/resume uploads using the tus.io protocol
* **Crash Recovery** – uploads resume after refresh or browser crash
* **Folder Uploads** – preserve directory structure
* **Media Preview** – video, audio, images, PDFs
* **Multi-language UI** – Uzbek, Russian, English
* **No Authentication** – simple sharing, zero friction
* **Zero Open Ports** – exposed securely via Cloudflare Tunnel

---
## ✅ Status

* ✔ Dockerized
* ✔ Cloudflare Tunnel
* ✔ No exposed ports
* ✔ Windows & Linux compatible
* ✔ Production-ready architecture

---

## 🧱 Tech Stack

* **Frontend**: React, TypeScript, Tailwind CSS, tus-js-client
* **Backend**: Go, tusd (tus.io server)
* **Reverse Proxy**: nginx
* **Deployment**: Docker, Docker Compose, Cloudflare Tunnel

---

## 🌍 Architecture

```
Internet
   │
   ▼
Cloudflare Edge
   │  (Tunnel)
   ▼
cloudflared (Docker)
   │
   ├── frontend (nginx, React)
   │
   └── backend (Go + tusd)
           │
           ▼
     ./data/uploads
```

* No public ports
* All services communicate over Docker internal network
* Cloudflare is the only public entrypoint

---

## 🚀 Quick Start (Docker + Cloudflare)

### 1️⃣ Prerequisites

* Docker + Docker Compose
* A Cloudflare account
* Domain added to Cloudflare (DNS managed by Cloudflare)

---

### 2️⃣ Create Cloudflare Tunnel (one-time)

```bash
cloudflared tunnel login
cloudflared tunnel create go
cloudflared tunnel route dns go go.odatly.uz
```

This generates:

* Tunnel name: `go`
* Credentials file: `<UUID>.json`

---

### 3️⃣ Project Structure

```
.
├── backend/
├── frontend/
├── cloudflared/
│   ├── config.yml
│   └── <TUNNEL-UUID>.json
├── data/uploads/
├── docker-compose.yml
├── Makefile
└── README.md
```

---

### 4️⃣ cloudflared/config.yml

```yaml
tunnel: go
credentials-file: /etc/cloudflared/<TUNNEL-UUID>.json
protocol: http2
loglevel: info

ingress:
  - hostname: go.odatly.uz
    service: http://frontend:80

  - service: http_status:404
```

> ⚠️ Use Docker service names (`frontend`, `backend`) — **never `localhost`**

---

### 5️⃣ docker-compose.yml

```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: dropgo-backend
    restart: unless-stopped
    environment:
      - PORT=1080
      - UPLOAD_DIR=/app/uploads
    volumes:
      - ./data/uploads:/app/uploads
    networks:
      - dropgo-network
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:1080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: dropgo-frontend
    restart: unless-stopped
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - dropgo-network

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: dropgo-cloudflared
    restart: unless-stopped
    command: tunnel run
    volumes:
      - ./cloudflared/config.yml:/etc/cloudflared/config.yml:ro
      - ./cloudflared:/etc/cloudflared:ro
    depends_on:
      backend:
        condition: service_healthy
      frontend:
        condition: service_started
    networks:
      - dropgo-network

networks:
  dropgo-network:
    driver: bridge
```

---

### 6️⃣ Start everything

```bash
make up
```

Open:

```
https://go.odatly.uz
```

---

## 🛠 Makefile Commands

### Docker

| Command        | Description             |
| -------------- | ----------------------- |
| `make up`      | Start all services      |
| `make down`    | Stop & remove services  |
| `make build`   | Build images            |
| `make rebuild` | Rebuild and restart     |
| `make ps`      | Show running containers |
| `make stop`    | Stop containers         |

### Logs

| Command              | Description       |
| -------------------- | ----------------- |
| `make logs`          | All logs          |
| `make logs-backend`  | Backend only      |
| `make logs-frontend` | Frontend only     |
| `make logs-tunnel`   | Cloudflare Tunnel |

### Shell

| Command               | Description    |
| --------------------- | -------------- |
| `make shell-backend`  | Backend shell  |
| `make shell-frontend` | Frontend shell |
| `make shell-tunnel`   | Tunnel shell   |

### Data

| Command        | Description     |
| -------------- | --------------- |
| `make backup`  | Backup uploads  |
| `make restore` | Restore uploads |

---

## 🧪 Local Development (No Docker)

```bash
# Backend
cd backend
go run cmd/server/main.go

# Frontend
cd frontend
npm install
npm run dev
```

* Backend: [http://localhost:1080](http://localhost:1080)
* Frontend: [http://localhost:8080](http://localhost:8080)

---

## 🔐 Security Notes

* No ports are exposed publicly
* Cloudflare Tunnel handles TLS, DDoS, and routing
* Optional:
  * Cloudflare WAF
  * Rate limiting
  * Cloudflare Access (login protection)

---

## 📌 API Endpoints

| Endpoint           | Method | Description              |
| ------------------ | ------ | ------------------------ |
| `/files/`          | POST   | tus upload               |
| `/api/files`       | GET    | List files               |
| `/api/files/{id}`  | GET    | Download                 |
| `/api/files/{id}`  | DELETE | Delete                   |
| `/api/stream/{id}` | GET    | Stream (range supported) |

---

## 🧹 Cleanup

```bash
make clean
```

Remove everything (including uploads):

```bash
make clean-all
```

---



