---
name: application_rate_limit_reviewer
version: 2.0
disable-model-invocation: true
---

# Application Rate Limit Security Reviewer - Scan Skill v2.0 STRICT (Generalized)

**Mode:** STRICT. Two scored gates: **ARL01 (IP-based)** and **ARL02 (App-based)**. Either missing, hardcoded, or disabled = Fail. Does not replace edge WAF review — documents when edge-only limits are MANUAL_REVIEW.

This version is project-agnostic. Apply it to any Spring Boot servlet app — it does not assume a specific service name, property prefix, or domain.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/application_rate_limit_reviewer.md` |
| Skill directory | `.cursor/skills/application_rate_limit_reviewer/` |
| Shared — invoke order | `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` |
| Shared — scoring law | `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md` |
| Shared — attack surface | `.cursor/extra/agents/reviewer/ATTACK_SURFACE_INVENTORY.md` |
| Cursor invoke name | `application_rate_limit_reviewer` |
| Report path | `AI/agents/security_reviewers/application_rate_limit_reviewer/application_rate_limit_reviewer_report.md` |
| Report reviewer line | `application_rate_limit_reviewer v2.0 STRICT` |
| Fleet position line | `#18 — Phase 5 (Abuse surfaces)` |

---

## 1. Supported Technology Stack

Spring Boot **servlet** application with one or more of:

| Signal | Evidence |
|---|---|
| Spring Boot web | `spring-boot-starter-web`, `@RestController`, `SecurityFilterChain` |
| Thymeleaf UI | `spring-thymeleaf`, `templates/`, `static/js/*.js` |
| AJAX | `fetch(`, any `/api/**` path, CSRF meta in layout |
| Stateless API | `httpBasic`, bearer/API-key auth, `SessionCreationPolicy.STATELESS` |
| Async workloads | `@Scheduled`, `ExecutorService`, queue/job processors, outbound batch loops |
| Rate limit libs | Bucket4j, Resilience4j, Guava `RateLimiter`, custom `*RateLimit*`/`*Throttle*` classes |

### 1.1 Out of Scope

Stop scored audit when not Spring Boot servlet MVC/REST.

```text
Project "{PROJECT_NAME}" is out of scope for application_rate_limit_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application with HTTP ingress or workload throttling surfaces.

You need a different, specialized security reviewer to review this application. This agent audits application-layer rate limiting (IP-based and app-based) for Spring Boot servlet applications only.
```

### 1.2 Implementation Reference (for fix phase only)

Generic pattern — substitute `{prefix}` with whatever property namespace the project already uses. Do not invent a namespace the project doesn't have; if none exists, recommend one in the finding.

| Layer | Recommended approach | Notes |
|---|---|---|
| **IP-based ingress (ARL01)** | Servlet `Filter`/`OncePerRequestFilter` registered on **every** `SecurityFilterChain` the project defines; key = resolved client IP, consistent with `server.forward-headers-strategy` | Covers Thymeleaf form posts, AJAX, and REST equally — not just one chain |
| **App-based throughput (ARL02)** | A single application-wide pair of token buckets — one per-minute, one per-hour — guarding total ingress, independent of caller identity | This is a global ceiling on what the app will accept, not a per-IP or per-caller limit |
| **Library** | Bucket4j 8.x (`io.github.bucket4j`) is a reasonable default; Resilience4j or a hand-rolled `AtomicInteger` + scheduled reset is also acceptable if behavior matches POLICY pass criteria | Judge against outcome, not library choice |
| **Storage backend** | If the project has a database/persistence layer (any `@Entity`, `DataSource`, JPA/JDBC repository) for its own data, the rate-limit counters should live in that same database or a shared cache (Redis/Key-Value) reachable by all instances. If the project has **no** database at all, in-memory counters are acceptable. | See §4 for the exact decision rule |
| **Config** | `{prefix}.ratelimit.ip.per-minute`, `{prefix}.ratelimit.app.per-minute`, `{prefix}.ratelimit.app.per-hour` — all overridable via environment variable, all non-zero in every internet-facing profile | A value hardcoded in Java with no property/env override does not satisfy "env-driven" |
| **API contract** | `429 Too Many Requests` + some retry hint — tracked as OBS03, not a gate | — |
| **Workload throughput** | Async batch/send loops hitting their own internal or third-party rate limit — tracked as OBS02, not a gate | Only relevant if the project has an async workload at all |
| **Audit** | `rate_limit_exceeded` log/metric event — tracked as OBS04, not a gate | Feeds `security_logging_monitoring_reviewer` |

