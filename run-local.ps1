param(
    [int]$StartService = 1,
    [int]$EndService = 15
)

$ErrorActionPreference = "Stop"

Write-Host "=== Starting Microservices (svc$StartService ~ svc$EndService) ===" -ForegroundColor Cyan

for ($i = $StartService; $i -le $EndService; $i++) {
    $name = "svc$i"
    $port = 9000 + $i
    
    Write-Host "Starting $name on port $port..." -ForegroundColor Yellow
    
    Start-Job -ScriptBlock { 
        param($name, $port)
        $env:SERVICE_NAME = $name
        $env:LISTEN_ADDR = ":$port"
        $env:SERVICE_ENV = "baseline"
        ./bin/$name
    } -ArgumentList $name, port -Name $name
}

Write-Host ""
Write-Host "All services started!" -ForegroundColor Green
Write-Host "Entrypoint: http://localhost:9001" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test commands:" -ForegroundColor White
Write-Host "  Baseline:   curl http://localhost:9001/?n=10" -ForegroundColor Gray
Write-Host "  Swimlane:   curl -H 'x-env: feature-101' http://localhost:9001/?n=10" -ForegroundColor Gray
