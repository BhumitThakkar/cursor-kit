# Unsafe Parsing & Deserialization Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Native deserialization of untrusted data and unconfigured XML parsers are always findings.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/unsafe_parsing_deserialization_reviewer.md` |
| Cursor invoke name | `unsafe_parsing_deserialization_reviewer` |
| Report path | `AI/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` |
| Report reviewer line | `unsafe_parsing_deserialization_reviewer v1.0 STRICT` |

---

## Verdict Vocabulary

Allowed values only:

- PASS
- FAIL
- MANUAL_REVIEW
- N/A

`UNCLEAR` is forbidden. If evidence is insufficient, use MANUAL_REVIEW and state the exact missing evidence.

---

## Resolution Requirement

Every finding must include a Resolution with five rows:

1. Pattern
2. Mechanism
3. Security property
4. Prohibited
5. Verify

Only Evidence may quote project source. Resolution rows must be prose, not pasteable code.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| PSD01 | Native serialization | Application deserializes untrusted Java objects (`ObjectInputStream`, native serialization) directly from HTTP requests, files, message queues, or cookies |
| PSD02 | XML parser XXE protection | XML parsers (`DocumentBuilderFactory`, `XMLInputFactory`, `XmlMapper`) instantiate without explicitly disabling external entities, DTDs, and schema fetching |
| PSD03 | Safe polymorphic typing | JSON or YAML parsers enable polymorphic typing (`DefaultTyping`, SnakeYAML default constructors) on untrusted inputs without a strict subclass allow-list |

### High

| ID | Citation | Condition |
|---|---|---|
| PSD04 | Safe archive extraction | Archive extraction logic (`ZipInputStream`) extracts files without verifying that the canonical expanded path falls within the intended target directory, or without capping the total expanded size (Zip Bomb/Slip) |
| PSD06 | Untrusted document handling | Application treats uploaded XML, SVG, Office, or PDF files as safe purely based on file extension or MIME type, rather than applying deep inspection, rasterization, or CSP constraints when served |

### Medium

| ID | Citation | Condition |
|---|---|---|
| PSD05 | Document parser limits | Complex document parsers (Apache POI, PDFBox, ImageMagick/wrappers) process user uploads without explicitly configured size limits, depth limits, or execution time limits |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| PSD01 | Native Java serialization is strictly absent for user/external data, replaced with simple JSON/DTO mapping. |
| PSD02 | XML parsers explicitly invoke `setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)` or equivalent safe defaults. |
| PSD03 | Jackson polymorphic typing uses `@JsonTypeInfo` tightly scoped with `@JsonSubTypes` to an explicit, safe class list. SnakeYAML uses `SafeConstructor`. |
| PSD04 | Extracted file paths are normalized (`File.getCanonicalPath()`) and checked against the target directory prefix before writing; extracted bytes are capped. |
| PSD05 | Document parsing logic explicitly bounds processing limits, or inputs are rigorously size-restricted before parsing begins. |
| PSD06 | SVGs are rasterized or served with strict headers/CSP preventing script execution; active content in documents is systematically stripped or isolated. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| PSD01 | Application does not use `ObjectInputStream` or Java native serialization at all. |
| PSD02 | Application does not parse XML. |
| PSD03 | Application does not use polymorphic JSON/YAML parsing. |
| PSD04 | Application does not extract ZIP/TAR/archives. |
| PSD05-PSD06 | Application does not process or parse uploaded complex documents (PDF/SVG/Office). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- XML parsers rely on framework versions that default to safe configurations, but it is ambiguous if those defaults are globally overridden elsewhere.
- An external third-party library is responsible for the ZIP extraction, and its internal path-traversal protections are unverified statically.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| PSD01 | Deserialization | Critical | Native serialization |
| PSD02 | XML | Critical | XML parser XXE protection |
| PSD03 | Deserialization | Critical | Safe polymorphic typing |
| PSD04 | Parsing | High | Safe archive extraction |
| PSD05 | Parsing | Medium | Document parser limits |
| PSD06 | Validation | High | Untrusted document handling |
