---
name: cryptography_reviewer
version: 1.0
disable-model-invocation: true
---

# Cryptography Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/cryptography_reviewer.md` |
| Skill directory | `.cursor/skills/cryptography_reviewer/` |
| Cursor invoke name | `cryptography_reviewer` |
| Report path | `AI/cryptography_reviewer/cryptography_reviewer_report.md` |
| Report reviewer line | `cryptography_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for cryptography_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot application.
```

---

## 2. File Discovery

Scan in this order.

### Core Cryptography
- Classes importing `javax.crypto.*` or `java.security.*`
- Classes importing `org.bouncycastle.*`
- Utilities for token generation, hashing, or encryption

### Configuration
- `application.properties`, `application.yml`
- Environment variables or secrets configuration

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find ciphers | `rg -n "Cipher.getInstance\|MessageDigest.getInstance\|Signature.getInstance" src` |
| Find insecure symmetric | `rg -n "AES/ECB\|DES/\|RC4\|DESede\|3DES" src` |
| Find insecure random | `rg -n "java.util.Random\|Math.random\(\|RandomStringUtils.random\(" src` |
| Find hardcoded keys | `rg -n "SecretKeySpec\(\".*\"\.getBytes\|String secret = \"\|String key = \"" src` |
| Find weak hashing | `rg -n "MessageDigest.getInstance\(\"MD5\"\)\|MessageDigest.getInstance\(\"SHA-1\"\)" src` |
| Find custom crypto | `rg -n "<< \| >> \| \^ \| bitwise" src` (filtered for crypto context) |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| CRYPT01-CRYPT06 | Application performs absolutely no explicit cryptographic operations. |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### CRYPT01 - No insecure symmetric modes
Fail when encryption uses ECB mode, DES, 3DES, or RC4.

### CRYPT02 - Secure asymmetric key sizes
Fail when RSA key sizes < 2048 or DSA is used.

### CRYPT03 - Secure randomness required
Fail when `java.util.Random` or `Math.random()` are used for security tokens, keys, IVs, or passwords.

### CRYPT04 - No hardcoded keys
Fail when symmetric or asymmetric keys/IVs are hardcoded in the source.

### CRYPT05 - Custom cryptography
Fail when developers write their own bitwise crypto algorithms.

### CRYPT06 - Weak hashing for integrity
Fail when MD5 or SHA-1 are used for secure hashing or signing.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Key sizes or cipher suites are configured dynamically from external systems.
- Cryptography happens inside closed-source third-party dependencies.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| CRYPT01 | Authenticated encryption | Use `AES/GCM/NoPadding` | Data is encrypted and authenticated | ECB or DES modes | Inspect `Cipher.getInstance` usage |
| CRYPT02 | Strong key sizes | Generate RSA 2048+ or EC keys | Keys resist factoring attacks | RSA < 2048 or DSA | Inspect `KeyPairGenerator.initialize` |
| CRYPT03 | Secure random | Use `new java.security.SecureRandom()` | Tokens/keys are unpredictable | `java.util.Random` | Search for `SecureRandom` usage |
| CRYPT04 | Externalized secrets | Inject keys via `@Value` or `Environment` | Code can be public without compromising keys | Hardcoded strings as keys | Confirm keys are loaded from properties/env |
| CRYPT05 | Standard libraries | Rely on `javax.crypto` or BouncyCastle | Algorithms are vetted and secure | Custom bitwise math for crypto | Confirm standard provider usage |
| CRYPT06 | Modern hashing | Use `MessageDigest.getInstance("SHA-256")` | Hashes resist collision attacks | MD5 or SHA-1 | Inspect `MessageDigest` initialization |

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
- Confirm `java.util.Random` for security is a Critical failure.
