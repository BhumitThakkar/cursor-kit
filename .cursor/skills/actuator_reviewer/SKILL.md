---
name: actuator_reviewer
version: 1.0
disable-model-invocation: true
---

# Spring Boot Actuator Security Reviewer — Scan Skill v1.0 STRICT

**Mode:** STRICT — fixed severity per CHECK-ID (POLICY.md Appendix A). **All environments** (dev, local, test, prod) use the same bar.

**Policy in one line:** Web-exposed Actuator may include **only** `health` (no auth) and `info` (auth required). Any other Actuator endpoint on the web port is a **red flag** — remove it from exposure, do not “secure it later.”

**Companion:** For errors, static leaks, and log redaction, invoke **`disclosure_reviewer` v2.0** — not scored in this agent.

## 0. Naming convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/actuator_reviewer.md` |
| Skill directory | `.cursor/skills/actuator_reviewer/` |
| Cursor invoke name | `actuator_reviewer` |
| Report path | `AI/actuator_reviewer/actuator_reviewer_report.md` |
| Report reviewer line | `actuator_reviewer v1.0 STRICT` |

---

## 1. Supported technology stack (mandatory gate)

**In scope:** Spring Boot applications that may use `spring-boot-starter-actuator` (servlet MVC or WebFlux).

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` in `pom.xml`, `build.gradle`, or `build.gradle.kts` |
| Deployable web app | `spring-boot-starter-web` and/or `spring-boot-starter-webflux` on classpath |

**Out of scope — stop scored audit.** Use **§1.2** report.

| Disqualifying signal | Report as technology |
|---|---|
| Not Spring Boot | {detected framework} |
| Library/module with no runtime config (no `application*.properties` / `application*.yml` and no Boot plugin) | Non-runnable module |

### 1.1 Stack gate procedure

Run after project name is known. **Do not score CHECK-IDs** until Spring Boot is confirmed.

1. Confirm Spring Boot build dependency.
2. **Pass** → continue. **Fail** → **§1.2** only.

### 1.2 Out-of-scope report

Output: `AI/actuator_reviewer/actuator_reviewer_report.md`

```
Project "{PROJECT_NAME}" is out of scope for actuator_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot application.

