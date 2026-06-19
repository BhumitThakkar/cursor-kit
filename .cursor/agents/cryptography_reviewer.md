---
name: cryptography_reviewer
version: 1.0
description: >-
  STRICT Spring Boot cryptography security auditor. Verifies algorithms,
  randomness, key lengths, mode configurations (no ECB), and hashing.
  Report-only.
---

# Cryptography Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/cryptography_reviewer/SKILL.md`
2. `.cursor/skills/cryptography_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/cryptography_reviewer.md` |
| Skill directory | `.cursor/skills/cryptography_reviewer/` |
| Cursor invoke name | `cryptography_reviewer` |
| Report path | `AI/cryptography_reviewer/cryptography_reviewer_report.md` |
| Report reviewer line | `cryptography_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot application.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for cryptography_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot application.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Cryptographic algorithm initializations (`Cipher.getInstance`)
- [ ] Random number generation (`SecureRandom` vs `Random`)
- [ ] Key pairs and signatures (`KeyPairGenerator`, `Signature`)
- [ ] Hashing functions (`MessageDigest`)
- [ ] Key material locations (properties, hardcoded strings)

### CHECK-IDs

- [ ] CRYPT01 - No insecure symmetric modes
- [ ] CRYPT02 - Secure asymmetric key sizes
- [ ] CRYPT03 - Secure randomness required
- [ ] CRYPT04 - No hardcoded keys
- [ ] CRYPT05 - Custom cryptography
- [ ] CRYPT06 - Weak hashing for integrity

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/cryptography_reviewer/cryptography_reviewer_report.md` (create `AI/cryptography_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Cryptography Security Report - {PROJECT_NAME}

**Reviewer:** cryptography_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Ciphers found:
- Randomness found:
- Key sources found:
- N/A checks with proof:
- Manual review items:

## Executive Summary

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Manual Review | 0 |

**Security Score:** {score}/100 - Grade {letter}
**Verdict:** {Excellent | Good | Fair | Poor | Critical - Do Not Deploy}

## Findings

### 1. {CHECK-ID} - {title}

**Severity:** Critical|High|Medium|Low
**File:** `path:line`
**Evidence:** `safe quoted evidence`
**Policy Rule:** `POLICY.md - {CHECK-ID} - {citation}`
**Possible Attack Scenario:** One or two sentences.

| Resolution row | Content |
|---|---|
| Pattern | SKILL.md section 8 - {CHECK-ID} - {pattern name} |
| Mechanism | Framework API or architecture approach in prose. |
| Security property | What must be true after fix. |
| Prohibited | Short label only. |
| Verify | Action plus pass signal. |

## Manual Review

## Passed Checks

## Completion Summary
```

---

## Step 5 - Final Validation

Before saving the report, verify:

- Every failed CHECK-ID has File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.
- Every Verify row includes an action and pass signal.
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
