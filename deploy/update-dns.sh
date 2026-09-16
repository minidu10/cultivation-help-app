#!/usr/bin/env bash
#
# Point the DuckDNS name at this instance's current public IP.
#
# Stopping and starting an EC2 instance assigns a new public IP. An Elastic IP
# would avoid that, but AWS bills for one attached to a stopped instance -
# which is most of the time here. This costs nothing instead.
set -euo pipefail

CONF=/etc/duckdns.conf
[ -f "$CONF" ] || { echo "update-dns: $CONF missing (run bootstrap.sh)" >&2; exit 1; }
# shellcheck disable=SC1090
. "$CONF"

# IMDSv2 requires a token; this is the metadata service, not the internet.
TOKEN=$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)
if [ -n "${TOKEN:-}" ]; then
    IP=$(curl -sf -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/public-ipv4 || true)
fi
# Outside EC2, or if metadata is unavailable, let DuckDNS detect the caller's IP.
IP="${IP:-}"

RESULT=$(curl -sf "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&ip=${IP}" || echo FAIL)

if [ "$RESULT" = "OK" ]; then
    echo "update-dns: ${DUCKDNS_DOMAIN} -> ${IP:-auto-detected}"
else
    echo "update-dns: FAILED (response: $RESULT)" >&2
    exit 1
fi
