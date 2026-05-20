docker compose up --build -d
Invoke-RestMethod http://localhost:8080/api/hello
Invoke-WebRequest http://localhost:3000 | Select-Object -ExpandProperty StatusCode

Write-Host "App is running:"
Write-Host "- Backend:  http://localhost:8080/api/hello"
Write-Host "- Frontend: http://localhost:3000"
