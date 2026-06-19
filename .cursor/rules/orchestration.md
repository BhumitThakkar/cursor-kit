# Orchestration Rules — The Constitution

> These rules apply to ALL agents in the cursor-kit orchestration system.
> Source: cursor-kit v2.0 — THE DEFINITIVE IMPLEMENTATION BLUEPRINT

## The Core Axiom

**Inside Cursor, there are no persistent agents. Each turn reconstructs the world from files, executes a discrete action, and advances state deterministically.**

This is not a live operating system. It is a **commit engine with memory.**

| What people assume | What is actually true |
|--------------------|----------------------|
| Agents are running concurrently | One agent executes per turn, sequentially |
| Events are broadcast in real-time | Events are written to a file; read at next turn |
| State exists in memory | State exists only in `.zeus/state.json` |
| Agents heartbeat every N seconds | Agents write a snapshot file when done |
| Locks need TTL to prevent deadlock | No concurrent writers → no TTL needed |

---

## The 14 Architectural Principles

| # | Principle |
|---|-----------|
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

## File System Contract

| Layer | Path | Purpose |
|-------|------|---------|
| Machine | `.zeus/` | State, journal, DAG, progress, memory, gates |
| Configuration | `.cursor/` | Rules, agent briefs |
| Human | `tasks/` | Task board, lessons, decisions |

**Separation principle:** `.zeus/` is the machine. `.cursor/` is the configuration. `tasks/` is the human interface.

---

## Execution Contract Schema

Every task dispatched by Zeus **must** include:

| Field | Description |
|-------|-------------|
| `input` | What the task receives (specific artifacts/paths, not descriptions) |
| `output` | What the task must produce (specific files/methods/deliverables) |
| `definition_of_done` | Measurable, binary criteria (verifiable by automation or inspection) |
| `validation` | Exact command or procedure to verify the contract |

**Good vs. Bad contracts:**

| Bad (Vague) | Good (Contractual) |
|-------------|-------------------|
| "Build the user service" | "Produce `UserService.java` with `register()` and `findByEmail()` methods" |
| "Make sure it's secure" | "No hardcoded secrets. `git secrets --scan` exits 0." |
| "Write tests" | "JaCoCo XML coverage ≥ 85% on `user-module`." |
| "Follow best practices" | "No `System.out.println`. `@Slf4j` for logging." |

---

## Progress Snapshot Contract

Every agent writes on completion to `.zeus/progress/{task_id}.json`:

| Field | Required | Description |
|-------|----------|-------------|
| `task_id` | Yes | Task identifier (T1, T2, etc.) |
| `agent` | Yes | Agent that produced this snapshot |
| `progress_pct` | Yes | 0–100 completion percentage |
| `current_step` | Yes | Human-readable current/final step |
| `artifacts` | Yes | Array of file paths produced (paths, not descriptions) |
| `gate_self_check` | Yes | PASS / FAIL / PARTIAL |
| `notes` | Conditional | Mandatory when flagging items for downstream agents |
| `updated_at` | Yes | ISO8601 timestamp |
