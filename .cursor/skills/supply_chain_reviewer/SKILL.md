---
name: supply_chain_reviewer
version: 2.0
disable-model-invocation: true
---

# Frontend Supply Chain Security Reviewer - Scan Skill v2.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

**Scope:** Thymeleaf/HTML templates and static resources with third-party `<script>` tags. **Not in scope:** `pom.xml`, OWASP dependency-check, Maven plugins (→ `vulnerability_reviewer`).

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/supply_chain_reviewer.md` |
| Skill directory | `.cursor/skills/supply_chain_reviewer/` |
| Cursor invoke name | `supply_chain_reviewer` |
| Report path | `AI/supply_chain_reviewer/supply_chain_reviewer_report.md` |
| Report reviewer line | `supply_chain_reviewer v2.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot applications that serve HTML (Thymeleaf, Freemarker, JSP, or static `resources/templates`) and may load third-party JavaScript.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| HTML surface | `src/main/resources/templates/**/*.html`, `src/main/resources/static/**/*.html`, or JSP views |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Pure JSON API — no HTML templates or static HTML | REST API without server-rendered views |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for supply_chain_reviewer because it uses {TECHNOLOGY}, which serves no HTML templates or third-party client-side scripts.

Use vulnerability_reviewer for Maven SCA. Use supply_chain_reviewer only when Thymeleaf/HTML includes external scripts.
```

---

## 2. File Discovery

Scan in this order.

### Frontend Assets

- `src/main/resources/templates/**/*.html`
- `src/main/resources/static/**/*.html`
- `src/main/webapp/**/*.jsp` (if present)
- Search for `<script src=` and `<link href=` pointing to CDNs

---

## 3. External script allow-list (SUP02)

Default empty. Record `SUP02 allow-list:` in Scope Notes before scoring. Same-origin and relative `src` always pass.

---

## 3.1 Required Search Probes

| Goal | Probe |
|---|---|
| Find third-party JS | `rg -n "<script.*src=.*http" src` |
| Find SRI | `rg -n "integrity=" src` |
| Find dynamic script injection | `rg -n "createElement\\(['\"]script|document\\.write" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| SUP01-SUP02 | Application serves no HTML/JSP/Thymeleaf templates and no static HTML with scripts (pure JSON API). |

---

## 5. CHECK-ID Scoring Procedure

### SUP01 - Third-party Script SRI/Self-host

Fail when cross-origin `<script src="https://...">` lacks `integrity` and `crossorigin`. Self-hosted same-origin scripts pass.

### SUP02 - External Script Allow-List

Fail when cross-origin script hostname is not in Scope Notes SUP02 allow-list. Empty allow-list fails all external scripts. Dynamic script injection from unvalidated parameters also fails.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:

- Script URL is assembled at runtime and static templates cannot prove the final host.
- A CDN script uses a versioned path that may change without SRI update.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| SUP01 | SRI Hashes | Generate a SHA-384 hash and add integrity and crossorigin attributes to CDN scripts | Compromised CDNs cannot execute malicious JS | CDN scripts without SRI | Modify CDN script locally; confirm browser blocks execution due to SRI mismatch |
| SUP02 | Documented origins | Host vendor JS on static resources or list hostnames in SUP02 allow-list with SRI | Third parties cannot push unapproved JS | Cross-origin script not on allow-list | Script host equals app host or appears in SUP02 allow-list |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Fleet run order

Run **after** `vulnerability_reviewer` and `container_secrets_reviewer` when HTML templates with external scripts are in deploy scope.

---

## 11. Final Self-Validation

Before finalizing a report:

- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm CDN scripts without SRI (SUP01) are Critical.
- Confirm SUP02 allow-list recorded in Scope Notes before scoring external scripts.
- Confirm no V* or SEC* CHECK-IDs appear in this report.
