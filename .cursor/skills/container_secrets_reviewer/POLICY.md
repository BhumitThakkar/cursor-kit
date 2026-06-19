# Container & Secrets Security Policy v1.1 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Committing live secrets or running root containers are always findings.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/container_secrets_reviewer.md` |
| Cursor invoke name | `container_secrets_reviewer` |
| Report path | `AI/container_secrets_reviewer/container_secrets_reviewer_report.md` |
| Report reviewer line | `container_secrets_reviewer v1.1 STRICT` |

**Scope:** Dockerfile hygiene, `.gitignore` secret patterns, and Spring properties secrets. Maven BOM/OWASP/plugin pins are owned by `vulnerability_reviewer`. CDN scripts are owned by `supply_chain_reviewer`.

---

## Cross-reviewer ownership (vulnerability_reviewer v1.0 migration)

| Former vulnerability CHECK-ID | Owner CHECK-ID |
|---|---|
| V07 — Env files gitignored | **SEC06** |
| V08 — Pinned container base | **SEC01** |

Do **not** expect `vulnerability_reviewer` to score V07/V08 after v2.0.

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
| SEC04 | No secrets in ENV or layers | Dockerfile explicitly sets `ENV` variables with production secrets, or commits a layer containing passwords/keys |
| SEC05 | No secrets in ARG or build context | Secrets are passed as build arguments (`ARG`) or copied from sensitive build settings (e.g., `settings.xml` with credentials) and left in the image history |
| SEC06 | Gitignore .env files | Project root `.gitignore` fails to exclude `.env` and `.env.*` files (excluding templates like `.env.example`) |
| SEC07 | Gitignore keystores | Project root `.gitignore` fails to exclude private keystores/certificates (`*.pem`, `*.key`, `*.p12`, `*.jks`) |
| SEC08 | Gitignore service accounts | Project root `.gitignore` fails to exclude cloud credential JSON patterns (e.g., `*service-account*.json`) |
| SEC09 | No live secret defaults | `application.properties` or `application.yml` contains live, valid production secrets either hardcoded or as fallback defaults (`${DB_PASS:real_password}`) |
| SEC10 | Rotate committed secrets | Evidence shows a live secret was committed in history and merely deleted from the latest commit, without proof of external credential rotation |

### High

| ID | Citation | Condition |
|---|---|---|
| SEC01 | Pinned base image tag | Dockerfile uses the `latest` tag for the base image instead of a pinned version and SHA digest |
| SEC02 | Non-root container user | Dockerfile lacks a `USER` directive switching away from `root`, resulting in the application running as root inside the container |
| SEC11 | Runtime secret injection | Application expects secrets to be baked into properties files at build time rather than exclusively resolving them from environment variables or secret managers at deployment time |
| SEC12 | Fail fast without secrets | Application defines unsafe fallback credentials (e.g., default AWS keys or DB passwords) instead of failing to start when required environment variables are absent |

### Medium

| ID | Citation | Condition |
|---|---|---|
| SEC03 | EXPOSE matches server.port | Dockerfile `EXPOSE` port differs from the Spring Boot `server.port` defined in properties, leading to network mapping confusion |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| SEC01 | Base image has an explicit version tag (e.g., `eclipse-temurin:17-jre`). |
| SEC02 | Dockerfile creates a non-root group and user, and includes a `USER appuser` directive before `CMD`. |
| SEC03 | `EXPOSE` port perfectly matches the configured `server.port`. |
| SEC04 | `ENV` is only used for non-sensitive configurations (like timezone or port). |
| SEC05 | `ARG` is not used to pass API keys, passwords, or tokens. |
| SEC06 | `.gitignore` explicitly lists `.env` and `.env.*` (but can allow `.env.example`). |
| SEC07 | `.gitignore` explicitly lists `*.pem`, `*.key`, `*.p12`, and `*.jks`. |
| SEC08 | `.gitignore` explicitly lists `*service-account*.json` or similar cloud credential conventions. |
| SEC09 | `application.properties` only contains placeholders (`${DB_PASS}`) or dummy defaults (`${DB_PASS:dummy}`). |
| SEC10 | If a secret was committed previously, the codebase comments or external issue tracker indicate it was cryptographically rotated. |
| SEC11 | All sensitive properties use Spring's `${ENV_VAR}` placeholder syntax. |
| SEC12 | Sensitive properties have no default (`${SECRET}`) and cause Spring Boot startup to throw an `IllegalArgumentException` if missing. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| SEC01-SEC05 | Project has no Dockerfile or containerization scripts. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Application uses an external secret manager SDK (Vault, AWS Secrets Manager) and the injection mechanism occurs purely at runtime in a cloud environment not visible here.
- A hardcoded string appears to be a secret but might be a safe development dummy value, requiring human verification.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| SEC01 | Docker | High | Pinned base image tag |
| SEC02 | Docker | High | Non-root container user |
| SEC03 | Docker | Medium | EXPOSE matches server.port |
| SEC04 | Docker | Critical | No secrets in ENV or layers |
| SEC05 | Docker | Critical | No secrets in ARG or build context |
| SEC06 | Git | Critical | Gitignore .env files |
| SEC07 | Git | Critical | Gitignore keystores |
| SEC08 | Git | Critical | Gitignore service accounts |
| SEC09 | Properties | Critical | No live secret defaults |
| SEC10 | Git | Critical | Rotate committed secrets |
| SEC11 | Properties | High | Runtime secret injection |
| SEC12 | Properties | High | Fail fast without secrets |
