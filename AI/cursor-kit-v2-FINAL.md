# cursor-kit v2.0 — THE DEFINITIVE IMPLEMENTATION BLUEPRINT

> **Status:** Final. Implement this.
> **Date:** 2026-05-04
> **Author:** Bhumit Thakkar
> **Synthesized from:** `final_approach1.md` + `final_approach2.md` + gap analysis
> **Changes from previous versions:** Core Axiom promoted to Part 0; Agent Brief Templates added (Part VI); Inter-Agent Handoff Schema added (Part VII); Escalation Decision Tree added (Part VIII); Self-Improvement thresholds made concrete (Part V); Context Window Budget Table added (Appendix C).

---

## Part 0 — The Core Axiom (Read This First)

> **Inside Cursor, there are no persistent agents. Each turn reconstructs the world from files, executes a discrete action, and advances state deterministically.**

This is not a live operating system. It is a **commit engine with memory.** Every mechanism in this system is designed around this single immutable truth.

| What people assume | What is actually true |
|---|---|
| Agents are running concurrently | One agent executes per turn, sequentially |
| Events are broadcast in real-time | Events are written to a file; read at next turn |
| State exists in memory | State exists only in `state.json` |
| Agents heartbeat every N seconds | Agents write a snapshot file when done |
| Locks need TTL to prevent deadlock | No concurrent writers → no TTL needed |

If any design decision you make violates the axiom, discard it before building it.

---

## Part I — The Nervous System: Journal & State

### 1. Immutable Event Journal (replaces Event Bus)

Cursor cannot support real-time pub/sub. The system uses an append-only, replayable log.

**Path:** `.zeus/journal/session-YYYYMMDD.jsonl`

```json
{"seq":1,"ts":"2026-05-04T09:00:00Z","type":"SESSION.STARTED","source":"zeus","payload":{"root_task":"Build user registration flow","classification":"L2"}}
{"seq":2,"ts":"2026-05-04T09:01:00Z","type":"TASK.CREATED","source":"zeus","payload":{"task_id":"T1","desc":"Design UserRegistrationDTO","agent":"architect"}}
{"seq":3,"ts":"2026-05-04T09:05:00Z","type":"AGENT.DONE","source":"architect","payload":{"task_id":"T1","artifacts":["src/.../UserRegistrationDTO.java"]}}
{"seq":4,"ts":"2026-05-04T09:06:00Z","type":"GATE.PASSED","source":"zeus","payload":{"task_id":"T1","tier":2,"gates":["G0","G1","G2"]}}
```

**Rules:**
- Append only. Never edit past entries.
- One file per session day. Past sessions archived to `.zeus/journal/archive/`.
- On crash: Zeus replays journal from `seq:1` to reconstruct world state.
- Every action (dispatch, done, gate pass/fail, override, kill) is a journal entry. Nothing happens unrecorded.

---

### 2. Derived State Store (Single Source of Truth)

**Path:** `.zeus/state.json`

```json
{
  "session": {
    "id": "uuid",
    "started": "ISO8601",
    "root_task": "text",
    "classification": "L0 | L1 | L2 | L3 | L4",
    "status": "ACTIVE | BLOCKED | DONE | KILLED"
  },
  "tasks": [
    {
      "id": "T1",
      "description": "text",
      "owner": "architect-agent",
      "status": "PENDING | IN_PROGRESS | GATING | PASSED | FAILED | BLOCKED",
      "depends_on": [],
      "contract": {
        "input": "what this task receives",
        "output": "what this task must produce",
        "definition_of_done": "measurable, binary criteria",
        "validation": "exact command to verify"
      },
      "gate_results": []
    }
  ],
  "locks": {
    "src/main/java/.../UserService.java": "backend-agent",
    "auth/": "backend-agent"
  },
  "dag_version": 1
}
```

**Critical design rule:** Agent status, progress percentage, critical path, and estimated time are **derived** at read-time from tasks + journal. Never store computed values. Storing them creates drift and corruption bugs.

---

### 3. Synchronous File Locking

Turn-based execution means no two agents write simultaneously. Locks exist solely to prevent Zeus from assigning overlapping files to different agents in successive batch dispatches.

**Lock types:**

| Type | Example | When to use |
|---|---|---|
| File lock | `UserService.java: "backend-agent"` | Single file owned by one agent |
| Module lock | `auth/: "backend-agent"` | Related files under one directory |

**Lifecycle:** Acquired by Zeus before dispatch. Released by Zeus on `AGENT.DONE` or `SESSION.KILL`. No TTL required.

---

## Part II — Precision Planning: Contracts & the DAG

### 1. Execution Contracts (Highest-Impact Quality Driver)

> *An agent cannot drift if its output is contractually defined.*

Every task dispatched by Zeus **must** include a contract. No exceptions.

```json
{
  "task_id": "T2",
  "agent": "backend-agent",
  "contract": {
    "input": "UserRegistrationDTO with fields: email (String), password (String), name (String)",
    "output": "UserService.java containing register(UserRegistrationDTO) and findByEmail(String); UserEntity.java with JPA annotations",
    "definition_of_done": "Compiles clean. Test coverage ≥ 85%. No hardcoded strings. No secrets in source.",
    "validation": "mvn compile && mvn test -pl user-module"
  }
}
```

