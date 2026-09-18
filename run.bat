@echo off
title PulsePoll Launcher
echo ===================================================
echo           PulsePoll Live Polling Engine            
echo ===================================================
echo Checking services...

:: Check Redis
powershell -Command "if (-not (Get-Process redis-server -ErrorAction SilentlyContinue)) { Start-Process -NoNewWindow 'C:\Users\Lenovo\AppData\Local\Microsoft\WinGet\Packages\taizod1024.redis-windows-fork_Microsoft.Winget.Source_8wekyb3d8bbwe\Redis-8.10.1-Windows-x64-msys2\redis-server.exe' '--save \"\" --appendonly no'; Write-Host '[Redis] Started background server.' } else { Write-Host '[Redis] Already running.' }"

:: Start Backend in separate window if not listening on 8080
powershell -Command "$con = Test-NetConnection -Port 8080 -ComputerName 127.0.0.1 -WarningAction SilentlyContinue; if (-not $con.TcpTestSucceeded) { Start-Process -FilePath 'C:\Program Files\Go\bin\go.exe' -ArgumentList 'run ./cmd/server' -WorkingDirectory 'c:\Users\Lenovo\Desktop\guvi\backend'; Write-Host '[Backend] Started Go Gin server on port 8080.' } else { Write-Host '[Backend] Already running on port 8080.' }"

:: Start Frontend if not listening on 5173
powershell -Command "$con = Test-NetConnection -Port 5173 -ComputerName 127.0.0.1 -WarningAction SilentlyContinue; if (-not $con.TcpTestSucceeded) { Start-Process -FilePath 'cmd.exe' -ArgumentList '/c npm.cmd run dev -- --port 5173 --host' -WorkingDirectory 'c:\Users\Lenovo\Desktop\guvi\frontend'; Write-Host '[Frontend] Started Vite React server on port 5173.' } else { Write-Host '[Frontend] Already running on port 5173.' }"

:: Wait and open browser
timeout /t 2 >nul
echo Opening PulsePoll in your default browser...
start http://localhost:5173

echo.
echo PulsePoll is live at: http://localhost:5173
echo Backend API is live at: http://localhost:8080
echo.
pause
