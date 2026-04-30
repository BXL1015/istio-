param(
    [string]$Swimlane = "",
    [string]$Service = "svc1",
    [int]$N = 10
)

$baseUrl = "http://localhost:9001"

if ($Swimlane -ne "") {
    $headers = @{ "x-env" = $Swimlane }
    Write-Host "Testing swimlane: $Swimlane"
    Write-Host "Request: $baseUrl/?n=$N with header x-env=$Swimlane"
    Invoke-RestMethod -Uri "$baseUrl/?n=$N" -Headers $headers
} else {
    Write-Host "Testing baseline environment"
    Write-Host "Request: $baseUrl/?n=$N"
    Invoke-RestMethod -Uri "$baseUrl/?n=$N"
}