**Good vs. Bad contract examples:**

| Bad (Vague) | Good (Contractual) |
|---|---|
| "Build the user service" | "Produce `UserService.java` with `register()` and `findByEmail()` methods; JPA entity with `@Table(name=\"users\")`" |
| "Make sure it's secure" | "No hardcoded secrets. `git secrets --scan` exits 0. CSRF token present in all Thymeleaf forms." |
| "Write tests" | "JaCoCo XML coverage ≥ 85% on `user-module`. All public methods have at least one unit test." |
| "Follow best practices" | "No `System.out.println`. `@Slf4j` for logging. All exceptions logged with context." |

A brief that cannot be contracted is not ready. Stop and clarify before dispatching.

---

### 2. Brief Validation Gate (Tier 0 — Pre-Execution)

Before Zeus builds a DAG or dispatches any agent, it validates the brief:

```
BRIEF VALIDATION (Zeus runs before any delegation):

  1. Is the output definition specific and measurable?
     → "Build the user module" FAILS. "Produce UserService.java with register() and findByEmail()" PASSES.

  2. Are all constraints listed and testable?
     → "Make it secure" FAILS. "git secrets --scan exits 0" PASSES.

  3. Is task scope bounded?
     → "Fix the entire auth system" FAILS. "Fix the JWT expiry bug in JwtTokenFilter.java" PASSES.

  4. Can a contract be written for every subtask?
     → If no: probe via Architect Agent or Requirements Analyst Agent.

  5. Are there hidden dependencies not stated?
     → If uncertain: run Architect Agent first before DAG construction.

RESULT:
  PASS  → proceed to DAG construction
  FAIL  → return to human with specific, numbered questions (not vague feedback)
```

---

### 3. DAG Classification & Construction

**Task levels:**

| Level | Name | DAG Behavior | Solo Mode |
|---|---|---|---|
| **L0** | Trivial | No DAG. Zeus executes inline. | Always |
| **L1** | Standard — Single Thread | Sequential DAG, one agent at a time | Always |
| **L2** | Standard — Parallel Safe | Batch dispatch independent branches | Yes (max 2 agents/turn) |
| **L3** | Complex — Cross-Domain | Multi-domain DAG; Architect Agent runs first | Yes (confirm cost with human) |
| **L4** | Complex — Unknown Deps | Iterative DAG: probe → discover → expand | Human approval required |

**DAG storage:** `.zeus/dag.json`

```json
{
  "version": 3,
  "confidence": 0.92,
  "nodes": [
    {"id": "T1", "agent": "architect", "status": "DONE", "duration_est": "8m"},
    {"id": "T2", "agent": "backend", "status": "PENDING", "depends_on": ["T1"]},
    {"id": "T3", "agent": "frontend", "status": "PENDING", "depends_on": ["T1"]},
    {"id": "T4", "agent": "qa", "status": "PENDING", "depends_on": ["T2", "T3"]}
  ],
  "edges": [["T1","T2"], ["T1","T3"], ["T2","T4"], ["T3","T4"]],
  "critical_path": ["T1", "T2", "T4"],
  "estimated_wall_clock": "34m"
}
```

**Probabilistic Planning Rule:** For L3/L4 tasks, the Architect Agent outputs the DAG with a `confidence` score.
- Confidence ≥ 0.80 → proceed with batch dispatch
- Confidence < 0.80 → halt; present DAG to human for review before any dispatch

**Rule:** DAG is rebuilt once per orchestration cycle. If task structure changes mid-execution, DAG version increments. No dynamic mid-execution evolution.

Zeus reports to the human before starting:
> *"6 nodes. 2 can run in parallel (T2 + T3). Critical path: T1 → T2 → T4. Estimated wall-clock: 34 minutes. DAG confidence: 92%."*

---

### 4. DAG Failure Taxonomy

| Failure Type | What Happened | Response |
|---|---|---|
| **Dependency misclassification** | Two "independent" tasks share a resource | Detect via lock conflict → pause conflicting branch → re-plan DAG |
| **Scope explosion** | L1 task turns out to be L3 during execution | Agent reports scope change → Zeus re-classifies → rebuild DAG |
| **Circular dependency** | Hidden dependency creates a cycle | DAG validator rejects → escalate to human with cycle description |
| **Estimation miss > 2x** | Task takes far longer than estimated | Zeus flags after 2x estimated time → human decides: continue or split |

---

## Part III — Execution Reality: Batch Dispatch

### 1. The Turn Loop

```
TURN 1 — PLAN:
  Zeus validates brief → Tier 0 gate → builds DAG
  Identifies all nodes with in_degree == 0 (ready to dispatch)
  Reports critical path + wall-clock estimate to human

TURN 2 — DISPATCH BATCH:
  Zeus dispatches all ready nodes sequentially in one orchestration cycle
  Each agent: receives [ROLE] + [CONTRACT] + [CONTEXT PACKAGE] → executes
  Each agent: writes output files + progress snapshot to .zeus/progress/{task_id}.json

TURN 3 — CONVERGE:
  Zeus reads all progress snapshots
  Runs Tier 2 gates on each output
  Updates state.json + appends to journal
  Newly unblocked nodes queued for next dispatch

TURN N — REPEAT until DAG exhausted

FINAL — CLOSE:
  All leaf nodes PASSED → Tier 3 gate (Zeus sign-off)
  Session report auto-generated → .zeus/session-reports/YYYYMMDD-UUID.md
```

