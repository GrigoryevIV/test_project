# Coolify Fullstack Example (Frontend + Backend + PostgreSQL)

This example repo contains a minimal full-stack project intended to be deployed using **Coolify**
across 3 servers:

- Server1: Coolify dashboard + Frontend (static) behind Nginx/Reverse Proxy
- Server2: Backend (Node.js + Express) in Docker
- Server3: PostgreSQL (container or native)

## Contents
- `frontend/` - Minimal React app (Vite) that calls the backend `/users` endpoint.
- `backend/` - Node.js + Express app using `pg` connecting to PostgreSQL using `DATABASE_URL`.
- `docker` - Docker files and sample `docker-compose` for local testing (optional).
- `db-init/` - SQL file to create `users` table and seed sample data.
- `README.md` - This file with deployment instructions.

## Quick start (local testing - optional)
You can test locally with Docker Compose (a single machine) inside `docker/`:

```bash
cd docker
docker compose up --build
# backend on http://localhost:3000
# frontend on http://localhost:5173 (Vite dev) or build and serve static content
```

## Deploying with Coolify (3 servers)
1. Install Docker on all 3 servers. Install Coolify on Server1 (the public server).
2. Add Server2 and Server3 as remote servers in Coolify (Resources → Servers → Add Server).
3. In Coolify create Services:
   - Frontend: point to `frontend` folder (Dockerfile) and deploy to Server1.
   - Backend: point to `backend` folder (Dockerfile) and deploy to Server2.
   - PostgreSQL: you may run PostgreSQL on Server3 either as a Docker container or native install. If using Docker, use the `postgres:15` image and persist data at `/var/lib/postgresql/data`.
4. Set secrets in Coolify (Secrets / Environment variables) for the backend service:
   - `DATABASE_URL=postgres://appuser:StrongPass123@SERVER3_IP:5432/appdb`
   - `NODE_ENV=production`
5. Configure domain and enable SSL from Coolify for the frontend/backend routes.
6. Test endpoints:
   - `GET https://api.yourdomain.com/health`
   - `GET https://api.yourdomain.com/users`

## Notes
- The backend will read `DATABASE_URL` env var.
- `db-init/init.sql` contains DB schema and sample seed. Run it on Server3 Postgres once.

If you want, I can:
- Push this repo to your GitHub (you provide a token or create the repo and I'll give you `git` commands).
- Generate GitHub Actions to build Docker images and push to a registry.