---
name: unsafe_parsing_deserialization_reviewer
version: 1.0
disable-model-invocation: true
---

# Unsafe Parsing & Deserialization Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/unsafe_parsing_deserialization_reviewer.md` |
| Skill directory | `.cursor/skills/unsafe_parsing_deserialization_reviewer/` |
| Cursor invoke name | `unsafe_parsing_deserialization_reviewer` |
| Report path | `AI/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` |
| Report reviewer line | `unsafe_parsing_deserialization_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that parse complex or polymorphic data payloads.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency |
| Parsing Surface | XML, ZIP, SVG, ObjectInputStream, Jackson polymorphic |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for unsafe_parsing_deserialization_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application parsing complex or untrusted data streams.
```

---

## 2. File Discovery

Scan in this order.

### Deserialization

- Uses of `ObjectInputStream`, `readObject`
- Jackson configurations (`enableDefaultTyping`, `@JsonTypeInfo`)
- SnakeYAML `Yaml` instantiations

### XML Parsing

- Uses of `DocumentBuilderFactory`, `SAXParserFactory`, `XMLInputFactory`, `TransformerFactory`
- Uses of `XmlMapper`

### Archive and Document Parsing

- Uses of `java.util.zip.ZipInputStream`, `ZipFile`
- SVG upload handling logic
- Apache POI, PDFBox, or iText document processing logic

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find Java serialization | `rg -n "ObjectInputStream\|readObject" src` |
| Find XML parsers | `rg -n "DocumentBuilderFactory\|XMLInputFactory\|SAXParserFactory\|TransformerFactory\|XmlMapper" src` |
| Find XXE protections | `rg -n "disallow-doctype-decl\|setFeature\|IS_SUPPORTING_EXTERNAL_ENTITIES" src` |
| Find polymorphic JSON | `rg -n "enableDefaultTyping\|activateDefaultTyping\|@JsonTypeInfo" src` |
| Find Yaml | `rg -n "new Yaml\(.*SafeConstructor" src` (manual check for unsafe `new Yaml()`) |
| Find zip extraction | `rg -n "ZipInputStream\|ZipEntry\|ZipFile" src` |
| Find canonical paths | `rg -n "getCanonicalPath" src` (in proximity to Zip logic) |
| Find complex docs | `rg -n "WorkbookFactory\|PDDocument\|svg" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| PSD01 | No native Java serialization used. |
| PSD02 | No XML parsing. |
| PSD03 | No polymorphic JSON/YAML parsing. |
| PSD04 | No archive extraction logic. |
| PSD05-PSD06 | No complex document/image upload parsing logic. |

---

## 5. CHECK-ID Scoring Procedure

### PSD01 - Native Serialization
Fail when `ObjectInputStream` reads from HTTP streams, message queues, sockets, or user-uploaded files without a strict class validation proxy (`ValidatingObjectInputStream`).

### PSD02 - XML Parser XXE Protection
Fail when an XML factory is created but does not explicitly disable DTDs or external entities before parsing input (e.g., missing `factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)`).

### PSD03 - Safe Polymorphic Typing
Fail when Jackson's `enableDefaultTyping()` is used globally, or `@JsonTypeInfo` is used with `Id.CLASS` or `Id.MINIMAL_CLASS` without an explicit `@JsonSubTypes` allow-list. Fail if SnakeYAML uses standard `Constructor` instead of `SafeConstructor`.

### PSD04 - Safe Archive Extraction
Fail when a `ZipInputStream` loop reads `zipEntry.getName()`, creates a `File`, and writes data to it without verifying that `new File(baseDir, zipEntry.getName()).getCanonicalPath()` starts with `baseDir.getCanonicalPath()`.

### PSD05 - Document Parser Limits
Fail when uploaded PDFs/Office docs are parsed entirely into memory without validating max file size, or if parser configurations allow infinite recursive expansion.

### PSD06 - Untrusted Document Handling
Fail when SVG files are uploaded and served back directly to users (as images/files) without deep sanitization or rasterization, risking XSS.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Vulnerability scanners report a library CVE in a parser, but the configuration/usage in the application cannot be statically verified as exploitable.
- Determining if a `ZipInputStream` relies on a third-party library that silently patches Zip Slip.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| PSD01 | JSON over Native | Replace `ObjectInputStream` with a strict JSON deserializer mapping to data-only DTOs | Gadget chains cannot execute arbitrary code | Untrusted native deserialization | Submit serialized payload; confirm rejection or parse error |
| PSD02 | Disable Entities | Call `setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)` | Parser ignores malicious DTDs and external references | Unconfigured XML factories | Submit XML with external entity; confirm parser aborts without fetching |
| PSD03 | Polymorphic allow-list | Use `@JsonTypeInfo(use = Id.NAME)` paired with `@JsonSubTypes` | Deserialization is strictly bound to expected types | Unchecked polymorphic types | Submit JSON specifying an unexpected class type; confirm `InvalidTypeIdException` |
| PSD04 | Path Validation | Compare the canonical path of the intended output file against the target directory's canonical path | Files cannot be written outside the target directory | Writing `../` zip entries blindly | Upload zip containing `../../tmp/test`; confirm extraction aborts |
| PSD05 | Strict Resource Bounds | Reject files exceeding maximum size limits before parsing begins | Application memory cannot be exhausted by malicious documents | Unbounded document parsing | Upload oversized document; confirm immediate rejection |
| PSD06 | Rasterize / Sanitize | Use an SVG sanitizer library, or rasterize to PNG/JPEG upon upload | Active scripts in SVGs cannot execute in victim browsers | Serving raw untrusted SVGs | Upload SVG with `<script>`; confirm script is stripped or file is rasterized |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm native serialization of untrusted input (PSD01) is Critical.
- Confirm XXE vulnerabilities (PSD02) are Critical.
- Confirm Zip Slip (PSD04) is High.