**Speed gain:** Dispatching ALL ready nodes per turn gives ~2-3x throughput vs. one-at-a-time sequential delegation.

---

### 2. Progress Snapshots (replaces Heartbeats)

Each agent writes on completion:

**Path:** `.zeus/progress/{task_id}.json`

```json
{
  "task_id": "T2",
  "agent": "backend-agent",
  "progress_pct": 100,
  "current_step": "UserService.java written; tests passing",
  "artifacts": ["src/main/java/.../UserService.java", "src/test/java/.../UserServiceTest.java"],
  "gate_self_check": "PASS",
  "notes": "Flagged: UserMapper.java is a utility class → QA Agent needs mock strategy",
  "updated_at": "ISO8601"
}
```

Zeus reads snapshots at the start of each turn. No fake streaming. No polling.

---

### 3. Dynamic Agent Briefs (Context Window Protection)

Static briefs bloat context. At dispatch time, Zeus assembles a brief dynamically:

```
AGENT BRIEF = [STATIC ROLE]            → from .cursor/agents/{agent-name}.md
            + [TASK CONTRACT]           → input / output / DoD / validation
            + [TAG-FILTERED LESSONS]    → only lessons matching task's domain tags
            + [ACTIVE LOCKS]            → what files this agent owns
            + [RELATED SNAPSHOTS]       → progress of agents this task depends on
            + [RELEVANT ADRs]           → decisions that affect this task's domain
```

**Token budget respected:** Never inject the full `lessons.md`. Always query the retrieval index first (see Part V).

---

### 4. Solo Mode Resource Controls

| Resource | Solo Mode (L0-L1) | Full Mode (L2+) |
|---|---|---|
| Max agents per turn | 2 | 5 |
| Prefer cheapest agent first | Yes | No |
| Token budget per session | Tracked + reported | Tracked + reported |
| Cost-aware scheduling | Defer non-critical agents | All agents dispatch |
| Human cost confirmation | Not required | Required for L3+ |

---

### 5. Kill Switch — Atomic Abort

When `.kill-switch` file is created or `SESSION.KILL` is journaled:

1. Zeus stops dispatching new tasks.
2. Running agent finishes its atomic file-write (no corrupted half-files).
3. Zeus writes `SESSION.KILLED` to journal: what completed, what didn't, artifact paths.
4. All locks released.
5. State store updated with full abort record.

**Human sees:**
> *"Session killed at 14:23. Backend: 100% done (UserService.java committed). Frontend: 0%, no artifacts written. QA: not started."*

---

## Part IV — Quality Gates: Tiered, Automated, Contract-Verified

### Tier Summary

```
TIER 0 — Pre-Execution (Brief Validation Gate)
  → Zeus validates brief + contract BEFORE dispatching anything
  → "Is this task well-defined enough to succeed?"
  → FAIL → return to human with specific questions

TIER 1 — Inline (Agent Self-Check, during execution)
  → Agent checks while writing: does this compile? hardcoded strings?
  → No Zeus involvement. Self-enforced per contract.

TIER 2 — Handoff (before returning to Zeus)
  → Agent validates output against contract's definition_of_done
  → Automated gate runners execute (see table below)
  → Result: PASS / FAIL / ESCALATE

TIER 3 — Closure (Zeus final sign-off)
  → All Tier 2 gates PASSED → Zeus approves → journal entry
  → Any ESCALATE → human review required before session closes
```

### Automated Gate Runners

| Gate | ID | Automated? | Method |
|---|---|---|---|
| Contract exists | G0 | YES | `state.json` has contract for this task |
| Code compiles | G1 | YES | `mvn compile` exit code 0 |
| Javadoc on public methods | G2 | YES | AST parse |
| Test coverage ≥ 85% | G3 | YES | JaCoCo XML report |
| No hardcoded values | G4 | YES | Regex scan |
| CSRF tokens present | G5 | YES | Thymeleaf template parser |
| Role-based access on routes | G6 | PARTIAL | Route scan; manual for complex rules |
| No secrets in source | G7 | YES | `git secrets --scan` |
| Image alt text present | G8 | YES | HTML parser on `<img>` tags |

**Gate logs:** `.zeus/gates/session-YYYYMMDD.jsonl` — every gate execution logged for Self-Improvement Agent.

---

### Rework Decision Tree

```
IF error_fix_time < 2 minutes:
    → Auto-fix in same cycle.
    → Does NOT count against rework budget.
    → Log as incremental fix, not rework event.

ELSE IF approach is structurally wrong (wrong pattern, wrong logic):
    → 1 rework cycle with specific, written feedback attached to contract.
    → If no improvement after 1 cycle → escalate to human immediately.
    → Do NOT give a second rework cycle. It won't help.

ELSE IF security or critical finding (G7, auth bypass, data exposure):
    → Escalate NOW. Zero rework cycles. Non-negotiable.
    → Write ADR with finding before any other work continues.
```

---

## Part V — Memory System: Store, Index, Retrieve

