# Application Rate Limit Security Policy v2.0 STRICT (Generalized)
# Any Spring Boot Servlet MVC, Thymeleaf, AJAX, or REST Application

**Mode:** STRICT. Two scored gates only: **ARL01 (IP-based)** and **ARL02 (App-based)**. No profile-based severity reduction. Frontend-only throttling is always a finding. Missing, hardcoded, or prod-disabled limits are always a Fail. OBS01–OBS04 are advisory and never scored.

Every scored finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/application_rate_limit_reviewer.md` |
| Cursor invoke name | `application_rate_limit_reviewer` |
| Report path | `AI/agents/security_reviewers/application_rate_limit_reviewer/application_rate_limit_reviewer_report.md` |
| Report reviewer line | `application_rate_limit_reviewer v2.0 STRICT` |
| Fleet position line | `#18 — Phase 5 (Abuse surfaces)` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** for ARL01/ARL02 only. `UNCLEAR` is forbidden. OBS01–OBS04 are always informational — no verdict, no score impact.

---

## Resolution Requirement

Every scored Fail: five Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). Only Evidence may quote source. OBS advisory notes do not require the five-row table.

Every scored finding and Manual Review CHECK-ID explanation must include `#### Picture in your head` — concrete mental model / analogy / before-after (prefer **In even simpler terms...** or **Here's a practical example:**). See `SCORING_REVIEWER_AGENT_MECHANISM.md`.

---

## Related reviewers (do not score these topics)

| Topic | Invoke | CHECK-IDs | When required |
|-------|--------|-----------|---------------|
| Per-username login lockout after N failures | `password_credentials_reviewer` | PWD15 | Local form/Basic login exists |
| OTP / step-up verification attempt limits | `step_up_auth_reviewer` | SUA04 | Browser OTP or step-up flows |
| Forwarded client IP correctness behind proxy (the *spoof-resistance* of IP extraction itself) | `middleware_tls_dos_reviewer` | MTD02 | App behind reverse proxy |
| Security audit events for rate-limit triggers | `security_logging_monitoring_reviewer` | LOG01 | Rate limits exist in app |
| Request body / multipart size DoS | `middleware_tls_dos_reviewer` | MTD06 | Large uploads |

Do **not** duplicate PWD15, SUA04, MTD02, MTD06, or LOG01 findings. ARL01 checks **whether IP-based limiting exists, is env-driven, and covers every ingress surface** — it does not re-judge whether the forwarded-header trust chain itself can be spoofed; that exact question belongs to MTD02. Cross-reference both in Scope Notes when relevant.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| ARL01 | No env-driven IP-based ingress rate limiting | Any ingress surface (Thymeleaf page, AJAX/`static/js` call, or `/api/**` endpoint) accepts unlimited requests per IP with no application-layer throttle, or the throttle is hardcoded (not env/property driven), or it resolves to disabled in the active production profile, or it exists only in frontend JS with no server enforcement |
| ARL02 | No env-driven app-based throughput limiting | The application has no application-wide cap on total requests per minute **and** per hour (either missing is sufficient), or either threshold is hardcoded, or either resolves to disabled in the active production profile |

OBS01–OBS04 carry no severity — they are recorded in **Advisory Notes**, never as Critical/High/Medium/Low findings and never in the Executive Summary **Manual Review** count unless a specific OBS item genuinely meets Manual Review Criteria above.

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| ARL01 | Per-IP throttle present on every discovered ingress surface (UI, AJAX, API alike); threshold is environment-configurable and non-zero in every internet-facing profile; storage backend satisfies the §4 decision rule in SKILL.md |
| ARL02 | Application-wide per-minute **and** per-hour throughput caps both present; both environment-configurable and non-zero in every internet-facing profile; storage backend satisfies the §4 decision rule in SKILL.md |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| ARL01 | No HTTP ingress at all exists in the project (e.g. pure batch/worker app with no web layer) |
| ARL02 | No HTTP ingress at all exists in the project (e.g. pure batch/worker app with no web layer) |

---

## Manual Review Criteria

Use **MANUAL_REVIEW** only when static evidence cannot prove **PASS** or **FAIL** for **ARL01** or **ARL02** (per `SCORING_REVIEWER_AGENT_MECHANISM.md`). State the exact missing evidence. Manual review is not pass.

- Rate limiting enforced only at CDN/WAF/API gateway with no repository config — require architecture diagram or infra-as-code reference.
- Provider-side quota (third-party APIs) enforced only externally with no repo-visible enforcement.
- Single- vs multi-instance deployment cannot be determined from the repository and a database is present (per SKILL.md §4) — document the ambiguity, do not guess.

**OBS01–OBS04 are not Manual Review by default.** Record them in **Advisory Notes** (see SKILL.md §5 OBS) with **Satisfied**, **Gap**, or **N/A**. Use MANUAL_REVIEW for an OBS item only when static evidence cannot prove Satisfied vs Gap (rare).

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| ARL01 | Ingress / IP-based | Critical | No env-driven IP-based ingress rate limiting |
| ARL02 | Ingress / App-based | Critical | No env-driven app-based throughput limiting |
| OBS01 | App / caller tenancy | Advisory (non-scored) | Per-caller/tenant fairness |
| OBS02 | Workload throughput | Advisory (non-scored) | Workload throughput recovery |
| OBS03 | API contract | Advisory (non-scored) | Retry-After / retry contract |
| OBS04 | Observability | Advisory (non-scored) | Rate-limit observability |