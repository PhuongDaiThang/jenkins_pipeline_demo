#!/usr/bin/env bash
set -euo pipefail

echo "Starting backend..."
(cd backend && mvn spring-boot:run) &
BACKEND_PID=$!

cleanup() {
  kill "$BACKEND_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 8
curl -f http://localhost:8080/api/hello

echo "Starting frontend..."
(cd frontend && npm install && npm run dev)
