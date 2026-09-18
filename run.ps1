# PulsePoll One-Click Launcher for PowerShell
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "          PulsePoll Live Polling Engine            " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Check Redis
$redisProc = Get-Process redis-server -ErrorAction SilentlyContinue
if (-not $redisProc) {
    Write-Host "[1/4] Starting Redis Server..." -ForegroundColor Yellow
    Start-Process -NoNewWindow "C:\Users\Lenovo\AppData\Local\Microsoft\WinGet\Packages\taizod1024.redis-windows-fork_Microsoft.Winget.Source_8wekyb3d8bbwe\Redis-8.10.1-Windows-x64-msys2\redis-server.exe" "--save `"`" --appendonly no"
} else {
    Write-Host "[1/4] Redis is running." -ForegroundColor Green
}

# 2. Check Backend
$beConn = Test-NetConnection -Port 8080 -ComputerName 127.0.0.1 -WarningAction SilentlyContinue
if (-not $beConn.TcpTestSucceeded) {
    Write-Host "[2/4] Starting Go Backend on port 8080..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Go\bin\go.exe" -ArgumentList "run ./cmd/server" -WorkingDirectory "$PSScriptRoot\backend"
    Start-Sleep -Seconds 2
} else {
    Write-Host "[2/4] Go Backend is running on port 8080." -ForegroundColor Green
}

# 3. Check Frontend
$feConn = Test-NetConnection -Port 5173 -ComputerName 127.0.0.1 -WarningAction SilentlyContinue
if (-not $feConn.TcpTestSucceeded) {
    Write-Host "[3/4] Starting Vite React Frontend on port 5173..." -ForegroundColor Yellow
    Start-Process "cmd.exe" -ArgumentList "/c npm.cmd run dev -- --port 5173 --host" -WorkingDirectory "$PSScriptRoot\frontend"
    Start-Sleep -Seconds 2
} else {
    Write-Host "[3/4] Frontend is running on port 5173." -ForegroundColor Green
}

# 4. Open in browser
Write-Host "[4/4] Opening browser to http://localhost:5173 ..." -ForegroundColor Cyan
Start-Process "http://localhost:5173"

Write-Host "`nApp URL:     http://localhost:5173" -ForegroundColor Green
Write-Host "Backend API: http://localhost:8080`n" -ForegroundColor Green
