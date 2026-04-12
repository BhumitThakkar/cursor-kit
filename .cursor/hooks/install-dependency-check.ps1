# Reserves .cursor/tools for OWASP Dependency-Check CLI; orgs install binary or use Maven plugin.
$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
$note = Join-Path $toolsDir 'README-dependency-check.txt'
Set-Content -LiteralPath $note -Value @'
OWASP Dependency-Check: install CLI to this folder or use dependency-check-maven in pom.xml.
https://jeremylong.github.io/DependencyCheck/
'@
exit 0
