# File Upload & Inclusion Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Trusting client MIME types or file paths is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/file_upload_inclusion_reviewer.md` |
| Cursor invoke name | `file_upload_inclusion_reviewer` |
| Report path | `AI/file_upload_inclusion_reviewer/file_upload_inclusion_reviewer_report.md` |
| Report reviewer line | `file_upload_inclusion_reviewer v1.0 STRICT` |

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
| UP01 | Magic byte verification | Application relies on client-provided MIME headers (`getContentType()`) or file extensions alone, without verifying file magic bytes/signatures (e.g., using Apache Tika) |
| UP04 | Safe storage location | Uploaded files are stored inside the web root, allowing direct execution, or are served without a non-executable content-disposition |
| UP08 | Secure archive extraction | Archive extraction (ZIP/TAR) is performed without preventing zip slip (validating canonical destination path), max expanded size, max file count, or nested bombs |
| UP09 | No raw path APIs | Application passes unvalidated user input directly into file APIs like `new File()`, `Paths.get()`, `ResourceLoader`, or template include paths |
| UP11 | No dynamic inclusion (LFI/RFI) | Application dynamically includes or executes local files (LFI) or remote URLs (RFI) based on request parameters |

### High

| ID | Citation | Condition |
|---|---|---|
| UP02 | Type allow-list | Upload endpoint accepts any file type without an explicit allow-list of permitted types |
| UP03 | Safe filename and extension | Application does not validate extensions after decoding, or fails to reject double extensions, null bytes, leading dots, and dangerous characters |
| UP05 | Authorized downloads | File downloads are served directly from public filesystem paths without passing through an authorization-checking handler (unless explicitly public by design) |
| UP07 | Active content rejection | Active content types (SVG, HTML, XML, Office macros) are accepted without explicit sanitization, rasterization, or safe transformation |
| UP10 | Path canonicalization | Application fails to canonicalize paths (`normalize()`) or manually rejects `..` without canonicalization, risking directory traversal bypasses |
| UP12 | Server-side metadata mapping | Files are retrieved by trusting a client-provided raw path rather than mapping an identifier (e.g., UUID) to a path via server-side database/metadata |

### Medium

| ID | Citation | Condition |
|---|---|---|
| UP06 | Max file size limits | Maximum file size limits are not enforced at the servlet layer (`spring.servlet.multipart.max-file-size`) |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| UP01 | Magic bytes are verified server-side using a library like Apache Tika. |
| UP02 | An explicit allow-list of acceptable formats is strictly enforced. |
| UP03 | Filenames are stripped of path separators, null bytes, and secondary extensions, or are completely regenerated server-side. |
| UP04 | Files are saved to an S3 bucket, a database, or a local directory completely outside the static web context. |
| UP05 | Download controllers check `@PreAuthorize` or perform ownership validation before streaming the file. |
| UP06 | `spring.servlet.multipart.max-file-size` and `max-request-size` are explicitly configured. |
| UP07 | SVG/XML are rejected or rigorously sanitized (e.g., rasterized to PNG). |
| UP08 | Archive entries are checked to ensure their `getCanonicalPath()` starts with the target directory's canonical path, and size/count limits are tracked during extraction. |
| UP09 | No user input flows unvalidated into path constructor APIs. |
| UP10 | Input paths are strictly canonicalized and validated to be within an allowed base directory. |
| UP11 | No dynamic URL or local file inclusion logic exists using request parameters. |
| UP12 | File retrieval uses an opaque ID (like a database UUID) which the server securely maps to the physical location. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| UP01-UP04, UP06-UP07 | Application does not accept any file uploads. |
| UP05 | Application has no file download endpoints. |
| UP08 | Application does not extract user-provided archives. |
| UP09-UP12 | Application does not read or serve files based on any client input or path. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Storage is handled by a third-party SDK (e.g., AWS S3 SDK) where bucket configuration (public/private) is not in the repo.
- Maximum file sizes are enforced exclusively at a reverse proxy/WAF not present in the code.
- File scanning relies on an external Antivirus service API whose implementation is opaque.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| UP01 | Uploads | Critical | Magic byte verification |
| UP02 | Uploads | High | Type allow-list |
| UP03 | Uploads | High | Safe filename and extension |
| UP04 | Uploads | Critical | Safe storage location |
| UP05 | Uploads | High | Authorized downloads |
| UP06 | Uploads | Medium | Max file size limits |
| UP07 | Uploads | High | Active content rejection |
| UP08 | Uploads | Critical | Secure archive extraction |
| UP09 | Inclusion | Critical | No raw path APIs |
| UP10 | Inclusion | High | Path canonicalization |
| UP11 | Inclusion | Critical | No dynamic inclusion (LFI/RFI) |
| UP12 | Inclusion | High | Server-side metadata mapping |
