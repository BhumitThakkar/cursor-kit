---
name: injection_reviewer
version: 1.0
disable-model-invocation: true
---

# Injection Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar. Frontend-only validation is always a finding.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/injection_reviewer.md` |
| Skill directory | `.cursor/skills/injection_reviewer/` |
| Cursor invoke name | `injection_reviewer` |
| Report path | `AI/injection_reviewer/injection_reviewer_report.md` |
| Report reviewer line | `injection_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications with injection-relevant surfaces.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Servlet MVC or REST | `spring-boot-starter-web`, `@Controller`, `@RestController`, `SecurityFilterChain`, or MVC mappings |
| Injection surface | SQL/JPA/JDBC, NoSQL/search, OS commands, expression evaluation, template rendering, email sending, LDAP, XPath, or dynamic code resolution |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Spring WebFlux primary stack only | Spring WebFlux |
| CLI/batch-only application with no external input boundary | Batch-only |
| Static website only | Static site |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for injection_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with injection-relevant surfaces (SQL, NoSQL, OS commands, expressions, templates, email, LDAP).

You need a different, specialized security reviewer to review this application. This agent audits injection prevention for Spring Boot servlet applications only.
```

No scored findings for out-of-scope projects.

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `application.properties`, `application.yml`, and profile variants
- Database driver/connection/JPA/Hibernate configuration
- Mail configuration (`spring.mail.*`)
- LDAP configuration (`spring.ldap.*`)
- Elasticsearch/search configuration

### Java/Kotlin Entry Points

- `@Controller`, `@RestController`
- `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`
- `@RequestParam`, `@PathVariable`, `@RequestHeader`, `@CookieValue`, `@RequestBody`, `@ModelAttribute`
- Webhook controllers, scheduled imports, message listeners

### SQL/Query Surfaces

- Spring Data repositories (`@Query`, derived queries, `@Modifying`)
- `JdbcTemplate`, `NamedParameterJdbcTemplate`
- `EntityManager` native and JPQL queries
- `@NamedQuery`, `@NamedNativeQuery`
- Criteria API, Specification builders
- MyBatis mappers if present

### NoSQL/Search Surfaces

- MongoDB `MongoTemplate`, `@Query` on Mongo repositories
- Elasticsearch `RestHighLevelClient`, Spring Data Elasticsearch queries
- Redis command construction
- Custom query DSL builders

### Command Execution Surfaces

- `Runtime.getRuntime().exec()`
- `ProcessBuilder`
- `Process` API
- Shell wrappers, script execution utilities

### Expression/Template Surfaces

- `SpelExpressionParser`, `ExpressionParser`
- Thymeleaf `th:utext` with user data
- Freemarker, Velocity, or other template engines with dynamic templates
- `ScriptEngine`, `Nashorn`, `GraalVM` scripting APIs
- Dynamic `Class.forName`, `BeanFactory.getBean` from user input

### Email Surfaces

- `JavaMailSender`, `MimeMessage`, `SimpleMailMessage`
- `MimeMessageHelper`
- Custom header construction
- Subject, To, CC, BCC, Reply-To from user input

### LDAP/XPath Surfaces

