---
name: owasp-checklist
description: >-
  L1 child skill under security-reviewer: OWASP Top 10 checklist and Spring/Thymeleaf
  secure patterns. Auto-load with security-reviewer when Java/Spring files are in scope;
  used by security-auditor for Spring-deep reviews.
---

# OWASP Security Checklist — Spring Boot

## Hierarchy (read this first)

- **Parent (L0):** [`security-reviewer`](../security-reviewer/SKILL.md) — workspace posture, secrets, Git/AI exposure, dependencies, Docker/CI. **Always read the parent skill’s “Knowledge hierarchy” and “Credentials, Git, and AI” sections before** applying the A01–A10 tables below, unless Zeus explicitly scoped a trivial one-file check and waived L0 in the brief.
- **This skill (L1):** Spring Boot / Thymeleaf **depth**. Do not contradict parent rules on secrets or severity framing; extend them with stack-specific evidence (annotations, config keys, patterns).

## When to Use

- **With parent:** Any `/cmd-review-project-security` or `security-review.mdc` activation that includes Java/Spring artifacts (see parent “When to auto-load owasp-checklist”).
- Security-auditor reviews, pre-release hardening, or CI policy design for Spring Boot apps.
- After dependency upgrades or new external integrations.

## A01: Broken Access Control

**Check for:**
- Every `@RestController` method has explicit access control: `@PreAuthorize`, `@Secured`, or a `SecurityConfig` rule
- No user can access another user's data by changing an ID in the URL (IDOR)
- Admin endpoints (`/admin/**`, `/api/admin/**`) are restricted to ADMIN role
- File download endpoints validate that the requesting user owns the file

**Spring pattern:**
```java
// Correct — method-level security
@PreAuthorize("hasRole('ADMIN')")
@GetMapping("/admin/users")
public List<UserResponse> getAllUsers() { ... }

// Correct — ownership check in service
public BookingResponse getBooking(Long id, String currentUserEmail) {
    Booking booking = repository.findById(id).orElseThrow(...);
    if (!booking.getOwnerEmail().equals(currentUserEmail)) {
        throw new AccessDeniedException("Not your booking");
    }
    return toResponse(booking);
}
```

---

## A02: Cryptographic Failures

**Check for:**
- Passwords stored as BCrypt — never MD5, SHA1, or plaintext
- Sensitive fields (payment info, national ID) encrypted at rest if stored
- HTTPS enforced in production — `server.ssl.*` configured or handled at load balancer
- JWT secrets are long random strings — not hardcoded words

**Spring pattern:**
```java
// Correct
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12);
}
```

---

## A03: Injection

**Check for:**
- No native SQL queries with string concatenation
- All queries use JPA, JPQL with named parameters, or `JdbcTemplate` with `?` placeholders
- No `@Query` with user input concatenated into the string
- No SpEL expressions built from user input

**Spring pattern:**
```java
// CORRECT — parameterized
@Query("SELECT b FROM Booking b WHERE b.ownerEmail = :email")
List<Booking> findByOwnerEmail(@Param("email") String email);

// WRONG — injection risk
@Query("SELECT b FROM Booking b WHERE b.ownerEmail = '" + email + "'")
```

---

## A04: Insecure Design

**Check for:**
- Auth decisions are made in the service layer or via `@PreAuthorize` — not in the controller with if-statements
- No security-by-obscurity — hidden URLs are not a substitute for access control
- Rate limiting on auth endpoints (login, password reset) — not unlimited retries

---

## A05: Security Misconfiguration

**Check for:**
- `spring.jpa.show-sql=false` in production profile
- Error responses do not expose stack traces — `server.error.include-stacktrace=never`
- CORS configured explicitly — not `allowedOrigins("*")` in production
- Actuator endpoints disabled or secured — `/actuator/**` not public
- `DEBUG` logging not enabled in production

**Spring pattern:**
```java
// Correct CORS config
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of("https://shreejalarammandir.org"));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
    source.registerCorsConfiguration("/api/**", config);
    return source;
}
```

---

## A06: Vulnerable Components

**Check for:**
- All dependencies are current stable versions — no known CVEs
- OWASP Dependency-Check plugin configured in `pom.xml`
- No transitive dependency pulling in a vulnerable version

