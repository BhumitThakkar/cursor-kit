---
name: test-coverage-check
description: >-
  QA-oriented playbook for verifying test coverage on new or changed code (JaCoCo / Maven Gradle)
  against project quality gate expectations. Read-only analysis instructions unless user authorizes runs.
---

# Test coverage check

## When to Use

- After Backend or Frontend changes before Zeus closes a task (align with **`quality-gates.mdc` Gate 3** — coverage on new code).
- When the user asks whether tests are “enough” for a PR or a set of files.
- Pair with **QA** subagent after substantive logic changes.

## Scope

- **New/changed code:** Prefer diff against default branch or list of touched types/packages from the user.
- **Whole module:** Only when explicitly requested.

## How to verify (Java / Maven)

1. Ensure JaCoCo is configured on the module (or document that it is missing and recommend minimal `pom.xml` snippet — do not edit unless brief allows).
2. Suggest running from repo root (user or CI executes):

   `mvn -q test jacoco:report`

3. Open **`target/site/jacoco/index.html`** or **`target/site/jacoco/jacoco.xml`** if present; interpret **line coverage** for packages touched by the change.
4. If JaCoCo is absent, fall back to: **test count**, **new test files**, and manual gap analysis against Gate 3 scenarios (happy path, null/empty, invalid, boundary, errors).

## How to verify (Java / Gradle)

- `./gradlew test jacocoTestReport` (or Windows `gradlew.bat`) when plugin applied; report under `build/reports/jacoco/`.

## Output contract

1. **Scope** — what files or modules were considered.
2. **Evidence** — commands that would be run (or were run if the agent executed them), report paths.
3. **Table** — `Package or class | Metric (e.g. line %) | Notes | Meets 80% target? (Y/N/Unknown)`.
4. **Gate 3 mapping** — short bullets: which scenarios are covered by existing tests vs missing.
5. **Verdict** — **PASS** / **FAIL** / **UNKNOWN** (UNKNOWN when reports cannot be read without running tests).

## Constraints

- Do not mock away the code under test when assessing coverage meaning.
- Treat **80% on new code** as the default target from Gate 3 unless `tasks/decisions.md` documents another threshold.

## Status

Registered in `tool-registry.mdc`; set to **`active`** after first successful use on a real change set.
