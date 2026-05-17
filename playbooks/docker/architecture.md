# Docker Architecture

## Preferred Stack

- Docker Engine 24+
- Docker BuildKit
- Multi-stage builds
- Non-root users
- Read-only filesystems where possible
- `.dockerignore` for every project

## Core Principles

1. Images must be minimal — only what the runtime needs
2. Builds must be reproducible — pin base image digests in production
3. Secrets must never appear in layers — use build secrets or runtime env
4. One process per container — let orchestrators manage multiple services

---

## Multi-Stage Build Pattern

### Node.js / TypeScript

```dockerfile
# syntax=docker/dockerfile:1

# --- Build stage ---
FROM node:20-alpine AS build

WORKDIR /app

# Copy dependency manifests first (better cache locality)
COPY package*.json ./
RUN npm ci --frozen-lockfile

# Copy source and build
COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --production

# --- Runtime stage ---
FROM node:20-alpine AS runtime

# Security: create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S app -u 1001 -G nodejs

WORKDIR /app

# Copy only what's needed at runtime
COPY --from=build --chown=app:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=app:nodejs /app/dist ./dist
COPY --from=build --chown=app:nodejs /app/package.json ./

USER app

EXPOSE 3000

# Use exec form to handle signals properly
CMD ["node", "dist/main.js"]
```

### Python / FastAPI

```dockerfile
# syntax=docker/dockerfile:1

FROM python:3.12-slim AS build

WORKDIR /app

# Install build deps
RUN pip install --no-cache-dir uv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-editable

COPY src ./src

# --- Runtime stage ---
FROM python:3.12-slim AS runtime

RUN useradd -r -u 1001 -g users app

WORKDIR /app

COPY --from=build --chown=app:users /app/.venv ./.venv
COPY --from=build --chown=app:users /app/src ./src

USER app

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Vue / React Frontend (NGINX)

```dockerfile
# syntax=docker/dockerfile:1

FROM node:20-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile

COPY . .
RUN npm run build

# --- Runtime stage ---
FROM nginx:1.25-alpine AS runtime

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# Non-root NGINX
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```

---

## NGINX Configuration for SPAs

```nginx
# nginx.conf
server {
  listen 8080;
  server_name _;
  root /usr/share/nginx/html;
  index index.html;

  # Security headers
  add_header X-Frame-Options "DENY" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;" always;

  # Gzip
  gzip on;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

  # Cache hashed static assets forever
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    try_files $uri =404;
  }

  # SPA fallback
  location / {
    try_files $uri $uri/ /index.html;
    add_header Cache-Control "no-cache";
  }

  # Health check endpoint
  location /health {
    return 200 "ok";
    add_header Content-Type text/plain;
  }
}
```

---

## `.dockerignore`

```dockerignore
.git
.gitignore
.env
.env.*
*.md
node_modules
dist
build
coverage
.nyc_output
.DS_Store
Thumbs.db
docker-compose*.yml
.github
docs
*.log
__pycache__
.venv
.pytest_cache
.mypy_cache
```

---

## Image Tagging Strategy

```bash
# Build with multi-platform support
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag registry.example.com/my-app:${GIT_SHA} \
  --tag registry.example.com/my-app:latest \
  --push .

# Tag on release
docker tag registry.example.com/my-app:${GIT_SHA} registry.example.com/my-app:v2.4.0
```

Tags to maintain per image:
- `latest` — most recent main branch build
- `v{semver}` — release tags
- `{git-sha}` — every build (for rollback and audit)
- `{branch-name}` — for staging environments

---

## Anti-Patterns to Avoid

```dockerfile
# ❌ Running as root
FROM node:20-alpine
CMD ["node", "server.js"]  # Runs as root by default

# ❌ Installing unnecessary tools
RUN apt-get install -y vim curl wget git build-essential

# ❌ Secrets baked into layers
ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}  # Visible in docker history

# ❌ Not pinning base image — breaks reproducibility
FROM node:latest

# ❌ Cache-busting every build by copying before npm install
COPY . .
RUN npm install

# ❌ Using ADD when COPY is sufficient
ADD https://example.com/binary /usr/local/bin/tool
```
