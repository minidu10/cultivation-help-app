#!/usr/bin/env bash
#
# One-time setup for a fresh Ubuntu EC2 instance.
#
#   curl -fsSL https://raw.githubusercontent.com/minidu10/cultivation-help-app/main/deploy/bootstrap.sh | bash
#
# or, after cloning:  bash deploy/bootstrap.sh
#
# Safe to re-run: every step checks before acting.
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/minidu10/cultivation-help-app.git}"
APP_DIR="${APP_DIR:-$HOME/cultivation-help-app}"
WEBROOT="/var/www/certbot"

say()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m X\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Run as the ubuntu user, not root. Sudo is used where needed."

# ---------------------------------------------------------------- swap
# The Maven build needs more memory than a 1 GB instance has. Without swap it
# is killed partway through with an error that does not mention memory.
say "Swap"
if swapon --show | grep -q /swapfile; then
    echo "    already active"
else
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile >/dev/null
    sudo swapon /swapfile
    grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    echo "    2 GB swapfile created and made permanent"
fi

# ---------------------------------------------------------------- packages
say "Docker and certbot"
if command -v docker >/dev/null 2>&1; then
    echo "    docker already installed"
else
    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo "    installed"
fi
command -v certbot >/dev/null 2>&1 || sudo apt-get install -y -qq certbot

# ---------------------------------------------------------------- repo
say "Repository"
if [ -d "$APP_DIR/.git" ]; then
    git -C "$APP_DIR" pull --ff-only
else
    git clone "$REPO_URL" "$APP_DIR"
fi
cd "$APP_DIR"

# ---------------------------------------------------------------- config
say "Configuration"
if [ -f .env ]; then
    echo "    .env already present, leaving it alone"
else
    read -rp "    DuckDNS subdomain (the part before .duckdns.org): " DUCK_SUB
    read -rp "    DuckDNS token: " DUCK_TOKEN
    read -rp "    Neon DB_URL: " DB_URL
    read -rp "    Neon DB_USERNAME: " DB_USERNAME
    read -rsp "    Neon DB_PASSWORD: " DB_PASSWORD; echo
    read -rp "    Gmail address: " MAIL_USERNAME
    read -rsp "    Gmail app password (16 chars): " MAIL_PASSWORD; echo
    read -rp "    AI_API_KEY: " AI_API_KEY
    read -rp "    AI_BASE_URL [https://api.groq.com/openai/v1]: " AI_BASE_URL
    read -rp "    AI_MODEL [openai/gpt-oss-120b]: " AI_MODEL
    read -rp "    GOOGLE_CLIENT_ID (blank to disable): " GOOGLE_CLIENT_ID
    read -rp "    OPENWEATHER_API_KEY: " OPENWEATHER_API_KEY

    cat > .env <<ENVEOF
COMPOSE_PROFILES=prod
DOMAIN=${DUCK_SUB}.duckdns.org

DB_URL=${DB_URL}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

JWT_SECRET=$(openssl rand -hex 32)
HOST_BIND=127.0.0.1
SWAGGER_ENABLED=false
RATE_LIMIT_ENABLED=true
AI_ALLOWED_ORIGINS=

MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_SMTP_AUTH=true
MAIL_STARTTLS=true
MAIL_USERNAME=${MAIL_USERNAME}
MAIL_PASSWORD=${MAIL_PASSWORD}
MAIL_FROM=AgroMaster <${MAIL_USERNAME}>

AI_API_KEY=${AI_API_KEY}
AI_BASE_URL=${AI_BASE_URL:-https://api.groq.com/openai/v1}
AI_MODEL=${AI_MODEL:-openai/gpt-oss-120b}

GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY}

TZ=Asia/Colombo
ENVEOF
    chmod 600 .env

    # Read back by the boot script, which runs before .env is otherwise loaded.
    sudo tee /etc/duckdns.conf >/dev/null <<DUCKEOF
DUCKDNS_SUBDOMAIN=${DUCK_SUB}
DUCKDNS_TOKEN=${DUCK_TOKEN}
DUCKDNS_DOMAIN=${DUCK_SUB}.duckdns.org
DUCKEOF
    sudo chmod 600 /etc/duckdns.conf
    echo "    .env written (JWT secret generated), DuckDNS credentials stored"
fi

# shellcheck disable=SC1091
DOMAIN=$(grep -E '^DOMAIN=' .env | cut -d= -f2-)
[ -n "$DOMAIN" ] || die "DOMAIN missing from .env"

# ---------------------------------------------------------------- dns
say "Point DuckDNS at this instance"
sudo bash deploy/update-dns.sh
sleep 5

# ---------------------------------------------------------------- certificate
say "TLS certificate for $DOMAIN"
sudo mkdir -p "$WEBROOT"
if sudo test -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem"; then
    echo "    already issued"
else
    read -rp "    Email for renewal notices: " LE_EMAIL
    # Standalone: nginx is not running yet, so port 80 is free.
    sudo certbot certonly --standalone --non-interactive --agree-tos \
        -d "$DOMAIN" -m "$LE_EMAIL"
    echo "    issued"
fi

# ---------------------------------------------------------------- images
say "Building images (slowest step, only happens here)"
sg docker -c "docker compose build" || docker compose build

# ---------------------------------------------------------------- boot service
say "Boot automation"
sudo cp deploy/agromaster.service /etc/systemd/system/agromaster.service
sudo sed -i "s|__APP_DIR__|$APP_DIR|g; s|__USER__|$USER|g" /etc/systemd/system/agromaster.service
sudo systemctl daemon-reload
sudo systemctl enable agromaster.service >/dev/null
echo "    enabled - the app now starts itself on every boot"

# ---------------------------------------------------------------- go
say "Starting"
sudo systemctl start agromaster.service
sleep 20
sg docker -c "docker compose ps" || docker compose ps

cat <<DONE

  Done.  https://$DOMAIN

  If docker commands complain about permissions, log out and back in once -
  group membership only applies to new sessions.

  Remaining manual step: add  https://$DOMAIN  to the Authorised JavaScript
  origins of your Google OAuth client, or the sign-in button will not work.

DONE
