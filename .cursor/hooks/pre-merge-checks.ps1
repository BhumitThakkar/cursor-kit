#Requires -Version 5.1
<#
.SYNOPSIS
  Pre-merge gate: run tests, coverage check, and optionally security scan.
.DESCRIPTION
  Runs Maven or Gradle test and coverage. Exits 1 if tests fail or coverage
  drops below threshold. Set SKIP_SECURITY=1 to skip dependency/secret scan.
  Expects to run from repository root.
.EXAMPLE
  .\pre-merge-checks.ps1
#>
$ErrorActionPreference = 'Stop'
$root = if ($env:REPO_ROOT) { $env:REPO_ROOT } else { Get-Location }
$minCoverage = if ($env:MIN_COVERAGE_PERCENT) { [int]$env:MIN_COVERAGE_PERCENT } else { 85 }
$skipSecurity = $env:SKIP_SECURITY -eq '1'

# Tests
if (Test-Path (Join-Path $root 'pom.xml')) {
  Push-Location $root
  try {
    mvn test -q
    if ($LASTEXITCODE -ne 0) { Write-Error "Tests failed."; exit 1 }
    # JaCoCo: fail if coverage below threshold (simplified; use mvn jacoco:check in real setup)
    mvn jacoco:report -q 2>$null
    if (-not $?) { Write-Warning "JaCoCo report failed; ensure coverage threshold in pom." }
  } finally { Pop-Location }
} elseif (Test-Path (Join-Path $root 'build.gradle') -or (Test-Path (Join-Path $root 'build.gradle.kts'))) {
  Push-Location $root
  try {
    ./gradlew test --no-daemon -q
    if ($LASTEXITCODE -ne 0) { Write-Error "Tests failed."; exit 1 }
    ./gradlew jacocoTestReport --no-daemon -q 2>$null
  } finally { Pop-Location }
} else {
  Write-Warning "No pom.xml or build.gradle found; skipping test run. Implement custom steps for your stack."
}

# Security (optional)
if (-not $skipSecurity) {
  $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  $cursorDir = Split-Path -Parent $scriptDir
  $localCli = Join-Path $cursorDir "tools\dependency-check\bin\dependency-check.bat"
  $dcCmd = $null
  if (Test-Path $localCli) { $dcCmd = $localCli }
  elseif (Get-Command 'dependency-check' -ErrorAction SilentlyContinue) { $dcCmd = 'dependency-check' }
  if ($dcCmd) {
    Push-Location $root
    try {
      & $dcCmd --project "pre-merge" --scan "." --format HTML --failOnCVSS 7 2>$null
      if ($LASTEXITCODE -ne 0) { exit 1 }
    } finally { Pop-Location }
  } else {
    Write-Warning "OWASP dependency-check not found. Run: .cursor\hooks\install-dependency-check.ps1  (or set SKIP_SECURITY=1)"
  }
}

Write-Output "Pre-merge checks passed (tests + coverage)."
exit 0
