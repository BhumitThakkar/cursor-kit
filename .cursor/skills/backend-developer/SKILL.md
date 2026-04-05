---
name: backend-developer
description: >-
  Handles Java and Spring Boot tasks for the IDScanner app.
  Use when editing controllers, services, models, repositories,
  properties files, or external integrations (Google Sheets, Word, Excel).
---

# Backend Developer Skill

## Project layout

| Concern | Path |
|---------|------|
| Controllers | `src/main/java/org/sjm/idscanner/controller/` |
| Services | `src/main/java/org/sjm/idscanner/service/` |
| Models | `src/main/java/org/sjm/idscanner/model/` |
| Repositories | `src/main/java/org/sjm/idscanner/dao/` |
| Helpers | `src/main/java/org/sjm/idscanner/helper/` |
| App config | `src/main/resources/application.properties` |
| Custom config | `src/main/resources/custom.properties` |
| Logging config | `src/main/resources/log4j2.yaml` |

## When to use

- Adding or modifying REST endpoints (`@PostMapping`, `@GetMapping`, etc.)
- Business logic in service classes
- JPA entity or repository changes
- Property/configuration changes (`application.properties`, `custom.properties`)
- External writer integrations (Google Sheets, Word, Excel)
- Docker/deployment adjustments (`Dockerfile`, `docker-compose.yml`)

## Conventions

### Controllers
- Annotate with `@RestController` + `@RequestMapping("/api")`.
- Inject dependencies via constructor (`@Autowired` on constructor).
- Log entry with `logger.info("----NEW CALL methodName()")` at the start of each endpoint.
- Return JSON strings via `HelperFunctions.convertObjectToJson(...)`.

### Services
- Plain classes (no `@Service` annotation in current codebase); instantiated directly in controllers.
- Keep parsing/scanning logic in `IDScannerService` (static methods).
- Keep writer logic in dedicated classes (`GoogleSheetWriter`, `WordWriter`, `ExcelWriter`).
- Use `Map<String, String>` as the standard data-transfer structure between controller and services.

### Models & Repositories
- JPA entities in `model/` with standard annotations (`@Entity`, `@Id`, `@GeneratedValue`).
- Spring Data repositories in `dao/` extending `JpaRepository`.

### Properties
- Runtime-toggleable features use `custom.properties` (loaded separately).
- Inject property values with `@Value("${property.name:default}")`.

### Logging
- Use Log4j2: `private static final Logger logger = LogManager.getLogger(MethodHandles.lookup().lookupClass());`
- Use `logger.info(...)` for operational messages; `logger.debug(...)` for verbose tracing.
- Never use `System.out.println`.

### Error handling
- Wrap risky operations in `try/catch`; log the exception message and stack trace.
- Return a user-readable error string from REST endpoints on failure.

### External integrations (Google Sheets)
- Column order in `GoogleSheetWriter.writeToSheet()` must match the Google Sheet layout exactly.
- Handle computed columns (e.g. `Timestamp`, `State-Zip Code`) as special cases in the row-building loop.
- Feature-flag writes via `google.sheets.enabled` property.

## Checklist (run mentally before finishing)

1. New endpoints follow `@RestController` + `@RequestMapping("/api")` pattern.
2. Logger is declared using `MethodHandles.lookup().lookupClass()`.
3. No `System.out.println` — use `logger` exclusively.
4. `try/catch` around I/O, network, and parsing calls with meaningful error messages.
5. Property values injected via `@Value` with a sensible default.
6. Data maps passed between layers use `Map<String, String>` consistently.
7. Google Sheet column order matches the actual sheet layout.
