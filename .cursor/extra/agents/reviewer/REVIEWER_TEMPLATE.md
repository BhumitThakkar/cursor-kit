# Security Reviewer Template — STRICT fleet standard

**Purpose:** Canonical fill-in blueprint for the four-file reviewer bundle under `.cursor/`.  
**Audience:** Humans and agents authoring or bumping a reviewer.  
**Does not replace:** verdict law (`SCORING_REVIEWER_AGENT_MECHANISM.md`) or attack-surface inventory (`ATTACK_SURFACE_INVENTORY.md`) — both live in `.cursor/extra/agents/reviewer/`.

| Read first | Path |
|---|---|
| Verdict + scoring law | `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md` |
| Attack-surface probes | `.cursor/extra/agents/reviewer/ATTACK_SURFACE_INVENTORY.md` |
| Fleet invoke order | `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` |
| This template | `.cursor/extra/agents/reviewer/REVIEWER_TEMPLATE.md` |

---

## 1. File set (every reviewer)

| # | Path | Role |
|---|---|---|
| 1 | `.cursor/skills/{agent_name}/POLICY.md` | CHECK-IDs, severities, pass/fail/N/A law |
| 2 | `.cursor/skills/{agent_name}/SKILL.md` | Stack gate, discovery, probes, resolution catalog, scoring |
| 3 | `.cursor/agents/{agent_name}.md` | Workflow steps, report contract |
| 4 | `.cursor/rules/{agent_name}.mdc` | Cursor invoke wrapper; non-negotiable rules |
| 5 | `.cursor/scripts/agents/{agent_name}/` | Optional scan scripts (e.g. `vulnerability_reviewer`) |
| 6 | `AI/{agent_name}/{agent_name}_report.md` | Report output (created per project run) |

**Placeholders**

| Token | Example |
|---|---|
| `{agent_name}` | `csrf_reviewer` |
| `{AGENT_PREFIX}` | `CSRF` |
| `{VERSION}` | `2.0` |
| `{DOMAIN_TITLE}` | `CSRF` |
| `{SP_DOMAIN}` | `SP-07` |
| `{PROJECT_NAME}` | From `spring.application.name` or folder name |

**Frontmatter (SKILL + agent)**

```yaml
---
name: {agent_name}
version: {VERSION}
disable-model-invocation: true   # SKILL only — always true for reviewers
description: >-
  One sentence: what this auditor checks. End with "Report-only."
---
```

---

## 2. CHECK-ID design

| Rule | Detail |
|---|---|
| Prefix | Domain-specific: `CSRF`, `AUTH`, `V`, `SEC`, `DISC`, `IV`, etc. |
| One behavior | `CSRF07 session mutation inventory` — not `CSRF insecure` |
| Fixed severity | Declared in POLICY; agent never downgrades by tone or confidence |
| N/A proof | Document search patterns + files proving surface absent |
| Resolution catalog | One row per CHECK-ID in SKILL §8 (or §6 for two-phase agents) |
| Cross-owner | If another agent owns a check, list in POLICY **Related reviewers** — do not score |

Every `MUST` in the SP POINT file maps to at least one CHECK-ID.

---

## 3. Authoring order

1. Read `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md`.
2. Read `.cursor/extra/agents/reviewer/ATTACK_SURFACE_INVENTORY.md` for applicable probes.
3. Read `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` when placing the agent in the fleet.
3. Write **POLICY.md** (CHECK-IDs + Appendix A).
4. Write **SKILL.md** (gate, discovery, procedures, resolution catalog).
5. Write **agent.md** (workflow referencing SKILL sections).
6. Write **rule.mdc** (invoke + 3–5 non-negotiable rules).
7. Self-validate with **§10** below.
8. Update `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` if invoke order or version changes.

---

## 4. POLICY.md template

```markdown
# {DOMAIN_TITLE} Security Policy v{VERSION} STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/{agent_name}.md` |
| Cursor invoke name | `{agent_name}` |
| Report path | `AI/{agent_name}/{agent_name}_report.md` |
| Report reviewer line | `{agent_name} v{VERSION} STRICT` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only. `UNCLEAR` is forbidden.

