param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$true)]
    [string]$Services,
    
    [string]$ImageTag = "main",
    
    [string]$Owner = "bxl1015",
    
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$swimlaneDir = "k8s/swimlanes/$Name"

if (Test-Path $swimlaneDir) {
    if ($Overwrite) {
        Remove-Item -Recurse -Force $swimlaneDir
    } else {
        Write-Error "Swimlane '$Name' already exists. Use -Overwrite to replace it."
    }
}

New-Item -ItemType Directory -Path $swimlaneDir -Force | Out-Null

$serviceList = $Services -split ',' | ForEach-Object { $_.Trim() }

$validServices = @("svc1","svc2","svc3","svc4","svc5","svc6","svc7","svc8","svc9","svc10","svc11","svc12","svc13","svc14","svc15")

foreach ($svc in $serviceList) {
    if ($svc -notin $validServices) {
        Write-Error "Invalid service: $svc. Valid services are: $($validServices -join ', ')"
    }
}

foreach ($svc in $serviceList) {
    $yaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $svc-$Name
  labels:
    app: $svc
    env: baseline
    swimlane: "true"
    swimlane-name: $Name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $svc
      swimlane-name: $Name
  template:
    metadata:
      labels:
        app: $svc
        env: baseline
        swimlane: "true"
        swimlane-name: $Name
    spec:
      containers:
        - name: $svc
          image: ghcr.io/$Owner/gitops-lane-$svc`:$ImageTag
          imagePullPolicy: Always
          env:
            - name: SERVICE_NAME
              value: $svc
            - name: SERVICE_ENV
              value: $Name
          resources:
            limits:
              memory: 128Mi
            requests:
              memory: 64Mi
          ports:
            - name: http
              containerPort: 9000
"@
    
    $yaml | Out-File -FilePath "$swimlaneDir/$svc.yaml" -Encoding utf8
    Write-Host "Created: $swimlaneDir/$svc.yaml"
}

$readmeContent = @"
# Swimlane: $Name

## Services

$($serviceList | ForEach-Object { "- $_" })

## Usage

``````bash
curl -H "x-env: $Name" http://<svc1-ip>:9000/?n=10
``````

## Image Tag

``````
$ImageTag
``````
"@

$readmeContent | Out-File -FilePath "$swimlaneDir/README.md" -Encoding utf8

Write-Host ""
Write-Host "Swimlane '$Name' created successfully!"
Write-Host "Directory: $swimlaneDir"
Write-Host "Services: $($serviceList -join ', ')"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review the generated files"
Write-Host "  2. Commit and push to Git"
Write-Host "  3. ArgoCD will automatically sync the new swimlane"
