# Pantheon boot - validates merged framework (PowerShell). Exit 0 always; uses issue counts in summary.
$ErrorActionPreference = 'Continue'
$PASS = '[PASS]'
$FAIL = '[FAIL]'
$WARN = '[WARN]'
$issues = 0
$warnings = 0

function Write-Divider([string]$Title) {
  Write-Output ''
  Write-Output '----------------------------------------------------------------'
  Write-Output "  $Title"
  Write-Output '----------------------------------------------------------------'
}

function Test-PathPass {
  param([string]$Label, [string]$Path)
  if (Test-Path -LiteralPath $Path) {
    Write-Output "  $PASS $Label"
  } else {
    Write-Output "  $FAIL $Label - MISSING: $Path"
    $script:issues++
  }
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repoRoot

Write-Output ''
Write-Output '================================================================'
Write-Output '       PANTHEON BOOT - cmd-initiate'
Write-Output '================================================================'
Write-Output ("  {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

Write-Divider '1 / DIRECTORY STRUCTURE'
Test-PathPass '.cursor root' '.cursor'
Test-PathPass 'rules/' '.cursor\rules'
Test-PathPass 'agents/' '.cursor\agents'
Test-PathPass 'skills/' '.cursor\skills'
Test-PathPass 'hooks/' '.cursor\hooks'
Test-PathPass 'commands/' '.cursor\commands'

Write-Divider '2 / RULES (.cursor/rules/*.mdc)'
$rules = @(
  @('sovereign-dev-manifesto', '.cursor\rules\sovereign-dev-manifesto.mdc'),
  @('wheel-of-problem-solving', '.cursor\rules\wheel-of-problem-solving.mdc'),
  @('zeus-pm', '.cursor\rules\zeus-pm.mdc'),
  @('agent-roster', '.cursor\rules\agent-roster.mdc'),
  @('on-the-fly-protocol', '.cursor\rules\on-the-fly-protocol.mdc'),
  @('memory', '.cursor\rules\memory.mdc'),
  @('quality-gates', '.cursor\rules\quality-gates.mdc'),
  @('tool-registry', '.cursor\rules\tool-registry.mdc'),
  @('security-review', '.cursor\rules\security-review.mdc')
)
foreach ($r in $rules) { Test-PathPass $r[0] $r[1] }

Write-Divider '3 / AGENTS (.cursor/agents/)'
@(
  'backend-dev', 'frontend-dev', 'qa-engineer', 'security-auditor', 'code-reviewer', 'devops-engineer',
  'architect', 'builder', 'zeus-pm', 'requirements-analyst', 'api-contract', 'database', 'debugging',
  'documentation', 'self-improvement', 'skills-manager', 'rules-manager', 'hook-manager',
  'commands-manager', 'subagents-manager', 'security-reviewer'
) | ForEach-Object { Test-PathPass $_ ".cursor\agents\$_.md" }

Write-Divider '4 / SKILLS (.cursor/skills/*/SKILL.md)'
@(
  'adr-generator', 'api-contract', 'commands-manager', 'database', 'debugging', 'documentation',
  'hook-manager', 'lessons-summarizer', 'mermaid-diagrams', 'owasp-checklist', 'requirements-analyst',
  'rules-manager', 'security-reviewer', 'self-improvement', 'skills-manager', 'spring-boot-patterns',
  'subagents-manager', 'test-coverage-check', 'thymeleaf-patterns', 'validate-spring-dto'
) | ForEach-Object { Test-PathPass $_ ".cursor\skills\$_\SKILL.md" }

Write-Divider '5 / INDEX + LEARNING'
Test-PathPass 'AGENTS.md' '.cursor\AGENTS.md'
Test-PathPass 'learning-log.md' '.cursor\learning-log.md'
Test-PathPass 'disabled list' '.cursor\agents\disabled.txt'

Write-Divider '6 / COMMANDS'
Test-PathPass 'cmd-initiate' '.cursor\commands\cmd-initiate.md'
Test-PathPass 'cmd-review-project-security' '.cursor\commands\cmd-review-project-security.md'
Test-PathPass 'cmd-security-scan' '.cursor\commands\cmd-security-scan.md'
Test-PathPass 'cmd-dependency-audit' '.cursor\commands\cmd-dependency-audit.md'
Test-PathPass 'cmd-uml-diagrams' '.cursor\commands\cmd-uml-diagrams.md'

Write-Divider '7 / HOOKS (.ps1)'
Test-PathPass 'hooks.json' '.cursor\hooks.json'
@(
  'session-init.ps1', 'task-close.ps1', 'quality-check.ps1', 'security-guard.ps1', 'mcp-audit.ps1',
  'gate-check.ps1', 'cmd-initiate.ps1', 'check-kill-switch.ps1', 'deploy-rate-limit.ps1',
  'emergency-kill.ps1', 'pre-merge-checks.ps1', 'rollback-on-test-failure.ps1', 'run-before-hook.ps1',
  'run-after-hook.ps1', 'cursor-allow.ps1', 'cursor-continue.ps1',
  'cursor-decision-allow.ps1', 'subagent-trace.ps1', 'install-dependency-check.ps1'
) | ForEach-Object { Test-PathPass $_ ".cursor\hooks\$_" }

Write-Divider '8 / SECURITY REVIEW BUNDLE (repo root)'
Test-PathPass 'security-review/improvements-pending' 'security-review\improvements-pending.md'
Test-PathPass 'security-review/README bundle' 'security-review\security-review.md'

Write-Divider '9 / MEMORY (tasks/)'
if (-not (Test-Path -LiteralPath 'tasks')) {
  Write-Output "  $WARN tasks/ missing"
  $warnings++
} else {
  Write-Output "  $PASS tasks/ directory"
}
foreach ($m in @('tasks\todo.md', 'tasks\lessons.md', 'tasks\decisions.md')) {
  $name = Split-Path $m -Leaf
  if (-not (Test-Path -LiteralPath $m)) {
    Write-Output "  $WARN $name missing"
    $warnings++
  }
  elseif ((Get-Item $m).Length -eq 0) {
    Write-Output "  $WARN $name empty (Zeus will populate on first use)"
    $warnings++
  }
  else {
    $lines = @(Get-Content -LiteralPath $m).Count
    Write-Output "  $PASS $name - $lines lines"
  }
}

Write-Output ''
Write-Output '================================================================'
Write-Output '  SUMMARY'
Write-Output '================================================================'
Write-Output ("  Blocking issues : {0}" -f $issues)
Write-Output ("  Warnings        : {0}" -f $warnings)
Write-Output ''

if ($issues -eq 0 -and $warnings -eq 0) {
  Write-Output "  STATUS: ALL SYSTEMS NOMINAL"
}
elseif ($issues -eq 0) {
  Write-Output "  STATUS: SYSTEM READY WITH WARNINGS"
  Write-Output "  Zeus may be woken. Review warnings above."
}
elseif ($issues -lt 4) {
  Write-Output ("  STATUS: SYSTEM DEGRADED - {0} blocking issue(s)." -f $issues)
}
else {
  Write-Output ("  STATUS: SYSTEM CRITICAL - {0} issues found." -f $issues)
}
Write-Output ''
exit 0