### Three-Layer Architecture

```
LAYER 1 — Ephemeral (current session only)
  → Journal + State Store + Progress snapshots
  → Archived to .zeus/journal/archive/ at session end

LAYER 2 — Project Knowledge (survives sessions)
  → .zeus/memory/
  → lessons.md       (tagged, searchable by index)
  → decisions/       (ADR-style, one file per decision)
  → patterns/        (proven reusable playbooks)
  → agent-effectiveness/{agent-id}.json

LAYER 3 — Cross-Project (personal assistant level)
  → ~/.cursor-kit/memory/
  → Global patterns promoted from Layer 2 monthly
  → Updated by Self-Improvement Agent
```

---

### Memory Retrieval Index

Storage without retrieval is dead weight.

**Path:** `.zeus/memory/index.json`

```json
{
  "coverage_failures":      ["lesson-12", "lesson-27"],
  "auth_patterns":          ["pattern-3"],
  "security_findings":      ["lesson-5", "lesson-19"],
  "utility_class_testing":  ["lesson-12"],
  "spring_boot":            ["lesson-7", "lesson-14", "pattern-1"],
  "thymeleaf":              ["lesson-9", "lesson-22"]
}
```

**At dispatch time:** Zeus queries index for tags matching the current task domain. Injects only matched lessons. A 500-line `lessons.md` becomes a 5-line filtered result set.

---

### Lesson Format

```markdown
---
id: lesson-12
tags: [quality-gate, qa-agent, coverage, backend, utility-class]
date: 2026-04-29
severity: medium
---

**What happened:** QA Agent consistently fails G3 (85% coverage) when Backend produces utility classes.
**Root cause:** Utility classes require mocking strategies that QA Agent doesn't plan for unless told explicitly.
**Prevention:** Backend Agent must flag utility classes in progress snapshot `notes` field before QA dispatch.
**Fixed in:** Session 2026-04-29, ADR-007.
```

---

### Self-Improvement Agent — Concrete Mandate

Run monthly. Output requires human approval before applying changes.

```
MONTHLY RUNBOOK:

1. METRICS ANALYSIS
   Parse .zeus/memory/agent-effectiveness/*.json
   Flag agents where any of these thresholds are breached:
     → Gate failure rate       > 20% over last 10 sessions
     → Rework cycle rate       > 30% of dispatched tasks
     → Escalation rate         > 15% of dispatched tasks
     → Token burn (vs. median) > 2x median for same task classification

2. ROOT CAUSE INVESTIGATION (for each flagged agent)
   → Is the brief template too vague? (most common)
   → Is the gate criteria unclear or too strict?
   → Is the agent lacking a critical lesson?
   → Is the task classification wrong (L1 dispatched as L0)?
   → Write findings as ADR proposal.

3. LESSON CONSOLIDATION
   → Find duplicate or contradicting lessons in lessons.md
   → Merge duplicates. Flag contradictions for human resolution.
   → Promote top 3 patterns from completed sessions to patterns/

4. COST REPORT
   → Token spend per agent per session (last 30 days)
   → Flag any agent burning > 2x its class median consistently
   → Propose: dispatch fewer times, or simplify brief

5. PRESENT TO HUMAN
   → Summary: flagged agents, proposed brief updates, ADR drafts
   → Human approves or rejects each change before applying
   → Nothing is auto-applied to agent briefs
```

**Agent Effectiveness Schema:** `.zeus/memory/agent-effectiveness/{agent-id}.json`

```json
{
  "agent_id": "backend-agent",
  "sessions_tracked": 24,
  "gate_failure_rate": 0.12,
  "rework_cycle_rate": 0.21,
  "escalation_rate": 0.04,
  "avg_token_burn_l1": 1840,
  "avg_token_burn_l2": 4210,
  "last_updated": "ISO8601"
}
```

---

## Part VI — Agent Brief Templates (NEW)

This is where actual output quality lives. Each agent has a static role file at `.cursor/agents/{agent}.md`. Below are the templates.

> **Rule:** The static role is the minimum. Zeus always appends the dynamic context package (contract + lessons + locks) at dispatch time.

---

### Zeus (Orchestrator)

```
You are Zeus, the orchestration agent for this project. You do not write code.

YOUR ONLY JOB:
1. Validate briefs (Tier 0 gate).
2. Build and maintain the DAG.
3. Dispatch agents with complete contracts.
4. Read progress snapshots and run Tier 2/3 gates.
5. Update state.json and append to the journal after every action.
6. Escalate to the human when criteria are met (see escalation tree).

RULES:
- Never dispatch a task without a complete contract (input/output/DoD/validation).
- Never store computed state. Derive it at read time.
- A brief that cannot be contracted is not ready. Return it to the human with specific questions.
- You are the system's immune system. Quality gates are not bureaucracy — they are your core function.
- Batch dispatch all ready nodes per turn. Never dispatch one-at-a-time when independent nodes exist.
```

---

### Architect Agent

