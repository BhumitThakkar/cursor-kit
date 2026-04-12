---
name: validate-spring-dto
description: >-
  Read-only checklist for Jakarta Bean Validation on Spring API models (DTOs, request bodies).
  Produces a markdown report with PASS/FAIL; does not modify source files.
---

# Validate Spring DTO / request models

## When to Use

- Backend or QA gate before merge: confirm request/response models used on REST boundaries have appropriate validation.
- After adding new `@PostMapping` / `@PutMapping` endpoints or changing DTO shapes.
- Pair with `quality-gates.mdc` Gate 1 (controller `@Valid` + `BindingResult` where applicable).

## Scope (files to analyze)

Include types that cross the HTTP boundary, for example:

- `**/*Request.java`, `**/*Response.java`, `**/*Dto.java`, `**/*DTO.java`
- Types referenced as `@RequestBody` parameters (discover via controller scan in the same change or module)
- Java `record` types used as API request bodies

Exclude unless explicitly in scope:

- JPA `@Entity` classes (validation rules differ; use persistence-layer review)
- Internal service-only POJOs never exposed on REST

Adjust globs per repo layout (e.g. `api.dto`, `web.model`).

## Read-only rule

This skill **only instructs analysis and reporting**. The agent must not apply fixes unless the user or Zeus brief explicitly authorizes edits.

## Checks

### 1. Request bodies on controllers

For each `@RequestBody` parameter:

- Parameter should be annotated with `@Valid` (or `@Validated` with appropriate group) when the type contains constrained fields.
- Nested DTO fields that must be validated need `@Valid` on the nested property inside the parent type.

### 2. DTO / record types

For each type in scope:

- **Constrained API surface:** Non-primitive fields that accept user input should have appropriate Jakarta annotations where business rules require them (e.g. `@NotNull`, `@NotBlank`, `@Size`, `@Email`, `@Min`/`@Max`, `@Pattern`).
- **Defensive defaults:** Optional fields may omit constraints if `null` is explicitly allowed and handled; document as assumption in the report.
- **Empty shells:** Flag types used on public endpoints with no field-level constraints and no class-level `@NotNull` / custom validator — likely **HIGH** if the type maps unvalidated JSON to persistence or security-sensitive operations.

### 3. Response DTOs

Usually fewer constraints; flag if sensitive data could leak through unbounded collections or unvalidated maps — **MEDIUM** informational.

### 4. Groups and custom validators

If `@Validated` groups or `@Constraint` are used, note in the report whether group sequences are consistent with controller `@Validated` usage.

## Output contract

Emit, in order:

1. **Scope** — globs and packages analyzed; list of files (or count + samples).
2. **Findings table**

   `| File | Line or symbol | Issue | Severity | Fix hint |`

   Severity: **HIGH** (unvalidated user input on write path), **MEDIUM** (missing nested `@Valid`, weak bounds), **LOW** (style / optional clarity).

3. **Verdict** — single line: **`PASS`** (no HIGH/MEDIUM) or **`FAIL`** (one or more HIGH/MEDIUM).

4. **Assumptions** — bullets for anything not verifiable without compilation or tests.

## Verification (mental test)

- A DTO with a `String email` field and **no** `@Email` / `@NotBlank` on a POST body → at least one **MEDIUM** or **HIGH** finding.
- A correctly constrained DTO with `@Valid` on the controller parameter and nested `@Valid` where needed → **PASS** for that path.

## Status

Registered in `.cursor/rules/tool-registry.mdc` as **`draft`** until Zeus verifies output on a real PR; then move row status to **`active`**.