---

## Resolution Requirement

Every finding: five Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). Only Evidence may quote source.

---

## Related reviewers (optional — use when checks moved to sibling agents)

| Topic | Invoke | CHECK-IDs | When required |
|-------|--------|-----------|---------------|
| {topic} | `{other_agent}` | {IDs} | {gate condition} |

Do **not** score checks owned by sibling agents.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| {PREFIX}01 | {short citation} | {fail condition} |

### High

| ID | Citation | Condition |
|---|---|---|
| {PREFIX}02 | {short citation} | {fail condition} |

### Medium

| ID | Citation | Condition |
|---|---|---|
| {PREFIX}03 | {short citation} | {fail condition} |

### Low (optional)

| ID | Citation | Condition |
|---|---|---|
| {PREFIX}04 | {short citation} | {fail condition} |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| {PREFIX}01 | {concrete pass signal} |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| {PREFIX}02 | {proof of absence} |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail. State exact missing evidence. Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| {PREFIX}01 | {domain slice} | Critical | {citation} |
```

---

## 5. SKILL.md template

```markdown
---
name: {agent_name}
version: {VERSION}
disable-model-invocation: true
---

# {DOMAIN_TITLE} Security Reviewer - Scan Skill v{VERSION} STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/{agent_name}.md` |
| Skill directory | `.cursor/skills/{agent_name}/` |
| Shared — invoke order | `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` |
| Shared — scoring law | `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md` |
| Shared — attack surface | `.cursor/extra/agents/reviewer/ATTACK_SURFACE_INVENTORY.md` |
| Cursor invoke name | `{agent_name}` |
| Report path | `AI/{agent_name}/{agent_name}_report.md` |
| Report reviewer line | `{agent_name} v{VERSION} STRICT` |

---

## 1. Supported Technology Stack

{Describe required signals and evidence table.}

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot servlet | {framework} |

Mandatory report wording:

\`\`\`text
Project "{PROJECT_NAME}" is out of scope for {agent_name} because it uses {TECHNOLOGY}, which {reason}.

You need a different, specialized security reviewer to review this application. This agent audits {scope} for Spring Boot servlet applications only.
\`\`\`

---

## 2. File Discovery

Scan in this order.

### {Category 1}

- {paths and what to look for}

---

## 3. Required Search Probes

| Goal | Probe |
|---|---|
| {goal} | `rg -n "{pattern}" {path}` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

| Check | N/A allowed only when |
|---|---|
| {PREFIX}02 | {proof} |

---

## 5. CHECK-ID Scoring Procedure

### {PREFIX}01 - {Title}

{Fail when / Pass when / MANUAL_REVIEW when — one subsection per CHECK-ID.}

---

## 6. Manual Review Triggers

- {condition requiring MANUAL_REVIEW}

---

## 7. Report Requirements

Every scored finding: File, Evidence, Policy Rule, Possible Attack Scenario, five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row: **Action + pass signal.**

---

## 8. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| {PREFIX}01 | {name} | {prose} | {property} | {label} | {action + signal} |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

Grades: 90+ A, 75+ B, 60+ C, 40+ D, below F

---

## 10. Final Self-Validation

Before finalizing a report:

- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm every N/A has proof in Scope Notes.
- Confirm Executive Summary counts match Findings.
- Confirm no CHECK-IDs owned by sibling agents appear in this report.
```

---

## 6. Agent workflow template (`new agents/{agent_name}.md`)

```markdown
---
name: {agent_name}
version: {VERSION}
description: >-
  STRICT Spring Boot {domain} auditor. {one-line scope}. Report-only.
---

# {DOMAIN_TITLE} Reviewer v{VERSION} STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/{agent_name}/SKILL.md`
2. `.cursor/skills/{agent_name}/POLICY.md`
3. `.cursor/extra/agents/reviewer/SCORING_REVIEWER_AGENT_MECHANISM.md` (verdict law)

