# Security Logging & Monitoring Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Logging raw passwords, tokens, or PII is always a Critical finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/security_logging_monitoring_reviewer.md` |
| Cursor invoke name | `security_logging_monitoring_reviewer` |
| Report path | `AI/security_logging_monitoring_reviewer/security_logging_monitoring_reviewer_report.md` |
| Report reviewer line | `security_logging_monitoring_reviewer v1.0 STRICT` |

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
| LOG03 | Secret log masking | Application explicitly logs (or fails to mask via generic JSON/object serialization) passwords, reset tokens, session IDs, API keys, OTPs, raw Authorization headers, full payment data, or unnecessary PII |
| LOG05 | Dedicated alert log file | Application lacks a dedicated log file routing for high-severity security alerts (separate from general application logs) that includes `[app_name]_alert_yyyy_MM_dd.log` or similar date-based naming in its pattern |

### High

| ID | Citation | Condition |
|---|---|---|
| LOG01 | Security event logging | Application fails to log critical security events: login success/failure, logout, password reset, role changes, access denied (403), CSRF failures, rate-limit triggers, or admin state changes |
| LOG02 | Correlation and context | Security log events lack correlation context (e.g., MDC request ID) or omit the actor, target resource, action, result, or source IP when investigating an incident |

### Medium

| ID | Citation | Condition |
|---|---|---|
| LOG04 | Log retention and protection | The repository lacks documentation, infrastructure-as-code, or configuration defining the retention period and tamper protection of production security logs |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| LOG01 | Security exceptions and Spring Security events (`AuthenticationSuccessEvent`, `AuthenticationFailureBadCredentialsEvent`, `AuthorizationFailureEvent`) are explicitly caught and logged with at least INFO/WARN severity. |
| LOG02 | A filter injects a `requestId` and `userId` into the SLF4J MDC, and logging configurations format this MDC into output lines. |
| LOG03 | Payloads are sanitized before logging; headers are filtered to exclude `Authorization`; credentials are never dumped to `log.debug` or exceptions. |
| LOG04 | Documentation (`README.md`, runbooks) or IaC (Terraform, Helm) explicitly states where logs are aggregated (e.g., Datadog, ELK) and their retention policy. |
| LOG05 | Logback or Log4j2 configuration explicitly routes high-severity security events to a dedicated rolling file appender named with the `[app_name]_alert_yyyy_MM_dd.log` pattern. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| LOG01 | Application is a pure library without authentication or authorization logic. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Broad `@ControllerAdvice` logs generic `Exception.getMessage()`, but it's ambiguous if business logic might accidentally include secrets in exception strings.
- Log aggregation, retention, and alerting are managed by a centralized platform team whose configurations are not in this repository.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| LOG01 | Logging | High | Security event logging |
| LOG02 | Context | High | Correlation and context |
| LOG03 | Secrets | Critical | Secret log masking |
| LOG04 | Operations | Medium | Log retention and protection |
| LOG05 | Alerting | Critical | Dedicated alert log file |
