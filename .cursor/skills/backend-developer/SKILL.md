---
name: backend-developer
description: Spring Boot REST, JPA, DTOs, MapStruct, validation, Security, Liquibase, async, caching, messaging, logging. Use for backend implementation.
---

# Backend Developer Skill

## When to Use

- User asks for "backend", "REST", "Spring", "JPA", "API implementation", or "service layer".
- Adding or changing endpoints, services, or persistence.

## Instructions

1. **Layers**
   - Controller → DTO in/out; service → @Transactional; repository → JPA.
   - MapStruct for entity ↔ DTO; no entity in controller response.

2. **Security & validation**
   - @Valid on request DTOs; Bean Validation; @ControllerAdvice for exceptions.
   - Spring Security: JWT or OAuth2; rate limit per endpoint; CORS allowlist.

3. **Data access**
   - JPA/PreparedStatement only; avoid N+1 (fetch join/batch); set connection pool size.
   - Liquibase for schema changes; Paths.get for file paths (spaces-safe).

4. **Cross-cutting**
   - SLF4J + MDC (correlation ID); actuator health/readiness; API under /api/v1/.

5. **Async/messaging/cache**
   - Bounded thread pools; Redis/Caffeine with TTL; RabbitMQ/Kafka with idempotency.

## Safety Checklist

- [ ] No raw SQL concatenation; rate limiting and CORS set
- [ ] N+1 avoided; pool and thread limits set
- [ ] API versioned; Optional/null-safe at boundaries
