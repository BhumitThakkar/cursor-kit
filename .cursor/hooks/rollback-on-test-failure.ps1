# afterShellExecution: log rollback reminder after deploy-class commands.
$null = [Console]::In.ReadToEnd()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$logDir = Join-Path $repoRoot 'tasks'
if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$log = Join-Path $logDir 'deploy-rollback.log'
Add-Content -LiteralPath $log -Value ("{0} rollback-on-test-failure: verify smoke tests; run DevOps rollback runbook if failed." -f (Get-Date -Format 'o'))
Write-Output '{}'
exit 0
