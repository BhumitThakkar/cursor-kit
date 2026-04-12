# beforeShellExecution — block dangerous shell patterns (bash script parity).
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$command = ''
if ($raw -match '"command"\s*:\s*"([^"]*)"') { $command = [Regex]::Unescape($Matches[1]) }

if ($command -match 'rm\s+-rf\s+(/|~|\.\.|\.cursor|tasks|src|target)') {
  Write-Output '{"permission":"deny","user_message":"Blocked: recursive delete of critical path.","agent_message":"BLOCKED by security-guard: rm -rf on critical path."}'
  exit 0
}
if ($command -match 'git push.*(origin\s+)?(main|master)\s*$') {
  Write-Output '{"permission":"deny","user_message":"Blocked: direct push to main/master.","agent_message":"BLOCKED by security-guard: use feature branch + PR."}'
  exit 0
}
if ($command -match '(?i)(drop\s+database|drop\s+table|truncate\s+table)') {
  Write-Output '{"permission":"deny","user_message":"Blocked: destructive database command.","agent_message":"BLOCKED by security-guard: destructive DB command."}'
  exit 0
}
if ($command -match '(curl|wget).+\|\s*(bash|sh|zsh)') {
  Write-Output '{"permission":"deny","user_message":"Blocked: remote pipe to shell.","agent_message":"BLOCKED by security-guard: curl|bash supply-chain risk."}'
  exit 0
}
if ($command -match 'chmod\s+777') {
  Write-Output '{"permission":"ask","question":"chmod 777 removes all access restrictions. Is this intentional?","user_message":"chmod 777 detected — confirm.","agent_message":"security-guard: chmod 777 needs confirmation."}'
  exit 0
}

Write-Output '{}'
exit 0
