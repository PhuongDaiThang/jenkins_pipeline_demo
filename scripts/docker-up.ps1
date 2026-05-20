function Wait-Url {
    param(
        [string]$Url,
        [string]$Name
    )

    Write-Host "Waiting for $Name at $Url"
    for ($i = 1; $i -le 30; $i++) {
        try {
            Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 | Out-Null
            Write-Host "$Name is ready."
            return
        }
        catch {
            Write-Host "$Name is not ready yet. Retry $i/30..."
            Start-Sleep -Seconds 2
        }
    }

    throw "$Name did not become ready at $Url."
}

docker compose up --build -d
Wait-Url "http://localhost:8080/api/hello" "Backend"
Wait-Url "http://localhost:5174" "Frontend"

Write-Host "App is running:"
Write-Host "- Backend:  http://localhost:8080/api/hello"
Write-Host "- Frontend: http://localhost:5174"
