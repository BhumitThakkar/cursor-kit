# Attack surface inventory

Run this inventory before creating or running any one-issue security reviewer.

The goal is to know what can be attacked, not what feature the app is supposed to provide.

**Fleet invoke order:** [`FLEET_INVOCATION_ORDER.md`](FLEET_INVOCATION_ORDER.md)

---

## Universal inventory

| Surface | What to capture | Typical reviewers |
|---------|-----------------|-------------------|
| HTTP routes | Controller paths, methods, auth requirements, state changes | `input_validation_reviewer`, `authorization_reviewer`, `csrf_reviewer`, `identifier_enumeration_reviewer` |
| Inputs | Path variables, query params, forms, JSON, headers, cookies, uploads | `input_validation_reviewer`, `injection_reviewer`, `xss_encoding_reviewer`, `file_upload_inclusion_reviewer` |
| Outputs | Thymeleaf, JSON, redirects, downloads, error pages, response headers | `xss_encoding_reviewer`, `open_redirect_reviewer`, `clickjacking_headers_reviewer`, `disclosure_reviewer` |
| Identity | Login, logout, reset, password change, session config, roles | `step_up_auth_reviewer`, `session_reviewer`, `password_credentials_reviewer`, `authorization_reviewer` |
| Object access | URL IDs, public IDs, ownership checks, admin override paths | `authorization_reviewer`, `identifier_enumeration_reviewer` |
| Files | Uploads, downloads, template includes, static resources, archive extraction | `file_upload_inclusion_reviewer`, `disclosure_reviewer` |
| Outbound calls | RestTemplate, WebClient, mail, webhooks, callback URLs, metadata calls | `injection_reviewer`, `middleware_tls_dos_reviewer`, `ssrf_reviewer` |
| Data binding | MVC model binding, JSON DTOs, entity binding, unknown fields | `input_validation_reviewer`, `mass_assignment_reviewer` |
| Parsers | XML, YAML, CSV, JSON polymorphism, Java serialization, document parsers | `file_upload_inclusion_reviewer`, `unsafe_parsing_deserialization_reviewer` |
| Secrets/config | Properties, env placeholders, Dockerfile, gitignore, CI scripts | `password_credentials_reviewer`, `disclosure_reviewer`, `container_secrets_reviewer` |
| Dependencies | Maven parent, plugins, CVE tools, third-party JS | `vulnerability_reviewer`, `supply_chain_reviewer`, `security_testing_reviewer` |
| Runtime/ops | TLS, proxy headers, rate limits, timeouts, actuator, logging | `clickjacking_headers_reviewer`, `disclosure_reviewer`, `middleware_tls_dos_reviewer`, `security_logging_monitoring_reviewer` |

---

## Spring Boot search probes

These are starting probes, not the full audit.

| Goal | Probe |
|------|-------|
| Find controllers | `rg -n "@(Controller|RestController|RequestMapping|GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping)" src` |
| Find raw params | `rg -n "@(RequestParam|PathVariable|RequestHeader|CookieValue).*String|HttpServletRequest|ServletRequest" src` |
| Find state changes | `rg -n "@(PostMapping|PutMapping|PatchMapping|DeleteMapping)|save\\(|delete\\(|update\\(" src` |
| Find redirects | `rg -n "redirect:|RedirectView|sendRedirect|Location" src` |
| Find file/path use | `rg -n "MultipartFile|Paths\\.get|new File|ResourceLoader|InputStreamResource|ZipInputStream" src` |
| Find outbound calls | `rg -n "RestTemplate|WebClient|HttpClient|URL\\(|URI\\(|openConnection|openStream" src` |
| Find risky DOM sinks | `rg -n "innerHTML|outerHTML|insertAdjacentHTML|document\\.write|eval\\(|new Function" src` |
| Find secret defaults | `rg -n "\\$\\{[^}:]+:[^}]+\\}|password|secret|token|key" src pom.xml Dockerfile .gitignore` |
| Find actuator exposure | `rg -n "management\\.endpoints|management\\.endpoint|spring-boot-starter-actuator" .` |
| Find deserialization/parser risk | `rg -n "ObjectInputStream|readObject|enableDefaultTyping|XmlMapper|DocumentBuilderFactory|SAXParserFactory|TransformerFactory|Yaml" src` |

Agents may add domain-specific probes, but they must not skip this inventory when the surface is in scope.

---

## Runtime probes

| Surface | Required runtime evidence when available |
|---------|------------------------------------------|
| Session cookies | `Set-Cookie` contains `Secure`, `HttpOnly`, `SameSite`, scoped path/domain. |
| CSRF | State-changing browser request without token returns 403. |
| CORS | Untrusted `Origin` is not reflected. |
| Clickjacking | HTML response contains `Content-Security-Policy: frame-ancestors ...` or `X-Frame-Options`. |
| Redirect | `next=https://evil.example` does not redirect externally. |
| IDOR | User A cannot read/update/delete User B resource by changing ID. |
| Upload | Renamed executable/polyglot/oversized file rejected; download served non-executable. |
| Actuator | `/actuator/env`, `/actuator/beans`, wildcard exposure are unavailable on web. |
| SSRF | URL input cannot reach private IPs, metadata IPs, file schemes, or redirects to blocked hosts. |

---

## Manual review triggers

Create `MANUAL_REVIEW` items when:

- authorization depends on service-layer ownership logic that static grep cannot prove,
- CSRF behavior depends on runtime security chain selection,
- file validation depends on a library wrapper whose behavior is not visible,
- redirect safety depends on environment allow-lists not present in repo,
- outbound request allow-lists are injected at deploy time,
- parser settings are hidden behind factory methods,
- a check needs two authenticated users or live roles to prove.

Manual review is not a pass. It is a work item that blocks security confidence.
