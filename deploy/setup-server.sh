#!/bin/bash
# ─────────────────────────────────────────────────────────
#  SettleX Backend — Server Setup Script (run ONCE on VPS)
#  This prepares the server to receive CI/CD deployments.
# ─────────────────────────────────────────────────────────

set -e

APP_DIR="/var/www/settlex-backend"   # Change this to your preferred path
REPO_URL="https://github.com/virugamacoder/SettleX-backend.git"
NODE_VERSION="20"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SettleX Backend — Initial Server Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Install Node.js (via nvm) ──────────────────────────
if ! command -v node &> /dev/null; then
  echo "[*] Installing Node.js $NODE_VERSION..."
  curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "[✓] Node.js already installed: $(node -v)"
fi

# ── Install PM2 globally ───────────────────────────────
if ! command -v pm2 &> /dev/null; then
  echo "[*] Installing PM2..."
  sudo npm install -g pm2
  pm2 startup  # enables PM2 to start on system boot
else
  echo "[✓] PM2 already installed: $(pm2 -v)"
fi

# ── Clone repository ───────────────────────────────────
if [ ! -d "$APP_DIR" ]; then
  echo "[*] Cloning repository to $APP_DIR..."
  sudo mkdir -p $APP_DIR
  sudo chown $USER:$USER $APP_DIR
  git clone $REPO_URL $APP_DIR
else
  echo "[✓] Repository already exists at $APP_DIR"
fi

# ── Install dependencies ───────────────────────────────
echo "[*] Installing Node dependencies..."
cd $APP_DIR
npm install --omit=dev

# ── Setup .env file ────────────────────────────────────
if [ ! -f "$APP_DIR/.env" ]; then
  echo "[!] No .env file found!"
  echo "    Copy .env.example and fill in your values:"
  echo "    cp $APP_DIR/.env.example $APP_DIR/.env"
  echo "    nano $APP_DIR/.env"
else
  echo "[✓] .env file exists"
fi

# ── Start app with PM2 ─────────────────────────────────
echo "[*] Starting app with PM2..."
cd $APP_DIR
pm2 start ecosystem.config.json
pm2 save

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Server setup complete!"
echo "  APP_DIR  : $APP_DIR"
echo "  PM2 list : pm2 list"
echo "  PM2 logs : pm2 logs app"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
