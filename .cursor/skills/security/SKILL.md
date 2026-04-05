---
name: security
description: OWASP Top 10, dependency vulns, secrets, pen-test, GDPR, SQL/XSS/CSRF, certs, access control, Spring Security. Use for security review.
---

# Security Skill

## When to Use

- User asks for "security", "OWASP", "vulnerability", "secrets", or "compliance".
- Before release or on schedule (dependency scan, audit).

## Instructions

1. **Scans**
   - OWASP Dependency-Check in CI; fail on critical/high.
   - Secrets scan (e.g. gitleaks); block commit if secret detected.

2. **Prevention**
   - SQL: parameterized only. XSS: escape/sanitize. CSRF: tokens on state-changing requests.
   - Spring Security: validate CORS, CSRF, auth, rate limit.

3. **Response**
   - Critical vuln or secret: block and alert; patch or rotate within 24h.
   - Compliance failure: rollback to last compliant; fix and redeploy.

4. **Audit**
   - Quarterly security audit; document and remediate.

## Safety Checklist

- [ ] No critical vulns; no secrets in repo
- [ ] Compliance and cert monitoring in place
- [ ] Quarterly audit scheduled
