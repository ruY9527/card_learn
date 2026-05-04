# Local Development Setup Guide

## Required Services

| Service | Version | Port | Notes |
|---------|---------|------|-------|
| MySQL | 8.0 | 3306 | Via Docker or local install |
| Redis | 7.x | 6379 | Via Docker or local install |
| JDK | 17 (preferred) or 8 | — | Set `JAVA_HOME` accordingly |
| Maven | 3.8+ | — | For backend builds |
| Node.js | 18+ | — | For frontend builds |
| Xcode | 15+ | — | iOS app only |

## Quick Start with Docker

```bash
# Copy environment config
cp .env.example .env

# Start all services (MySQL, Redis, backend, frontend)
docker-compose up -d

# Verify services
docker-compose ps
```

## Manual Setup

### 1. MySQL

```bash
# Start MySQL (Docker)
docker run -d --name card-learn-mysql \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=card_learn \
  -p 3306:3306 \
  mysql:8.0

# Import schema and seed data
mysql -uroot -p123456 card_learn < sql/V1__init_schema.sql
# ... import remaining V2-V7 files in order
```

### 2. Redis

```bash
docker run -d --name card-learn-redis -p 6379:6379 redis:7-alpine
```

### 3. Backend

```bash
cd card-learn-boot

# Build
mvn clean package -DskipTests

# Run (with config)
java -jar target/card-learn-boot-*.jar --spring.config.location=file:conf/application.yml
```

Or use the startup script:
```bash
./start-backend.sh
```

### 4. Frontend

```bash
cd card-ui
npm install
npm run dev
```

Or use the startup script:
```bash
./start-web.sh
```

## Configuration Values to Change

| File | Key | Default | Change To |
|------|-----|---------|-----------|
| `card-learn-boot/conf/application.yml` | `spring.datasource.password` | placeholder | `123456` (or your MySQL password) |
| `card-learn-boot/conf/application.yml` | `spring.redis.host` | placeholder | `localhost` |
| `.env` | `MYSQL_ROOT_PASSWORD` | `123456` | Your actual password |

## Known Field Name Mappings (Frontend ↔ Backend)

| Frontend JSON Key | Backend VO Field | Notes |
|-------------------|------------------|-------|
| `totalDays` | `totalStudyDays` | Stats page — mismatch caused 0 data bug |
| `appUserId` | `userId` | Login/session — mismatch caused auth failure |

## Verification Script

```bash
#!/bin/bash
echo "=== Checking services ==="

# MySQL
mysql -uroot -p123456 -e "SELECT 1" 2>/dev/null && echo "MySQL: OK" || echo "MySQL: FAIL"

# Redis
redis-cli ping 2>/dev/null && echo "Redis: OK" || echo "Redis: FAIL"

# Backend
curl -sf http://localhost:8080/doc.html > /dev/null && echo "Backend: OK" || echo "Backend: FAIL"

# Frontend
curl -sf http://localhost:5173 > /dev/null && echo "Frontend: OK" || echo "Frontend: FAIL"
```
