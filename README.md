# Cultivation Help App

A cloud-based farm management platform for tracking crops, expenses, harvests, and farm profit/loss, with an AI advisor for farming guidance.

## Live URL

- https://agromaster.live

## Tech Stack

- Backend: Spring Boot 3, Java 17
- Frontend: React 18, Vite, Nginx
- AI Service: FastAPI (Python), Groq/Ollama modes
- Database: PostgreSQL (AWS RDS)
- Deployment: Docker Compose on AWS EC2

## Core Features

- Crop and planting management
- Expense tracking by category
- Harvest and revenue records
- Automatic profit/loss analytics
- AI crop advisory assistant
- Weather integration (OpenWeather)

## Project Structure

```text
cultivation-help-app/
|- ai-service/
|  |- main.py
|  |- requirements.txt
|  |- routers/
|  |  `- chat.py
|  `- services/
|     |- gemini.py
|     |- groq_service.py
|     `- ollama.py
|- backend/
|  |- pom.xml
|  `- src/
|     |- main/
|     |  |- java/com/cultivation/app/
|     |  |  |- config/
|     |  |  |- controller/
|     |  |  |- dto/
|     |  |  |- entity/
|     |  |  |- exception/
|     |  |  |- repository/
|     |  |  |- security/
|     |  |  |- service/
|     |  |  `- AppApplication.java
|     |  `- resources/
|     |     |- application.yml
|     |     `- db/migration/
|     |        |- V0__init_core_schema.sql
|     |        |- V1__add_ai_insights_and_reminders.sql
|     |        |- V2__add_user_city_column.sql
|     |        `- V3__add_user_preferences.sql
|     `- test/java/com/cultivation/app/
|        `- AppApplicationTests.java
|- docs/
|- frontend-web/
|  |- nginx.conf
|  |- package.json
|  |- src/
|  |  |- api/
|  |  |- components/
|  |  |- context/
|  |  |- pages/
|  |  |- utils/
|  |  |- App.jsx
|  |  `- main.jsx
|  `- public/
|- mobile/
|- .env.example
|- docker-compose.yml
`- README.md
```

## Environment Variables

1. Copy the root env template:

```bash
cp .env.example .env
```

2. Fill all required values in .env:

```env
DB_URL=jdbc:postgresql://<rds-endpoint>:5432/postgres?sslmode=require&preferQueryMode=simple&connectTimeout=30&socketTimeout=120&tcpKeepAlive=true
DB_USERNAME=postgres
DB_PASSWORD=<your-password>
JWT_SECRET=<long-random-secret>
GROQ_API_KEY=<optional>
OPENWEATHER_API_KEY=<optional>
```

Notes:
- Use your AWS RDS endpoint in DB_URL.
- sslmode=require is recommended for RDS.
- Do not commit .env to GitHub.

## Run Locally with Docker

```bash
docker-compose up -d --build
```

Services:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Swagger: http://localhost:8080/swagger-ui.html
- AI Service: http://localhost:8000

## AWS Deployment (EC2 + RDS)

### 1. Prepare AWS RDS (PostgreSQL)

- Create a PostgreSQL RDS instance.
- In RDS security group, allow inbound port 5432 from your EC2 security group.
- Copy endpoint, username, password, and database name.
- Use the endpoint in DB_URL inside .env.

### 2. Prepare AWS EC2

- Launch Ubuntu EC2 instance.
- Open inbound ports: 22, 80, 443 (and 3000 only if needed for temporary direct access).
- Install Docker and Docker Compose plugin.

### 3. Deploy Application

```bash
git clone https://github.com/<your-username>/cultivation-help-app.git
cd cultivation-help-app
cp .env.example .env
# edit .env with your AWS RDS and API keys
docker compose up -d --build
```

### 4. Domain and HTTPS (agromaster.live)

- Point DNS A record for agromaster.live to your EC2 public IP.
- Point www.agromaster.live similarly (optional but recommended).
- Ensure SSL cert files exist at:
  - /etc/letsencrypt/live/agromaster.live/fullchain.pem
  - /etc/letsencrypt/live/agromaster.live/privkey.pem
- Restart frontend container after issuing/renewing certs:

```bash
docker compose restart frontend
```

### 5. Verify Deployment

- Open https://agromaster.live
- Check API: https://agromaster.live/api
- Check AI route: https://agromaster.live/ai

## Useful Commands

```bash
docker compose ps
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f ai-service
docker compose restart
docker compose down
```

## Security Checklist

- Keep .env out of Git.
- Use a strong JWT_SECRET.
- Restrict RDS inbound rules to EC2 security group only.
- Rotate API keys and DB passwords periodically.

## License

MIT