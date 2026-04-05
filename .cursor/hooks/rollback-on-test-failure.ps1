#Requires -Version 5.1
<#
.SYNOPSIS
  Placeholder for "rollback when tests fail after deploy".
.DESCRIPTION
  In a real setup this would: call your deployment API to rollback, or run
  a rollback script (e.g. revert to previous Docker image / k8s revision).
  This script exits 1 so CI marks the job as failed; implement actual rollback
  in your pipeline (e.g. GitHub Actions step that runs on failure).
.EXAMPLE
  # In CI, run after deploy + health check:
  .\run-tests.ps1; if ($LASTEXITCODE -ne 0) { .\rollback-on-test-failure.ps1; exit 1 }
#>
param(
  [string]$RollbackScript = $env:ROLLBACK_SCRIPT  # Optional: path to your rollback script
)
Write-Warning "Post-deploy test failure: rollback required."
if ($RollbackScript -and (Test-Path $RollbackScript)) {
  & $RollbackScript
  exit $LASTEXITCODE
}
Write-Output "Set ROLLBACK_SCRIPT to your rollback script for automatic rollback. Exiting 1 to fail pipeline."
exit 1
