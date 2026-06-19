# Cryptography Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/cryptography_reviewer.md` |
| Cursor invoke name | `cryptography_reviewer` |
| Report path | `AI/cryptography_reviewer/cryptography_reviewer_report.md` |
| Report reviewer line | `cryptography_reviewer v1.0 STRICT` |

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
| CRYPT01 | No insecure symmetric modes | Application uses `AES/ECB/PKCS5Padding`, `DES`, `3DES`, or `RC4` for encrypting data |
| CRYPT03 | Secure randomness required | Application uses `java.util.Random`, `Math.random()`, or Apache Commons `RandomStringUtils` to generate encryption keys, session identifiers, CSRF tokens, or OTPs |
| CRYPT04 | No hardcoded keys | Application hardcodes symmetric/asymmetric cryptographic keys, IVs, or secrets directly in source code |

### High

| ID | Citation | Condition |
|---|---|---|
| CRYPT02 | Secure asymmetric key sizes | Application uses RSA keys smaller than 2048 bits or DSA for asymmetric cryptography |
| CRYPT05 | Custom cryptography | Application implements custom cryptographic algorithms instead of relying on standard JDK/BouncyCastle providers (`javax.crypto.*`, `java.security.*`) |

### Medium

| ID | Citation | Condition |
|---|---|---|
| CRYPT06 | Weak hashing for integrity | Application uses `MD5` or `SHA-1` for general data integrity hashing or digital signatures (note: for passwords, see password_credentials_reviewer) |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| CRYPT01 | Symmetric encryption explicitly uses authenticated encryption like `AES/GCM/NoPadding` or `AES/CBC/PKCS5Padding` with a secure randomized IV. |
| CRYPT02 | RSA key sizes are explicitly defined as 2048 or 4096 bits. Elliptic Curve (EC) is preferred. |
| CRYPT03 | Security tokens, IVs, and keys are generated exclusively using `java.security.SecureRandom`. |
| CRYPT04 | Cryptographic keys and static IVs are loaded from external configuration properties, environment variables, or secret managers. |
| CRYPT05 | Code uses standard library instances (e.g. `Cipher.getInstance()`, `Signature.getInstance()`) and never rolls its own bitwise cryptographic logic. |
| CRYPT06 | Hashing uses `SHA-256`, `SHA-512`, `SHA3-256`, or equivalent modern digest algorithms. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| CRYPT01-CRYPT06 | Application performs absolutely no cryptographic operations (no explicit encryption, decryption, custom signing, or token generation). Note: passwords and JWTs are handled by other reviewers. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Key lengths are derived from external configuration files not present in the repository.
- A wrapper library is used for cryptography, and its internal implementation or cipher suites cannot be determined from the source code.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| CRYPT01 | Crypto | Critical | No insecure symmetric modes |
| CRYPT02 | Crypto | High | Secure asymmetric key sizes |
| CRYPT03 | Randomness | Critical | Secure randomness required |
| CRYPT04 | Key Mgmt | Critical | No hardcoded keys |
| CRYPT05 | Custom | High | Custom cryptography |
| CRYPT06 | Integrity | Medium | Weak hashing for integrity |
