---
name: container_secrets_reviewer
version: 1.1
disable-model-invocation: true
---

# Container & Secrets Security Reviewer - Scan Skill v1.1 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/container_secrets_reviewer.md` |
| Skill directory | `.cursor/skills/container_secrets_reviewer/` |
| Cursor invoke name | `container_secrets_reviewer` |
| Report path | `AI/container_secrets_reviewer/container_secrets_reviewer_report.md` |
| Report reviewer line | `container_secrets_reviewer v1.1 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot applications that use property files, Git repositories, and/or Dockerfiles.

| Required signal | Evidence |
|---|---|
| Spring Boot | `application.properties`, `application.yml` |
| Version Control | `.gitignore` |
| Docker | `Dockerfile`, `docker-compose.yml` |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| No configs | Completely empty project lacking properties, gitignore, and Dockerfiles |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for container_secrets_reviewer because it lacks Spring Boot properties, a Dockerfile, and Git configuration.
```

---

## 2. File Discovery

Scan in this order.

### Git Configuration

- `.gitignore` in the project root

### Properties and Configuration

- `application.properties`, `application.yml`, `bootstrap.yml`
- Check all active profiles (dev, prod)

### Docker

- `Dockerfile`
- `docker-compose.yml`

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find image tags | `rg -n "^FROM" Dockerfile` |
| Find container user | `rg -n "^USER" Dockerfile` |
| Find exposed ports | `rg -n "^EXPOSE" Dockerfile` |
| Find Docker ENV/ARG | `rg -n "^ENV\|^ARG" Dockerfile` |
| Find gitignore keys | `rg -n "\.env\|pem\|key\|p12\|jks\|json" \.gitignore` |
| Find property defaults | `rg -n "\$\{[^}]*:[^}]*\}" src` (look for `password`, `key`, `secret`, `token`) |
| Find hardcoded secrets | `rg -n "password=\w+\|secret=\w+\|token=\w+" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| SEC01-SEC05 | Application does not include a `Dockerfile`. |

---

## 5. CHECK-ID Scoring Procedure

### SEC01 - Pinned Base Image Tag
Fail when `FROM` uses `:latest` or omits a tag entirely.

### SEC02 - Non-root Container User
Fail when the `Dockerfile` does not contain a `USER` directive switching to a non-root account before the final `CMD` or `ENTRYPOINT`.

### SEC03 - EXPOSE Matches server.port
Fail when `EXPOSE <port>` does not match `server.port` in the primary application properties.

### SEC04 - No Secrets in ENV or Layers
Fail when `ENV` sets database passwords, API keys, or when a layer explicitly copies a `.env` or keystore file.

### SEC05 - No Secrets in ARG or Build Context
Fail when `ARG` is used to pass secrets that get cached in Docker image history.

### SEC06 - Gitignore .env Files
Fail when `.env` is absent from `.gitignore`.

### SEC07 - Gitignore Keystores
Fail when extensions `.pem`, `.key`, `.p12`, or `.jks` are absent from `.gitignore`.

### SEC08 - Gitignore Service Accounts
Fail when service account JSON patterns are absent from `.gitignore`.

### SEC09 - No Live Secret Defaults
Fail when properties files contain hardcoded secrets or fallback values (`${DB_PASS:SuperSecret123}`).

### SEC10 - Rotate Committed Secrets
Fail when a secret was found deleted in recent history without evidence of rotation. (If scanning tools flag historical secrets without resolution, it's a fail).

### SEC11 - Runtime Secret Injection
Fail when the application hardcodes keys rather than pulling them via `${SECRET_VAR}`.

### SEC12 - Fail Fast Without Secrets
Fail when properties define fallback keys (`${API_KEY:dummy_dev_key}`) in production profiles instead of failing context startup.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Evaluating whether a hardcoded string is a dummy dev secret or a real production secret.
- Scanning git history manually for previously committed keys if automated tool logs are missing.

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
| SEC01 | Explicit image tag | Append a specific version tag and optionally a SHA-256 digest to `FROM` | Build uses a predictable, reproducible base environment | Using `:latest` | Run `docker build`; confirm explicit tag is pulled |
| SEC02 | Non-root runtime | Create a group/user and add `USER appuser` to the Dockerfile | Container breakout does not yield host root privileges | Running as root | Run `docker inspect`; confirm `User` is not `root` or `0` |
| SEC03 | Port mapping | Align `EXPOSE` with `server.port` | Network routers and proxies can accurately map traffic | Mismatched exposed ports | Inspect Dockerfile; confirm `EXPOSE` matches properties |
| SEC04 | Runtime injection | Remove sensitive `ENV` directives; rely on orchestration (e.g., Kubernetes Secrets) at runtime | Image layers do not leak secrets | Secrets in `ENV` | Run `docker history`; confirm no secrets visible |
| SEC05 | Buildkit secrets | Use `RUN --mount=type=secret` or pass via env, avoiding `ARG` | Build-time secrets are not cached in image history | Secrets in `ARG` | Run `docker history`; confirm no secrets in ARG instructions |
| SEC06 | Ignore environments | Add `.env` and `.env.*` to `.gitignore` | Local environment variables are not pushed to Git | Committing `.env` files | Run `git check-ignore .env`; confirm it is ignored |
| SEC07 | Ignore keystores | Add `*.pem`, `*.key`, `*.p12`, `*.jks` to `.gitignore` | Private certificates/keys are not pushed to Git | Committing keystores | Run `git check-ignore test.p12`; confirm it is ignored |
| SEC08 | Ignore credentials | Add `*service-account*.json` to `.gitignore` | Cloud credentials are not pushed to Git | Committing service JSONs | Run `git check-ignore service-account.json`; confirm it is ignored |
| SEC09 | Environment placeholders | Replace hardcoded secrets with `${SECRET_ENV_VAR}` | Codebase contains zero actionable secrets | Hardcoded default secrets | Grep properties for passwords; confirm none exist |
| SEC10 | Secret rotation | Use the vendor's dashboard to invalidate the compromised key and generate a new one | Compromised keys cannot access production systems | Deleting line without rotating | Attempt to use old key; confirm authentication fails |
| SEC11 | Env lookup | Rely exclusively on Spring Boot's property resolution from environment variables | Images are completely environment-agnostic | Baking secrets into jars | Run app without env vars; confirm it fails to connect |
| SEC12 | Fast failure | Remove dummy default values (`:dummy`) for required sensitive fields | Application refuses to boot in an insecure state | Fallback to dummy secrets | Start app missing required secret; confirm immediate startup crash |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Fleet run order

Run **after** `vulnerability_reviewer` when Dockerfile, `.gitignore`, or properties secrets are in deploy scope. Run **before** `supply_chain_reviewer` when both container and HTML/CDN checks apply.

**Absorbed checks:** SEC01 and SEC06 own former `vulnerability_reviewer` V08 and V07 respectively.

---

## 11. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm non-root execution (SEC02) is a High severity failure.
- Confirm hardcoded secrets in properties (SEC09) is a Critical severity failure.
- Confirm no V* or SUP* CHECK-IDs appear in this report.
