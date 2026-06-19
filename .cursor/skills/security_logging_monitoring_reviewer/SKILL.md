---
name: security_logging_monitoring_reviewer
version: 1.0
disable-model-invocation: true
---

# Security Logging & Monitoring Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/security_logging_monitoring_reviewer.md` |
| Skill directory | `.cursor/skills/security_logging_monitoring_reviewer/` |
| Cursor invoke name | `security_logging_monitoring_reviewer` |
| Report path | `AI/security_logging_monitoring_reviewer/security_logging_monitoring_reviewer_report.md` |
| Report reviewer line | `security_logging_monitoring_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot applications that perform authentication, authorization, and output application logs.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency |
| Logging Config | `logback-spring.xml`, `log4j2.xml`, `application.properties` |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for security_logging_monitoring_reviewer because it uses {TECHNOLOGY}, which lacks a Spring Boot logging and security context.
```

---

## 2. File Discovery

Scan in this order.

### Logging Configurations

- `src/main/resources/logback-spring.xml` or `logback.xml`
- `src/main/resources/log4j2.xml`
- `application.properties` or `.yml` (Spring logging properties)

### Correlation

- `Filter` or `OncePerRequestFilter` implementations managing `MDC`
- Log format patterns containing `%X{...}`

### Event Handlers

- `ApplicationListener<AbstractAuthenticationEvent>` implementations
- `AuthenticationEntryPoint` or `AccessDeniedHandler`
- `@ControllerAdvice` and `@ExceptionHandler` methods

### Sensitive Data Handling

- Log statements (`log.info`, `log.debug`) inside login, registration, and reset services.
- `toString()` methods on user/credential entities.

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find MDC filters | `rg -n "MDC\.put\|MDC\.clear\|ThreadContext" src` |
| Find log formats | `rg -n "pattern>\|logging\.pattern\.console\|%X{" src` |
| Find Auth events | `rg -n "AuthenticationSuccessEvent\|AuthenticationFailure\|AccessDenied" src` |
| Find exception handlers | `rg -n "@ExceptionHandler.*\(.*SecurityException\|AccessDeniedException\)" src` |
| Find login logs | `rg -n "log\.info.*login\|log\.error.*auth" src` |
| Find risky logs | `rg -n "log\..*password\|log\..*token\|log\..*credential" src` |
| Find broad dumps | `rg -n "log\..*\(.*request\)\|log\..*\(.*body\)" src` (manual review for secret masking) |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| LOG01 | Application has no authentication, authorization, or sensitive business logic to log. |

---

## 5. CHECK-ID Scoring Procedure

### LOG01 - Security Event Logging
Fail when login failures, access denied (403), password resets, or critical admin actions are swallowed or handled without emitting an auditable log event (INFO/WARN/ERROR).

### LOG02 - Correlation and Context
Fail when logs omit `MDC` correlation IDs (e.g., no `requestId` injected by a filter) or fail to capture the authenticated `userId` and source IP for security events, making incident investigation impossible.

### LOG03 - Secret Log Masking
Fail when raw passwords, authorization headers, JWT tokens, reset tokens, or plaintext PII are logged. This includes blindly logging entire `HttpServletRequest` headers or request bodies on failed logins.

### LOG04 - Log Retention and Protection
Fail when there is no documentation, IaC, or logback configuration indicating where production logs are forwarded (e.g., Datadog, Splunk, CloudWatch) to ensure tampering protection and retention.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Exception handlers log generic error strings and it's unclear if business exceptions might include sensitive tokens in their messages.
- Retention policies are managed outside the repository by a platform team.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| LOG01 | Explicit audit trail | Add `ApplicationListener<AbstractAuthenticationFailureEvent>` or log in `AccessDeniedHandler` | Attack attempts generate visibility | Silent authentication/authorization failures | Submit bad password; confirm WARN log emitted |
| LOG02 | MDC context filter | Implement `OncePerRequestFilter` to `MDC.put("requestId", uuid)` and `clear()` in finally block | All logs for a request can be grouped | Anonymous, isolated log lines | Perform action; confirm `[req=1234]` in log prefix |
| LOG03 | Secret masking | Avoid logging request bodies on auth endpoints; sanitize `toString()` methods of sensitive entities | Credentials cannot be harvested from log aggregators | Logging passwords or tokens | Trigger failed login; confirm password is not in log output |
| LOG04 | Document retention | Add an architecture note or link to the platform IaC defining the SIEM integration | Evidence cannot be deleted by an attacker on the host | Ephemeral, local-only logs in prod | Review `README.md`; confirm log destination is documented |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm logging secrets (LOG03) is Critical.
- Confirm missing correlation IDs (LOG02) is High.
