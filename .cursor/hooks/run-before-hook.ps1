# Cursor beforeShellExecution wrapper: run a script, output {"permission":"allow"|"deny"} from exit code.
# Usage: ./hooks/run-before-hook.ps1 ScriptName.ps1 [workspace]
# If second arg is "workspace", run script from first workspace root (from stdin JSON).
param([string]$ScriptName, [string]$RunFrom = '')
$ErrorActionPreference = 'Stop'
$hooksDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $hooksDir $ScriptName

$stdin = [System.Console]::In.ReadToEnd()
$cwd = $null
if ($RunFrom -eq 'workspace' -and $stdin) {
    try {
        $obj = $stdin | ConvertFrom-Json
        if ($obj.workspace_roots -and $obj.workspace_roots.Count -gt 0) {
            $cwd = $obj.workspace_roots[0]
        }
    } catch { }
}

if ($cwd -and (Test-Path $cwd)) { Push-Location $cwd }
try {
    & $scriptPath
    $code = $LASTEXITCODE
    if ($code -eq 0) { Write-Output '{"permission":"allow"}' }
    else { Write-Output ('{"permission":"deny","reason":"' + $ScriptName + ' failed (exit ' + $code + ')"}') }
} finally {
    if ($cwd -and (Test-Path $cwd)) { Pop-Location }
}
