---
name: testing
description: JUnit 5, Mockito, Spring slices, Testcontainers, Pact, load, chaos, JaCoCo, mutation testing. Use for test design and coverage.
---

# Testing Skill

## When to Use

- User asks for "tests", "JUnit", "Mockito", "integration test", "coverage", or "Testcontainers".
- Adding or changing behavior that requires tests.

## Instructions

1. **Unit tests**
   - JUnit 5 + Mockito; test data builders; one logical behavior per test.
   - Target critical paths and edge cases.

2. **Integration**
   - @WebMvcTest / @DataJpaTest or full context; Testcontainers for DB/messaging.
   - Critical paths must have integration coverage.

3. **Contract and load**
   - Pact for API consumer/provider; load (Gatling/k6) on significant changes.
   - Chaos scenarios nightly in staging.

4. **Coverage**
   - JaCoCo; minimum 85%; fail if coverage drops.
   - Mutation testing to find weak tests.

5. **Gate**
   - Failed tests block deploy; no skip without override and ticket.

## Safety Checklist

- [ ] Min 85% coverage; critical paths have integration tests
- [ ] Failed tests block deploy
- [ ] Load/chaos defined for significant changes and staging