**Filter order diagram (conceptual):**

```text
Request → CorrelationMdcFilter (if present) → [IpRateLimitFilter] → [AppThroughputFilter]
        → SecurityContext → Controller → Service
```

---

## 2. File Discovery

Scan in this order.

### Security and filters
- `SecurityConfig.java` (or equivalent) — every `SecurityFilterChain` bean, `addFilterBefore`/`addFilterAfter`
- `*Filter.java`, `*Interceptor.java`, `WebMvcConfigurer`

### Rate limit implementation
- `**/ratelimit/**`, `**/throttle/**`, Bucket4j, Bandwidth, Resilience4j config
- `application.properties`/`.yml`/`.env` — any `*ratelimit*`/`*rate.limit*`/`*throttle*` key and its value per profile

### Entry points (ingress) — discover, don't assume
- Every `@RequestMapping`/`@PostMapping`/`@GetMapping` in every `@Controller`/`@RestController`
- Login/auth endpoints if present (cross-reference PWD15/SUA04 — do not re-score)
- Any bulk/mutation/export-style endpoint discovered in the actual codebase

### Frontend (AJAX parity)
- `static/js/*.js` — any debounce/disable/timer logic
- Thymeleaf forms posting to mutation endpoints

### Persistence (for storage-backend decision only)
- `@Entity`, `@Repository`, `JpaRepository`/`CrudRepository`, `DataSource`, `spring.datasource.*`, Testcontainers/DB config

### Workload / async (OBS02 only)
- `@Scheduled`, `ExecutorService`, job/queue processors, outbound batch send loops

---

## 3. Required Search Probes

| Goal | Probe |
|---|---|
| Rate limit classes | `rg -n -i "RateLimit|rate.limit|throttle|Bucket4j|Bandwidth|tryConsume|acquireOrThrow" src` |
| Filters | `rg -n "OncePerRequestFilter|HandlerInterceptor|addFilterBefore" src` |
| Properties | `rg -n -i "ratelimit|rate.limit|throttle" src/main/resources` |
| Env-driven check | `rg -n "\\$\\{.*RATELIMIT|\\$\\{.*RATE_LIMIT|\\$\\{.*THROTTLE" src/main/resources` |
| AJAX endpoints | `rg -n "fetch\\(" src/main/resources/static` |
| Forwarded IP | `rg -n "forward-headers-strategy|X-Forwarded-For|getRemoteAddr" src/main/resources src` |
| Persistence signal | `rg -n "@Entity|JpaRepository|CrudRepository|spring.datasource" src` |
| Caller/tenant concept (OBS01 only) | `rg -n -i "sourceApp|apiKey|service.?account|tenant" src` |
| Workload loop (OBS02 only) | `rg -n "@Scheduled|ExecutorService|RATE_LIMITED" src` |

Record probes and hits in Scope Notes.

---

## 4. Storage Backend Decision Rule (applies to both ARL01 and ARL02)

1. Search for any persistence signal (§2 "Persistence", §3 "Persistence signal" probe).
2. **If the project has no database/persistence layer at all** → in-memory counters (`ConcurrentHashMap`, in-process Bucket4j) are acceptable for both ARL01 and ARL02.
3. **If the project does persist data in a database** → the rate-limit counters must use that same database, a co-located table, or a shared cache (Redis/Key-Value) reachable across instances. Pure JVM-local in-memory counters in a DB-backed project count against whichever of ARL01/ARL02 uses them — note it as part of that check's Fail, not a separate CHECK-ID.
4. If you cannot determine whether the deployment is single- or multi-instance, do not guess — record MANUAL_REVIEW with the reasoning. Do not Fail solely on instance-count uncertainty when no database exists.

---

## 5. CHECK-ID Scoring Procedure