```
You are the Architect Agent. You design systems. You do not write production code.

YOUR OUTPUT for any task is one or more of:
- A DAG of subtasks with dependency edges and confidence score.
- Interface definitions (Java interfaces, DTOs, contracts between components).
- Decision records (ADRs) for any non-obvious design choice.
- A list of hidden dependencies or integration risks.

RULES:
- Always produce a confidence score with your DAG (0.0–1.0). If confidence < 0.80, say why.
- Flag scope explosion immediately. Do not silently expand scope.
- Design for the constraint: this is a solo developer on nonprofit Azure credits.
- Your interfaces are contracts. Be specific about method signatures, not descriptions.
- If two valid approaches exist, present both with tradeoffs. Do not pick silently.
```

---

### Backend Agent

```
You are the Backend Agent. You write production-grade Spring Boot / Java code.

STANDARDS (non-negotiable):
- @Slf4j for all logging. No System.out.println.
- All public methods have Javadoc.
- No hardcoded strings. Use @Value or constants.
- No secrets in source. No API keys, no passwords.
- Exception handling: log with context, never swallow.
- Utility classes must be flagged in your progress snapshot notes field.

YOUR OUTPUT:
- Java source files at the paths specified in your contract.
- A progress snapshot at .zeus/progress/{task_id}.json.
- Tier 1 self-check result in the snapshot (compiled? obvious issues?).

RULES:
- Read your contract's input/output/DoD before writing a single line.
- If the contract is ambiguous, write a clarification question in your snapshot and stop. Do not guess.
- Write tests in the same task unless the contract explicitly defers testing to QA Agent.
```

---

### Frontend Agent

```
You are the Frontend Agent. You write Thymeleaf templates and frontend logic.

STANDARDS (non-negotiable):
- All forms must include Thymeleaf CSRF token: th:action + _csrf hidden field.
- All <img> tags must have descriptive alt text.
- No inline JavaScript. Use external JS files or th:onclick sparingly.
- Accessibility: labels for all inputs, ARIA roles where semantic HTML is insufficient.
- No hardcoded URLs. Use @{} Thymeleaf URL expressions.

YOUR OUTPUT:
- Thymeleaf HTML files at the paths specified in your contract.
- A progress snapshot at .zeus/progress/{task_id}.json.
```

---

### QA Agent

```
You are the QA Agent. You write tests and validate coverage.

STANDARDS (non-negotiable):
- JUnit 5 + Mockito for unit tests.
- Coverage target: ≥ 85% on the module specified in your contract.
- If Backend Agent flagged utility classes in their snapshot notes: plan mock strategy before writing tests.
- Integration tests use @SpringBootTest only when unit tests are insufficient.
- Test method naming: should_{expectedBehavior}_when_{condition}

YOUR OUTPUT:
- Test source files at the paths specified in your contract.
- JaCoCo report (mvn test -pl {module} produces it automatically).
- A progress snapshot at .zeus/progress/{task_id}.json with coverage %.

RULES:
- Read the Backend Agent's progress snapshot before starting. Check the notes field for flags.
- If coverage cannot reach 85% without testing private methods, escalate. Do not test private methods.
```

---

### Security Agent

```
You are the Security Agent. You audit code for security vulnerabilities.

YOUR SCOPE per task (read your contract):
- Secret scanning: git secrets --scan on specified paths.
- CSRF audit: all POST/PUT/DELETE endpoints must have CSRF protection.
- Auth audit: all routes must have explicit role-based access (@PreAuthorize or SecurityConfig).
- Input validation: all controller method params must have @Valid or explicit validation.
- Dependency audit: flag any dependency with known CVEs.

OUTPUT:
- A findings report at .zeus/progress/{task_id}.json with severity (CRITICAL / HIGH / MEDIUM / INFO).
- CRITICAL or HIGH findings: write ADR immediately. Block session close until resolved.
- MEDIUM / INFO: log as lessons. Do not block.

RULES:
- A security finding is never a rework item. It is an escalation item.
- Do not suggest "workarounds" for security findings. Fix them or escalate.
```

---

### DevOps Agent

```
You are the DevOps Agent. You handle Azure deployment, Docker, nginx, and CI/CD configuration.

CONTEXT: This project deploys to Azure App Service using nonprofit credits. Cost efficiency is a hard constraint.

STANDARDS:
- Docker: non-root user, no secrets baked into image, minimal base image (eclipse-temurin:21-jre-alpine).
- Azure: use environment variables from App Service config, never from Dockerfile.
- nginx: TLS termination at proxy level. No HTTP in production.
- .gitattributes: LF line endings for shell scripts, CRLF for Windows-only files.

OUTPUT:
- Configuration files at paths specified in your contract.
- A progress snapshot at .zeus/progress/{task_id}.json.
- Flag any configuration that increases Azure cost with an explicit note.
```

---

## Part VII — Inter-Agent Handoff Schema (NEW)

When Agent A's output feeds Agent B, the handoff must be explicit and structured. Ambiguous handoffs are the most common cause of silent drift.

### Standard Handoff Format

Agent A writes to its progress snapshot `artifacts` field. Agent B's contract `input` field must reference those exact artifacts.

**Example: Backend → QA handoff**

Backend Agent progress snapshot:
```json
{
  "task_id": "T2",
  "agent": "backend-agent",
  "artifacts": [
    "src/main/java/com/temple/user/service/UserService.java",
    "src/main/java/com/temple/user/entity/UserEntity.java"
  ],
  "notes": "UserMapper.java is a utility class — QA needs mock strategy for it.",
  "gate_self_check": "PASS"
}
```

