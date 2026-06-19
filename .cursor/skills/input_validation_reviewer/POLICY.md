# Input Validation Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only validation is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/input_validation_reviewer.md` |
| Cursor invoke name | `input_validation_reviewer` |
| Report path | `AI/input_validation_reviewer/input_validation_reviewer_report.md` |
| Report reviewer line | `input_validation_reviewer v1.0 STRICT` |

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
| IV02 | Backend validation required | External input is accepted without backend/server-side validation |
| IV03 | No frontend-only validation | UI, JavaScript, HTML, or browser validation exists without equivalent or stricter backend enforcement |
| IV04 | Reject invalid input fail-closed | Invalid input is sanitized, coerced, truncated, defaulted, or ignored while request is accepted |
| IV09 | Do not trust client metadata | Security or validation decision trusts client-controlled metadata without server-side verification |

### High

| ID | Citation | Condition |
|---|---|---|
| IV01 | External input allow-list or typed parser | External input lacks allow-list validation, typed parser, enum conversion, or equivalent positive validation |
| IV05 | Validate syntax and semantics | Only format is checked where business meaning, ownership, tenant, workflow, or range must also be enforced |
| IV06 | Validate every trust boundary | Headers, cookies, path variables, query params, JSON bodies, multipart metadata, webhooks, imports, or backend feeds are excluded from validation inventory |
| IV07 | Canonicalize before validation | Validation happens before canonicalization, decoding happens after validation, or encoded bypasses are possible |
| IV08 | ReDoS-safe anchored regex | Regex validation is unanchored, partial-match based, or vulnerable to catastrophic backtracking |

### Medium

| ID | Citation | Condition |
|---|---|---|
| IV10 | Backend bypass tests required | No direct backend tests or runtime evidence prove invalid requests are rejected when frontend validation is bypassed |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| IV01 | Every reviewed external input has positive validation evidence tied to that field or parser. |
| IV02 | Backend validation exists at controller, DTO, binder, parser, or service boundary for every reviewed external input. |
| IV03 | Every frontend/UI constraint has matching or stricter backend enforcement, or no frontend validation exists and N/A proof is recorded. |
| IV04 | Invalid shape/value produces controlled rejection and state remains unchanged. |
| IV05 | Syntax and business semantics are both enforced where the value affects security, state, ownership, money, role, tenant, workflow, or limits. |
| IV06 | Scope Notes inventory all external input groups and each has validation evidence or N/A proof. |
| IV07 | Boundary code normalizes/decodes once, validates canonical value, and does not decode later into a more dangerous form. |
| IV08 | Regexes are full-string anchored, bounded/safe, and complex regexes have negative long-input tests or are replaced by typed validators. |
| IV09 | Client metadata is treated only as a hint and backed by server verification. |
| IV10 | Tests or runtime evidence submit invalid direct requests without browser validation and prove backend rejection. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| IV01 | No external input surface exists after complete inventory. |
| IV02 | No external input surface exists after complete inventory. |
| IV03 | No frontend/UI validation exists after template and JavaScript scan. |
| IV04 | No input acceptance path exists after complete inventory. |
| IV05 | Reviewed inputs are purely technical values with no semantic rule; document why. |
| IV06 | Not allowed for in-scope apps unless no external input surface exists. |
| IV07 | No encoded/textual input exists; document binary-only or absent input proof. |
| IV08 | No regex or pattern validation exists; typed parsers or framework validators are used instead. |
| IV09 | No client metadata is used for validation/security decisions. |
| IV10 | No runnable tests exist in repo; prefer MANUAL_REVIEW when release proof is still required. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- validation helper implementation unavailable,
- deploy-time validation rules not in repo,
- semantic validation requires live database/user/tenant data,
- frontend bypass proof requires running the app,
- regex safety requires performance test,
- webhook/import trust model depends on external signature verification.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| IV01 | Input validation | High | External input allow-list or typed parser |
| IV02 | Input validation | Critical | Backend validation required |
| IV03 | Input validation | Critical | No frontend-only validation |
| IV04 | Input validation | Critical | Reject invalid input fail-closed |
| IV05 | Input validation | High | Validate syntax and semantics |
| IV06 | Input validation | High | Validate every trust boundary |
| IV07 | Input validation | High | Canonicalize before validation |
| IV08 | Input validation | High | ReDoS-safe anchored regex |
| IV09 | Input validation | Critical | Do not trust client metadata |
| IV10 | Input validation | Medium | Backend bypass tests required |
