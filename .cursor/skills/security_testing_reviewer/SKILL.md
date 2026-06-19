---
name: security_testing_reviewer
version: 1.0
disable-model-invocation: true
---

# Security Testing & Assurance Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/security_testing_reviewer.md` |
| Skill directory | `.cursor/skills/security_testing_reviewer/` |
| Cursor invoke name | `security_testing_reviewer` |
| Report path | `AI/security_testing_reviewer/security_testing_reviewer_report.md` |
| Report reviewer line | `security_testing_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that should undergo security testing before production.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Release process | CI/CD pipeline, build scripts, or documented release process |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| No release pipeline | Library / utility with no deployment |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for security_testing_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with a release pipeline requiring security testing assurance.
```

---

## 2. File Discovery

Scan in this order.

### CI/CD Pipeline

- `.github/workflows/*.yml`
- `Jenkinsfile`
- `.gitlab-ci.yml`
- `azure-pipelines.yml`

### ZAP Configuration

- `.zap/` directory
- `zap-baseline.yaml`, `zap-full-scan.yaml`
- ZAP context files (`.context`)
- ZAP automation framework YAML

### Reports and Scan Artefacts

- `AI/vulnerability_reviewer/` directory
- `reports/` directory
- ZAP HTML/JSON reports

### Scan Scripts

- `.cursor/scripts/agents/vulnerability_reviewer/run-vulnerability-scan.ps1`
- OWASP dependency-check Maven profile
- Gitleaks and Trivy configurations

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find CI pipeline | `rg -n "zap\|zaproxy\|owasp-zap" .github .gitlab-ci.yml Jenkinsfile` |
| Find ZAP configs | `rg -l "zap" . --glob "*.yml" --glob "*.yaml"` |
| Find ZAP reports | `rg -l "alertcount\|OWASPZAPReport\|ZAP Scanning Report" .` |
| Find auth context | `rg -n "authentication\|loginUrl\|usernameParameter" . --glob "*.context" --glob "*.yaml"` |
| Find CSRF config | `rg -n "csrf\|antiCSRF\|csrfTokenName" . --glob "*.context" --glob "*.yaml"` |
| Find scan scripts | `rg -l "vulnerability-scan\|dependency-check\|gitleaks\|trivy" .` |
| Find report archive | `rg -n "upload-artifact\|archiveArtifacts\|artifacts:" .github Jenkinsfile .gitlab-ci.yml` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| TEST03 | Application has no authenticated endpoints. |
| TEST05 | Application does not use CSRF tokens. |

---

## 5. CHECK-ID Scoring Procedure

### TEST01 - ZAP DAST Scan Present
Fail when no ZAP configuration, context files, CI step, or scan script exists. Also fail when a scan script exists but there is no evidence it has been executed (no reports, no CI integration).

### TEST02 - High/Critical Alerts Remediated
Fail when the latest ZAP report contains High or Critical alerts without corresponding accepted-risk documentation (owner, reason, expiry). If no report exists at all, this is covered by TEST01; mark TEST02 as MANUAL_REVIEW noting "no report available to assess."

### TEST03 - Authenticated Scan Coverage
Fail when the application has login-protected endpoints (Thymeleaf sessions, authenticated REST APIs) but the ZAP context or scan configuration does not include authentication setup.

### TEST04 - CI Report Archiving
Fail when CI pipeline definitions lack an artifact upload step for ZAP reports, or when no report directory structure exists for auditable release records.

### TEST05 - CSRF Context in Scans
Fail when the application uses CSRF protection but the ZAP context/automation does not configure anti-CSRF token handling, rendering the scan results unreliable for state-changing operations.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- ZAP scans are managed by an external pen-testing team and results are in a separate tool.
- CI pipeline exists but artifact retention settings cannot be verified from the YAML alone.
- The repo contains scan scripts but no evidence of recent execution.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| TEST01 | Integrate ZAP | Add a ZAP baseline or full scan step to the CI pipeline targeting the staging URL | Every release is scanned for common web vulnerabilities before production | No DAST scanning | Run CI pipeline; confirm ZAP step executes and produces a report |
| TEST02 | Fix or accept risk | Fix each High/Critical alert, or create an accepted-risk entry with owner, rationale, and time-bound expiry | Known critical vulnerabilities are not shipped unknowingly | Unacknowledged High/Critical alerts | Review latest ZAP report; confirm zero High/Critical or documented exceptions |
| TEST03 | Auth context setup | Configure ZAP authentication context with login URL, form-based or script-based auth, and session indicator | Post-login attack surfaces (admin panels, user dashboards) are tested | Unauthenticated-only scans for authenticated apps | Run authenticated scan; confirm ZAP accesses logged-in pages |
| TEST04 | Archive reports | Add `actions/upload-artifact` or equivalent to CI pipeline for ZAP HTML/JSON output | Audit trail exists for every release's security posture | Discarded scan results | Check CI artefacts after build; confirm ZAP report is downloadable |
| TEST05 | CSRF token handling | Configure `antiCsrfTokenNames` in ZAP context or automation framework YAML | ZAP correctly submits CSRF tokens, avoiding false results on state-changing endpoints | Incomplete scan due to CSRF failures | Run active scan on a POST form; confirm ZAP injects valid CSRF tokens |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm no ZAP scan at all (TEST01) is Critical.
- Confirm unresolved High/Critical alerts (TEST02) is Critical.
