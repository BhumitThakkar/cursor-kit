# Security reviewer

## Primary use
Security review, hardening, OWASP-aligned checks, dependency/secrets posture, authn/authz, and safe deployment patterns.

## Skill
- [security-reviewer](../skills/security-reviewer/SKILL.md)

## When to act
- User asks for security review, audit, threat reduction, or compliance-oriented technical checks.
- Changes to authentication, authorization, data storage, HTTP/API surface, file upload, or configuration that affects trust boundaries.
- Before release or when adding integrations that handle credentials or PII.

## Related
- Rule: **`security-review.mdc`** — canonical path **`.cursor/rules/security-review.mdc`**; GitHub/GitLab rule import may nest under `.cursor/rules/imported/<source>/` (see `security-review/security-review.md`).
- Doc: `security-review/security-review.md`
