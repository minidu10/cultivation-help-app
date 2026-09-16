#!/usr/bin/env bash
#
# Runs on every boot. Order matters:
#
#   1. DNS first  - the IP has just changed, so nothing else will resolve
#   2. Start app  - pull the images CI published; nothing is ever built here
#   3. Renew TLS  - only now, because the HTTP-01 challenge needs nginx running
#                   to serve /.well-known/acme-challenge/
#
# An expired certificate does not stop nginx from starting; it just serves an
# invalid one. So even after months powered off, the box comes up and then
# repairs its own certificate.
set -uo pipefail

APP_DIR="${APP_DIR:-__APP_DIR__}"
cd "$APP_DIR" || exit 1

echo "--- agromaster boot $(date -Is) ---"

# 1 -----------------------------------------------------------------
bash deploy/update-dns.sh || echo "boot: DNS update failed, continuing"

# 2 -----------------------------------------------------------------
# Pull first: CI deploys on push, but this covers a push that landed while the
# instance was stopped, so the running version cannot drift behind main.
docker compose pull --quiet || echo "boot: pull failed, starting existing images"
docker compose up -d --remove-orphans

# 3 -----------------------------------------------------------------
DOMAIN=$(grep -E '^DOMAIN=' .env | cut -d= -f2-)
WEBROOT="${CERTBOT_WEBROOT:-/var/www/certbot}"
sudo mkdir -p "$WEBROOT"

# Give nginx a moment to bind 80 before the challenge arrives.
sleep 10

# certbot owns /etc/letsencrypt and /var/log/letsencrypt as root, while this
# service runs as the unprivileged app user - so the renewal needs sudo.
if sudo certbot renew --webroot -w "$WEBROOT" --quiet --deploy-hook \
      "docker compose -f $APP_DIR/docker-compose.yml exec -T frontend nginx -s reload"; then
    echo "boot: certificate check complete"
else
    echo "boot: certbot renew reported a problem (site still serves its existing cert)"
fi

echo "boot: ready at https://${DOMAIN}"
