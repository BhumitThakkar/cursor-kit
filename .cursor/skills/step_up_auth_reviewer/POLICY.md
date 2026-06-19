# Step-up Authentication Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only confirmation is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/step_up_auth_reviewer.md` |
| Cursor invoke name | `step_up_auth_reviewer` |
| Report path | `AI/step_up_auth_reviewer/step_up_auth_reviewer_report.md` |
| Report reviewer line | `step_up_auth_reviewer v1.0 STRICT` |

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
| SUA01 | Critical flows require fresh identity proof | Irreversible or high-impact flow executes without requiring fresh proof of identity beyond the existing session cookie |
| SUA03 | Recent authenticator event required | Step-up accepts an old session cookie or stale authentication timestamp instead of a fresh authenticator event (password re-entry, OTP, MFA, WebAuthn) |
| SUA05 | API cannot skip step-up | API endpoint performs sensitive mutation when caller presents only a session cookie or bearer token without completing step-up challenge |

### High

| ID | Citation | Condition |
|---|---|---|
| SUA02 | Critical flow inventory completeness | One or more high-impact operations (password change, email change, MFA disable, account delete, PII export, privilege elevation, payout/bank change, secret rotation, high-value transaction) lack step-up enforcement |
| SUA04 | OTP/token security properties | OTP or link token used for step-up is missing any of: short TTL, single-use enforcement, rate limiting, high entropy, server-side hashed storage, or constant-time comparison |
| SUA06 | Step-up scoped and short-lived | Step-up result grants broad access to multiple critical flows or does not expire within a short time window after the specific action |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| SUA01 | Every identified critical flow requires fresh proof of identity before execution. Evidence shows service-layer or security-filter enforcement, not just UI prompts. |
| SUA02 | All high-impact operations from the SP-03 examples list are inventoried and each has step-up enforcement or documented justification for exclusion. |
| SUA03 | Step-up mechanism requires a recent authenticator event with verifiable timestamp; stale sessions are rejected. Evidence shows freshness check in backend code. |
| SUA04 | OTP/link tokens meet all six properties: short TTL (minutes not hours), single-use (invalidated after use), rate-limited (brute-force protected), high entropy (cryptographically random, sufficient length), stored hashed server-side, and compared in constant time where applicable. |
| SUA05 | API endpoints for sensitive mutations enforce step-up server-side; direct API calls without step-up completion return 403 or equivalent rejection. |
| SUA06 | Step-up authorization is scoped to the specific action requested and expires quickly; completing step-up for one action does not silently authorize other critical flows. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| SUA01 | Application has no authenticated users or no state-changing operations after complete inventory. |
| SUA02 | No high-impact operations exist after scanning all controllers, services, and admin endpoints. |
| SUA03 | No step-up mechanism exists (likely triggers SUA01 FAIL unless no critical flows exist). |
| SUA04 | No OTP or link token mechanism is used for step-up; other step-up methods (password re-entry, WebAuthn) are used instead. |
| SUA05 | No API endpoints perform sensitive mutations after complete inventory. |
| SUA06 | No step-up mechanism exists (likely triggers SUA01 FAIL unless no critical flows exist). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- step-up enforcement depends on service-layer ownership logic or role hierarchy not visible from source,
- authentication freshness is checked by a library or framework component whose behavior is not verifiable from repo,
- OTP/token properties depend on external identity provider configuration,
- rate limiting is enforced by infrastructure (API gateway, WAF) not visible in repo,
- critical flow inventory completeness requires business context about which operations are high-impact,
- step-up scope/expiry is managed by session attributes whose lifecycle depends on runtime configuration.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| SUA01 | Step-up auth | Critical | Critical flows require fresh identity proof |
| SUA02 | Step-up auth | High | Critical flow inventory completeness |
| SUA03 | Step-up auth | Critical | Recent authenticator event required |
| SUA04 | Step-up auth | High | OTP/token security properties |
| SUA05 | Step-up auth | Critical | API cannot skip step-up |
| SUA06 | Step-up auth | High | Step-up scoped and short-lived |