QA Agent contract (Zeus assembles this before dispatch):
```json
{
  "task_id": "T3",
  "agent": "qa-agent",
  "contract": {
    "input": "Artifacts from T2: UserService.java, UserEntity.java. Note: UserMapper.java is a utility class requiring mock strategy.",
    "output": "UserServiceTest.java with ≥ 85% coverage on user-module",
    "definition_of_done": "mvn test -pl user-module exits 0. JaCoCo coverage ≥ 85%.",
    "validation": "mvn test -pl user-module"
  }
}
```

---

### Handoff Rules

| Rule | Detail |
|---|---|
| **Artifacts are paths, not descriptions** | Never say "the user service file." Say `src/main/java/.../UserService.java`. |
| **Notes field is mandatory when flagging** | If Backend flags utility classes, QA must receive that flag in its contract input. Zeus is responsible for this propagation. |
| **Gate results travel forward** | If T2 passed G3 at 87% coverage, that result is visible in T3's context. QA Agent does not re-run coverage from scratch. |
| **No implicit contracts** | Zeus does not assume Agent B knows what Agent A produced. Every handoff is explicit in the contract. |
| **Conflict on artifact version** | If two agents produce the same file, Zeus detects via lock table. One agent must be serialized after the other. Never merge silently. |

---

## Part VIII — Escalation Decision Tree (NEW)

> *"Escalate to human" appears 8+ times in this document. Here is exactly what that means each time.*

### Escalation Protocol

When Zeus decides to escalate:

```
1. STOP all new dispatches immediately.
2. WRITE escalation to journal:
   {"type": "ESCALATION.TRIGGERED", "reason": "...", "blocked_tasks": [...]}
3. WRITE a clear, specific message to the human (not "something went wrong"):
   → What exactly happened (which task, which gate, which file)
   → What Zeus tried
   → What the human must decide (binary choice where possible)
   → What resumes after human responds
4. UPDATE state.json: session.status = "BLOCKED"
5. WAIT. Do not attempt to self-resolve. Do not retry silently.
```

---

### Escalation Trigger Table

| Trigger | Condition | Human Decision Required |
|---|---|---|
| **Brief fails Tier 0** | Brief cannot be contracted | Clarify scope / rewrite brief |
| **DAG confidence < 0.80** | L3/L4 task, architect uncertain | Approve or restructure DAG |
| **Circular dependency** | DAG validator finds a cycle | Break the cycle (which dependency is wrong?) |
| **Scope explosion** | Agent reports task is 2+ levels higher than classified | Split task or extend budget |
| **Estimation miss > 2x** | Task running at 2x estimated duration | Continue or split task |
| **Structural rework failed** | Agent failed same structural error twice | Provide explicit guidance or rewrite contract |
| **Security / Critical finding** | Security Agent flags CRITICAL or HIGH | Fix now or accept risk (documented in ADR) |
| **Circuit breaker OPEN × 3** | Same agent opened circuit 3 times in session | Restart agent / rewrite brief |
| **Lock conflict detected** | Two tasks conflict on same file unexpectedly | Re-sequence DAG manually |
| **Override contradicts contract** | Human override conflicts with existing task contract | Zeus presents conflict, human resolves |

---

### Human Override Protocol

Human writes to `.zeus/overrides/{task_id}.json`:

```json
{
  "action": "REDIRECT | CANCEL | INJECT_DEPENDENCY | FORCE_PASS | RESEQUENCE",
  "details": "Use interface instead of abstract class for UserRepository",
  "written_at": "ISO8601"
}
```

Zeus reads overrides at the **start of each turn** (highest priority). Override is treated as a journal event. State store updated atomically. Override logged to `decisions/` as ADR — human decisions are decisions too.

**Override action meanings:**

| Action | What Zeus does |
|---|---|
| `REDIRECT` | Update task contract with new direction; re-dispatch agent |
| `CANCEL` | Kill specific task; release its locks; unblock dependents if possible |
| `INJECT_DEPENDENCY` | Add new dependency to DAG; rebuild from current state |
| `FORCE_PASS` | Mark gate as manually approved; log reason in ADR |
| `RESEQUENCE` | Rebuild DAG with human-specified ordering |

---

## Part IX — On-the-Fly Tool Protocol

```
STEP 1: IDENTIFY
  Gap named precisely → entry in state.json pending-tools

STEP 2: SPEC
  Full spec written to .zeus/pending/{tool-name}/SPEC.md
  Must include: purpose, inputs, outputs, security surface

STEP 3: BUILD
  Builder Agent creates tool

STEP 4: GATE
  Automated quality gates applied (G0, G1, G4, G7 minimum)

STEP 5: REVIEW
  Security Agent scans — same session, not 24-hour window
  → PASS → promote to production registry immediately
  → FAIL → return to Builder with specific findings

STEP 6: LOG
  ADR written to .zeus/memory/decisions/
  Tool registered in .zeus/tools/registry.json
```

---

## Part X — Safety Systems

### Circuit Breaker

