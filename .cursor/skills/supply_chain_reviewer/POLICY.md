# Frontend Supply Chain Security Policy v2.0 STRICT
# Spring Boot Thymeleaf / server-rendered HTML applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Cross-origin CDN scripts without SRI or outside the documented allow-list are always findings.

**Scope:** Client-side third-party scripts in HTML templates only. Maven BOM, OWASP dependency-check, plugin pins, and repository trust are owned by `vulnerability_reviewer` (V02–V08). Dockerfile and repository secrets are owned by `container_secrets_reviewer`.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/supply_chain_reviewer.md` |
| Cursor invoke name | `supply_chain_reviewer` |
| Report path | `AI/supply_chain_reviewer/supply_chain_reviewer_report.md` |
| Report reviewer line | `supply_chain_reviewer v2.0 STRICT` |

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

## External script allow-list (SUP02)

Default: **empty** — document in Scope Notes before scoring SUP02:

```text
SUP02 allow-list: (comma-separated hostnames, e.g. cdn.example.com)
```

| Script `src` | Result |
|---|---|
| Relative path or same host as application | **PASS** |
| Cross-origin host in SUP02 allow-list | **PASS** with SRI per SUP01 |
| Cross-origin host not in allow-list | **FAIL** |
| Empty allow-list + any cross-origin script | **FAIL** |

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| SUP01 | Third-party script SRI/Self-host | Cross-origin `<script>` without both `integrity` and `crossorigin`, and not self-hosted |
| SUP02 | External script allow-list | Cross-origin script host not in SUP02 allow-list (empty list fails all external scripts) |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| SUP01 | External script has `integrity` + `crossorigin`, or script is self-hosted from application static resources. |
| SUP02 | Each cross-origin script hostname is in Scope Notes SUP02 allow-list, or no cross-origin scripts exist. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| SUP01-SUP02 | Application serves no HTML templates and includes no third-party JS (pure JSON API). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Script `src` is built dynamically at runtime and template static analysis cannot resolve the final URL.
- Subresource is loaded via JavaScript `document.createElement('script')` outside scanned templates.

Manual review is not Pass.

---

## Cross-reviewer ownership (v1.1 → v2.0 migration)

| Former CHECK-ID | New owner |
|---|---|
| SUP01–SUP06 (Maven/BOM/SCA) | `vulnerability_reviewer` V02–V08 |
| SUP07 | `supply_chain_reviewer` SUP01 |
| SUP08 | `supply_chain_reviewer` SUP02 |

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| SUP01 | Third-party JS | Critical | Third-party script SRI/Self-host |
| SUP02 | Third-party JS | Critical | External script allow-list |
