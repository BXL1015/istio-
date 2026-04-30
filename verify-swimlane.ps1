param(
    [string]$Swimlane = "",
    [int]$N = 10
)

$baseUrl = "http://localhost:9001"

Write-Host "=== Swimlane Verification ===" -ForegroundColor Cyan
Write-Host ""

if ($Swimlane -ne "") {
    Write-Host "Testing swimlane: $Swimlane" -ForegroundColor Yellow
    Write-Host "Header: x-env=$Swimlane" -ForegroundColor Gray
    Write-Host ""
    
    $response = curl.exe -s -H "x-env: $Swimlane" "$baseUrl/?n=$N"
} else {
    Write-Host "Testing baseline environment" -ForegroundColor Yellow
    Write-Host ""
    
    $response = curl.exe -s "$baseUrl/?n=$N"
}

Write-Host "Response:" -ForegroundColor Green
Write-Host $response