```
CLOSED (normal)
  → failure occurs → increment failure counter
  → counter > threshold (3 failures) → OPEN

OPEN
  → Zeus stops dispatching to this agent
  → Alert human with: which agent, what failed, how many times
  → After cooldown (next turn) → PROBE

PROBE
  → Allow one dispatch with simplified task
  → Success → CLOSE (reset counter)
  → Failure → OPEN (double cooldown)

ESCALATED
  → After 3 OPEN cycles with no recovery
  → status: REQUIRES_HUMAN_APPROVAL
  → No further auto-retry. Human must inspect agent brief.
```

---

### Simulation Mode (L3/L4 tasks)

```
SIMULATE:
  Zeus builds DAG
  → Walks it with mock agents (no real execution, no file writes)
  → Surfaces: resource conflicts, lock contention, unclear contracts, DAG confidence score
  → Zeus writes simulation report to .zeus/session-reports/simulate-{UUID}.md
  → Human reviews: approve as-is / restructure / add constraints
  → Only after human approval does real dispatch begin
```

---

## Part XI — File Structure

```
.zeus/                                     # Machine layer
├── state.json                             # Single source of truth
├── dag.json                               # Current DAG (versioned)
├── journal/
│   ├── session-YYYYMMDD.jsonl             # Append-only event journal
│   └── archive/                           # Past sessions, compressed
├── progress/
│   └── {task_id}.json                     # Per-task agent snapshots
├── overrides/
│   └── {task_id}.json                     # Human mid-session overrides
├── pending/                               # Beta tools awaiting review
│   └── {tool-name}/
│       ├── SPEC.md
│       └── audit-record.json
├── tools/
│   └── registry.json                      # Approved tool registry
├── memory/
│   ├── lessons.md                         # Tagged, searchable
│   ├── index.json                         # Retrieval index
│   ├── decisions/
│   │   ├── index.md
│   │   └── adr-001.md ...
│   ├── patterns/
│   │   └── auth-flow.md
│   └── agent-effectiveness/
│       └── {agent-id}.json
├── gates/
│   └── session-YYYYMMDD.jsonl             # Gate execution logs
└── session-reports/
    ├── YYYYMMDD-UUID.md                   # End-of-session summaries
    └── simulate-UUID.md                   # Simulation mode reports

.cursor/                                   # Configuration layer (unchanged)
├── rules/
└── agents/
    ├── zeus.md
    ├── architect.md
    ├── backend.md
    ├── frontend.md
    ├── qa.md
    ├── security.md
    └── devops.md

tasks/                                     # Human interface layer
├── todo.md
├── lessons.md      → symlink to .zeus/memory/lessons.md
└── decisions.md    → symlink to .zeus/memory/decisions/
```

**Separation principle:** `.zeus/` is the machine. `.cursor/` is the configuration. `tasks/` is the human interface.

---

## Part XII — Implementation Roadmap

> **Critical gate:** Phase 2 cannot begin until Phase 1 runs flawlessly in production for one full week. A corrupted State Store will destroy batch execution. Do not rush this gate.

### Phase 1 — The Nerve Center (Weeks 1–2)
**Goal:** Journal + State Store + Contracts. No change to agent behavior yet.

- [ ] Implement `.zeus/journal/` as append-only JSONL
- [ ] Implement `.zeus/state.json` as authoritative state with contract schema
- [ ] Define execution contract schema; add to Zeus dispatch prompt
- [ ] Add Tier 0 brief validation gate to Zeus
- [ ] Write agent brief templates to `.cursor/agents/` (Part VI above)
- [ ] Zeus still operates hub-and-spoke; state store is read-only context for now

**Value delivered:** Crash recovery. Task contracts. Immediate quality improvement. No infrastructure risk.

---

### Phase 2 — The Engine (Weeks 3–4)
**Goal:** DAG-based planning + batch dispatch.

- [ ] Implement DAG builder in Zeus (brief → nodes + edges + confidence score)
- [ ] Implement batch dispatch (all ready nodes per turn)
- [ ] Implement progress snapshot writing by agents
- [ ] Implement synchronous lock management in state.json
- [ ] Implement DAG failure taxonomy handlers
- [ ] Implement inter-agent handoff schema (Part VII) in Zeus contract assembly

**Value delivered:** Complex tasks run faster. Planning failures handled explicitly. Handoffs are traceable.

---

### Phase 3 — Quality Automation (Weeks 5–6)
**Goal:** Automated gate runners + tiered rework.

- [ ] Implement automated gate runners (G0–G8, see Part IV)
- [ ] Implement Tier 1 inline self-check in agent brief templates
- [ ] Implement rework decision tree in Zeus
- [ ] Gate logs written to `.zeus/gates/`
- [ ] Implement escalation decision tree (Part VIII) in Zeus

**Value delivered:** Rework cycles cut ~60%. Defects caught at creation. Escalation is now deterministic.

---

### Phase 4 — Intelligence (Weeks 7–8)
**Goal:** Three-layer memory with retrieval. Dynamic context injection.

- [ ] Restructure `.zeus/memory/` with tagging + lesson format (Part V)
- [ ] Implement retrieval index (`index.json`) + tag-filtered lesson injection
- [ ] Implement agent-effectiveness tracking (`.json` schema in Part V)
- [ ] Implement dynamic agent brief assembly (static role + contract + filtered lessons)
- [ ] Human override protocol (`.zeus/overrides/`)

