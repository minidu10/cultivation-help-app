# AgroMaster — Smart Farm Management Platform

[![CI/CD](https://github.com/minidu10/cultivation-help-app/actions/workflows/ci.yml/badge.svg)](https://github.com/minidu10/cultivation-help-app/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

AgroMaster is an AI-powered farm management platform for small-scale Sri Lankan
farmers. It tracks every crop from planting to harvest, records the costs against
it and the revenue it produced, and answers the question that matters: **did this
crop actually make money?**

**Live demo:** https://agromaster.duckdns.org

> Hosted on a free-tier EC2 instance that is powered off between demos. If the
> link does not respond, the server is asleep — ask and it will be started.

**Documentation:** [Technical Overview](docs/AgroMaster-Technical-Overview.pdf)
(12 pages — how it works and why) · [Software Requirements Specification](docs/AgroMaster-SRS.pdf)
(19 pages) · [Deployment runbook](docs/DEPLOYMENT.md)

---

## Engineering notes

The parts of this build that were not obvious, and why they were done that way:

| Decision | Reasoning |
|---|---|
| **Images built in CI, never on the server** | The 1 GB instance cannot reliably compile Java. GitHub Actions publishes to ghcr.io and the server only pulls — deploys went from 3–5 minutes with OOM risk to about 30 seconds |
| **AI reached only through the backend** | The AI service was briefly a public, unauthenticated LLM endpoint billed to this project's API key. It is now on the internal network with the backend in front of it |
| **AI insights cached on a fingerprint** | The dashboard asked the model for an insight per crop on every load. The result is stored against a hash of the figures behind it, so an unchanged crop costs nothing |
| **One daily reminder digest, not one email per task** | Per-reminder mail floods the inbox on a busy week and trains people to ignore it. A unique constraint on `(reminder_id, lead_days)` makes duplicate sends impossible at the database level |
| **One compose file for both environments** | `COMPOSE_PROFILES` decides which services start, so the deploy command is identical locally and in production and the two cannot drift |
| **6-digit codes, attempt-limited** | A million possibilities is brute-forceable, so codes expire in 10 minutes, die after 5 wrong guesses and are single-use — enforced in the database, not in job logic |

---

## Features

- **Crop Management** — Track every crop from seed to harvest with status monitoring and growth milestones
- **Expense Tracking** — Log seeds, fertilizer, labor and equipment costs by category
- **Harvest Records** — Record yield quantities and revenue with historical comparisons
- **Profit Analytics** — Real-time P&L charts with seasonal breakdowns and per-crop profitability scores
- **AI Advisor** — Personalized crop recommendations and cost optimizations, backed by any OpenAI-compatible model
- **Weather Integration** — Live weather data and 7-day forecasts tailored to your farm location in Sri Lanka
- **Verified Accounts** — Registration and password reset are confirmed by a 6-digit code emailed to the address, so every account has a reachable inbox
- **Google Sign-In** — One-tap account creation with a Google account; the address is already proven, so no code is needed
- **Reminder Digests** — One email a day at 7:00 AM listing tasks due tomorrow and the day after, never one message per task. Farmers switch it off in Settings

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, Vite, React Router, Recharts, Nginx |
| Backend | Spring Boot 4, Spring Security, Flyway, JWT, Java 17 |
| AI Service | FastAPI, Python 3.12, OpenAI-compatible API |
| Database | PostgreSQL (Neon) |
| Deployment | Docker Compose, AWS EC2, Let's Encrypt, DuckDNS |

---

## Architecture

```
                         Browser
                            │  HTTPS
                            ▼
           ┌─────────────────────────────────┐
           │  Nginx   80 → redirect, 443 TLS │   the only public port
           │  gzip · cache · security headers│
           └─────────────────────────────────┘
               │                        │
               │ /                      │ /api
               ▼                        ▼
        React SPA (static)      Spring Boot  127.0.0.1:8080
                                     │
                        ┌────────────┼────────────┐
                        ▼            ▼            ▼
                  FastAPI AI    PostgreSQL     SMTP
                127.0.0.1:8000    (Neon)      (Gmail)

  Neither the backend nor the AI service is reachable from the internet;
  both bind to loopback and are reached only through Nginx.
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
│   ├── nginx.conf.template   # ${DOMAIN} rendered at container start
│   ├── security-headers.conf
│   └── Dockerfile
├── ai-service/           # FastAPI AI microservice
│   ├── main.py
│   ├── routers/
│   ├── services/
│   └── Dockerfile
├── deploy/                   # server bootstrap and boot automation
├── docs/
│   ├── AgroMaster-Technical-Overview.pdf  # architecture and design rationale
│   ├── AgroMaster-SRS.pdf                 # requirements specification
│   └── DEPLOYMENT.md                      # production runbook
├── scripts/
│   ├── seed-local.sql        # demo data for local analysis
│   └── analysis-queries.sql  # starter queries for pgAdmin
├── docker-compose.yml    # one file, local + prod via COMPOSE_PROFILES
├── .env.example
└── README.md
```

---

## Environments

There is **one** `docker-compose.yml`. Which services start is decided by `COMPOSE_PROFILES` in `.env`, so the command is identical everywhere:

```bash
docker compose up -d --build
```

| Service | `COMPOSE_PROFILES=local` | `COMPOSE_PROFILES=prod` |
|---|---|---|
| `db` (Postgres container) | starts | not started — `DB_URL` points at managed Postgres |
| `backend` | starts | starts |
| `ai-service` | starts | starts |
| `frontend` (nginx + SSL) | not started — use the Vite dev server | starts |

---

## Local Development

### Prerequisites
- Docker and Docker Compose
- Node.js 20+ (for the frontend dev server)

### 1. Clone and configure
```bash
git clone https://github.com/minidu10/cultivation-help-app.git
cd cultivation-help-app
cp .env.example .env
```

The defaults in `.env.example` run entirely locally — no cloud database needed. Set `JWT_SECRET` to any 32+ character string. `AI_API_KEY` and `OPENWEATHER_API_KEY` are optional; without them the AI Advisor and weather widgets fail while everything else works.

### 2. Start the backend services
```bash
docker compose up -d --build
```

Starts Postgres, the Spring Boot API and the AI service. The first Maven build takes ~3–5 minutes. Flyway creates the schema automatically on first boot.

### 3. Start the frontend
```bash
cd frontend-web
npm install
npm run dev
```

| Service | URL |
|---------|-----|
| **Frontend (dev server)** | **http://localhost:5173** |
| Backend API | http://localhost:8080 |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| AI Service | http://localhost:8000 |
| Postgres | localhost:**5434** |

The Vite dev server proxies `/api` and `/ai` to the containers, mirroring what nginx does in production — so the app uses relative paths everywhere and the frontend needs no environment file at all.

> Postgres is published on **5434**, not 5432, because a locally installed PostgreSQL usually occupies 5432/5433. Change `DB_PORT` in `.env` if you need a different one. Containers always reach it internally on 5432.

### 4. Load demo data (optional)

Register an account at http://localhost:5173, then:

```bash
docker compose exec -T db psql -U postgres -d cultivation < scripts/seed-local.sql
```

Adds 4 crops across a season — one profitable, one marginal, one failed, one still growing — with ~35 expenses, 5 harvests and 5 reminders, so the dashboards and profit analytics have real shape.

### Reading the emails the app sends

Locally, no mail leaves your machine. Mailpit accepts everything and shows it at **http://localhost:8025** — verification codes, password resets, welcome messages and reminder digests all land there.

| Email | When |
|---|---|
| Verification code | Registration, step 1 |
| Password reset code | Forgot password |
| Welcome | Account created |
| Reminder digest | Daily at 07:00, for tasks 2 days and 1 day out |

The digest is deliberately **one message per farmer per day**, not one per reminder — a week with ten tasks produces a handful of emails, not ten. Each task is announced at most twice (two days ahead, then the day before), enforced by a unique constraint on `reminder_notifications (reminder_id, lead_days)` rather than by job logic, so a restart or a second instance cannot double-send.

To watch it work without waiting for 07:00, drop the interval temporarily:

```bash
REMINDER_CRON="*/15 * * * * *" docker compose up -d backend   # every 15 seconds
docker compose up -d backend                                   # back to daily
```

Tune the lead times with `REMINDER_LEAD_DAYS` (default `2,1`; add `0` to also mail on the day itself), or turn the job off entirely with `REMINDER_EMAIL_ENABLED=false`.

**Production** swaps Mailpit for any SMTP relay. Brevo's free tier is 300 emails/day forever:

```env
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_SMTP_AUTH=true
MAIL_STARTTLS=true
MAIL_USERNAME=<brevo smtp login>
MAIL_PASSWORD=<brevo smtp key>
MAIL_FROM=AgroMaster <no-reply@yourdomain.com>
```

### Google Sign-In setup

Optional — the button hides itself until a client id is configured, and email/password signup works regardless.

1. At [console.cloud.google.com](https://console.cloud.google.com) create a project, then **APIs & Services → OAuth consent screen**. External user type, fill in the app name and support email.
2. **Credentials → Create credentials → OAuth client ID → Web application.**
3. Add **Authorised JavaScript origins** — the page the button is shown on, not the API:

   | Environment | Origin |
   |---|---|
   | Local | `http://localhost:5173` |
   | Production | `https://yourdomain.com` |

4. Copy the client id into `.env` and restart the backend:

   ```env
   GOOGLE_CLIENT_ID=1234567890-abcdefg.apps.googleusercontent.com
   ```

No client secret is needed. The browser obtains an ID token and the backend verifies its signature against Google's published keys, checking issuer, audience and expiry — an unverified token is rejected, so a forged one naming someone else's address cannot sign in.

**Account linking.** Signing in with Google using an address that already has a password account links the two, and afterwards either method works. Linking only happens when Google reports the address as verified, so an unverified Google account cannot claim an existing user. A Google-only account has no password until one is set through **Forgot password**, at which point both methods work.

### Inspecting the database

Connect any client (pgAdmin, DBeaver) to `localhost:5434`, database `cultivation`, user/password `postgres`. `scripts/analysis-queries.sql` has ready-made queries for profit per crop, spend by category, monthly burn and revenue per acre.

Data lives in the `pgdata` volume and survives `docker compose down`. To wipe and start fresh: `docker compose down -v`.

---

## Production Deployment

Full runbook: **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)**

One command on a fresh Ubuntu instance:

```bash
git clone https://github.com/minidu10/cultivation-help-app.git
cd cultivation-help-app && bash deploy/bootstrap.sh
```

It creates swap, installs Docker, writes `.env`, issues a TLS certificate,
builds the images and installs a boot service.

The instance is designed to be **stopped between uses**. On each start the boot
service updates DNS to the new public IP, starts the containers from prebuilt
images, and renews the certificate if it is due — roughly 90 seconds, no manual
steps. The database is on Neon, so nothing is lost while the server is off.

| Script | |
|---|---|
| `deploy/bootstrap.sh` | one-time server setup |
| `deploy/on-boot.sh` | runs on every boot |
| `deploy/update-dns.sh` | points DuckDNS at the current IP |
| `deploy/agromaster.service` | systemd unit tying it together |

---

## CI/CD

Every push to `main` runs [`.github/workflows/ci.yml`](.github/workflows/ci.yml):

```
backend  → mvnw verify                          ┐ every push
frontend → npm ci, eslint, build                ┘ and pull request

images   → build 3 images, push to ghcr.io      ┐ main only
deploy   → ssh to EC2, pull, restart            ┘
```

Images are built **in CI, never on the server** — the instance has no JDK,
Maven or Node. Each image is tagged `:latest` and `:<commit-sha>`, so rolling
back is `IMAGE_TAG=<sha>` and a restart.

**Required GitHub Secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `EC2_HOST` | The DuckDNS hostname — **not an IP**, which changes on every restart |
| `EC2_SSH_KEY` | Full contents of the `.pem`, including the BEGIN and END lines |

Publishing needs no secret: the workflow's built-in `GITHUB_TOKEN` has
`packages: write`.

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

## TLS renewal

Handled by the boot service, not cron — a nightly cron job never fires on an
instance that is powered off between demos.

[`deploy/on-boot.sh`](deploy/on-boot.sh) runs on every start, in this order:

1. Update DuckDNS with the new public IP
2. Start the containers
3. Attempt `certbot renew`, then reload nginx if the certificate changed

Renewal comes last because the HTTP-01 challenge needs nginx already serving
port 80. An expired certificate does not stop nginx from starting, so even after
months powered off the instance comes up and then repairs its own certificate.

---

## Environment Variables Reference

All configuration lives in the root `.env`. The frontend has no environment file.

| Variable | Required | Description |
|----------|----------|-------------|
| `COMPOSE_PROFILES` | Yes | `local` or `prod` — decides which services start |
| `DB_URL` | Yes | PostgreSQL JDBC URL, without credentials. Local: `jdbc:postgresql://db:5432/cultivation` |
| `DB_USERNAME` | Yes | Database username |
| `DB_PASSWORD` | Yes | Database password |
| `POSTGRES_DB` | local only | Database the container creates (default `cultivation`) |
| `DB_PORT` | local only | Host port for the Postgres container (default `5434`) |
| `JWT_SECRET` | Yes | Secret for JWT signing (min 32 chars) |
| `AI_API_KEY` | No | Key for the AI Advisor; without it those endpoints return 503 |
| `AI_BASE_URL` | No | Any OpenAI-compatible endpoint. Defaults to Gemini's |
| `AI_MODEL` | No | Model name for that endpoint |
| `OPENWEATHER_API_KEY` | No | OpenWeather key; without it weather endpoints fail |
| `OPENWEATHER_BASE_URL` | No | Defaults to `https://api.openweathermap.org` |
| `TZ` | Yes | Container timezone. Must match the farm's — reminders are stored without a zone, so a UTC container fires a 07:00 task at 01:30 |
| `MAIL_HOST` / `MAIL_PORT` | Yes | `mailpit` / `1025` locally; your SMTP relay in production |
| `MAIL_SMTP_AUTH` / `MAIL_STARTTLS` | Yes | `false` locally, `true` for a real relay |
| `MAIL_USERNAME` / `MAIL_PASSWORD` | prod only | SMTP credentials |
| `MAIL_FROM` | No | Sender shown on every email |
| `GOOGLE_CLIENT_ID` | No | OAuth Web client id. Blank hides the Google button |
| `DOMAIN` | prod | Domain nginx serves and finds TLS certificates under |
| `HOST_BIND` | No | `0.0.0.0` locally; `127.0.0.1` in production so only nginx is public |
| `SWAGGER_ENABLED` | No | `false` in production - it publishes the whole API map |
| `RATE_LIMIT_ENABLED` | No | Per-IP limits on `/api/auth/**`. Leave on |
| `REMINDER_LEAD_DAYS` | No | Days of advance notice, default `2,1` |
| `REMINDER_CRON` | No | Digest schedule, default `0 0 7 * * *` (07:00 daily) |
| `REMINDER_EMAIL_ENABLED` | No | `false` disables reminder emails for everyone |

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