You need a different reviewer for this codebase. This agent audits Spring Boot Actuator exposure only.
```

Include **Stack status:** OUT OF SUPPORTED STACK, **Evidence**, no scored findings.

---

## 2. File discovery

Scan in this order:

### Build
- `pom.xml`, `build.gradle`, `build.gradle.kts` — `spring-boot-starter-actuator`

### Configuration (all profiles)
- `application.properties`, `application.yml`, `application-*.properties`, `application-*.yml`
- Keys: `management.endpoints.web.exposure.include`, `management.endpoints.web.exposure.exclude`, `management.endpoints.web.base-path`, `management.endpoint.health.show-details`, `management.endpoint.health.probes.enabled`, `management.server.*`

### Security
- `SecurityFilterChain` / `SecurityWebFilterChain` beans
- `requestMatchers` / `authorizeHttpRequests` / `authorizeExchange` touching Actuator paths
- `*SecurityConfig*.java`, `*Security*.kt`

### Scope N/A

| Condition | Skip | Report as |
|---|---|---|
| No `spring-boot-starter-actuator` on classpath | A02–A06 | N/A — actuator not present; A01 still scored |
| Actuator present but `management.endpoints.enabled-by-default=false` and empty web exposure | A02, A03 | Document in Scope Notes |

### 2.1 Allowed web endpoints (fixed — not project-specific)

```
ALLOWED_WEB_ENDPOINTS: health, info
```

| Endpoint | Auth on web port | Purpose |
|---|---|---|
| **health** | **None** — `permitAll` on health probe paths | Load balancers / Kubernetes |
| **info** | **Required** — authenticated only | Version/build metadata for operators |

**Any other Actuator id** (`env`, `beans`, `metrics`, `shutdown`, `configprops`, `mappings`, `loggers`, `threaddump`, `heapdump`, `prometheus`, `flyway`, `liquibase`, `caches`, `conditions`, `scheduledtasks`, etc.) **must not** appear in `management.endpoints.web.exposure.include` or equivalent enablement on the **main** web port.

**Wildcard `*`** in web exposure is always **Fail** (A03).

**URL paths:** Resolve Actuator base path from `management.endpoints.web.base-path` (default `/actuator`). Security rules must use the **project’s** base path — never assume `/api/**` or a fixed API prefix. Example pattern: `{base-path}/health/**` permitAll, `{base-path}/info` authenticated.

---

## 3. Actuator checks

### A01 — Actuator Dependency Absent
**Look for:** `spring-boot-starter-actuator` in build file  
**Severity:** Medium  
**Fail if:** Spring Boot web app has no Actuator starter (operational blind spot — no standard health URL).  
**Pass if:** Starter present.  
**Note:** Does not require Actuator on every app; flags absence for deploy/orchestration risk.

### A02 — Forbidden Actuator Endpoint Exposed on Web
**Look for:** `management.endpoints.web.exposure.include`, `management.endpoints.web.exposure.exclude` combinations, env-specific duplicates, `spring.config.activate.on-profile` blocks  
**Severity:** Critical  
**Fail if:** Any exposed web endpoint id is **not** exactly `health` or `info` (after normalizing comma lists). Includes `env`, `beans`, `metrics`, `shutdown`, and every id not in **§2.1**.  
**Pass if:** Web exposure lists only `health` and/or `info` (both allowed together).  
**Evidence:** Quote the `exposure.include` line (or profile variant).

### A03 — Wildcard Web Exposure
**Look for:** `exposure.include=*`, `exposure.include=*,health`, `include: "*"`  
**Severity:** Critical  
**Fail if:** Wildcard appears in web exposure include.  
**Pass if:** Explicit endpoint ids only.

### A04 — Health Requires Authentication
**Look for:** `SecurityFilterChain` / `SecurityWebFilterChain` rules for `{base-path}/health`, `{base-path}/health/**`, liveness/readiness paths  
**Severity:** High  
**Fail if:** Anonymous request to health (or probe subpaths) receives **401/403** because of security matchers, **or** health is not `permitAll` while info is explicitly public.  
**Pass if:** `permitAll` (or equivalent) on health probe paths in reviewed security config.  
**N/A if:** A01 fail and no actuator (no health URL).

### A05 — Info Allows Anonymous Access
**Look for:** `permitAll` on `{base-path}/info`, missing auth on info while catch-all is open  
**Severity:** High  
**Fail if:** Unauthenticated request can read `/actuator/info` (or mapped info path).  
**Pass if:** Info requires authentication (or is not exposed — only health exposed is valid).  
**N/A if:** Info not in `exposure.include`.

### A06 — Health Details Leak to Anonymous Callers
**Look for:** `management.endpoint.health.show-details`, `management.endpoint.health.show-components`  
**Severity:** Medium  
**Fail if:** `show-details=always` (or equivalent always-on) while health is anonymous.  
**Pass if:** `show-details=never`, or `when-authorized` with health anonymous only (probes see status, not component secrets).  
**N/A if:** No actuator or health not exposed.

---

## 4. Evidence collection format

```
FILE: path/to/file (line N)
EVIDENCE: exact offending line(s)
CONTEXT: 2 lines before and after
```

Policy citation: `POLICY.md · {CHECK-ID} — {citation string from Appendix A}`

---

## 5. Finding format

Every **scored** finding includes:

1. **File** — path and line  
2. **Evidence** — offending line (only field that may quote source code)  
3. **Policy Rule** — Appendix A citation  
4. **Possible Attack Scenario** — **§5.1**  
5. **Resolution** — five rows per **§5.2** and **§6**

### 5.1 Possible Attack Scenario

One or two sentences — **possible** impact if unfixed. Plain English; no exploit code.

### 5.2 Resolution content rules

**Only Evidence may quote source code.**

| Row | Write this | Do not write |
|---|---|---|
| **Pattern** | `§6 · {CHECK-ID} — {pattern name}` | Code blocks |
| **Mechanism** | API names + prose (1–2 sentences) | Pasteable statements |
| **Security property** | What must be true after fix | — |
| **Prohibited** | Short label | Evidence copy-paste |
| **Verify** | Action + pass signal (**§6.1**) | Bare "Review config" |

**Forbidden in Resolution rows:** code fences, HTML tags, pasteable Java/Kotlin/YAML statements, repeating Evidence as the fix.

---

## 6. Secure resolution catalog

Report **Resolution** as five table rows per finding.

### 6.1 Verify column rules

Every Verify must state **action** and **pass signal**. Forbidden: bare "Review config", "Check actuator".

| ID | Pattern name | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| A01 | Standard health surface | Add `spring-boot-starter-actuator`; set web exposure to health and info only per §2.1 | Operators and platform can probe health | No actuator on deployable app | Build file lists actuator starter; GET health path returns 200 without credentials |
| A02 | Health and info only on web | Set `management.endpoints.web.exposure.include=health,info`; remove every other endpoint id from web exposure | No env/beans/metrics/shutdown on web port | Any non-allowlisted Actuator endpoint on web | Grep all profiles: exposure.include contains only health and info |
| A03 | Explicit endpoint list | Replace wildcard with `health,info` only | No blanket Actuator exposure | Wildcard web exposure | No asterisk in management.endpoints.web.exposure.include in any profile |
| A04 | Anonymous health probes | permitAll on project base-path health and probe subpaths in security chain; keep info authenticated | Probes succeed without credentials | Authenticated health checks | curl health URL without auth returns 200; liveness/readiness succeed in cluster |
| A05 | Protected info endpoint | Require authentication for info path; keep health permitAll | Build metadata not public | Anonymous info access | curl info without auth returns 401 or 403; with auth returns 200 |
| A06 | Minimal health details | Set health show-details to never or when-authorized for anonymous probes | Anonymous callers see status only | show-details always with public health | Anonymous health response has no component passwords or env fragments |

Reference: [Spring Boot Actuator](https://docs.spring.io/spring-boot/reference/actuator/index.html), [Spring Security](https://docs.spring.io/spring-security/reference/).

---

## 7. Severity classification

| Severity | Definition |
|---|---|
| Critical | Secret or full ops surface exposed (forbidden endpoints, wildcard) |
| High | Wrong auth on health or info |
| Medium | Defence-in-depth (no actuator, verbose health details) |
| Low | Best practice |
| Info | Observation only |

---

## 8. Scoring formula

```
Base Score: 100

Deductions:
- Critical: -20
- High:     -10
- Medium:   -5
- Low:      -2
- Info:      -0

Floor: 0

Grade:
90-100 → A
75-89  → B
60-74  → C
40-59  → D
0-39   → F
```
