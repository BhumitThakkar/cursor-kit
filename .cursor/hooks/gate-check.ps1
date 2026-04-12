# preToolUse — remind agents of quality gates before Write/Shell.
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$toolType = ''
if ($raw -match '"type"\s*:\s*"([^"]*)"') { $toolType = $Matches[1] }

if ($toolType -eq 'Write') {
  @{ additional_context = 'GATE REMINDER: Before finalising this file — quality gate in quality-gates.mdc satisfied? Reviewer APPROVED? QA tests exist? No System.out, no hardcoded secrets, @Valid on bodies.' } | ConvertTo-Json -Compress
  exit 0
}
if ($toolType -eq 'Shell') {
  @{ additional_context = 'GATE REMINDER: If this is the final build/test step — confirm all gate criteria before telling Zeus the task is done.' } | ConvertTo-Json -Compress
  exit 0
}
Write-Output '{}'
exit 0
