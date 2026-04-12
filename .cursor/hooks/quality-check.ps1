# afterFileEdit - Java + secret heuristics (parity with legacy bash hook).
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$file = ''
if ($raw -match '"file_path"\s*:\s*"([^"]*)"') { $file = $Matches[1] }
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$full = if ([string]::IsNullOrWhiteSpace($file)) { '' } elseif ([System.IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $repoRoot $file }

$issues = New-Object System.Collections.Generic.List[string]

if ($full -like '*.java' -and (Test-Path -LiteralPath $full)) {
  $content = Get-Content -LiteralPath $full -Raw
  if ($content -match 'System\.out\.println') {
    $issues.Add("[QUALITY] System.out.println in $file — use SLF4J.")
  }
  if ($content -match '"(localhost|127\.0\.0\.[0-9]+|http://[0-9]+\.[0-9]+)"') {
    $issues.Add("[QUALITY] Hardcoded URL/IP in $file — use configuration.")
  }
  if ($content -match '(TODO|FIXME|HACK|XXX):') {
    $issues.Add("[WARNING] TODO/FIXME in $file — track in tasks/todo.md.")
  }
  if ($content -match '@RestController|@Controller' -and $content -match '@RequestBody' -and $content -notmatch '@Valid') {
    $issues.Add("[QUALITY] @RequestBody without @Valid in $file.")
  }
  if ($file -notmatch '(?i)[\\/]src[\\/]test[\\/]' -and $content -match 'org\.apache\.logging\.log4j\.LogManager') {
    $issues.Add("[QUALITY] Prefer SLF4J LoggerFactory over Log4j2 LogManager in $file (project standard).")
  }
}

if ($full -and (Test-Path -LiteralPath $full)) {
  $secretPat = '(?i)(password|secret|api_key|apikey|token)\s*=\s*[''"][^''"]{4,}'
  if ((Get-Content -LiteralPath $full -Raw) -match $secretPat) {
    Write-Output "{`"permission`":`"deny`",`"user_message`":`"Possible secret in $file.`",`"agent_message`":`"BLOCKED: hardcoded secret pattern.`"}"
    exit 0
  }
}

if ($issues.Count -gt 0) {
  $msg = 'Quality issues found:`n' + ($issues -join "`n")
  @{ additional_context = $msg } | ConvertTo-Json -Compress
} else {
  Write-Output '{}'
}
exit 0
