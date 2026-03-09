#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  SettleX Backend — Generate Self-Signed SSL Certificate for AWS EC2 (IP-only)
#
#  Usage (run ON the EC2 server from the project root):
#    bash deploy/generate-aws-certs.sh <SERVER_IP>
#
#  Example:
#    bash deploy/generate-aws-certs.sh 16.171.146.88
#
#  Creates:
#    nginx/certs/private.key
#    nginx/certs/cert.pem
#
#  NOTE: This is a self-signed cert valid for the given IP.
#  Browsers will still warn — for production without a domain, use HTTP (port 80).
#  To eliminate cert errors permanently, point a domain to this IP and use
#  Let's Encrypt:  https://letsencrypt.org
# ─────────────────────────────────────────────────────────────────────────────

set -e

SERVER_IP="${1:-}"

if [[ -z "$SERVER_IP" ]]; then
  echo "ERROR: Please provide the server IP address."
  echo ""
  echo "Usage: bash deploy/generate-aws-certs.sh <SERVER_IP>"
  echo "Example: bash deploy/generate-aws-certs.sh 16.171.146.88"
  exit 1
fi

CERT_DIR="$(cd "$(dirname "$0")/.." && pwd)/nginx/certs"
mkdir -p "$CERT_DIR"

echo "Generating self-signed SSL certificate for IP: $SERVER_IP"
echo "Output directory: $CERT_DIR"
echo ""

openssl req -x509 \
  -newkey rsa:4096 \
  -nodes \
  -keyout "$CERT_DIR/private.key" \
  -out    "$CERT_DIR/cert.pem" \
  -days 365 \
  -subj "/C=IN/ST=Gujarat/L=AWS/O=SettleX/CN=$SERVER_IP" \
  -addext "subjectAltName=IP:$SERVER_IP,IP:127.0.0.1,DNS:localhost"

chmod 600 "$CERT_DIR/private.key"
chmod 644 "$CERT_DIR/cert.pem"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Certificate generated for IP: $SERVER_IP"
echo "  Key : $CERT_DIR/private.key"
echo "  Cert: $CERT_DIR/cert.pem"
echo ""
echo "  Restart nginx to apply:"
echo "    docker compose restart nginx"
echo ""
echo "  ⚠  BROWSER WARNING: This cert is self-signed."
echo "     API calls over HTTP (port 80) are unaffected."
echo "     For no browser warnings, use a domain + Let's Encrypt."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
