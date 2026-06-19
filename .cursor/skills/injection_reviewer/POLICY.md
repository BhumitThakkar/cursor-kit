# Injection Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only validation is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/injection_reviewer.md` |
| Cursor invoke name | `injection_reviewer` |
| Report path | `AI/injection_reviewer/injection_reviewer_report.md` |
| Report reviewer line | `injection_reviewer v1.0 STRICT` |

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
| INJ01 | SQL parameterized queries only | SQL query uses string concatenation, interpolation, or format strings with user input instead of parameterized queries or JPA bind parameters |
| INJ02 | JPQL/HQL/native bind parameters | JPQL, HQL, or native query uses string concatenation with user input instead of bind parameters; dynamic ORDER BY or column name is not from enum or allow-list |
| INJ04 | No OS command from user input | `Runtime.exec`, `ProcessBuilder`, shell wrapper, or equivalent uses user-controlled fragments in command construction |
| INJ05 | Expression/template injection safe | `SpelExpressionParser`, template engine, or expression evaluator processes user-controlled strings without restricted context and allow-listed expressions |
| INJ08 | No dynamic code evaluation from user input | User-controlled string is evaluated as a template, expression, class name, bean name, or script at runtime |
| INJ10 | Strict SpEL injection prevention | Application evaluates Spring Expression Language (SpEL) using `StandardEvaluationContext` on user-supplied data instead of `SimpleEvaluationContext`, enabling arbitrary code execution |

### High

| ID | Citation | Condition |
|---|---|---|
| INJ03 | NoSQL/search structured APIs only | NoSQL, Elasticsearch, search DSL, or query DSL filter built from user input uses string concatenation instead of structured API with allow-listed fields and operators |
| INJ06 | Email header CRLF rejection | Email subject, to, from, CC, BCC, reply-to, or custom header field accepts user text without stripping or rejecting CR/LF characters |
| INJ07 | LDAP/XPath parameterized or encoded | LDAP filter or XPath expression uses string concatenation with user input without parameterization or context-specific encoding |
| INJ09 | Dynamic ORDER BY / column from allow-list | Dynamic ORDER BY clause, column name, or table name in query is derived from user input without enum or explicit allow-list validation |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| INJ01 | Every SQL query uses parameterized queries (`?` placeholders, named parameters) or JPA/Spring Data derived queries with no string concatenation of user input. |
| INJ02 | Every JPQL/HQL/native query uses `:name` or `?n` bind parameters; dynamic ORDER BY or column names come from enum or allow-list with no user string passed through. |
| INJ03 | Every NoSQL/search query uses structured API builders with allow-listed fields and operators; no user string is interpolated into query syntax. |
| INJ04 | No `Runtime.exec`, `ProcessBuilder`, or shell wrapper exists, or those present do not include any user-controlled input in command arguments. |
| INJ05 | No expression/template evaluation of user-controlled strings exists, or evaluation uses a restricted context with allow-listed expressions only. |
| INJ06 | Email header fields reject or strip `\r` and `\n` from user-supplied values before inclusion in headers, subject, or address fields. |
| INJ07 | LDAP filters use parameterized APIs or proper LDAP encoding; XPath uses parameterized APIs or context-specific escaping with no user string in query structure. |
| INJ08 | No user-controlled string is used as a class name, bean name, template path, script source, or expression evaluation input. |
| INJ09 | Dynamic ORDER BY, column, or table references use enum mapping or explicit allow-list; user string is never placed directly in query structure. |
| INJ10 | Any required SpEL evaluation on user data strictly utilizes `SimpleEvaluationContext` to sandbox the execution environment and prevent Java method execution. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| INJ01 | No SQL database interaction exists after scanning build files, config, and source for JDBC, JPA, Spring Data, and raw SQL evidence. |
| INJ02 | No JPQL, HQL, or native query annotations or API calls exist after scanning repositories and DAOs. |
| INJ03 | No NoSQL, Elasticsearch, or search/query DSL dependency or usage exists after scanning build files and source. |
| INJ04 | No `Runtime`, `ProcessBuilder`, `Process`, or shell execution API exists after scanning source. |
| INJ05 | No `SpelExpressionParser`, template evaluation API, expression evaluator, or scripting engine exists after scanning source. |
| INJ06 | No email sending exists after scanning for `JavaMailSender`, `MimeMessage`, `SimpleMailMessage`, SMTP, or mail dependencies. |
| INJ07 | No LDAP or XPath dependency or API usage exists after scanning build files and source. |
| INJ08 | No dynamic class loading, bean resolution, template path resolution, or script evaluation from external input exists after scanning source. |
| INJ09 | No dynamic ORDER BY, column, or table selection from external input exists after scanning query construction. |
| INJ10 | Application does not evaluate SpEL expressions dynamically at runtime. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- query construction is hidden behind a library or generated code whose internals are not visible,
- parameterization depends on framework version or configuration not present in repo,
- expression evaluation context restrictions depend on runtime configuration,
- email header sanitization is performed by a library wrapper whose behavior is not visible,
- LDAP/XPath query safety depends on an external SDK whose escaping is not verifiable from source,
- command execution paths depend on deploy-time feature flags.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| INJ01 | Injection | Critical | SQL parameterized queries only |
| INJ02 | Injection | Critical | JPQL/HQL/native bind parameters |
| INJ03 | Injection | High | NoSQL/search structured APIs only |
| INJ04 | Injection | Critical | No OS command from user input |
| INJ05 | Injection | Critical | Expression/template injection safe |
| INJ06 | Injection | High | Email header CRLF rejection |
| INJ07 | Injection | High | LDAP/XPath parameterized or encoded |
| INJ08 | Injection | Critical | No dynamic code evaluation from user input |
| INJ09 | Injection | High | Dynamic ORDER BY / column from allow-list |
| INJ10 | Injection | Critical | Strict SpEL injection prevention |
