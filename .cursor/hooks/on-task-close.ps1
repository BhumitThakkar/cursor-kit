# stop — when status is completed, append a deduped lesson stub to tasks/lessons.md (Zeus memory protocol)
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$status = ''
if ($raw -match '"status"\s*:\s*"([^"]*)"') { $status = $Matches[1] }
$conv = ''
if ($raw -match '"conversation_id"\s*:\s*"([^"]*)"') { $conv = $Matches[1] }
if ([string]::IsNullOrWhiteSpace($conv)) { $conv = 'unknown' }

if ($status -cne 'completed') {
  Write-Output '{}'
  exit 0
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$lessons = Join-Path $repoRoot 'tasks\lessons.md'
$dir = Split-Path -Parent $lessons
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

$marker = "<!-- on-task-close session: $conv -->"
if (Test-Path -LiteralPath $lessons) {
  $prior = Get-Content -LiteralPath $lessons -Raw
  if ($prior.Contains($marker)) {
    Write-Output '{}'
    exit 0
  }
}

$date = Get-Date -Format 'yyyy-MM-dd'
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm'
$block = @"

## $date - Session close (auto)

$marker

**What happened:** Cursor ``stop`` hook reported status ``completed`` at $ts. Replace with a full lesson (see ``memory.mdc``) after a user correction, quality-gate failure, or outcome worth preserving; delete this stub if nothing applies.

**Root cause:** _TBD_

**Prevention rule:** _TBD_

**Applies to:** Zeus / all agents

"@

if (-not (Test-Path -LiteralPath $lessons)) {
  $initial = "# Lessons`n`n" + $block.Trim() + "`n"
  Set-Content -LiteralPath $lessons -Encoding utf8 -Value $initial
  Write-Output '{}'
  exit 0
}

$content = Get-Content -LiteralPath $lessons -Raw
$content = $content -replace '(?m)^\s*_No lessons recorded yet\._\s*\r?\n?', ''
if ([string]::IsNullOrWhiteSpace($content.Trim())) {
  $content = "# Lessons`n`n"
}
elseif (-not ($content -match '(?m)^#\s+Lessons')) {
  $content = "# Lessons`n`n" + $content.TrimStart()
}
$content = $content.TrimEnd() + "`n`n" + $block.Trim() + "`n"
Set-Content -LiteralPath $lessons -Encoding utf8 -Value $content

Write-Output '{}'
exit 0
