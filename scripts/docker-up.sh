#!/usr/bin/env bash
set -euo pipefail

docker compose up --build -d
curl -f http://localhost:8080/api/hello
curl -f http://localhost:3000

echo "App is running:"
echo "- Backend:  http://localhost:8080/api/hello"
echo "- Frontend: http://localhost:3000"
