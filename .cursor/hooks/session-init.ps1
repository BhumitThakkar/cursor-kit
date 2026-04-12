# sessionStart — surface memory files as additional_context JSON.
$ErrorActionPreference = 'Stop'
$null = [Console]::In.ReadToEnd()
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$parts = New-Object System.Collections.Generic.List[string]

$lessons = Join-Path $repoRoot 'tasks\lessons.md'
if ((Test-Path -LiteralPath $lessons) -and ((Get-Item $lessons).Length -gt 0)) {
  $parts.Add("=== LESSONS (prevention rules from past mistakes) ===`n" + (Get-Content -LiteralPath $lessons -Raw))
}
$decisions = Join-Path $repoRoot 'tasks\decisions.md'
if ((Test-Path -LiteralPath $decisions) -and ((Get-Item $decisions).Length -gt 0)) {
  $parts.Add("=== DECISIONS (architectural constraints in effect) ===`n" + (Get-Content -LiteralPath $decisions -Raw))
}
$todo = Join-Path $repoRoot 'tasks\todo.md'
if ((Test-Path -LiteralPath $todo) -and ((Get-Item $todo).Length -gt 0)) {
  $incomplete = Select-String -LiteralPath $todo -Pattern '^\-\s\[\s\]' -AllMatches
  if ($incomplete) {
    $lines = ($incomplete | ForEach-Object { $_.Line }) -join "`n"
    $parts.Add("=== INCOMPLETE TASKS from previous session ===`n" + $lines)
  }
}

if ($parts.Count -gt 0) {
  $ctx = ($parts -join "`n`n")
  @{ additional_context = $ctx } | ConvertTo-Json -Compress
} else {
  Write-Output '{}'
}
exit 0
