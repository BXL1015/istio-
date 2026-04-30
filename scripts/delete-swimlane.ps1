param(
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$ErrorActionPreference = "Stop"

$swimlaneDir = "k8s/swimlanes/$Name"

if (-not (Test-Path $swimlaneDir)) {
    Write-Error "Swimlane '$Name' does not exist."
}

Remove-Item -Recurse -Force $swimlaneDir

Write-Host "Swimlane '$Name' deleted successfully!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Commit and push to Git"
Write-Host "  2. ArgoCD will automatically prune the swimlane resources"