**Value delivered:** System remembers. Sessions get progressively smarter. Briefs are lean.

---

### Phase 5 — Polish & Observability (Weeks 9–10)
**Goal:** Self-improvement + cost visibility + simulation mode.

- [ ] Self-Improvement Agent monthly runbook (concrete thresholds from Part V)
- [ ] Session report auto-generator
- [ ] Simulation mode for L3/L4 tasks
- [ ] Cost/token tracking per agent per session
- [ ] Tool registry + same-session security review (Part IX)

**Value delivered:** Full safety net. Complete visibility. Cost awareness. System improves itself.

---

## Appendix A — The 14 Architectural Principles (The Constitution)

| # | Principle |
|---|---|
| 1 | **Each turn reconstructs the world from files.** No assumed persistent state. |
| 2 | **Every action is a journal entry.** Nothing happens unrecorded. |
| 3 | **Contracts before code.** No agent starts without input / output / DoD / validation. |
| 4 | **Derive, don't store.** Computed state is never persisted — only ground truth. |
| 5 | **Locks prevent conflicts.** No agent writes to a resource it doesn't own. |
| 6 | **Automation first.** If a gate can be automated, it must be. |
| 7 | **Escalation is not failure.** It is the system working correctly. |
| 8 | **Critical is critical.** No time pressure overrides a security finding. |
| 9 | **Lessons not written are lessons not learned.** Write before close, not after. |
| 10 | **The system observes itself.** Self-Improvement Agent is not optional. |
| 11 | **Batch dispatch is the default** for dependency-free branches. |
| 12 | **A brief that cannot be contracted is not ready.** Stop and clarify. |
| 13 | **Solo mode is not lesser mode.** Cost-aware scheduling is intelligent scheduling. |
| 14 | **Human overrides are first-class events.** Not hacks — logged decisions. |

---

## Appendix B — Before vs. After

| Dimension | Zeus v1 (Before) | cursor-kit v2.0 (After) |
|---|---|---|
| State | In Zeus memory (volatile) | `state.json` (persistent, derived) |
| Communication | Hub-and-spoke via Zeus | Event Journal (append-only, replayable) |
| Parallelism | Sequential one-at-a-time | Batch dispatch per turn |
| Task definition | Informal brief | Execution contracts with DoD |
| Brief validation | None | Tier 0 pre-execution gate |
| Agent briefs | Static files | Dynamic: role + contract + filtered lessons |
| Agent templates | None | Full templates per agent type (Part VI) |
| Handoff schema | Implicit / assumed | Explicit artifact paths + notes propagation |
| Escalation | "Escalate to human" (undefined) | Deterministic decision tree with 10 triggers |
| Feedback loops | None between agents | Progress snapshots + shared state |
| Rework cycles | 2 flat cycles | Tiered: auto-fix / structural / critical |
| Kill switch | Process-level, partial artifacts | Atomic abort + full record |
| Memory | Session-local only | 3-layer + retrieval index |
| Memory retrieval | Read entire lessons.md | Tag-filtered indexed lookup |
| Session recovery | None (crash = restart) | Journal replay |
| Observability | Human must ask | Session reports auto-generated |
| Self-improvement | Vague monthly review | Data-driven, threshold-triggered, human-approved |
| Gates | Manual, post-execution | Automated G0–G8, pre/inline/post, tiered |
| Human override | Undefined | Explicit protocol, atomic, logged as ADR |
| Cost awareness | None | Token tracking, solo-mode budgets |
| DAG failures | Not handled | Taxonomy with 4 failure types + responses |
| Tool creation | No review | Same-session security scan + ADR |
| Simulation mode | None | L3/L4 dry-run before real dispatch |

---

## Appendix C — Context Window Budget Table (NEW)

> **Rule:** Never saturate an agent's context window. Inject the minimum required for the task.

| Agent | Task Level | Estimated Token Budget | Notes |
|---|---|---|---|
| Zeus | L0–L1 | 800–1,200 | State + brief only |
| Zeus | L2–L4 | 2,000–3,500 | State + DAG + filtered lessons |
| Architect | L2–L3 | 2,500–4,000 | Full system context needed |
| Backend | L1 | 1,500–2,000 | Role + contract + 3–5 lessons |
| Backend | L2–L3 | 2,500–4,000 | + ADRs + related snapshots |
| Frontend | L1 | 1,200–1,800 | Role + contract + CSRF/accessibility lessons |
| QA | L1–L2 | 1,800–2,800 | Role + contract + backend snapshot + coverage lessons |
| Security | Any | 1,500–2,500 | Role + contract + security lessons only |
| DevOps | Any | 1,500–2,500 | Role + contract + infrastructure lessons only |
| Self-Improvement | Monthly | 4,000–6,000 | All effectiveness metrics + last 30 session reports |

**Enforcement:** Zeus checks estimated brief size before dispatch. If estimated tokens exceed 1.5x budget for that agent + level, trim lessons (keep only top 3 by recency + relevance score).

---

*This document is complete. Every component maps to a phase. Every phase delivers value before the next begins. Start with Phase 1. Do not design Phase 5 infrastructure before Phase 1 is running in production.*
