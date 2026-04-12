# stop — append session marker to tasks/todo.md
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$status = ''
if ($raw -match '"status"\s*:\s*"([^"]*)"') { $status = $Matches[1] }
$conv = ''
if ($raw -match '"conversation_id"\s*:\s*"([^"]*)"') { $conv = $Matches[1] }
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$todo = Join-Path $repoRoot 'tasks\todo.md'
$dir = Split-Path -Parent $todo
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
if (-not (Test-Path -LiteralPath $todo)) {
  Set-Content -LiteralPath $todo -Value "# Active Tasks`n"
}
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm'
Add-Content -LiteralPath $todo -Value "`n---`n<!-- session-end | id: $conv | status: $status | $ts -->`n"
if ($status -ne 'completed') {
  Add-Content -LiteralPath $todo -Value "## INTERRUPTED SESSION — $ts`nStatus: $status — review before continuing.`n"
}
Write-Output '{}'
exit 0
