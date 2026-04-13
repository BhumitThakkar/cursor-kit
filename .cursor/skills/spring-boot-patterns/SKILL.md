---
name: spring-boot-patterns
description: Spring Boot coding standards, patterns, and conventions for this project. Uses SLF4J API with Log4j2 as the logging implementation. Loaded dynamically when implementing Java/Spring Boot code.
---

# Spring Boot Patterns

## When to Use

- Implementing or reviewing Java/Spring Boot services, controllers, repositories, or config.
- Adding REST endpoints, validation, observability, caching, or messaging.
- Before merge: quick scan for N+1 risk, boundary null handling, and API versioning drift.

## Package structure

```
com.example.project
  ├── controller/     # @RestController — HTTP boundary only, no business logic
  ├── service/        # @Service — all business logic lives here
  ├── repository/     # @Repository — JPA interfaces only
  ├── dto/            # Request/Response DTOs with validation annotations
  ├── entity/         # @Entity — JPA-managed database objects
  ├── config/         # @Configuration — beans, security, CORS
  └── exception/      # @ControllerAdvice + custom exceptions
```

## Controller pattern

```java
@RestController
@RequestMapping("/api/v1/resource")
@RequiredArgsConstructor
public class ResourceController {

    private static final Logger log = LoggerFactory.getLogger(ResourceController.class);
    private final ResourceService resourceService;

    /**
     * Creates a new resource.
     *
     * @param request the creation request
     * @param result  binding result for validation errors
     * @return created resource response
     */
    @PostMapping
    public ResponseEntity<ResourceResponse> create(
            @Valid @RequestBody ResourceRequest request,
            BindingResult result) {
        if (result.hasErrors()) {
            throw new ValidationException(result);
        }
        log.info("Creating resource: {}", request.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(resourceService.create(request));
    }
}
```

## Service pattern

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ResourceService {

    private static final Logger log = LoggerFactory.getLogger(ResourceService.class);
    private final ResourceRepository resourceRepository;

    /**
     * Creates a new resource after validating business rules.
     */
    @Transactional
    public ResourceResponse create(ResourceRequest request) {
        log.debug("Validating resource creation for: {}", request.getName());
        // business logic here
        Resource saved = resourceRepository.save(toEntity(request));
        log.info("Resource created with id: {}", saved.getId());
        return toResponse(saved);
    }
}
```

## DTO validation pattern

```java
public class ResourceRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String name;

    @NotNull(message = "Type is required")
    private ResourceType type;

    @Email(message = "Must be a valid email")
    private String contactEmail;
}
```

## Path handling (always use Path API)

```java
// CORRECT
Path filePath = Paths.get(baseDir, fileName);
Path resolved = rootPath.resolve(relativePath).normalize();

// WRONG — never do this
String path = baseDir + "/" + fileName;
```

## Exception handling

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException ex) {
        log.warn("Validation failed: {}", ex.getMessage());
        return ResponseEntity.badRequest().body(new ErrorResponse(ex.getErrors()));
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        log.warn("Resource not found: {}", ex.getMessage());
        return ResponseEntity.notFound().build();
    }
}
```

## Configuration pattern

```java
// application.properties — all environment-specific values live here
app.upload.dir=${UPLOAD_DIR:/tmp/uploads}
app.max-file-size=${MAX_FILE_SIZE:5242880}

// Injected via @Value
@Value("${app.upload.dir}")
private String uploadDir;
```

## Logging levels

- `log.error` — exceptions that need immediate attention
- `log.warn` — recoverable issues, validation failures
- `log.info` — business events (resource created, payment processed)
- `log.debug` — internal state useful during development only

## Logging implementation: **Log4j2** (with SLF4J API)

This project standardizes on **SLF4J as the logging API** and **Apache Log4j2** as the implementation (not Logback).

### Maven / Gradle (Spring Boot)

- Exclude the default Logback starter and add Log4j2:

```xml
<!-- pom.xml — do not use spring-boot-starter-logging alongside this -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-log4j2</artifactId>
</dependency>
```

