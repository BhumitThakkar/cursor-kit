# Spring Boot Actuator Security Policy v1.0 STRICT

**Mode:** STRICT — fixed severity per CHECK-ID. **All environments** use the same bar.

Every finding must cite exactly one row from **Appendix A**:
`POLICY.md · {CHECK-ID} — {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/actuator_reviewer.md` |
| Cursor invoke name | `actuator_reviewer` |
| Report path | `AI/actuator_reviewer/actuator_reviewer_report.md` |
| Report reviewer line | `actuator_reviewer v1.0 STRICT` |

---

## Allowed web exposure (canonical)

| Endpoint | Web exposure | Authentication |
|---|---|---|
| **health** | Allowed | **None** — probes must work without login |
| **info** | Allowed | **Required** |
| **All other Actuator ids** | **Forbidden** on web port | Do not expose — remove from `exposure.include` |

Procedure: **SKILL.md §2.1**. Wildcard `*` in web exposure is forbidden.

---

## Resolution requirement

Every finding **must** include a **Resolution** structured per **SKILL.md §6** for that CHECK-ID.

**Do not embed copy-paste code** in the report.

Required Resolution rows: **Pattern**, **Mechanism**, **Security property**, **Prohibited**, **Verify** — per **SKILL.md §5.2** and **§6.1**.

**Evidence** is the only field that may quote offending source code.

---

## Supported technology stack

**In scope:** Spring Boot applications. Gate: **SKILL.md §1**. Out-of-scope wording: **§1.2**.

---

## Scope N/A

| Condition | N/A checks |
|---|---|
| No `spring-boot-starter-actuator` | A02–A06 (A01 still applies) |

---

## Related reviewers

Actuator web exposure and health `show-details` are scored **only** in this agent (A02, A03, A06).

For HTTP error bodies, static secret files, and credential logging, invoke **`disclosure_reviewer` v2.0** (DISC01–DISC04). Do not duplicate those checks here.

---

## Actuator policy

### Critical

| ID | Citation | Condition |
|---|---|---|
| A02 | No forbidden Actuator endpoints on web | `management.endpoints.web.exposure.include` lists any endpoint other than `health` and `info` |
| A03 | No wildcard Actuator web exposure | `*` in `management.endpoints.web.exposure.include` |

### High

| ID | Citation | Condition |
|---|---|---|
| A04 | Health reachable without auth | Health / probe paths require authentication in security config |
| A05 | Info requires authentication | `info` exposed on web but reachable without authentication |

### Medium

| ID | Citation | Condition |
|---|---|---|
| A01 | Actuator present for operations | Deployable Spring Boot app without `spring-boot-starter-actuator` |
| A06 | Health details not always visible | `show-details=always` (or equivalent) with anonymous health |

---

## Appendix A — CHECK-ID index

| ID | Domain | Severity | Citation |
|---|---|---|---|
| A01 | Actuator | Medium | Actuator dependency present |
| A02 | Actuator | Critical | No forbidden endpoints on web |
| A03 | Actuator | Critical | No wildcard web exposure |
| A04 | Actuator | High | Health reachable without auth |
| A05 | Actuator | High | Info requires authentication |
| A06 | Actuator | Medium | Health details not always visible |

Score per **SKILL.md §8**.
