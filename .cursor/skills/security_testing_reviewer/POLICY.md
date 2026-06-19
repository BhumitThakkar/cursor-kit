# Security Testing & Assurance Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Skipping DAST or shipping unresolved High/Critical alerts is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/security_testing_reviewer.md` |
| Cursor invoke name | `security_testing_reviewer` |
| Report path | `AI/security_testing_reviewer/security_testing_reviewer_report.md` |
| Report reviewer line | `security_testing_reviewer v1.0 STRICT` |

---

## Verdict Vocabulary

Allowed values only:

- PASS
- FAIL
- MANUAL_REVIEW
- N/A

`UNCLEAR` is forbidden. If evidence is insufficient, use MANUAL_REVIEW and state the exact missing evidence.

---

## Resolution Requirement

Every finding must include a Resolution with five rows:

1. Pattern
2. Mechanism
3. Security property
4. Prohibited
5. Verify

Only Evidence may quote project source. Resolution rows must be prose, not pasteable code.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| TEST01 | ZAP DAST scan present | No OWASP ZAP baseline or full scan is configured or has been run against the application before production deployment |
| TEST02 | High/Critical alerts remediated | ZAP reports contain High or Critical alerts that are neither fixed nor documented as formally accepted risk with owner and expiry |

### High

| ID | Citation | Condition |
|---|---|---|
| TEST03 | Authenticated scan coverage | Application has logged-in UI/API behaviour (Thymeleaf sessions, authenticated AJAX) but ZAP scan is unauthenticated only, missing coverage of post-login attack surface |
| TEST04 | CI report archiving | ZAP HTML/JSON reports are not archived as CI/release artefacts, making audit trail impossible |
| TEST05 | CSRF context in scans | Application uses CSRF tokens but the ZAP context does not include CSRF token handling, causing false positives/negatives and marking the scan incomplete |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| TEST01 | A ZAP baseline or full scan script/config exists in the repo or CI pipeline and evidence shows it has been executed against a staging or pre-production environment. |
| TEST02 | The latest ZAP report shows zero High/Critical alerts, or each remaining alert has a documented accepted-risk entry with owner, reason, and expiry. |
| TEST03 | ZAP context files or CI configuration include authentication setup (login URL, credentials, session detection) for at least one authenticated user role. |
| TEST04 | CI pipeline definition archives the ZAP report as a build artefact, or a `reports/` directory contains timestamped reports linked from release records. |
| TEST05 | ZAP context or automation framework config includes CSRF token name extraction and header/form-field injection. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| TEST03 | Application has no authenticated endpoints (fully public, no login). |
| TEST05 | Application does not use CSRF tokens (e.g., pure stateless JWT API with CSRF disabled per SP-07). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- ZAP scans are run by a separate QA/security team and reports are stored in an external system not visible in the repo.
- CI pipeline runs ZAP but the artefact retention policy cannot be verified from the pipeline YAML alone.
- The most recent ZAP report is outdated (> 1 release cycle old) and the current state is unknown.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| TEST01 | DAST | Critical | ZAP DAST scan present |
| TEST02 | DAST | Critical | High/Critical alerts remediated |
| TEST03 | DAST | High | Authenticated scan coverage |
| TEST04 | CI | High | CI report archiving |
| TEST05 | DAST | High | CSRF context in scans |
