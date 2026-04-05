# Cursor afterShellExecution wrapper: run a script from workspace root (from stdin JSON).
# Usage: ./hooks/run-after-hook.ps1 ScriptName.ps1
param([string]$ScriptName)
$hooksDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $hooksDir $ScriptName
$stdin = [System.Console]::In.ReadToEnd()
$cwd = $null
if ($stdin) {
    try {
        $obj = $stdin | ConvertFrom-Json
        if ($obj.workspace_roots -and $obj.workspace_roots.Count -gt 0) {
            $cwd = $obj.workspace_roots[0]
        }
    } catch { }
}
if ($cwd -and (Test-Path $cwd)) { Push-Location $cwd }
try { & $scriptPath } finally { if ($cwd -and (Test-Path $cwd)) { Pop-Location } }
