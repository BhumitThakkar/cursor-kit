---
name: application_rate_limit_reviewer
version: 2.0
description: >-
  STRICT, project-agnostic Spring Boot rate-limit auditor. Two hard gates:
  IP-based ingress limiting and App-based throughput limiting, both
  .env/properties-driven. Either missing, hardcoded, or disabled in prod = Fail.
  Storage backend (in-memory vs DB/shared store) judged against whether the
  project persists data in a database. Workload recovery, Retry-After, tenant
  fairness, and observability are tracked as non-scored advisory notes. Report-only.
---

# Application Rate Limit Reviewer v2.0 STRICT (Generalized)

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/application_rate_limit_reviewer/SKILL.md`
2. `.cursor/skills/application_rate_limit_reviewer/POLICY.md`
3. `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md` (verdict law)

| Artifact | Path / value |
|---|---|
| Invoke name | `application_rate_limit_reviewer` |
| Report path | `AI/agents/security_reviewers/application_rate_limit_reviewer/application_rate_limit_reviewer_report.md` |
| Report reviewer line | `application_rate_limit_reviewer v2.0 STRICT` |
| Fleet position line | `#18 — Phase 5 (Abuse surfaces)` |

**STRICT mode:** Two scored gates only — **ARL01 (IP-based)** and **ARL02 (App-based)**. **If either is missing, hardcoded, or disabled in the active profile, that gate is an automatic Fail.** Frontend-only throttling never satisfies either gate. Every scored Fail gets five Resolution rows. `OBS01`–`OBS04` are advisory only — recorded in **Advisory Notes** with Satisfied/Gap/N/A, never scored, never counted in Executive Summary **Manual Review** unless static evidence is genuinely insufficient (per `SCORING_REVIEWER_AGENT_MECHANISM.md`). Only Evidence may quote project source. Do not score PWD15, SUA04, MTD02, MTD06, or LOG01 — cross-reference only.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` §1 before scoring.

**Pass:** Spring Boot servlet with HTTP ingress (UI, API, or both) and/or async workload throttling.

**Fail:** out-of-scope report only. No CHECK-IDs scored. Use mandatory wording from SKILL §1.1.

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] `SecurityFilterChain` beans (every chain — UI, API, or both, if more than one exists)
- [ ] Servlet filters/interceptors that implement or could implement rate limiting
- [ ] Any `*RateLimit*`, `*Throttle*`, Bucket4j, Resilience4j, or Guava `RateLimiter` classes
- [ ] `application.properties` / `application.yml` / `.env` — any key matching `*ratelimit*`, `*rate.limit*`, `*throttle*`, and what each resolves to **per active profile** (dev vs prod)
- [ ] Persistence layer presence — `@Entity`, `JpaRepository`/`CrudRepository`, `DataSource`, Testcontainers DB config (used only to decide the ARL01/ARL02 storage-backend criterion — see SKILL §4)
- [ ] Every HTTP ingress surface: Thymeleaf form POSTs, `static/js/*.js` `fetch(`/AJAX calls, `@RestController`/`/api/**` endpoints, any auth endpoints
- [ ] `server.forward-headers-strategy` and IP-resolution code (`getRemoteAddr()` vs forwarded-header helper)
- [ ] Any caller/tenant concept (service accounts, API keys, `sourceApp`-style fields) — informs OBS01 only, not ARL01/ARL02

### CHECK-IDs (order matters)

- [ ] ARL00 - Rate limit surface inventory (prerequisite — Scope Notes table, not scored)
- [ ] ARL01 - IP-based ingress rate limiting (env-driven, all ingress surfaces)
- [ ] ARL02 - App-based throughput limiting (env-driven, per-minute AND per-hour)
- [ ] OBS01 - Per-caller/tenant fairness (advisory)
- [ ] OBS02 - Workload throughput recovery — fail-fast vs pause/resume (advisory)
- [ ] OBS03 - Retry-After / API retry contract (advisory)
- [ ] OBS04 - Rate-limit observability/logging (advisory)

Record ARL00–ARL02 as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden. OBS01–OBS04: record under **Advisory Notes** as **Satisfied**, **Gap**, or **N/A** — never inflate Manual Review count when evidence is clear.

---

## Step 4 - Write Report

**Path:** `AI/agents/security_reviewers/application_rate_limit_reviewer/application_rate_limit_reviewer_report.md` (create `AI/agents/security_reviewers/application_rate_limit_reviewer/` if missing)

### In-scope report structure

```markdown
# Application Rate Limit Security Report - {PROJECT_NAME}

**Reviewer:** application_rate_limit_reviewer v2.0 STRICT
**Fleet position:** #18 — Phase 5 (Abuse surfaces)
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- ARL00 surface inventory table:
- Auth chains (UI / API):
- Storage backend signal (DB present? which entity/table):
- Forward-headers / proxy:
- Cross-reviewer notes (PWD15, SUA04, MTD02, LOG01):
- N/A checks with proof:
- Manual review items (ARL01/ARL02 only — undecidable from repo):
- Advisory notes (OBS01–OBS04 — Satisfied / Gap / N/A):

## Executive Summary

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Manual Review | 0 |

**Security Score:** {score}/100 - Grade {letter}
**Verdict:** {Excellent | Manual Review Required | Critical - Do Not Deploy}

## Findings

### 1. {CHECK-ID} - {title}

**Severity:** Critical
**File:** `path:line`
**Evidence:** `safe quoted evidence`
**Policy Rule:** `POLICY.md - {CHECK-ID} - {citation}`
**Possible Attack Scenario:** One or two sentences.

#### Picture in your head

Concrete mental model, analogy, or before/after story a non-expert can picture (not jargon-only). Prefer ending complex explanations with **In even simpler terms...** or **Here's a practical example:**.

| Resolution row | Content |
|---|---|
| Pattern | {short name of the fix pattern, copied from SKILL.md §8} |
| Mechanism | ... |
| Security property | ... |
| Prohibited | ... |
| Verify | Action plus pass signal. |

## Manual Review

(ARL01/ARL02 only — when static evidence cannot prove PASS or FAIL. State exact missing evidence. One short paragraph per item.)

## Advisory Notes

(OBS01–OBS04 only — label each **Satisfied**, **Gap**, or **N/A**. Move **Satisfied** items with clear proof to Passed Checks instead when appropriate. Do not count here in Executive Summary Manual Review.)

## Passed Checks

## Completion Summary
```

---

## Step 5 - Final Validation

Before saving the report, verify:

- ARL00 inventory table is present in Scope Notes.
- ARL01 and ARL02 each have an explicit PASS/FAIL/MANUAL_REVIEW/N/A verdict with reasoning.
- Every FAIL has File, Evidence, Policy Rule, Possible Attack Scenario, `#### Picture in your head`, and five Resolution rows.
- Storage backend signal (DB present or not) is documented and applied consistently to both ARL01 and ARL02.
- OBS01–OBS04 appear under **Advisory Notes** (or Passed Checks when Satisfied with clear proof), never in Findings, never affect the score, never in Manual Review unless evidence is genuinely insufficient.
- Executive Summary **Manual Review** count equals Manual Review section items only (typically 0–2 for ARL storage-backend ambiguity).
- No duplicate scoring of PWD15, SUA04, MTD02, MTD06, LOG01.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.