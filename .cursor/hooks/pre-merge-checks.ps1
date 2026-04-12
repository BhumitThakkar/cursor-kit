# Runs tests before git push/merge when wired via run-before-hook. Args: optional "workspace".
# Exit 0 pass, 1 fail.
$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Push-Location $repoRoot
try {
  if (Test-Path -LiteralPath 'pom.xml') {
    & mvn -q test
    if ($LASTEXITCODE -ne 0) { exit 1 }
  }
  elseif (Test-Path -LiteralPath 'package.json') {
    if (Test-Path -LiteralPath 'pnpm-lock.yaml') { & pnpm test }
    elseif (Test-Path -LiteralPath 'yarn.lock') { & yarn test }
    else { & npm test }
    if ($LASTEXITCODE -ne 0) { exit 1 }
  }
}
finally {
  Pop-Location
}
exit 0
