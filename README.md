# 🌾 Cultivation Help App

> A cloud-based farm management system that helps farmers track crops,
> record expenses, monitor harvests, and calculate profit/loss automatically —
> with AI-powered crop advisory built in.

![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2-6DB33F?style=flat&logo=spring)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![React](https://img.shields.io/badge/React-18-61DAFB?style=flat&logo=react)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat&logo=postgresql)
![Azure](https://img.shields.io/badge/Azure-Deployed-0078D4?style=flat&logo=microsoft-azure)

## ✨ Features

- 🌱 Crop & planting cycle management
- 💰 Expense tracking by category (fertilizer, labor, transport…)
- 🌽 Harvest quantity & revenue recording
- 📊 Automatic profit / loss calculation
- 🤖 AI crop advisor (Gemini 1.5 Flash + Ollama local fallback)
- 📈 Analytics dashboard with charts
- 📱 Flutter mobile app (iOS + Android)
- 🌐 React web dashboard

## 🏗️ Architecture

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x |
| Web Dashboard | React 18 + Vite + Recharts |
| Backend API | Spring Boot 3.2 + Java 17 |
| AI Service | Python FastAPI + Gemini + Ollama |
| Database | PostgreSQL 15 (Azure Database) |
| Cache | Redis |
| Cloud | Microsoft Azure (App Service + Blob Storage) |
| CI/CD | GitHub Actions |

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Docker Desktop
- Flutter SDK
- Node.js 18+
- Python 3.11+

### Run locally with Docker
```bash
docker-compose up -d
```
API will be available at `http://localhost:8080`
Swagger UI at `http://localhost:8080/swagger-ui.html`

## 📁 Project Structure
```text
cultivation-help-app/
├── backend/          # Spring Boot REST API
│   ├── src/
│   └── .mvn/         # Maven wrapper support files (keep tracked)
├── frontend-web/     # React + Vite dashboard
│   ├── src/
│   └── public/
├── ai-service/       # Python FastAPI AI microservice
│   ├── routers/
│   └── services/
├── mobile/           # Flutter mobile app
├── docs/             # Architecture and notes
├── docker-compose.yml
└── .env.example      # Root environment template
```

## 🧹 Repository Hygiene

- Keep source code and config files tracked; keep generated artifacts untracked.
- Do not commit local environments or build output:
	- `backend/target/`
	- `frontend-web/node_modules/`
	- `frontend-web/dist/`
	- `ai-service/venv/`, `ai-service/.venv/`, `ai-service/__pycache__/`
- Keep secrets only in local `.env` files. Use `.env.example` templates for sharing expected keys.

## 🔗 Live Demo
> Coming soon — deploying to Azure

## 📄 License
MIT