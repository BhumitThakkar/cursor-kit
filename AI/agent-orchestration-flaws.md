# Agent Orchestration Review — Top 5 Flaws

**Date:** 2026-04-29
**Reviewer:** Claude Code (automated analysis)

---

## 1. No Real-Time Feedback Loop Between Subagents

Subagents work in isolation and return results to Zeus PM, but there is no mechanism for subagents to call back to each other or share intermediate state during execution. If a subagent encounters a blocker mid-task, it must return to Zeus and wait — causing latency and context loss.

**Fix:** Introduce a shared task context (e.g., a `.zeus/state.json` file) that all subagents can read/write to during execution.

---

## 2. Sequential Delegation — No Parallelism

The orchestration loop delegates agents **in sequence** (`Assign scoped brief to each agent in sequence`), not in parallel. For independent subtasks, this doubles or triples wall-clock time unnecessarily.

**Fix:** Batch independent tasks and invoke multiple subagents concurrently via multiple Agent tool calls in a single turn.

---

## 3. Quality Gate Rework Cycles Are Too Generous

Max 2 rework cycles per task unit means a subagent can fail → revise → fail → revise before escalation. With a 3-cycle max and no time-budget, a badly scoped task can burn significant orchestration cost.

**Fix:** Add a time budget or token cap per rework cycle, or escalate after the first clear failure with no improvement.

---

## 4. On-the-Fly Protocol Spawns Unvetted Agents

The "On-the-Fly Protocol" (spawning a **Builder** subagent to create a missing tool/agent) can introduce code or agents that have not been reviewed against quality-gates or security rules. New tools are registered before use — but registration itself has no review gate.

**Fix:** Require a lightweight review step (e.g., security scan + peer sign-off) before a dynamically-created agent or tool is admitted to the registry.

---

## 5. Kill Switch Is Process-Level, Not Task-Level

The kill switch (`.kill-switch` file) halts the entire Zeus session, but does not gracefully interrupt an in-flight subagent task. A subagent mid-execution won't see the kill signal until it returns to Zeus, meaning wasted work and potential side-effects (e.g., partial writes, dangling processes).

**Fix:** Signal subagents via a shared flag file they poll periodically, and have the Agent tool respect cancellation tokens.

---

**Biggest leverage:** Flaws #1 and #2 are the most impactful — they make the whole orchestration feel slow and brittle. Parallelism alone could cut task completion time by 50%+ for complex workflows with independent subtasks.
