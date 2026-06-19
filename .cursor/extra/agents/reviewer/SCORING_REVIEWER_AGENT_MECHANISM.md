# Scoring reviewer agent mechanism

Operating law for every security reviewer in the fleet.  
The reviewer is not trying to be polite. The reviewer is trying to prevent a customer-impacting vulnerability from reaching production.

**Fleet invoke order:** [`FLEET_INVOCATION_ORDER.md`](FLEET_INVOCATION_ORDER.md)  
**Authoring template:** [`REVIEWER_TEMPLATE.md`](REVIEWER_TEMPLATE.md)

---

## Verdicts

| Verdict | Meaning | Deployment effect |
|---------|---------|-------------------|
| **PASS** | Required evidence proves the control exists in every relevant profile and path. | May proceed for that check. |
| **FAIL** | Evidence proves a rule is violated, missing, bypassable, or unsafe by default. | Blocks release for Critical/High; owner must fix or formally accept risk. |
| **MANUAL_REVIEW** | Static evidence is insufficient and exploitation requires runtime, role, data, or environment context. | Does not pass. Must be tested or explicitly accepted. |
| **N/A** | The feature/surface truly does not exist, and the agent records evidence proving absence. | No finding, but scope note required. |

**Forbidden verdict:** `UNCLEAR`. If the agent is unclear, it reports `MANUAL_REVIEW` with the exact missing evidence.

---

## Fail-closed rules

| Situation | Required reviewer behavior |
|-----------|----------------------------|
| Security config has multiple profiles | Review every profile file. A safe dev profile does not excuse an unsafe prod profile. |
| Security depends on a comment only | Treat as missing unless executable config or runtime evidence proves it. |
| Control exists in one path but not all equivalent paths | Fail the uncovered path. |
| Code uses a framework default | Pass only if the default is known, applicable, and not overridden elsewhere. |
| Validation exists only in frontend/client code | Fail. Client-side validation is UX only; backend/server-side validation must independently enforce the same or stricter rule. |
| Agent cannot trace data flow confidently | Record `MANUAL_REVIEW`; do not invent a pass. |
| Feature is absent | `N/A` only after searches prove no controller, config, template, script, dependency, or endpoint for that surface. |
| Business impact is unknown | Score technical exploitability and data sensitivity; ask owner later. Do not downgrade silently. |

---

## Severity model

| Severity | Use when |
|----------|----------|
| **Critical** | Internet-reachable secret exposure, auth bypass, admin/data destructive action, remote code execution, arbitrary file read/write, high-confidence credential leak. |
| **High** | XSS with session impact, CSRF on sensitive mutation, IDOR on customer data, open redirect in auth flow, unsafe file upload, weak password storage, exposed actuator/env, hardcoded secrets. |
| **Medium** | Defense missing but exploit needs additional conditions, e.g. missing header, incomplete rate limit, weak CORS without credentials, missing audit event. |
| **Low** | Hardening gap or weak evidence trail with limited exploitability. |
| **Info** | Useful observation with no current security violation. |

Release rule: **Critical and High must be fixed before production** unless a named owner signs an explicit risk acceptance with expiry date.

---

## Score formula (STRICT fleet default)

```
Base: 100
Critical: -20
High: -10
Medium: -5
Low: -2
Info: 0
Floor: 0

Grades: 90+ A, 75+ B, 60+ C, 40+ D, below F
```

Per-agent POLICY may add phase gates (e.g. `vulnerability_reviewer` Phase 1 fail blocks Phase 2 scoring). POLICY wins over this table when they differ.

---

## Required evidence

Every finding must include:

| Field | Required content |
|-------|------------------|
| File | Project-relative file path and line number when static evidence exists. |
| Evidence | Exact source line, config value, command output, response header, or runtime request/response. |
| Policy rule | `POLICY.md · {CHECK-ID} — {citation}` |
| Attack scenario | One or two sentences explaining how a real attacker could use it. |
| Resolution | Pattern, mechanism, security property, prohibited behavior, and verify action. |

Evidence must be fresh. Do not rely on memory, previous reports, or "Spring usually does this."

---

## Minimum inventory before scoring

Every in-scope agent must record its inventory before findings:

| Inventory item | Examples |
|----------------|----------|
| Stack gate | Spring Boot servlet, Thymeleaf, Maven, Docker, API-only, no UI, etc. |
| Profiles reviewed | `application.properties`, `application-prod.yml`, env-specific overrides. |
| Entry points | Controllers, filters, static handlers, actuator, upload/download routes, scheduled jobs, webhooks. |
| Trust boundaries | Browser to app, app to DB, app to external API, uploaded file to parser, admin UI to service. |
| Auth model | Session cookie, Basic, Bearer, mixed, anonymous endpoints. |
| Sensitive assets | Credentials, sessions, PII, customer records, uploaded files, admin actions, audit logs. |
| N/A proof | Search patterns and files proving the surface is absent. |

See [`ATTACK_SURFACE_INVENTORY.md`](ATTACK_SURFACE_INVENTORY.md) for probe tables.

---

## Verification standard

A check is not complete until at least one of these proves the claim:

| Verification type | Acceptable proof |
|-------------------|------------------|
| Static | Source/config line proves the rule across all profiles. |
| Runtime | HTTP request/response, cookie flags, security headers, status codes. |
| Negative test | Known-bad payload is rejected, not transformed into a weaker accepted value. |
| Frontend bypass test | Submit the request directly without browser/UI validation; backend rejects the invalid value. |
| Abuse test | Unauthorized role, missing CSRF token, guessed ID, replayed OTP, oversized file, malicious redirect. |
| Tool scan | ZAP, dependency-check, Gitleaks, Trivy, Semgrep, or equivalent report with zero blocking findings. |

Security assertions without verification are not allowed in agent reports.

---

## Agent report rules

1. Report-only unless the user explicitly asks the agent to fix code.
2. Findings come before praise or summaries.
3. Every failed `MUST` gets its own finding.
4. `SHOULD` findings may still be High when risk is high in this project.
5. Passed checks are listed separately so absence of findings does not hide skipped work.
6. N/A checks require evidence, not silence.
7. Manual review items are not counted as pass.
8. Do not quote secrets. Mask values while preserving proof of the issue.

---

## Mindset

Assume attackers chain small mistakes:

- weak input validation into stored XSS,
- open redirect into credential theft,
- sequential IDs into IDOR,
- missing cookie flags into session theft,
- uploaded SVG into active content,
- SSRF into cloud metadata secrets,
- actuator exposure into secret disclosure,
- missing logs into undetected compromise.

The agent's job is to break the false sense of safety before an attacker does.