- If another starter pulls in `spring-boot-starter-logging`, exclude it from that artifact so **only one** SLF4J binding exists at runtime.

### Configuration files

- Prefer **`log4j2-spring.xml`** (or `log4j2.xml`) on the classpath so Spring’s `LoggingSystem` and profile support work as expected.
- Override levels without redeploy where possible: `logging.level.com.example=DEBUG` in `application.properties` / YAML.
- Keep **appenders, layouts, and policies** in XML (or YAML if you standardize on it) — not hard-coded in Java.
- Use **environment placeholders** for paths and sensitive file names — never commit secrets into `log4j2*.xml`.

### Application code (do)

- Declare: `private static final Logger log = LoggerFactory.getLogger(MyClass.class);` with imports from **`org.slf4j`** only.
- Always **use placeholders**: `log.info("Created booking {}", bookingId);` — never string concatenation for variables.
- Pass throwables as the last argument: `log.error("Payment failed", exception);`
- Use **MDC** for correlation / trace / tenant keys; configure `%X{correlationId}` (or equivalent) in the pattern layout so logs are greppable in ELK/Loki/etc.
- Use **sensible async appenders** only where measured benefit exists; understand queue full policy (lose vs block).
- For **JSON logs** in production, use the official Log4j2 JSON layout or an agreed encoder — one object per line.

### Application code (don’t)

- Do not use **`org.apache.logging.log4j.LogManager.getLogger`** in normal application classes — stick to **SLF4J** so the implementation can change with one dependency swap.
- Do not depend on **Log4j 1.x** (`log4j:log4j`) or bridges that pull it in.
- Do not log **passwords, tokens, full card numbers, or session IDs** at INFO/DEBUG; redact or hash identifiers when audit needs a stable key.
- Do not build **log messages from raw user input** without placeholders — avoids log injection and layout surprises.
- Do not enable **string substitution / lookups** in pattern layouts for data that can contain user-controlled content (keep Log4j2 **patched** per vendor advisories; avoid risky `%m{...}` style features in untrusted contexts).

### Security / ops hygiene

- Pin **`log4j2.version`** (when managed explicitly) to a **current supported release**; run dependency-check in CI.
- Restrict **file appender paths** in production to directories the process user owns; avoid world-writable locations.
- Ensure the JVM exits or context **stops cleanly** so async appenders **flush** (Spring Boot handles most cases; watch custom shutdown paths).

## MapStruct (entity ↔ DTO)

- Define mapper interfaces `@Mapper(componentModel = "spring")`; never hand-copy dozens of fields in services.
- Keep entities inside persistence/service layers; controllers return DTOs only.

## MDC correlation

- Set correlation/trace ID in a servlet filter or `OncePerRequestFilter`; clear in `finally` to avoid thread-pool leaks.
- Include the same key in structured logs and outbound HTTP headers where applicable.

## Actuator

- Enable `health`, `readiness`, `liveness` as needed; secure endpoints in prod (`management.endpoints.web.exposure`).

## Caching (Redis / Caffeine)

- Always set TTL or size bounds; document cache key structure; avoid caching mutable entities without versioning.

## Messaging (RabbitMQ / Kafka)

- Consumers must be **idempotent** (unique keys, dedup store, or outbox pattern); acknowledge only after side effects succeed.

## N+1 prevention

- Prefer `@EntityGraph`, `JOIN FETCH`, or DTO projections for hot reads; verify with integration tests and logging of query counts in dev.

## Optional and null-safe boundaries

- Return empty collections instead of null; use `Optional` in service returns where absence is normal; validate null at controller edges.

## API versioning

- Namespace controllers under `/api/v1/...`; breaking changes require `/v2` or header versioning per ADR — never silent breakage.

## Safety Checklist

- [ ] Logging: SLF4J API + Log4j2 only; no second SLF4J binding; no `LogManager` in app code
- [ ] No entity returned from `@RestController` methods
- [ ] `@Valid` + `BindingResult` on request bodies where applicable
- [ ] MDC cleared after request
- [ ] Cache entries bounded (TTL/size)
- [ ] Messaging handlers safe under at-least-once delivery