- `LdapTemplate`, `DirContext`, `SearchControls`
- `javax.naming` LDAP operations
- `XPath`, `XPathExpression`, `XPathFactory`
- `DocumentBuilderFactory` with XPath evaluation

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find controllers | `rg -n "@(Controller\|RestController\|RequestMapping\|GetMapping\|PostMapping\|PutMapping\|DeleteMapping\|PatchMapping)" src` |
| Find raw params | `rg -n "@(RequestParam\|PathVariable\|RequestHeader\|CookieValue).*String\|HttpServletRequest\|ServletRequest" src` |
| Find SQL concatenation | `rg -n "\" *\+ *\"|StringBuilder.*append.*sql\|String\.format.*SELECT\|String\.format.*INSERT\|String\.format.*UPDATE\|String\.format.*DELETE" src` |
| Find JDBC template | `rg -n "JdbcTemplate\|NamedParameterJdbcTemplate\|jdbcTemplate\|namedParameterJdbcTemplate" src` |
| Find JPA/JPQL queries | `rg -n "@Query\|@NamedQuery\|@NamedNativeQuery\|nativeQuery\|createQuery\|createNativeQuery\|EntityManager" src` |
| Find JPQL/HQL queries | `rg -n "@Query\|createQuery\|createNativeQuery" src` |
| Find NoSQL queries | `rg -n "MongoTemplate\|QueryBuilder\|ElasticsearchRestTemplate" src` |
| Find OS execution | `rg -n "Runtime\.getRuntime\(\)\.exec\|ProcessBuilder" src` |
| Find Expression/SpEL | `rg -n "ExpressionParser\|SpelExpressionParser\|getValue" src` |
| Find SpEL contexts | `rg -n "StandardEvaluationContext\|SimpleEvaluationContext" src` |
| Find template injection risk | `rg -n "th:utext\|Template\|FreeMarker\|Velocity\|StringTemplate\|TemplateEngine" src` |
| Find email sending | `rg -n "JavaMailSender\|MimeMessage\|SimpleMailMessage\|MimeMessageHelper\|MailMessage\|spring\.mail" src` |
| Find LDAP operations | `rg -n "LdapTemplate\|DirContext\|SearchControls\|ldapTemplate\|spring\.ldap" src` |
| Find XPath usage | `rg -n "XPath\|XPathFactory\|XPathExpression\|evaluate\|javax\.xml\.xpath" src` |
| Find dynamic class/bean loading | `rg -n "Class\.forName\|getBean\|loadClass\|newInstance\|Reflection" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| INJ01 | No SQL database interaction exists after scanning build files, config, and source |
| INJ02 | No JPQL, HQL, or native query exists after scanning repositories and DAOs |
| INJ03 | No NoSQL, Elasticsearch, or search/query DSL dependency or usage exists |
| INJ04 | No `Runtime`, `ProcessBuilder`, `Process`, or shell execution API exists |
| INJ05 | No `SpelExpressionParser`, template evaluation API, expression evaluator, or scripting engine exists |
| INJ06 | No email sending exists after scanning for mail dependencies and APIs |
| INJ07 | No LDAP or XPath dependency or API usage exists |
| INJ08 | No dynamic class loading, bean resolution, template path resolution, or script evaluation from external input exists |
| INJ09 | No dynamic ORDER BY, column, or table selection from external input exists |
| INJ10 | No SpEL usage exists in the application |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### INJ01 - SQL Parameterized Queries Only

Fail when any SQL query uses string concatenation, string interpolation, `String.format`, or `StringBuilder` to include user input in query structure instead of parameterized queries with `?` or named parameters.

Pass requires evidence that every SQL statement uses bind parameters or Spring Data derived queries.

### INJ02 - JPQL/HQL/Native Bind Parameters

Fail when JPQL, HQL, or native query uses string concatenation with user input instead of `:name` or `?n` bind parameters. Also fail when dynamic `ORDER BY` or column name is derived from user input without enum or explicit allow-list.

Pass requires evidence that every JPQL/HQL/native query uses bind parameters and dynamic structural elements come from allow-lists.

### INJ03 - NoSQL/Search Structured APIs Only

Fail when NoSQL query, Elasticsearch query, search DSL, or query DSL filter is constructed by concatenating user input into query strings instead of using structured API builders with allow-listed fields and operators.

Pass requires evidence that every query uses structured builders and user input only populates values within allow-listed field/operator combinations.

### INJ04 - No OS Command from User Input

Fail when `Runtime.exec`, `ProcessBuilder`, shell wrapper, or any command execution API includes user-controlled fragments in command arguments, path, or environment.

Pass requires evidence that no command execution APIs exist, or those present use only hardcoded commands with no user input in arguments.

### INJ05 - Expression/Template Injection Safe

Fail when `SpelExpressionParser`, template engine, expression evaluator, or scripting engine processes user-controlled strings without a restricted evaluation context and allow-listed expressions. Also fail when `th:utext` renders unsanitized user data.

Pass requires evidence that no expression/template evaluation of user input exists, or evaluation uses restricted context with allow-listed expressions only.

### INJ06 - Email Header CRLF Rejection

Fail when email Subject, To, CC, BCC, Reply-To, or custom header field includes user-supplied text without rejecting or stripping `\r` and `\n` characters.

Pass requires evidence that user-supplied values in email headers are sanitized for CRLF or the mail library provably rejects injection attempts.

### INJ07 - LDAP/XPath Parameterized or Encoded

Fail when LDAP filter or XPath expression uses string concatenation with user input without parameterization or context-specific encoding.

Pass requires evidence that LDAP filters use parameterized APIs or proper LDAP encoding, and XPath uses parameterized APIs or context-specific escaping.

### INJ08 - No Dynamic Code Evaluation from User Input
Fail when the application evaluates user-controlled strings as template paths, class names (`Class.forName()`), script engine inputs, or bean names, allowing arbitrary code execution.

### INJ09 - Dynamic ORDER BY / Column from Allow-List
Fail when a dynamic `ORDER BY` clause, table name, or column name is built using string concatenation from user input without explicitly validating the input against a hardcoded enum or allow-list.

### INJ10 - Strict SpEL Injection Prevention
Fail when the application evaluates Spring Expression Language (SpEL) expressions derived from or influenced by user input using a `StandardEvaluationContext`. This context allows arbitrary Java class instantiation and method execution, leading directly to RCE.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:

- query construction is hidden behind a generated DAO or library whose internals are not visible,
- parameterization depends on a framework version or ORM configuration not present in repo,
- expression evaluation context restrictions are loaded from external configuration at deploy time,
- email header sanitization is performed by a library wrapper whose CRLF handling is not verifiable from source,
- LDAP/XPath query safety depends on an external SDK whose escaping behavior is not documented in repo,
- command execution paths are gated by feature flags resolved at deploy time,
- NoSQL query builder safety depends on driver version not pinned in build file.

Manual review is not Pass.

---

## 7. Report Requirements

Every scored finding must include:

| Field | Requirement |
|---|---|
| File | Project-relative file path and line number |
| Evidence | Exact source/config/test line or runtime proof |
| Policy Rule | `POLICY.md - {CHECK-ID} - {citation}` |
| Possible Attack Scenario | Realistic impact in one or two sentences |
| Resolution | Five rows from section 8 |

Evidence is the only field that may quote project source. Resolution rows are prose, not pasteable code.

### 7.1 Verify Row Rules

Every Verify row must include:

1. Action: what to test, inspect, or search.
2. Pass signal: observable result that proves the fix.

Forbidden Verify text:

- `Review queries`
- `Grep codebase`
- `Add sanitization`
- `Check manually`

Replace with direct action and pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| INJ01 | Parameterized SQL only | `JdbcTemplate` with `?` placeholders, `NamedParameterJdbcTemplate` with named parameters, or Spring Data derived queries | User input never appears in SQL structure; only in bind parameter values | String concatenation, interpolation, or format strings in SQL with user data | Submit `' OR '1'='1` in each user-controlled field; query behavior does not change and input is treated as literal value |
| INJ02 | JPQL/HQL bind parameters | `@Query` with `:name` parameters, `EntityManager.createQuery` with `setParameter`, Criteria API for dynamic structure | User input is always a bind parameter value; query structure is static or built from allow-listed enums | String concatenation in JPQL/HQL/native queries with user input; raw user string in ORDER BY or column position | Submit SQL injection payload in query parameters; JPQL/HQL treats it as literal value; dynamic ORDER BY rejects unknown column names |
| INJ03 | Structured query builders | MongoDB Criteria/Query builders, Elasticsearch QueryBuilders, Spring Data query derivation with allow-listed field names | Query structure is programmatic; user input populates values only within allow-listed fields and operators | String concatenation in NoSQL/search query strings with user input | Submit NoSQL injection payload in filter fields; query builder treats it as literal value; unlisted fields are rejected |
| INJ04 | Eliminate command execution | Remove `Runtime.exec`/`ProcessBuilder` with user input; use Java libraries or APIs instead of OS commands; if unavoidable, use strict allow-list for command and arguments | No user-controlled fragment reaches OS command construction | Any user input in `Runtime.exec`, `ProcessBuilder` arguments, path, or environment variables | Search for `Runtime.getRuntime`, `ProcessBuilder`; confirm zero user-controlled arguments; if present, verify allow-list rejects unlisted values |
| INJ05 | Restricted expression context | Use `SimpleEvaluationContext` instead of `StandardEvaluationContext` for SpEL; allow-list expressions; never render user input with `th:utext`; use `th:text` for user data | User input cannot define or modify expression/template structure | `StandardEvaluationContext` with user input, `th:utext` with unsanitized user data, user-controlled template strings | Submit SpEL/template injection payload; expression evaluator rejects or treats as literal; `th:utext` is not used with user data |
| INJ06 | CRLF rejection in email headers | Reject or strip `\r` and `\n` from all user-supplied values before placing in Subject, To, CC, BCC, Reply-To, or custom headers | Email headers cannot be split or injected by user-controlled CR/LF sequences | Raw user text in email header fields without CRLF filtering | Submit `Subject: test\r\nBCC: attacker@evil.com` payload; email is rejected or CRLF is stripped; no header splitting occurs |
| INJ07 | Parameterized LDAP/XPath | Use `LdapQueryBuilder` or `LdapUtils.encodeLdapFilter` for LDAP; use parameterized XPath APIs or `XPathVariableResolver` for XPath | User input is encoded or parameterized; never placed raw in filter/expression structure | String concatenation in LDAP filter or XPath expression with user input | Submit LDAP/XPath injection payload; filter/expression treats input as literal value |
| INJ08 | Static dispatch only | Use enum or switch/map for class/bean/template/script resolution; never pass user string to `Class.forName`, `getBean`, template path, or script engine | User-controlled strings cannot select executable code, class, bean, template, or script | `Class.forName(userInput)`, `getBean(userInput)`, template path from user input, `ScriptEngine.eval(userInput)` | Search for dynamic resolution APIs; confirm no user-controlled string reaches them; if present, verify allow-list rejects unlisted values |
| INJ09 | Enum/allow-list ORDER BY | Map user sort parameter to enum or explicit allow-list of column names; reject unknown values | Dynamic query structure uses only pre-approved identifiers; user string never appears in ORDER BY or column position | Raw user string in ORDER BY clause, column name, or table reference | Submit unexpected column name in sort parameter; backend rejects with validation error; SQL structure does not change |

---

## 9. Scoring Formula

```text
Base Score: 100

Critical: -20
High:     -10
Medium:   -5
Low:      -2
Info:      0

Floor: 0

Grade:
90-100 = A
75-89  = B
60-74  = C
40-59  = D
0-39   = F
```

Manual review does not reduce the score, but it blocks a clean security conclusion.

---

## 10. Final Self-Validation

Before finalizing a report:

- Confirm stack gate result and evidence.
- Confirm every CHECK-ID is PASS, FAIL, MANUAL_REVIEW, or N/A.
- Confirm no `UNCLEAR` appears.
- Confirm every failed CHECK-ID has the required finding fields.
- Confirm every N/A includes proof.
- Confirm frontend-only validation is Fail.
- Confirm string concatenation in SQL/JPQL/HQL is always Fail.
- Confirm no `Runtime.exec`/`ProcessBuilder` with user input is marked Pass.
- Confirm Executive Summary totals match Findings and Manual Review.
- Confirm no code changes were made.
