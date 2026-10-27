# run-zap-dast.ps1 - OWASP ZAP DAST for EmailingService (TEST01-TEST05)
# Location: .cursor/scripts/agents/security_testing_reviewer/run-zap-dast.ps1
# Requires: Docker (zaproxy/zaproxy:stable), Java 17, Maven, PostgreSQL on localhost:5432
# Config:   AI/agents/security_reviewers/security_testing_reviewer/.zap/automation.yaml
# Output:   AI/agents/security_reviewers/security_testing_reviewer/zap-report.html
#           AI/agents/security_reviewers/security_testing_reviewer/zap-report.json

param(
    [string]$TargetUrl = "http://localhost:8080",
    [int]$AppStartupWaitSeconds = 120
)

$ErrorActionPreference = "Stop"

$ScanOutputRel = "AI/agents/security_reviewers/security_testing_reviewer"
$ZapPlanRel = "$ScanOutputRel/.zap/automation.yaml"

function Find-ProjectRoot {
    param([string]$StartDir)
    $dir = $StartDir
    while ($dir) {
        if (Test-Path (Join-Path $dir "pom.xml")) { return $dir }
        $parent = Split-Path $dir -Parent
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

function Import-ProjectDotEnv {
    param([string]$Root)
    $envFile = Join-Path $Root ".env"
    if (-not (Test-Path $envFile)) { return }
    Get-Content $envFile -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) { return }
        if ($line.StartsWith("#")) { return }
        if ($line -notmatch '^([^=]+)=(.*)$') { return }
        $key = $Matches[1].Trim()
        $val = $Matches[2].Trim()
        if ($val.Length -ge 2) {
            if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        if ([string]::IsNullOrWhiteSpace($key)) { return }
        if (-not [string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($key))) { return }
        [Environment]::SetEnvironmentVariable($key, $val, "Process")
    }
}

function Test-CommandOnPath {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Wait-ForHealth {
    param([string]$Url, [int]$MaxSeconds)
    $deadline = (Get-Date).AddSeconds($MaxSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $resp = Invoke-WebRequest -Uri "$Url/actuator/health/liveness" -UseBasicParsing -TimeoutSec 5
            if ($resp.StatusCode -eq 200) { return $true }
        }
        catch { }
        Start-Sleep -Seconds 3
    }
    return $false
}

$Root = Find-ProjectRoot -StartDir $PSScriptRoot
if (-not $Root) {
    Write-Host "ERROR: Could not locate project root (pom.xml)." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Set-Location $Root
Import-ProjectDotEnv -Root $Root

if (-not (Test-CommandOnPath "docker")) {
    Write-Host "ERROR: docker not on PATH — required for OWASP ZAP." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 2
}

$mvn = if (Test-Path (Join-Path $Root "mvnw.cmd")) { Join-Path $Root "mvnw.cmd" } else { "mvn" }

$zapUser = if ($env:DAST_ZAP_USERNAME) { $env:DAST_ZAP_USERNAME } else { "dast-zap-user" }
$zapPass = if ($env:DAST_ZAP_PASSWORD) { $env:DAST_ZAP_PASSWORD } else { "dast-zap-ci-not-for-production" }
[Environment]::SetEnvironmentVariable("ZAP_AUTH_USER", $zapUser, "Process")
[Environment]::SetEnvironmentVariable("ZAP_AUTH_PASSWORD", $zapPass, "Process")
[Environment]::SetEnvironmentVariable("SPRING_PROFILES_ACTIVE", "prod,dast", "Process")
[Environment]::SetEnvironmentVariable("EMAILINGSERVICE_REQUIRE_HTTPS", "false", "Process")
[Environment]::SetEnvironmentVariable("EMAILINGSERVICE_SESSION_COOKIE_SECURE", "false", "Process")

if (-not $env:emailing.service.db.user) {
    [Environment]::SetEnvironmentVariable("emailing.service.db.user", "dast", "Process")
}
if (-not $env:emailing.service.db.password) {
    [Environment]::SetEnvironmentVariable("emailing.service.db.password", "dast", "Process")
}

$scanOutputDir = Join-Path $Root ($ScanOutputRel -replace '/', [IO.Path]::DirectorySeparatorChar)
New-Item -ItemType Directory -Force -Path $scanOutputDir | Out-Null

Write-Host "Building JAR..." -ForegroundColor Cyan
& $mvn -B -DskipTests package
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Maven build failed." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 3
}

$jar = Get-ChildItem -Path (Join-Path $Root "target") -Filter "*.jar" |
    Where-Object { $_.Name -notmatch "sources|javadoc|original" } |
    Select-Object -First 1
if (-not $jar) {
    Write-Host "ERROR: No application JAR in target/." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 4
}

Write-Host "Starting application ($($jar.Name)) with profiles prod,dast..." -ForegroundColor Cyan
$appLog = Join-Path $scanOutputDir "dast-app.log"
$appProc = Start-Process -FilePath "java" -ArgumentList @("-jar", $jar.FullName) `
    -RedirectStandardOutput $appLog -RedirectStandardError $appLog -PassThru -NoNewWindow

$zapExit = 0
try {
    if (-not (Wait-ForHealth -Url $TargetUrl -MaxSeconds $AppStartupWaitSeconds)) {
        Write-Host "ERROR: Application did not become healthy. See $appLog" -ForegroundColor Red
        if (Test-Path $appLog) { Get-Content $appLog -Tail 80 }
        Read-Host "Press Enter to exit"
        exit 5
    }

    Write-Host "Running OWASP ZAP Automation Framework plan..." -ForegroundColor Cyan
    docker run --rm `
        -v "${Root}:/zap/wrk:rw" `
        -e "ZAP_AUTH_USER=$zapUser" `
        -e "ZAP_AUTH_PASSWORD=$zapPass" `
        ghcr.io/zaproxy/zaproxy:stable `
        zap.sh -cmd -autorun "/zap/wrk/$ZapPlanRel"

    $zapExit = $LASTEXITCODE
    if (Test-Path (Join-Path $scanOutputDir "zap-report.html")) {
        Write-Host "ZAP HTML report: $ScanOutputRel/zap-report.html" -ForegroundColor Green
    }
    if (Test-Path (Join-Path $scanOutputDir "zap-report.json")) {
        Write-Host "ZAP JSON report: $ScanOutputRel/zap-report.json" -ForegroundColor Green
    }

    if ($zapExit -ne 0) {
        Write-Host "ZAP completed with exit code $zapExit (review $ScanOutputRel and accepted-risks.md)." -ForegroundColor Yellow
    }
    else {
        Write-Host "ZAP scan completed successfully." -ForegroundColor Green
    }
}
finally {
    if ($appProc -and -not $appProc.HasExited) {
        Stop-Process -Id $appProc.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Read-Host "Press Enter to exit"
exit $zapExit
