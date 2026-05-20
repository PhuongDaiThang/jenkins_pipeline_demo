Write-Host "Starting backend in a new PowerShell window..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; mvn spring-boot:run"

Start-Sleep -Seconds 8
Invoke-RestMethod http://localhost:8080/api/hello

Write-Host "Starting frontend..."
cd frontend
npm install
npm run dev
