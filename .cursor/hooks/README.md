# Safety Hooks for Multi-Agent Framework

These hooks enforce orchestrator and agent safety mechanisms. Wire them into your CI pipeline or git hooks (e.g. pre-push, pre-deploy).

## Scripts

| Script | Purpose | When to run |
|--------|---------|-------------|
| `deploy-rate-limit.ps1` | Enforce max deploys per day (e.g. 10) | Before deploy (CI or manual) |
| `rollback-on-test-failure.ps1` | Trigger rollback when tests fail post-deploy | After deploy health check |
| `emergency-kill.ps1` | Halt automated deploys (kill switch) | Manual when needed |
| `pre-merge-checks.ps1` | Security scan, coverage, tests (code review gate) | Before merge / in CI |

## Configuration

- **Deploy count**: Stored in `deploy-count.json` (or env `DEPLOY_COUNT_FILE`). Reset daily or per calendar day.
- **Kill switch**: Set env `AGENT_DEPLOY_KILL_SWITCH=1` or create file `hooks/.kill-switch` to block deploys.
- **Paths**: Scripts assume they are run from repo root or with `$PSScriptRoot`; adjust paths for your layout.

## Wiring into CI (example)

```yaml
# Before deploy
- run: .cursor/hooks/deploy-rate-limit.ps1
- run: .cursor/hooks/pre-merge-checks.ps1  # if not already in PR pipeline

# After deploy (e.g. GitHub Actions)
- run: .cursor/hooks/rollback-on-test-failure.ps1
  if: failure()
```

## Wiring into Git

```bash
# .git/hooks/pre-push
#!/bin/sh
# On Windows with Git Bash, or use PowerShell.exe -File
powershell.exe -NoProfile -File .cursor/hooks/pre-merge-checks.ps1
exit $?
```

## Installing OWASP Dependency-Check

Required for the security step in `pre-merge-checks.ps1`. **Java 8+** must be installed.

**Option A – Local install (recommended, no PATH change):**
```powershell
cd .cursor\hooks
.\install-dependency-check.ps1
```
Installs to `.cursor\tools\dependency-check`. The pre-merge script uses this path automatically.

**Option B – Manual:** Download [dependency-check CLI](https://github.com/dependency-check/DependencyCheck/releases) zip, extract, and add the `bin` directory to your PATH. The script will use `dependency-check` from PATH if the local install is not present.

**Note:** When running the CLI (or pre-merge-checks), `java` must be on PATH or `JAVACMD` set (e.g. to `C:\Program Files\Java\jdk-21\bin\java.exe`). The `.bat` uses `java` to launch the JAR.

## Requirements

- PowerShell 5.1+ (Windows) or PowerShell Core (cross-platform).
- For `pre-merge-checks`: Maven/Gradle and project test/coverage commands; Java 8+ and OWASP Dependency-Check for security scan (see above).
