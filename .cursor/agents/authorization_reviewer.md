---
name: authorization_reviewer
version: 2.0
description: >-
  STRICT Spring Boot authorization auditor v2.0. Strict allow-path structure
  (denyAll catch-all, no wildcards), object-level auth, method security,
  fail-closed filters. Supersedes strict_allow_path_reviewer. Report-only.
---

# Authorization Reviewer v2.0 STRICT

## Step 1 - Load References

1. `.cursor/skills/authorization_reviewer/SKILL.md` (§3 strict allow-path scan, §7 catalog)
2. `.cursor/skills/authorization_reviewer/POLICY.md` (strict allow-path structure)

| Report line | `authorization_reviewer v2.0 STRICT` |
| Report path | `AI/authorization_reviewer/authorization_reviewer_report.md` |

---

## Step 2.5 - Stack Gate

`SKILL.md` §1. Fail → out-of-scope report.

---

## Step 3 - Pre-Scan Checklist

### Discovery

- [ ] All `SecurityFilterChain` / `authorizeHttpRequests` definitions
- [ ] Endpoint inventory for AUTH02 (controllers ↔ matchers)
- [ ] Catch-all rule (`anyRequest()`)
- [ ] Method security annotations + enabler
- [ ] Auth filter exception handlers (AUTH10)

### CHECK-IDs

- [ ] AUTH01 - Intentional SecurityFilterChain
- [ ] AUTH02 - Explicit path allow-lists (PUBLIC / ROLE / AUTHENTICATED)
- [ ] AUTH03 - Secure catch-all **denyAll only**
- [ ] AUTH04 - No wildcards in matchers
- [ ] AUTH05 - Authentication mechanism wired
- [ ] AUTH06 - Object-level authorization
- [ ] AUTH07 - Admin roles least privilege
- [ ] AUTH08 - Server-side owner/tenant derivation
- [ ] AUTH09 - Method security enabled
- [ ] AUTH10 - No fail-open exception handling

Scope Notes: document PUBLIC / ROLE / AUTHENTICATED path layers when present.

---

## Step 4 - Report

`AI/authorization_reviewer/authorization_reviewer_report.md`

---

## Step 5 - Validation

- `.anyRequest().permitAll()` or `.anyRequest().authenticated()` → **AUTH03 Critical Fail**
- `*` or `**` in matcher path → **AUTH04 Fail**
- Client-supplied user/tenant ID → **AUTH08 Fail**
- Missing `SecurityFilterChain` → **AUTH01 Critical Fail**

---

## Report-only