```xml
<!-- pom.xml — dependency check plugin -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.9</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

---

## A07: Auth and Session Failures

**Check for:**
- Session timeout configured — not infinite
- JWT expiry set — access token short-lived (15–60 min), refresh token longer
- No auth tokens in URL query parameters — they appear in server logs
- Remember-me tokens stored securely and rotated on use
- Failed login attempts logged (but not the password)

```properties
# application.properties
server.servlet.session.timeout=30m
spring.security.oauth2.resourceserver.jwt.issuer-uri=${JWT_ISSUER}
```

---

## A08: Software and Data Integrity Failures

**Check for:**
- No `ObjectInputStream` deserializing untrusted data
- No user-controlled data passed into SpEL evaluation
- Dependency integrity verified (checksums in CI)

---

## A09: Logging and Monitoring Failures

**Check for:**
- Auth failures logged: `log.warn("Login failed for user: {}", email)`
- Passwords, tokens, and PII never appear in logs
- Log injection not possible — user input logged with `{}` placeholder, never concatenated
- Sensitive request/response bodies not logged by default
- **Log4j2:** dependency on a **supported 2.x** release; `log4j2*.xml` (or YAML) has **no secrets**; pattern layouts do not enable risky lookups on **user-controlled** message data; file appenders not directed to world-writable paths in prod

```java
// CORRECT — safe logging
log.info("User login attempt for: {}", email);

// WRONG — log injection risk
log.info("User login attempt for: " + email);

// WRONG — logs sensitive data
log.debug("Processing payment: {}", paymentRequest); // exposes card details
```

---

## A10: SSRF (Server-Side Request Forgery)

**Check for:**
- No user-controlled URLs fetched server-side without allowlist validation
- `RestTemplate` or `WebClient` calls do not use raw user input as the URL
- File upload paths do not resolve to external URLs

```java
// CORRECT — allowlist validation before fetch
private static final List<String> ALLOWED_HOSTS = List.of("api.example.com");

public String fetchFromTrustedSource(String url) {
    URI uri = URI.create(url);
    if (!ALLOWED_HOSTS.contains(uri.getHost())) {
        throw new SecurityException("Host not allowed: " + uri.getHost());
    }
    return restTemplate.getForObject(url, String.class);
}
```

---

## File Upload — Full Checklist

```java
@PostMapping("/upload")
public ResponseEntity<?> upload(@RequestParam("file") MultipartFile file) {

    // 1. Size check
    if (file.getSize() > 5 * 1024 * 1024) {
        throw new ValidationException("File too large — max 5MB");
    }

    // 2. MIME type check — not extension alone
    String contentType = file.getContentType();
    if (!List.of("image/jpeg", "image/png", "image/webp").contains(contentType)) {
        throw new ValidationException("File type not allowed");
    }

    // 3. Sanitise filename — remove path traversal
    String originalName = StringUtils.cleanPath(file.getOriginalFilename());
    if (originalName.contains("..")) {
        throw new ValidationException("Invalid filename");
    }

    // 4. Save outside web root — use Path API
    Path uploadPath = Paths.get(uploadDir).resolve(originalName).normalize();
    Files.copy(file.getInputStream(), uploadPath, StandardCopyOption.REPLACE_EXISTING);

    return ResponseEntity.ok().build();
}
```

---

## Dependency scanning (CI)

- Run **OWASP Dependency-Check** (Maven/Gradle plugin or CLI) on every meaningful build; fail builds on agreed CVSS threshold.
- Track suppressions in version-controlled XML with expiry and rationale.

## Secrets detection

- Block commits containing high-entropy tokens, private keys, or `password=` literals — use `git-secrets`, TruffleHog, or GitHub secret scanning.
- Never log access tokens or refresh tokens.

## GDPR-oriented checks

- Data minimization: collect only fields you need; document lawful basis.
- Consent capture for marketing communications; unsubscribe flows tested.
- Right to erasure: define how PII is removed across DB, object storage, logs, and backups.

## Certificate monitoring

- Track TLS cert expiry for every public hostname; automate renewal (ACME) or calendar alerts.

## Spring Security configuration checklist

- CORS: explicit origins; methods; headers — no accidental wildcard with credentials.
- CSRF: correct defaults for browser sessions vs stateless APIs.
- Authentication/authorization: `SecurityFilterChain` matches all dispatcher paths; method security (`@PreAuthorize`) where needed.
- Rate limiting on auth and expensive endpoints.

## Safety Checklist

- [ ] Dependency report reviewed for CRITICAL/HIGH
- [ ] No secrets in repo or Docker layers
- [ ] Prod CORS/CSP/auth settings re-verified after config change
- [ ] Cert expiry > 30 days or renewal automated
