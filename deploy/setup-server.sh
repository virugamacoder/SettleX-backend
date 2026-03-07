#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  SettleX Backend — EC2 First-Time Setup Script
#  Run this ONCE on a fresh AWS EC2 instance (Ubuntu 22.04/24.04)
#  After this, all deployments are handled automatically by GitHub Actions CI/CD
#
#  Usage:
#    chmod +x deploy/setup-server.sh
#    bash deploy/setup-server.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SettleX Backend — EC2 Docker Setup"
echo "  This script runs ONCE to prepare the server."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. System Update ─────────────────────────────────────────────────────────
echo ""
echo "[1/4] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# ── 2. Install Docker ─────────────────────────────────────────────────────────
echo ""
echo "[2/4] Installing Docker..."
if command -v docker &>/dev/null; then
  echo "      [✓] Docker already installed: $(docker --version)"
else
  # Official Docker install for Ubuntu
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  # Install Docker Engine + Compose plugin (modern approach — no separate docker-compose binary)
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "      [✓] Docker installed: $(docker --version)"
fi

# ── 3. Add current user to docker group (no sudo needed) ──────────────────────
echo ""
echo "[3/4] Configuring Docker permissions..."
if groups "$USER" | grep -q '\bdocker\b'; then
  echo "      [✓] User '$USER' already in docker group"
else
  sudo usermod -aG docker "$USER"
  echo "      [✓] Added '$USER' to docker group"
  echo "      [!] IMPORTANT: Log out and back in (or run: newgrp docker) for group change to take effect"
fi

# ── 4. Enable & start Docker service ─────────────────────────────────────────
echo ""
echo "[4/4] Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker
echo "      [✓] Docker service enabled and running"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Server setup complete!"
echo ""
echo "  NEXT STEPS:"
echo "  1. Log out and back in (for docker group)"
echo "  2. Verify Docker works:  docker run hello-world"
echo "  3. Add all GitHub Secrets to your repo"
echo "  4. Push to main branch — CI/CD will deploy automatically"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