**Order:** Inventory (ARL00) → ARL01 → ARL02 → OBS01–OBS04 (advisory, always last).

### ARL00 — Rate limit surface inventory (prerequisite, not scored)

Build table in Scope Notes:

| Path | Method | Chain (UI/API) | Mutation? | Auth | IP limit found? | App-level limit found? |
|---|---|---|---|---|---|---|

### ARL01 — IP-based ingress rate limiting

**Fail when any of:**
- No per-IP throttle exists on one or more discovered ingress surfaces (Thymeleaf, AJAX, or REST).
- A limit exists only in `static/js/*.js` (debounce/disable) with no matching server-side enforcement — frontend-only is always Fail.
- The limit value is hardcoded in Java with no property/env override.
- The active production profile resolves the limit to `0`/disabled with no documented provider/edge enforcement.
- The project has a database (per §4) and the counter is pure in-memory with no shared/DB-backed store, and multi-instance deployment is documented or inferred.

**Pass when:** every discovered ingress surface (UI, AJAX, API alike) is covered by a per-IP throttle, the threshold is environment-configurable, it is non-zero in every internet-facing profile, and the storage backend satisfies §4.

**MANUAL_REVIEW when:** limiting is enforced only at an edge/WAF/CDN layer not present in the repository — require documented proof.

### ARL02 — App-based throughput limiting

**Fail when any of:**
- No application-wide cap exists on requests per minute **or** requests per hour (both are required — one without the other is still a Fail).
- Either threshold is hardcoded with no property/env override.
- The active production profile resolves either threshold to `0`/disabled with no documented provider/edge enforcement.
- The project has a database (per §4) and the counter is pure in-memory with no shared/DB-backed store, and multi-instance deployment is documented or inferred.

**Pass when:** the application enforces both a per-minute and a per-hour ceiling on total ingress, both are environment-configurable and non-zero in every internet-facing profile, and the storage backend satisfies §4.

**MANUAL_REVIEW when:** the cap is enforced only at an edge/WAF/CDN/API-gateway layer not present in the repository — require documented proof.

### OBS01 — Per-caller/tenant fairness *(advisory, not scored)*

Record in **Advisory Notes** (not Manual Review unless static evidence cannot prove Satisfied vs Gap):

- **Gap** — multiple distinct callers/API keys/`sourceApp` values share one global app bucket with no per-caller partition; one bad caller can starve the rest. Recommend per-caller buckets layered on top of ARL01/ARL02.
- **Satisfied** — per-caller partitioning exists, or only one caller is in scope.
- **N/A** — no multi-caller ingress surface.

### OBS02 — Workload throughput recovery *(advisory, not scored)*

Only applies if an async workload loop (§2 "Workload / async") exists. Record in **Advisory Notes**:

- **Gap** — limiter exhaustion fails the entire remaining batch with no pause/resume/chunking.
- **Satisfied** — pause/resume, chunking, or `RATE_LIMITED` retry path documented.
- **N/A** — no async workload loop.

### OBS03 — Retry-After / API retry contract *(advisory, not scored)*

Record in **Advisory Notes** or **Passed Checks** (not Manual Review when evidence is clear):

- **Satisfied** — 429 responses include `Retry-After` and/or equivalent JSON hint for API clients (`retryAfter`, `retryAfterEpochSeconds`). List proof in Passed Checks.
- **Gap** — 429 without machine-readable retry hint on API/AJAX paths.
- **N/A** — no HTTP API ingress.

### OBS04 — Rate-limit observability *(advisory, not scored)*

Record in **Advisory Notes** or **Passed Checks** (cross-reference `security_logging_monitoring_reviewer` LOG01 — do not duplicate scoring):

- **Satisfied** — limiter exhaustion emits audit log/metric with path (and identity when available).
- **Gap** — silent 429 with no trace.
- **N/A** — no rate limiter in app.

---

## 6. Manual Review Triggers

Per `SCORING_REVIEWER_AGENT_MECHANISM.md` and `REVIEWER_TEMPLATE.md` — **Manual Review is not Pass** and applies only when static evidence cannot prove PASS or FAIL:

