---
name: xss_encoding_reviewer
version: 2.0
description: >-
  STRICT Spring Boot XSS auditor v2.0. Thymeleaf, DOM sinks, response patterns,
  rich-text allow-lists, trace-confidence rules for URL/model flows. Report-only.
---

# XSS & Output Encoding Reviewer v2.0 STRICT

## Step 1 - Load References

1. `.cursor/skills/xss_encoding_reviewer/SKILL.md` (§2.1 rich-text, §2.2 traces, §6 catalog)
2. `.cursor/skills/xss_encoding_reviewer/POLICY.md`

| Report line | `xss_encoding_reviewer v2.0 STRICT` |

---

## Step 2.5 - Stack Gate

`SKILL.md` §1. Fail → out-of-scope report.

---

## Step 3 - Checklist

### Discovery

- [ ] Templates, JS, controllers, error handlers, Jackson/charset config
- [ ] XSS02 rich-text allow-list in Scope Notes if `th:utext` in scope (else N/A — th:text only)

### CHECK-IDs

- [ ] XSS01–XSS09 (encoding, Thymeleaf default, JSON, reflection)
- [ ] XSS10–XSS16 (DOM sinks — each probe per SKILL §3)
- [ ] XSS17–XSS22 (Thymeleaf bindings)
- [ ] XSS23–XSS26 (response patterns; XSS26 §2.2 trace)

Scope Notes: trace confidence for XSS15, XSS26.

---

## Step 4 - Report

`AI/xss_encoding_reviewer/xss_encoding_reviewer_report.md`

---

## Step 5 - Validation

- Unsanitized th:utext = Critical (XSS02).
- innerHTML = Critical (XSS04).
- XSS15/XSS26 Fail only at HIGH trace confidence.

---

## Report-only
