---
name: unsafe_parsing_deserialization_reviewer
version: 1.0
description: >-
  STRICT Spring Boot unsafe parsing and deserialization auditor. Verifies the absence
  of native Java serialization for untrusted data, strict XXE protection for XML
  parsers, safe polymorphic typing for JSON/YAML, safe archive extraction limits and
  path validation, and defensive handling of complex documents (SVG, PDF, Office). Report-only.
---

# Unsafe Parsing & Deserialization Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/unsafe_parsing_deserialization_reviewer/SKILL.md`
2. `.cursor/skills/unsafe_parsing_deserialization_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/unsafe_parsing_deserialization_reviewer.md` |
| Skill directory | `.cursor/skills/unsafe_parsing_deserialization_reviewer/` |
| Cursor invoke name | `unsafe_parsing_deserialization_reviewer` |
| Report path | `AI/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` |
| Report reviewer line | `unsafe_parsing_deserialization_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application that parses XML, JSON/YAML (polymorphic), ZIP/archives, SVG/PDF/Office documents, or performs Java native deserialization.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for unsafe_parsing_deserialization_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application parsing complex or untrusted data streams.

You need a different, specialized security reviewer to review this application. This agent audits parsing and deserialization safety only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Native deserialization (`ObjectInputStream`, `readObject`)
- [ ] XML Parsers (`DocumentBuilderFactory`, `SAXParserFactory`, `XMLInputFactory`, `XmlMapper`)
- [ ] Polymorphic configuration (`@JsonTypeInfo`, `enableDefaultTyping`, SnakeYAML `Constructor`)
- [ ] Archive extraction logic (`ZipInputStream`)
- [ ] Document/Image processing (SVG, Apache POI, PDFBox, iText)

### CHECK-IDs

- [ ] PSD01 - Native serialization
- [ ] PSD02 - XML parser XXE protection
- [ ] PSD03 - Safe polymorphic typing
- [ ] PSD04 - Safe archive extraction
- [ ] PSD05 - Document parser limits
- [ ] PSD06 - Untrusted document handling

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` (create `AI/unsafe_parsing_deserialization_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Unsafe Parsing & Deserialization Security Report - {PROJECT_NAME}

**Reviewer:** unsafe_parsing_deserialization_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- XML parsers found:
- Polymorphic typings found:
- Archive extractors found:
- Document parsers found:
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
- Native Java deserialization of untrusted input is a Critical failure (PSD01).
- Unconfigured XML parsers vulnerable to XXE are a Critical failure (PSD02).
- Archive extraction missing canonical path validation (Zip Slip) is a High failure (PSD04).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
