# SettleX Backend

Production-ready Node.js REST API with full Docker + CI/CD pipeline.

---

## Quick Start (Local Development)

### Prerequisites
- Docker Desktop installed and running
- `openssl` available (comes with Git for Windows/Mac/Linux)

### 1. Clone & Configure
```bash
git clone https://github.com/virugamacoder/SettleX-backend.git
cd SettleX-backend

# Copy env and fill in your values
cp .env.example .env
```

Edit `.env` and set `NODE_ENV=local` plus your MongoDB URL, JWT secret, and CoinMarketCap key.

### 2. Generate Local SSL Certificates
```bash
# On Linux/Mac:
bash deploy/generate-local-certs.sh

# On Windows (Git Bash or WSL):
bash deploy/generate-local-certs.sh
```

### 3. Run with Docker
```bash
docker compose -f docker-compose.yml -f docker-compose.local.yml up --build
```

- API: `https://localhost/v1/`
- Health: `https://localhost/health`

> Accept the self-signed cert warning in your browser (it's local-only).

---

## Production — AWS EC2 Setup (One Time Only)

### Step 1: Launch EC2 Instance
- AWS → EC2 → Launch Instance
- **OS**: Ubuntu 22.04 LTS
- **Type**: t2.micro (free tier) or better
- **Security Group Rules**:
  | Port | Protocol | Source |
  |------|----------|--------|
  | 22   | TCP      | Your IP |
  | 80   | TCP      | 0.0.0.0/0 |
  | 443  | TCP      | 0.0.0.0/0 |
- Download the `.pem` key pair

### Step 2: Install Docker on EC2
SSH into your EC2 and run the setup script:
```bash
# Copy and run the setup script
curl -fsSL https://raw.githubusercontent.com/virugamacoder/SettleX-backend/main/deploy/setup-server.sh | bash

# Then log out and back in for docker group
exit
```

### Step 3: Add GitHub Secrets
Go to **GitHub → Your Repo → Settings → Secrets → Actions** and add:

| Secret | Value |
|--------|-------|
| `DOCKER_HUB_USERNAME` | Your Docker Hub username |
| `DOCKER_HUB_TOKEN` | Docker Hub → Account Settings → Security → Access Token |
| `SERVER_HOST` | EC2 Public IP (e.g. `13.x.x.x`) |
| `SERVER_USER` | `ubuntu` (or `ec2-user` for Amazon Linux) |
| `SERVER_SSH_KEY` | Full content of your `.pem` key file |
| `SERVER_PORT` | `22` |
| `APP_DIR` | `/home/ubuntu/settlex` |
| `NODE_ENV` | `production` |
| `PORT` | `3000` |
| `BASE_URL` | `http://your-ec2-ip` or `https://yourdomain.com` |
| `MONGODB_URL` | MongoDB Atlas connection string |
| `JWT_SECRET` | Strong random string (32+ chars) |
| `JWT_ACCESS_EXPIRATION_MINUTES` | `30` |
| `JWT_REFRESH_EXPIRATION_DAYS` | `30` |
| `COINMARKET_CAP_API_KEY` | Your API key |
| `SSL_CERT_PEM` | Content of your `cert.pem` |
| `SSL_PRIVATE_KEY` | Content of your `private.key` |

### Step 4: Deploy!
```bash
git push origin main
```
That's it. GitHub Actions will build, push to Docker Hub, SSH into EC2, and deploy automatically.

---

## CI/CD Pipeline

```
git push main
      │
      ▼
┌─────────────────────────────┐
│  GitHub Actions             │
│                             │
│  Job 1: Build               │
│  ├─ docker build            │
│  └─ docker push → DockerHub │
│                             │
│  Job 2: Deploy              │
│  ├─ SSH → EC2               │
│  ├─ Write .env (secrets)    │
│  ├─ Write SSL certs         │
│  ├─ Copy nginx.conf         │
│  ├─ docker compose pull     │
│  └─ docker compose up -d    │
└─────────────────────────────┘
      │
      ▼
  EC2: App live ✓
```

---

## Reusing on Another AWS Account / Region

Just:
1. Launch a new EC2 (same Security Group rules)
2. Run `bash deploy/setup-server.sh`
3. Update GitHub Secrets with the new EC2 IP/key
4. Push to `main`

Done — no other changes needed.

---

## Useful Commands (on EC2)

```bash
# Navigate to app directory
cd /home/ubuntu/settlex

# View running containers
docker compose ps

# View app logs
docker compose logs -f app

# View nginx logs
docker compose logs -f nginx

# Restart everything
docker compose restart

# Stop everything
docker compose down

# Manual re-deploy (normally done by CI/CD)
docker compose pull && docker compose up -d
```

---

## Environment Variables Reference

See [.env.example](.env.example) for the full list with descriptions.
