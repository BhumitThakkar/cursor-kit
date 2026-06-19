---
name: file_upload_inclusion_reviewer
version: 1.0
disable-model-invocation: true
---

# File Upload & Inclusion Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/file_upload_inclusion_reviewer.md` |
| Skill directory | `.cursor/skills/file_upload_inclusion_reviewer/` |
| Cursor invoke name | `file_upload_inclusion_reviewer` |
| Report path | `AI/file_upload_inclusion_reviewer/file_upload_inclusion_reviewer_report.md` |
| Report reviewer line | `file_upload_inclusion_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications handling file uploads, downloads, or dynamic file reads.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Upload/File surface | `MultipartFile`, `File`, `Paths.get`, `ZipInputStream`, `Resource` |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Pure DB/Stateless API | API with no file handling |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for file_upload_inclusion_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application handling file uploads, downloads, or dynamic file reads.
```

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `application.properties`, `application.yml` (multipart config)

### Upload Handlers

- `@PostMapping` methods accepting `MultipartFile`
- Classes importing `org.apache.tika.Tika` or similar magic byte detectors
- File sanitization and validation utilities

### Storage & Retrieval

- Methods interacting with `java.io.File`, `java.nio.file.Files`, `java.nio.file.Paths`
- S3/Blob storage clients
- `@GetMapping` methods returning `ResponseEntity<Resource>` or writing to `HttpServletResponse.getOutputStream()`

### Archives

- Methods using `java.util.zip.ZipInputStream` or `java.util.zip.ZipFile`

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find uploads | `rg -n "MultipartFile\|StandardMultipartHttpServletRequest" src` |
| Find content type | `rg -n "getContentType\(\)\|getOriginalFilename\(\)" src` |
| Find magic bytes | `rg -n "Tika\|detect\|magic" src` |
| Find size limits | `rg -n "multipart\.max-file-size\|multipart\.max-request-size" src` |
| Find path usage | `rg -n "new File\(\|Paths\.get\(\|Files\.read\|Files\.write" src` |
| Find zip extraction | `rg -n "ZipInputStream\|ZipEntry\|getNextEntry" src` |
| Find canonicalization| `rg -n "getCanonicalPath\|normalize\(\)" src` |
| Find downloads | `rg -n "ResponseEntity<Resource>\|UrlResource\|InputStreamResource" src` |
| Find SVG/XML | `rg -n "\.svg\|\.xml\|\.html" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| UP01-UP04, UP06-UP07 | Application does not accept file uploads. |
| UP05 | Application has no file download endpoints. |
| UP08 | Application does not extract archives. |
| UP09-UP12 | Application does not read or serve files based on client input. |

---

## 5. CHECK-ID Scoring Procedure

### UP01 - Magic Byte Verification
Fail when application relies on `MultipartFile.getContentType()` or extension instead of a server-side magic byte library (like Tika) to verify file types.

### UP02 - Type Allow-list
Fail when upload logic lacks an explicit allow-list of safe extensions/types.

### UP03 - Safe Filename and Extension
Fail when `MultipartFile.getOriginalFilename()` is trusted directly without stripping path characters, null bytes, or validating against double extensions (`.jpg.php`).

### UP04 - Safe Storage Location
Fail when uploaded files are saved into `src/main/resources/static` or any public web root directory on the local filesystem.

### UP05 - Authorized Downloads
Fail when download endpoints do not enforce access control (`@PreAuthorize`, ownership check) before serving the file.

### UP06 - Max File Size Limits
Fail when `spring.servlet.multipart.max-file-size` is not configured, allowing default unlimited or excessively large uploads.

### UP07 - Active Content Rejection
Fail when active files (SVG, HTML, XML) are uploaded without sanitization or rasterization.

### UP08 - Secure Archive Extraction
Fail when ZIP extraction logic uses `entry.getName()` to create a `File` without verifying that the `getCanonicalPath()` of the destination starts with the intended extraction directory's canonical path (zip slip).

### UP09 - No Raw Path APIs
Fail when client input (e.g., `?file=...`) is passed directly to `new File()`, `Paths.get()`, or template inclusions.

### UP10 - Path Canonicalization
Fail when paths derived from user input are not properly normalized (`Paths.get(path).normalize()`) to prevent `../` traversal.

### UP11 - No Dynamic Inclusion (LFI/RFI)
Fail when application executes or includes files dynamically based on request parameters.

### UP12 - Server-side Metadata Mapping
Fail when files are requested by specifying a physical path in the API (`/download?path=/var/data/doc.pdf`) instead of an opaque ID (`/download/uuid-1234`).

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- File storage uses an external cloud provider whose bucket policies are unknown.
- Max file size is enforced exclusively at an external WAF/Proxy.

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
| UP01 | Magic byte check | Use `Tika` or similar to read the file header stream | File type is cryptographically verified | Trusting `getContentType()` | Upload an `.exe` renamed to `.jpg`; confirm rejection |
| UP02 | Extension allow-list | Compare verified type/extension against a hardcoded `List<String>` | Only safe formats are processed | Allowing all extensions | Upload a `.txt` file; confirm rejection if not in allow-list |
| UP03 | Filename regeneration | Discard `getOriginalFilename()` and generate a UUID for storage | Path traversal and double extensions are impossible | Trusting client filename | Upload file named `../../shell.php`; confirm it saves as `UUID.extension` |
| UP04 | Out-of-root storage | Save files to S3, DB, or a local directory completely outside the static asset path | Uploaded files cannot be executed by the web server | Saving to `/static` or web root | Attempt to access uploaded file directly via URL; confirm 404 |
| UP05 | Authorized streaming | Add `@PreAuthorize` and ownership checks to the download controller | Only authorized users can download files | Unauthenticated file access | Request download URL without auth; confirm 401/403 |
| UP06 | Size limits | Set `spring.servlet.multipart.max-file-size` in properties | DoS via massive uploads is prevented | Missing size limits | Upload file exceeding limit; confirm 413 Payload Too Large |
| UP07 | Active content handling | Reject SVG/HTML or convert SVGs to PNG via a rasterizer library | XSS/XXE via file upload is prevented | Accepting raw SVGs | Upload SVG with embedded `<script>`; confirm rejection or safe PNG conversion |
| UP08 | Zip slip prevention | Compare `entryFile.getCanonicalPath().startsWith(targetDir.getCanonicalPath())` | Archive entries cannot traverse outside extraction folder | Blindly extracting `ZipEntry.getName()` | Upload ZIP with `../` entry; confirm rejection or extraction fails |
| UP09 | No path APIs | Remove `new File(userInput)`; rely on DB lookups | LFI/RFI is impossible | Client input in path constructors | Submit path payload; confirm API ignores it |
| UP10 | Strict canonicalization | Use `Paths.get(dir, input).normalize().toFile()` and verify bounds | `../` payloads are safely resolved and rejected if out of bounds | Manual string replacement of `../` | Submit `....//` payload; confirm rejection or safe resolution |
| UP11 | Static inclusions | Hardcode template paths; do not use variables for inclusion | Dynamic code execution is prevented | Dynamic inclusions from params | Search for dynamic include tags; confirm absence |
| UP12 | Metadata ID mapping | Store physical paths in DB; expose only a UUID to the client | Physical filesystem layout is hidden from clients | Exposing real file paths | Inspect API response; confirm it returns `id=UUID` not `path=/var` |

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
- Confirm trusting MIME types (UP01) is Critical.
- Confirm zip slip vulnerability (UP08) is Critical.
