# AgroMaster — Smart Farm Management Platform

AgroMaster is an AI-powered farm management platform built for Sri Lankan farmers. It combines crop tracking, expense management, harvest records, profit analytics, and an AI advisor — all in one dashboard.

**Live:** https://agromaster.live

---

## Features

- **Crop Management** — Track every crop from seed to harvest with status monitoring and growth milestones
- **Expense Tracking** — Log seeds, fertilizer, labor and equipment costs by category
- **Harvest Records** — Record yield quantities and revenue with historical comparisons
- **Profit Analytics** — Real-time P&L charts with seasonal breakdowns and per-crop profitability scores
- **AI Advisor** — Personalized crop recommendations and cost optimizations powered by Groq AI
- **Weather Integration** — Live weather data and 7-day forecasts tailored to your farm location in Sri Lanka

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, Vite, React Router, Recharts, Nginx |
| Backend | Spring Boot 4, Spring Security, Flyway, JWT, Java 17 |
| AI Service | FastAPI, Python 3.12, Groq API |
| Database | PostgreSQL (AWS RDS) |
| Deployment | Docker Compose, AWS EC2, Let's Encrypt SSL |

---

## Architecture

```
Browser
  │
  ▼
Nginx (port 80 → redirect HTTPS / port 443 → SSL)
  ├── /        → React SPA (static files)
  ├── /api     → Spring Boot backend (internal port 8080)
  └── /ai      → FastAPI AI service (internal port 8000)
                        │
                        ▼
                  AWS RDS PostgreSQL
```

---

## Project Structure

```
cultivation-help-app/
├── backend/              # Spring Boot REST API
│   ├── src/
│   │   └── main/java/com/cultivation/app/
│   │       ├── controller/
│   │       ├── service/
│   │       ├── repository/
│   │       ├── entity/
│   │       ├── dto/
│   │       ├── security/
│   │       └── config/
│   └── Dockerfile
├── frontend-web/         # React + Vite SPA
│   ├── src/
│   │   ├── pages/
│   │   ├── components/
│   │   ├── context/
│   │   └── api/
│   ├── nginx.conf
│   └── Dockerfile
├── ai-service/           # FastAPI AI microservice
│   ├── main.py
│   ├── routers/
│   ├── services/
│   └── Dockerfile
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Local Development

### Prerequisites
- Docker and Docker Compose

### 1. Clone the repository
```bash
git clone https://github.com/minidu10/cultivation-help-app.git
cd cultivation-help-app
```

### 2. Set up environment variables
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
DB_URL=jdbc:postgresql://your-rds-endpoint:5432/postgres?sslmode=require&preferQueryMode=simple&connectTimeout=30&socketTimeout=120&tcpKeepAlive=true
DB_USERNAME=postgres
DB_PASSWORD=your_password
SPRING_JPA_HIBERNATE_DDL_AUTO=none
SPRING_FLYWAY_ENABLED=true
JWT_SECRET=your_long_random_secret_min_32_chars
GROQ_API_KEY=your_groq_api_key
OPENWEATHER_API_KEY=your_openweather_api_key
OPENWEATHER_BASE_URL=https://api.openweathermap.org
```

```bash
cp frontend-web/.env.example frontend-web/.env
```

Edit `frontend-web/.env`:
```env
VITE_API_URL=http://localhost:8080/api
VITE_AI_URL=http://localhost:8000
VITE_WEATHER_API_KEY=your_openweather_api_key
```

### 3. Run with Docker Compose
```bash
docker compose up -d --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8080 |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| AI Service | http://localhost:8000 |

---

## Production Deployment (AWS EC2)

### Prerequisites
- Ubuntu EC2 instance with inbound ports **22, 80, 443** open
- Domain A record pointing to the EC2 public IP
- AWS RDS PostgreSQL instance running

### 1. Install Docker
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ubuntu && newgrp docker
```

### 2. Get SSL certificate
```bash
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --standalone \
  -d yourdomain.com -d www.yourdomain.com \
  --email your@email.com --agree-tos --non-interactive
```

### 3. Clone and configure
```bash
git clone https://github.com/minidu10/cultivation-help-app.git
cd cultivation-help-app
```

Create root `.env`:
```bash
cp .env.example .env
# Fill in your RDS credentials and API keys
```

Create `frontend-web/.env` for production:
```bash
cat > frontend-web/.env << 'EOF'
VITE_API_URL=/api
VITE_AI_URL=/ai
VITE_WEATHER_API_KEY=your_openweather_api_key
EOF
```

> **Important:** Use `/api` and `/ai` (not `localhost`) for production — nginx proxies these internally.

### 4. Deploy
```bash
docker compose up -d --build
```

Backend Maven build takes ~3–5 minutes on first run.

### 5. Verify
```bash
docker compose ps   # all 3 containers should show "Up"
```

Open `https://yourdomain.com` in the browser.

---

## CI/CD

Every push to the `main` branch automatically deploys to production via GitHub Actions.

**Workflow:** `.github/workflows/deploy.yml`

```
push to main → SSH into EC2 → git pull → docker compose down → docker compose up --build
```

**Required GitHub Secrets** (Settings → Secrets → Actions):

| Secret | Description |
|--------|-------------|
| `EC2_HOST` | EC2 public IP address |
| `EC2_USER` | SSH username (`ubuntu`) |
| `EC2_SSH_KEY` | Contents of your `.pem` private key file |

---

## Useful Commands

```bash
# Check status
docker compose ps

# Stream logs
docker compose logs -f
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f ai-service

# Rebuild a single service
docker compose up -d --build frontend

# Restart all
docker compose restart

# Full stop
docker compose down

# Hard reset (removes containers, images, volumes)
docker system prune -af --volumes
```

---

## Auto-renew SSL

```bash
sudo crontab -e
# Add this line:
0 3 * * * certbot renew --quiet && cd /home/ubuntu/cultivation-help-app && docker compose restart frontend
```

---

## Environment Variables Reference

### Root `.env`
| Variable | Required | Description |
|----------|----------|-------------|
| `DB_URL` | Yes | PostgreSQL JDBC connection URL |
| `DB_USERNAME` | Yes | Database username |
| `DB_PASSWORD` | Yes | Database password |
| `JWT_SECRET` | Yes | Secret key for JWT signing (min 32 chars) |
| `GROQ_API_KEY` | Yes | Groq API key for AI advisor |
| `OPENWEATHER_API_KEY` | Yes | OpenWeather API key |

### `frontend-web/.env`
| Variable | Local | Production |
|----------|-------|------------|
| `VITE_API_URL` | `http://localhost:8080/api` | `/api` |
| `VITE_AI_URL` | `http://localhost:8000` | `/ai` |
| `VITE_WEATHER_API_KEY` | your key | your key |

---

## Security Checklist

- Never commit `.env` files to Git
- Use a strong random `JWT_SECRET` (32+ characters)
- Restrict RDS inbound rules to EC2 security group only
- Keep SSL certificates up to date (auto-renew cron above)
- Rotate API keys and database passwords periodically

---

## License

MIT — Built for Sri Lankan Farmers
