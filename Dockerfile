# ─────────────────────────────────────────────────────────────
# AXMEDIA Premium – Astro Static Site (Production Dockerfile)
# Multi-stage build for minimal image size
# ─────────────────────────────────────────────────────────────

# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Build the static site
RUN npm run build

# Stage 2: Runtime (nginx)
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config (optional but recommended)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built site from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