- WAF/CDN/API-gateway rate limits not present in the repository (ARL01/ARL02 enforced only at edge).
- Provider-side quota (third-party APIs) enforced only externally.
- Instance count (single vs multi) cannot be determined from the repository **and** a database is present (SKILL §4.4) — applies to ARL01/ARL02 storage-backend verdict only.

Do **not** place OBS01–OBS04 in Manual Review when Satisfied or Gap is provable from static evidence. Use **Advisory Notes** instead.

---

## 7. Report Requirements

Every scored finding (ARL01/ARL02 Fail): File, Evidence, Policy Rule, Possible Attack Scenario, `#### Picture in your head`, five Resolution rows. OBS01–OBS04: one short paragraph each under **Advisory Notes** with **Satisfied** / **Gap** / **N/A** label — no Resolution-row table required.

---

## 8. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| ARL01 | Env-driven IP ingress throttle | Bucket4j (or equivalent) filter on every `SecurityFilterChain`; key = resolved client IP consistent with `forward-headers-strategy`; threshold from `{prefix}.ratelimit.ip.per-minute` | Any single IP's request cost is bounded regardless of which chain/page it hits | Limit present on only one chain, hardcoded threshold, frontend-only debounce | Flood one endpoint from one IP across UI and API; expect 429/lockout on both; threshold changeable via env var |
| ARL02 | Env-driven app-wide throughput cap | Two buckets — per-minute and per-hour — guarding total ingress, independent of caller; thresholds from `{prefix}.ratelimit.app.per-minute` / `{prefix}.ratelimit.app.per-hour` | The app can never be driven past its own documented capacity, regardless of source | Only one of the two windows implemented; hardcoded threshold; disabled in prod | Exceed either window; expect 429 before app degrades; both thresholds changeable via env var |
| OBS01 | Caller-scoped quota | Separate buckets per service account/API key/`sourceApp`, layered on top of ARL01/ARL02 | Tenant fairness | One caller exhausts the shared global bucket | Two callers; exhaust one; confirm the other unaffected |
| OBS02 | Workload pause-resume | Blocking acquire or chunked scheduler resume; status `PAUSED` not terminal `FAILED` | Large batches complete within provider cap without manual resubmission | Fail-all-remaining on first bucket miss | Submit a batch larger than the per-minute cap; confirm it completes via pause/resume |
| OBS03 | Retry-After contract | Add `Retry-After` header (or JSON equivalent) on every 429 | Clients can back off correctly | Opaque 429 with no retry hint | Assert header/field present on a blocked API call |
| OBS04 | Rate-limit audit event | Log/metric on limiter exhaustion with path + identity | Ops can detect abuse in real time | Silent drop with no trace | Trigger the limit; confirm log/metric entry |

---

## 9. Scoring Formula

Base Score: 100
ARL01 Fail: -50 (Critical)
ARL02 Fail: -50 (Critical)
Floor: 0

OBS01–OBS04 never affect the score.

| Outcome | Score | Grade | Verdict |
|---|---|---|---|
| ARL01 PASS, ARL02 PASS | 100 | A | Excellent |
| Either ARL01 or ARL02 is MANUAL_REVIEW (other PASS) | 80 | B | Manual Review Required |
| Both ARL01 and ARL02 are MANUAL_REVIEW | 60 | C | Manual Review Required |
| Either ARL01 or ARL02 FAILs | 50 | F | Critical - Do Not Deploy |
| Both ARL01 and ARL02 FAIL | 0 | F | Critical - Do Not Deploy |

N/A checks (rare — e.g. no HTTP ingress at all) are excluded from both the deduction and the table above; document the N/A proof and score only the remaining check.

---

## 10. Final Self-Validation

- Stack gate documented.
- ARL00 inventory table present.
- ARL01 and ARL02 each have an explicit, reasoned verdict — including the storage-backend determination from §4.
- No PWD15/SUA04/MTD02/MTD06/LOG01 duplicate findings.
- Executive Summary counts match Findings.
- Every Fail has five Resolution rows; every OBS note is under **Advisory Notes** with Satisfied/Gap/N/A — not under Manual Review unless static evidence is genuinely insufficient.