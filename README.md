# Kora Analytics API — DeployReady

A Node.js REST API containerised with Docker, deployed to AWS EC2, and delivered via an automated GitHub Actions CI/CD pipeline.

---

## Architecture Overview

```
GitHub (push to main)
        │
        ▼
GitHub Actions Pipeline
  ├── 1. Test       (npm test)
  ├── 2. Build      (Docker image tagged with commit SHA)
  ├── 3. Push       (GitHub Container Registry)
  └── 4. Deploy     (SSH into EC2, pull image, restart container)
        │
        ▼
AWS EC2 (t2.micro, Ubuntu 24.04)
  └── Docker container listening on port 80
```

---

## API Endpoints

| Method | Route      | Description                            |
| ------ | ---------- | -------------------------------------- |
| GET    | `/health`  | Returns `{ "status": "ok" }`           |
| GET    | `/metrics` | Returns uptime and memory usage        |
| POST   | `/data`    | Accepts a JSON body and echoes it back |

---

## Running Locally with Docker

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd DeployReady
   ```

2. Copy the example env file:
   ```bash
   cp .env.example .env
   ```

3. Start the app:
   ```bash
   docker compose up --build
   ```

4. Test it:
   ```bash
   curl http://localhost:3000/health
   ```

---

## Running Tests

```bash
cd app
npm install
npm test
```

---

## CI/CD Pipeline

The pipeline runs automatically on every push to `main` via `.github/workflows/deploy.yml`.

**Steps:**
1. **Test** — runs `npm test`. Pipeline stops if any test fails.
2. **Build** — builds the Docker image tagged with the Git commit SHA.
3. **Push** — pushes the image to GitHub Container Registry (GHCR).
4. **Deploy** — SSHs into the EC2 server, pulls the new image, and restarts the container.

**Required GitHub repository secrets:**

| Secret | Description |
|--------|-------------|
| `SERVER_HOST` | EC2 public IP address |
| `SERVER_USER` | SSH username (`ubuntu`) |
| `SSH_PRIVATE_KEY` | Contents of the `.pem` key file |
| `GHCR_USERNAME` | GitHub username |
| `GHCR_TOKEN` | GitHub personal access token with `write:packages` scope |

---

## Cloud Deployment

Deployed on **AWS EC2 `t2.micro`** in `us-east-1`.

- The container runs on port 80 and is configured to restart automatically.
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for full setup details.

**Live URL:** `http://54.236.210.238/health`
