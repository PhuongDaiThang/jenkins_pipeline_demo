#!/usr/bin/env bash
set -euo pipefail

wait_for_url() {
  local url="$1"
  local name="$2"

  echo "Waiting for ${name} at ${url}"
  for i in {1..30}; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "${name} is ready."
      return 0
    fi
    echo "${name} is not ready yet. Retry ${i}/30..."
    sleep 2
  done

  echo "${name} did not become ready at ${url}."
  return 1
}

docker compose up --build -d
wait_for_url http://localhost:8080/api/hello Backend
wait_for_url http://localhost:5174 Frontend

echo "App is running:"
echo "- Backend:  http://localhost:8080/api/hello"
echo "- Frontend: http://localhost:5174"