| Artifact | Path / value |
|---|---|
| Invoke name | `{agent_name}` |
| Report path | `AI/{agent_name}/{agent_name}_report.md` |
| Report reviewer line | `{agent_name} v{VERSION} STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. Every finding gets five Resolution rows. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` §1 before scoring.

**Pass:** {gate pass criteria}

**Fail:** out-of-scope report only. No CHECK-IDs scored. Use mandatory wording from SKILL §1.1.

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] {discovery item}

### CHECK-IDs

- [ ] {PREFIX}01 - {title}
- [ ] {PREFIX}02 - {title}

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/{agent_name}/{agent_name}_report.md` (create `AI/{agent_name}/` if missing)

### In-scope report structure

\`\`\`markdown
# {DOMAIN_TITLE} Security Report - {PROJECT_NAME}

**Reviewer:** {agent_name} v{VERSION} STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Entry points reviewed:
- N/A checks with proof:
- Manual review items:

## Executive Summary

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Manual Review | 0 |

**Security Score:** {score}/100 - Grade {letter}
**Verdict:** {Excellent | Good | Fair | Poor | Critical - Do Not Deploy}

## Findings

### 1. {CHECK-ID} - {title}

**Severity:** Critical|High|Medium|Low
**File:** `path:line`
**Evidence:** `safe quoted evidence`
**Policy Rule:** `POLICY.md - {CHECK-ID} - {citation}`
**Possible Attack Scenario:** One or two sentences.

| Resolution row | Content |
|---|---|
| Pattern | SKILL.md §8 - {CHECK-ID} |
| Mechanism | ... |
| Security property | ... |
| Prohibited | ... |
| Verify | Action plus pass signal. |

## Manual Review

## Passed Checks

## Completion Summary
\`\`\`

---

## Step 5 - Final Validation

Before saving the report, verify:

- Every failed CHECK-ID has File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.
- Every Verify row includes action + pass signal.
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
```

---

## 7. Rule template (`new rules/{agent_name}.mdc`)

```markdown
---
description: >-
  Cursor rule for {agent_name} v{VERSION} STRICT. {one-line scope}. Invoke agent only.
globs: "**/*.java,**/*.kt,**/*.xml,**/*.html,**/*.js,**/application.properties,**/application.yml,**/application-*.properties,**/application-*.yml,**/pom.xml,**/build.gradle,**/build.gradle.kts"
alwaysApply: false
---

# {DOMAIN_TITLE} Reviewer Rule v{VERSION} STRICT

**Do not inline-audit.** Invoke **`{agent_name}`** -> `.cursor/agents/{agent_name}.md`.

| Report line | `{agent_name} v{VERSION} STRICT` |
| Report path | `AI/{agent_name}/{agent_name}_report.md` |

**POLICY.md wins.**

## References

| Artifact | Path |
|---|---|
| Policy | `.cursor/skills/{agent_name}/POLICY.md` |
| Skill | `.cursor/skills/{agent_name}/SKILL.md` |
| Shared template | `.cursor/extra/agents/reviewer/REVIEWER_TEMPLATE.md` |

## Non-negotiable rules

1. **{Highest-impact rule — always FAIL}.**
2. **{Second rule}.**
3. **{Third rule}.**

Allowed verdicts: **PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A**. `UNCLEAR` is forbidden.
```

**Globs:** Narrow when the agent is narrow (e.g. `supply_chain_reviewer` → `**/*.html,**/templates/**` only). Never use `alwaysApply: true` for reviewers.

---

## 8. Variant — two-phase auditor (`vulnerability_reviewer` pattern)

Use when Phase 1 static config must pass before an agent-run script executes.

| Piece | Difference |
|---|---|
| POLICY | Split **Phase 1** and **Phase 2** CHECK-ID tables; Phase 1 fail blocks Phase 2 |
| SKILL | §2 workflow with mandatory status blocks (FAILED/PENDING vs PASSED/COMPLETED) |
| Agent | Separate Step 3 (static) and Step 4 (run script); two report templates |
| Rule | Document script path and gate explicitly |

