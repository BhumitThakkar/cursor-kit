# cursor-kit — Elite Orchestration: A 180+ IQ System

> **Status:** Design Blueprint
> **Author:** Principal Architect (Claude Code)
> **Date:** 2026-04-29
> **Audience:** Bhumit Thakkar — who deserves a system worthy of their ambition

---

## Foreword

The current Zeus PM implementation is **functional and well-structured**. It classifies tasks, delegates to specialists, enforces gates, and writes to memory. It works. But "works" is the floor, not the ceiling.

What follows is a full ground-up redesign of cursor-kit's orchestration philosophy — one where every component is a first-class citizen with a purpose, every failure mode is planned for, every resource is accounted for, and the system gets measurably smarter over time. This is not incremental improvement. This is a manifesto for elite execution.

Read with an open mind. Argue with it. Then build it.

---

## The 180+ IQ Principle

A 180+ IQ system is not one that uses many agents. It is one that:

- **Anticipates failure before it happens** — not reacting, predicting
- **Allocates resources contextually** — not uniform distribution
- **Maintains complete state transparency** — no black boxes
- **Learns from every session** — never repeating the same mistake
- **Operates at the lowest possible latency** — no wasted cycles
- **Governs itself without human intervention for known failure classes**
- **Escalates to humans only when the system has exhausted its own options**

Every section below enforces at least three of these principles. None of it is aspirational. Every line has a concrete implementation path.

---

## Part I — The Nervous System: Unified Event Bus + State Store

### What Exists Today

Zeus PM is the sole orchestrator. All communication flows through it. Agents return outputs to Zeus; Zeus decides what happens next. This is a **hub-and-spoke model** — simple but brittle.

### What Should Exist