**Phase 1 fail — mandatory status block (verbatim in report):**

```
**Phase 1 of 2:** FAILED — static configuration
**Phase 2 of 2:** PENDING — not run

Phase 2 ({tool list}) was not executed because Phase 1 failed.

Fix all Phase 1 findings, then re-invoke {agent_name}.
```

**Phase 1 pass:**

```
**Phase 1 of 2:** PASSED — static configuration
**Phase 2 of 2:** COMPLETED — scan script executed
```

---

## 9. Variant — prerequisite CHECK-ID (e.g. `CSRF00`)

Some agents use a **non-scored prerequisite** recorded in Scope Notes before other CHECK-IDs:

| Pattern | Example |
|---|---|
| Prerequisite ID | `CSRF00` auth model classification |
| Gating | Later checks use N/A or different fail rules per prerequisite value |
| Report | Prerequisite value in report header / Scope Notes |

Document prerequisite order in agent Step 3: "CHECK-IDs (order matters)".

---

## 10. Author self-validation (before merge)

| # | Check |
|---|---|
| 1 | Version bumped in all four files + `FLEET_INVOCATION_ORDER.md` |
| 2 | Report reviewer line matches everywhere: `{agent_name} v{VERSION} STRICT` |
| 3 | Every CHECK-ID in POLICY appears in SKILL §5 and §8 |
| 4 | Every CHECK-ID in agent Step 3 checklist |
| 5 | Invoke order row exists in `FLEET_INVOCATION_ORDER.md` |
| 6 | Out-of-scope wording matches SKILL §1.1 exactly |
| 7 | Resolution Verify rows are action + pass signal, not vague |
| 8 | Rule has 3+ non-negotiable FAIL rules for highest-severity checks |
| 9 | `disable-model-invocation: true` on SKILL |
| 10 | Agent ends with **Report-only** |

---

## 11. Version bump checklist

When shipping `{agent_name}` v{N+1}:

1. Bump `version:` in SKILL and agent frontmatter.
2. Update title lines (`v{N+1} STRICT`) in POLICY, SKILL, agent, rule.
3. Update **Report reviewer line** table in POLICY and SKILL §0.
4. Add **Cross-reviewer ownership** or migration table if CHECK-IDs moved.
5. Update `.cursor/extra/agents/reviewer/FLEET_INVOCATION_ORDER.md` (version + order).
7. Update relevant `domains/SP-xx-*/POINT.md` **Existing agent** line.

---

## 12. Fleet conventions (do not drift)

| Topic | Standard |
|---|---|
| Evidence | Only field that may quote source lines or tool output |
| Resolution prose | No pasteable code fences in Resolution rows |
| Frontend-only controls | Always **FAIL** when backend lacks equivalent enforcement |
| Spring defaults | Pass only with cited config/API proof across all profiles |
| Secrets in reports | Mask values; preserve proof of issue |
| Invoke | User/rule invokes `{agent_name}` — agent does not inline-audit from rule alone |
| Scoring | 100 base; Critical −20, High −10, Medium −5, Low −2; floor 0 |

---

## 13. Quick reference — live agent shapes

| Shape | Examples | Notes |
|---|---|---|
| Standard single-phase | `csrf_reviewer`, `authorization_reviewer`, `container_secrets_reviewer` | Steps 1–5, one report |
| Two-phase scan | `vulnerability_reviewer` | Static gate → script |
| Prerequisite gate | `csrf_reviewer` (CSRF00) | Classify before scoring family |
| Slim scope | `supply_chain_reviewer` v2.0 | Frontend-only; narrow globs |
| Companion run order | disclosure + actuator + clickjacking | Document in POLICY + crosswalk |

---

*Template version: 1.0 · Fleet: 25 live agents · Maintained in `.cursor/extra/agents/reviewer/`*