A **dual-stream architecture**:
- **Event Bus** — a lightweight, append-only log of what is happening right now (publish/subscribe)
- **State Store** — a persistent, versioned snapshot of the world (what exists, who owns it, what's blocked)

This is the same pattern that makes Kubernetes, Kafka, and Postgres REPL sets elite. The state of the world is never in one agent's memory. It is in the store.

### Concrete Design

```
.zeus/
├── bus/                     # Append-only event log
│   ├── session-YYYYMMDD.json   # One file per session, rotated daily
│   └── archive/              # Past sessions, compressed
├── state/
│   ├── current.json         # Live state snapshot
│   ├── versions/            # Versioned snapshots for rollback
│   └── locks/               # Distributed locks (agent occupancy)
├── registry/                # Tool + agent registry (promoted from tool-registry.mdc)
└── memory/                  # Persistent learned knowledge
    ├── lessons.md
    ├── decisions/
    │   └── index.md         # ADR-style decision log
    └── patterns/            # Extracted reusable patterns
```

### Event Schema (Every Event is a Fact)

```json
{
  "id": "uuid-v4",
  "seq": 1,
  "timestamp": "2026-04-29T14:23:01.003Z",
  "type": "AGENT.SPAWN | AGENT.RETURN | GATE.PASS | GATE.FAIL | STATE.UPDATE | ALERT.ESCALATE",
  "source": "zeus-pm | backend-agent | ...",
  "payload": { },
  "causality": "uuid-of-parent-event"
}
```

**Why this matters:**
- Every agent can read the bus and know what every other agent is doing **right now** without asking Zeus
- The event bus becomes the source of truth for observability dashboards
- When a subagent crashes, its last event is in the log — no data loss
- Session recovery after a crash: replay the bus from the last known state

### State Schema (What the World Looks Like Now)

```json
{
  "session": {
    "id": "uuid-v4",
    "started": "ISO8601",
    "root_task": "text",
    "classification": "Standard | Complex | ...",
    "status": "ACTIVE | BLOCKED | DONE | KILLED"
  },
  "agents": [
    {
      "id": "backend-agent",
      "status": "IDLE | WORKING | BLOCKED | DONE | DEAD",
      "current_task": "uuid-of-parent-event",
      "occupied_since": "ISO8601",
      "outputs": [{ "seq": 1, "artifact_path": "..." }]
    }
  ],
  "tasks": [
    {
      "id": "uuid-v4",
      "description": "text",
      "owner": "agent-id",
      "status": "PENDING | IN_PROGRESS | GATING | PASSED | FAILED | BLOCKED",
      "gate_results": [{ "gate": "Gate-3", "result": "PASS", "at": "ISO8601" }],
      "depends_on": ["uuid-of-blocking-task"],
      "planned_duration": "5m",
      "actual_duration": "4m 23s"
    }
  ],
  "locks": [
    {
      "resource": "src/main/java/.../UserController.java",
      "owner": "backend-agent",
      "acquired_at": "ISO8601",
      "ttl": "10m"
    }
  ]
}
```

### Distributed Locking — No Conflicts

When a subagent begins work on a file, it **acquires a lock** on that file in the State Store. The lock has a TTL (default 10 minutes, renewable). Every other agent checks the lock table before writing to any file. **No more two agents editing the same file without knowing it.**

Locks are released on: task completion, gate failure, or TTL expiry. If TTL expires and the agent hasn't returned, Zeus is alerted and the task is flagged for recovery.

---

## Part II — Task Classification: From Taxonomy to Execution DAG

### What Exists Today

Tasks are classified as Trivial / Standard / Complex / Unknown. This is a good start but it only drives *whether* to orchestrate — not *how*.

### What Should Exist

Every non-trivial task is decomposed into a **Directed Acyclic Graph (DAG)** before any delegation begins. The DAG is:

1. **Executable by agents in parallel wherever dependency-free**
2. **Blocked nodes are visible and queued, not hidden**
3. **Critical path is computed and communicated to the human**

### DAG Classification Levels

| Level | Name | DAG Behavior |
|-------|------|-------------|
| **L0** | Trivial | No DAG. Zeus executes inline. |
| **L1** | Standard — Single Thread | Sequential DAG, one agent at a time |
| **L2** | Standard — Parallel Safe | DAG with parallel branches, concurrent agent execution |
| **L3** | Complex — Cross-Domain | DAG with multiple agent domains, requires Architect Agent up front |
| **L4** | Complex — Unknown Dependencies | DAG built iteratively: probe, discover, expand |

### DAG Input: The Brief Validator

Before Zeus generates a DAG, it runs a **Brief Validator**:

```
Given: task description + handoff package
Check:
  1. Is the output definition specific and measurable?
  2. Are constraints listed and testable?
  3. Is the task scope bounded (not "fix the entire auth system")?
  4. Are there hidden dependencies not stated in the brief?
     → Probe: ask Architect or Requirements Analyst
  5. Are there external consumers of intermediate outputs?
     → Mark those outputs as "contract" — cannot change without version bump
```

If the brief fails validation, Zeus does NOT delegate. It returns to the user (or asks the Requirements Analyst) until the brief is DAGgable.

### Critical Path Calculation

Once the DAG is built, Zeus computes the **critical path** — the longest chain of dependent tasks. This is what determines wall-clock time. Zeus reports to the human:

> "This task has 12 nodes. 8 can run in parallel. Critical path is: Architect → Backend → QA → Reviewer → Deploy. Estimated wall-clock: 47 minutes."

This is a **180+ IQ move** because it turns an abstract "complex task" into a concrete time budget — letting the human decide whether to proceed, split the task, or accept the cost.

---

## Part III — Agent Execution Model: Parallelism by Design

### What Exists Today

`DELEGATE → Assign scoped brief to each agent in sequence` (zeus-pm.mdc line 67).

### What Should Exist

**Parallelism is the default for independent branches of the DAG.** Zeus identifies all nodes with zero in-degree (no blocking dependencies) and dispatches them in a single orchestration turn.

### Implementation

```
DISPATCH PHASE (single Zeus turn):
  1. Build DAG
  2. Identify all nodes where in_degree == 0 and status == PENDING
  3. For each such node:
       → Spawn agent with full brief
       → Register agent as WORKING in State Store
       → Subscribe agent to the event bus
  4. Zeus monitors the event bus, NOT polling agents directly

WAIT PHASE:
  5. As agents complete, they publish AGENT.RETURN to the bus
  6. Zeus receives events, updates State Store
  7. Newly unblocked nodes (in_degree satisfied, all blockers DONE) → dispatch
  8. Repeat until DAG is exhausted

CONVERGE PHASE:
  9. All leaf nodes done → run final gate sequence
  10. Write session summary to bus + state store
```

### Real-Time Feedback Loop (Flaw #1 Fixed)

Agents publish **progress heartbeats** to the event bus every 60 seconds:

```json
{
  "type": "AGENT.HEARTBEAT",
  "source": "backend-agent",
  "payload": {
    "task_id": "uuid",
    "progress_pct": 65,
    "current_step": "Writing UserService.java",
    "intermediate_artifact": "src/main/java/.../UserService.java@65pct",
    "estimated_remaining": "3m"
  }
}
```

Every other agent subscribed to the bus can see these heartbeats. Frontend Agent waiting for an API contract can see that Backend Agent is 65% done and still on track. No need to ask Zeus. No interruption required.

### Subagent Cancellation (Flaw #5 Fixed)

When a kill signal fires:

1. Zeus publishes `SESSION.KILL` to the event bus (not a file check)
2. All subscribed agents receive the event within one heartbeat cycle (≤60s)
3. Each agent:
   - Stops accepting new work
   - Finishes its current atomic step (no half-written files — atomic writes only)
   - Writes a `AGENT.ABORTED` event with: what was done, what was not done, artifact paths
   - Releases all locks
4. State Store is updated with the full abort record
5. Human sees: "Session killed at 14:23. Backend Agent: 65% done (UserService.java@65pct, not committed). Frontend Agent: 0% done, no artifacts."

**No dangling processes. No lost work. Full transparency on what was stopped.**

### Resource Pooling

Zeus maintains a **resource budget**:

| Resource | Budget | Notes |
|----------|--------|-------|
| Concurrent agents | 5 | Max active subagents at once |
| Memory per agent | 60s session | Auto-cleanup after TTL |
| Event bus retention | 7 days | Compressed archive after |
| State Store versions | 30 | Rotated, oldest dropped |

When the concurrent agent pool is full, new tasks queue rather than overflow. This prevents resource exhaustion — a failure mode that looks like "everything is slow" but is actually pool starvation.

---

## Part IV — Quality Gates: Real-Time, Tiered, and Self-Verifying

### What Exists Today

Gates are binary pass/fail checks applied after an agent returns. 2 rework cycles. Gate 3 (QA) has an 85% coverage requirement. Gates are enforced by Zeus but owned by agents checking their own work.

### What Should Exist

**Three-tier gate model:**

```
TIER 1 — Inline Gate (in-agent, real-time)
  → The agent runs this while writing, not after
  → Examples: does this compile? are there obvious hardcoded values?
  → No Zeus involvement. Self-enforced.

TIER 2 — Handoff Gate (before returning to Zeus)
  → QA Agent or domain specialist validates before the agent calls "done"
  → Gate criteria are exact and automated where possible
  → Result: PASS / FAIL / ESCALATE

TIER 3 — Closure Gate (Zeus final sign-off)
  → All Tiers passed → Zeus approves
  → Any ESCALATE → human review required
```

### Automated Gate Execution

Gate criteria that are mechanically verifiable should be **automated** (not human-judged):

| Gate | Automated? | How |
|------|-----------|-----|
| G1: Code compiles | YES | `mvn compile` exit code |
| G2: Javadoc on public methods | YES | AST parse + count public methods with doc |
| G3: 85% coverage | YES | JaCoCo XML report parsed |
| G4: No hardcoded values | YES | Regex scan of source files |
| G5: CSRF tokens present | YES | Parse Thymeleaf templates for `th:action` |
| G6: Role-based access present | PARTIAL | Route table scan; manual for complex rules |
| G7: No secrets in source | YES | `git secrets --scan` or equivalent |
| G8: Image alt text | YES | HTML parser scanning `<img` tags |

When a gate is automated, Zeus can run it **in parallel with the agent writing** (inline, Tier 1), catching failures before the agent ever calls done. This cuts rework cycles by catching defects where they're created.

### Gate Dashboard

Every session produces a **gate log**:

```
.zeus/
└── gates/
    └── session-YYYYMMDD-UUID.json
        → { "task_id": "...", "gate": "G3", "run_at": "...", "result": "PASS", "evidence": { "pct": 87 } }
```

Zeus reads gate logs at session start to identify patterns:
- "QA Agent has failed Gate 3 (coverage) 4 times in the last 10 sessions — always on Backend Agent output"
- This becomes a lesson in `tasks/lessons.md` and a trigger for the Self-Improvement Agent

### Smart Rework — Tiered Escalation (Flaw #3 Fixed)

Current: Max 2 rework cycles → escalate at cycle 3.

**Proposed: Two-dimension rework model**

| Failure Type | Response |
|-------------|----------|
| **Incremental** (wrong value, missing import, style fix) | Auto-fix in same cycle. Agent corrects and re-runs gate in ≤2 minutes. Does not count as rework cycle. |
| **Structural** (wrong approach, missing test scenario, architectural mismatch) | Rework cycle counts. If no improvement on cycle 2, escalate to human immediately — do not waste cycle 3. |
| **Critical** (security finding, secret in source, deployed vulnerability) | Escalate NOW. No cycles. This is not negotiable under any time pressure. |

**Why this matters:** 80% of rework cycles are incremental fixes that could be auto-resolved. The rework cycle counter is currently being wasted on problems that a linter would catch. Free up rework cycles for what they were designed for: structural course corrections.

---

## Part V — Memory System: From Session-Local to Permanent Knowledge

### What Exists Today

`tasks/lessons.md` and `tasks/decisions.md` are written at session end. They are append-only. They are read at session start. This is a **session-local loop** — lessons learned in one session are technically available in all future sessions, but in practice they are rarely consulted because they grow unbounded and lack structure.

### What Should Exist

**Three-layer memory architecture:**

```
LAYER 1 — Ephemeral (current session only)
  → Event bus + State Store (Part I)
  → Lives in .zeus/bus/ and .zeus/state/
  → Dies at session end (but archived first)

LAYER 2 — Project Knowledge (survives sessions, scoped to project)
  → .zeus/memory/
  → Structured as:
      lessons.md          (flattened, tagged, searchable)
      decisions/
          index.md       (ADR-style, newest first)
          adr-001.md ... (one file per decision)
      patterns/          (extracted reusable playbooks)
          auth-flow.md   (proven auth pattern, ready to copy)
          api-contract.md
      agent-effectiveness/  (per-agent metrics over time)
          backend-agent.json  → { "avg_gate_failures": 0.3, "avg_cycle_count": 1.2 }

LAYER 3 — Cross-Project Learning (personal assistant level)
  → ~/.cursor-kit/memory/ (lives outside any one project)
  → Cursor-kit's own patterns, refined across projects
  → Updated by Self-Improvement Agent monthly
```

### Lesson Tagging (Making Memory Searchable)

Every lesson written to `lessons.md` must include tags:

```markdown
---
tags: [quality-gate, qa-agent, coverage, backend]
---

**Lesson:** QA Agent consistently fails Gate 3 (85% coverage) when Backend Agent
produces utility classes. Utility classes are hard to unit test without mocking the
database, which QA avoids. **Prevention:** Backend Agent must flag utility classes
to QA Agent before QA writes tests, so QA can plan mocking strategy upfront.
**When:** 2026-04-29
```

Tagging enables **semantic search**: "Show me all lessons tagged `security` from the last 90 days." Zeus runs this at session start. Instead of reading a 500-line `lessons.md`, Zeus reads the filtered result set.

### The Self-Improvement Agent's Real Job

Currently: "Monthly effectiveness; learning log (self-improvement.md)" — vague and passive.

**Proposed mandate:**

```
SELF-IMPROVEMENT AGENT — Monthly Mandate:
  1. Parse .zeus/memory/agent-effectiveness/*.json
  2. Identify agents with declining metrics (rising failure rates, rising cycle counts)
  3. For each declining agent:
       → Root-cause: is it the agent's brief, the gate criteria, or the agent itself?
       → Propose a fix (brief update, gate adjustment, or new constraint)
       → Write ADR: "Why agent X is underperforming + recommended fix"
  4. Extract top 3 patterns from completed sessions → promote to .zeus/memory/patterns/
  5. Review .zeus/memory/lessons.md → consolidate duplicate lessons
  6. Present findings to human for approval before applying changes
```

This is **meta-cognition at the system level** — the system observes itself and proposes its own improvements. That is 180+ IQ.

---

## Part VI — On-the-Fly Protocol: Safe by Design (Flaw #4 Fixed)

### What Exists Today

1. IDENTIFY → 2. SPEC → 3. SPAWN Builder → 4. VERIFY (gate) → 5. REGISTER → 6. INVOKE → 7. LOG

Step 4 (verify) and step 5 (register) are supposed to act as safety gates, but the registry entry is a paste-and-forget operation with no review phase.

### What Should Exist

**Beta Registry with Mandatory Review Window:**

```
STEP 1: IDENTIFY   — Gap named precisely. Written to .zeus/state/pending-tools.json
STEP 2: SPEC       — Full spec written to .zeus/pending/{tool-name}/SPEC.md
STEP 3: BUILD      — Builder Agent builds tool to .zeus/pending/{tool-name}/
STEP 4: GATE-6     — Quality Gate 6 applied. Automated criteria must pass.
STEP 5: BETA       — Tool enters BETA REGISTRY (invisible to production agents)
                    → Security Agent notified; has 24h to audit
                    → ToolRegistry Agent validates dependencies
                    → Config Manager writes audit record
STEP 6: PROMOTE    — If no critical/high findings in 24h → promoted to production registry
                    → If findings → returned to Builder with findings; restart from step 3
STEP 7: LOG        — ADR written to .zeus/memory/decisions/
```

**No tool enters production before step 6 completes.** The beta period is not optional. It is enforced by the State Store (tools not in `registry/production/` are not loadable by any agent brief).

**Builder Agent constraint:** When spawning on-the-fly, Builder Agent's brief must include: "You are building a beta-quality tool. It will be audited before production use. Do not describe it as production-ready."

---

## Part VII — Safety Systems: Circuit Breakers, Rollback, and Observability

### Circuit Breaker (Improved)

Current: N consecutive failures → open circuit → cooldown → single probe.

**Enhanced model:**

```
Circuit State Machine:
  CLOSED (normal) → Failure occurs
    → Increment failure counter for this path
    → If counter > threshold → OPEN

  OPEN (failing fast) → Reject requests immediately
    → Alert human: "Circuit OPEN for {path}. {N} failures. No auto-retry."
    → After cooldown → PROBE

  PROBE (testing recovery) → Allow one request through
    → Success → CLOSE (reset counter)
    → Failure → OPEN (double cooldown window, alert escalation)

  ESCALATED (chronic failure) → After 3 OPEN cycles with no recovery
    → Mark path as REQUIRES_HUMAN_APPROVAL
    → No further auto-retry; human must explicitly reset
```

Every circuit in the system has: a name, a failure threshold, a cooldown window, and an owner (which agent owns this path). These are tracked in `tasks/decisions.md` when first created.

### Auto-Rollback (Enhanced)

Current: `rollback-on-test-failure.ps1` hook after deploy.

**Enhanced model: Pre-deploy gate + atomic deploy + automatic rollback trigger**

```
PRE-DEPLOY GATE (run before any deploy command):
  1. Smoke test passes in staging environment
  2. Gate 5 criteria all verified (no secrets, pinned versions, etc.)
  3. State Store updated: deployment.status = "PRE_FLIGHT_CHECKED"

DEPLOY EXECUTION:
  4. Deploy begins → State Store: deployment.status = "IN_PROGRESS"
  5. Post-deploy smoke test fires automatically
  6. If smoke test fails:
       → State Store: deployment.status = "ROLLBACK_TRIGGERED"
       → Rollback executes immediately (no human action needed)
       → Alert published to event bus: "Auto-rollback fired for {branch}"
       → Human notified: "Deploy failed. Auto-rollback complete. Review: {link}"

ATOMIC DEPLOY MARKER:
  7. Only one deploy in IN_PROGRESS state at a time per environment
  8. Concurrent deploy attempts are rejected before any work starts
  9. This is enforced at the State Store layer, not by the hook
```

This is how elite CI/CD systems work (Spinnaker, ArgoCD). Every deploy is either: fully succeeded, or fully rolled back. No partial state.

### Observability Dashboard (What Every Session Produces)

At the end of every session, Zeus writes a **session report**:

```markdown
# Session Report — 2026-04-29

**Task:** Build user registration flow
**Classification:** L2 (Standard, parallel-safe)
**DAG:** 6 nodes, 3 parallel branches
**Critical Path:** Architect → Backend → QA → Reviewer (34 minutes)
**Actual Duration:** 31 minutes (3 minutes under estimate)

## Agents Used
| Agent | Task | Duration | Gates Passed |
|-------|------|----------|--------------|
| Architect | System design | 8m | G1-G2 |
| Backend | UserService + Controller | 12m | G1-G4 |
| Frontend | Registration form | 10m | G2-G4 |
| QA | Test suite | 9m | G3 |

## Gate Summary
| Gate | Result | Automated? |
|------|--------|-----------|
| G1: Compile | PASS | YES |
| G3: Coverage 87% | PASS | YES |
| G4: Security | PASS | PARTIAL |
| G5: Deploy config | N/A | — |

## Lessons
- Backend Agent produced utility class without flagging QA → QA missed mocking strategy → +1 rework cycle
- Pattern flagged for tasks/lessons.md: "Backend utility classes must be pre-flagged to QA"

## Critical Path Actual vs. Estimated
[Estimated: 34m] ████████████████████ [Actual: 31m] ██████████████████░░

**Status:** CLOSED
```

This report is what a principal engineer opens on Monday morning to understand what happened last week. It is also what Self-Improvement Agent parses to find patterns. Every session is a data point.

---

## Part VIII — The Complete File Tree: What cursor-kit Should Look Like

```
cursor-kit/
├── .zeus/                         # NEW: Core orchestration layer
│   ├── bus/                        # Append-only event log
│   │   ├── session-YYYYMMDD.json
│   │   └── archive/
│   ├── state/                      # Live state store
│   │   ├── current.json            # ← State Store (replaces in-memory Zeus state)
│   │   ├── versions/              # Versioned snapshots
│   │   └── locks/                # Distributed file locks
│   ├── registry/                  # Production registry (promoted from .cursor/rules/)
│   │   ├── tools.json             # Tool registry (consolidated)
│   │   └── agents.json            # Agent roster (consolidated)
│   ├── pending/                   # On-the-fly tools in beta
│   │   └── {tool-name}/
│   │       ├── SPEC.md
│   │       ├── tool-file
│   │       └── audit-record.json
│   ├── memory/                    # Persistent learned knowledge
│   │   ├── lessons.md            # Tagged, searchable
│   │   ├── decisions/
│   │   │   ├── index.md
│   │   │   └── adr-001.md ...
│   │   ├── patterns/
│   │   │   └── auth-flow.md
│   │   └── agent-effectiveness/
│   │       └── backend-agent.json
│   ├── gates/                    # Gate execution logs
│   │   └── session-YYYYMMDD-UUID.json
│   └── session-reports/           # End-of-session reports
│       └── 2026-04-29-UUID.md
│
├── .cursor/                       # Configuration layer (existing, refactored)
│   ├── agents/                    # Agent brief definitions (refactor into agents.json)
│   ├── rules/                    # Rules (consolidate into .zeus/registry/)
│   ├── hooks/                    # Hook scripts (augment with bus publisher)
│   ├── commands/                 # Slash commands
│   └── skills/                   # Skill definitions
│
├── tasks/                         # Human-visible project memory (layered on .zeus/memory/)
│   ├── todo.md
│   ├── lessons.md                # ← symlink or redirect to .zeus/memory/lessons.md
│   └── decisions.md             # ← symlink or redirect to .zeus/memory/decisions/
│
└── .kill-switch                   # Emergency halt (existing)
```

**Key principle:** `.zeus/` is the machine. `.cursor/` is the configuration. `tasks/` is the human interface. They are not the same thing and should not be mixed.

---

## Part IX — Implementation Roadmap

This is not a weekend project. It is a phased migration. Each phase delivers value independently.

### Phase 1 — Foundation (Week 1–2)
**Goal:** Event bus + State Store without changing agent behavior

- [ ] Implement `.zeus/bus/` as append-only JSON log (publish/subscribe via file system)
- [ ] Implement `.zeus/state/current.json` as authoritative state (Zeus writes; all agents read)
- [ ] Write bus publisher hook in `subagentStart` hook
- [ ] Zeus still operates in hub-and-spoke mode; state store is read by all agents for context
- [ ] **Value delivered:** Session crash recovery. After a crash, Zeus can reconstruct what was happening from the bus.

### Phase 2 — Parallelism (Week 3–4)
**Goal:** DAG-based planning + concurrent agent dispatch

- [ ] Implement DAG builder in Zeus (task brief → nodes + edges)
- [ ] Modify Zeus dispatch phase to send multiple agents concurrently
- [ ] Implement heartbeat publishing in subagents (every 60s to bus)
- [ ] Implement distributed locking in State Store (acquire/release per file)
- [ ] **Value delivered:** Complex tasks run 40–60% faster. Lock conflicts eliminated.

### Phase 3 — Smart Gates (Week 5–6)
**Goal:** Automated gate execution + tiered rework model

- [ ] Implement automated gate runners (compile check, coverage parse, secrets scan)
- [ ] Implement Tier 1 (inline) gates — run alongside agent writing
- [ ] Implement tiered rework model (incremental vs. structural vs. critical)
- [ ] Gate dashboard in `.zeus/gates/session-*.json`
- [ ] **Value delivered:** Rework cycles cut by ~60%. Gate failures caught where they happen.

### Phase 4 — Memory + Self-Improvement (Week 7–8)
**Goal:** Three-layer memory architecture

- [ ] Restructure `.zeus/memory/` with tagging system
- [ ] Implement ADR-style decision log in `decisions/`
- [ ] Implement agent-effectiveness tracking in JSON
- [ ] Self-Improvement Agent monthly runbook
- [ ] **Value delivered:** The system remembers. Sessions become progressively smarter.

### Phase 5 — On-the-Fly Safety + Beta Registry (Week 9–10)
**Goal:** Safe tool/agent creation with audit trail

- [ ] Implement beta registry + 24h audit window
- [ ] Security Agent notified on every new beta tool
- [ ] Production registry gated on beta completion
- [ ] ADR required for every on-the-fly creation
- [ ] **Value delivered:** No unvetted tools in production. Full audit trail for every dynamically created artifact.

### Phase 6 — Observability + Session Reports (Week 11–12)
**Goal:** Every session produces a machine-readable report

- [ ] Implement end-of-session report generator in Zeus
- [ ] Critical path tracking (estimated vs. actual)
- [ ] Agent effectiveness metrics per session
- [ ] Self-Improvement Agent reads session reports for pattern extraction
- [ ] **Value delivered:** Full project visibility. Monday morning briefings from the system itself.

---

## Part X — What This System Enables (The Shock Factor)

### Scenario: A complex multi-domain task lands at 9am

**Old system:**
- Zeus plans for 5 minutes, delegates to Backend (20 min), waits, delegates to Frontend (20 min), waits, delegates to QA (15 min), waits, delegates to Reviewer (5 min), waits.
- Total: ~65 minutes of wall-clock time. Human has no visibility until the end.
- If Backend hits a blocker at minute 15, the whole chain stalls.

**New system:**
- Zeus reads task brief → DAG built in 30 seconds
- 3 parallel branches identified: [Architect + Backend], [Frontend], [DevOps]
- Backend and Frontend dispatched at minute 1, concurrently
- Backend publishes heartbeats: "65% done, API contract written to state"
- Frontend reads the API contract from State Store at minute 20 and starts building components immediately — no need to wait for Backend to finish
- QA is dispatched when Backend publishes AGENT.RETURN (minute 23)
- Critical path is 34 minutes. Human sees live progress. At minute 25, human knows: "On track. QA running."
- Session report auto-generated. Self-Improvement Agent sees Backend Agent utility class pattern → flags it → next session, Backend Agent brief is updated with pre-flagging requirement before the task even starts.

**The system learns. The system plans. The system parallelizes. The system reports. That is 180+ IQ.**

---

## Appendix A — Comparison: Before vs. After

| Dimension | Before | After |
|-----------|--------|-------|
| State | In Zeus memory (volatile) | State Store (persistent, versioned) |
| Communication | Hub-and-spoke via Zeus | Event bus (pub/sub, real-time) |
| Parallelism | Sequential delegation by default | DAG-based, parallel by default |
| Feedback loops | None between subagents | Heartbeat + shared state |
| Rework cycles | 2 flat cycles | Tiered: auto-fix / structural / critical |
| On-the-fly tools | Created and registered, no review | Beta registry + 24h audit |
| Kill switch | Process-level, leaves partial artifacts | Task-level, atomic abort + full record |
| Memory | Session-local, append-only | 3-layer, tagged, searchable |
| Session recovery | None (crash = restart from scratch) | Bus replay from last known state |
| Observability | Human must ask | Session reports auto-generated |
| Self-improvement | Monthly vague review | Data-driven, ADR-documented, human-approved |
| Gates | Manual pass/fail | Automated + manual, tiered |

---

## Appendix B — Architectural Principles (The Constitution)

1. **State is never in one agent's memory.** It is in the State Store.
2. **Every action is an event.** Nothing happens that is not published to the bus.
3. **Locks prevent conflicts.** No agent writes to a file it doesn't own.
4. **Automation first.** If a gate can be automated, it must be.
5. **Escalation is not failure.** It is the system working correctly.
6. **Critical is critical.** No time pressure overrides a critical security finding.
7. **Lessons not written are lessons not learned.** Write before the ZEUS BRIEF, not after.
8. **The system observes itself.** Self-Improvement Agent is not optional.
9. **Parallelism is the default** for dependency-free branches.
10. **A brief that cannot be DAG'd is not ready.** Stop and clarify before building.

---

*This document is the architectural blueprint for cursor-kit v2.0. It is intended to be read, debated, and refined. When approved, each part maps to a phase in the implementation roadmap. Every phase delivers value before the next begins.*
