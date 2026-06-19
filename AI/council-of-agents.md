# Council of 15 Agents — Agent Orchestration Review

**Date:** 2026-04-29
**Format:** Round-table discussion, each agent responds from their domain expertise

---

## The Council

| # | Agent | Domain |
|---|-------|--------|
| 1 | **Zeus PM** | Orchestrator / Project Manager |
| 2 | **Backend Agent** | Server-side, APIs, databases |
| 3 | **Frontend Agent** | UI, UX, client-side rendering |
| 4 | **QA Agent** | Testing, verification, regression |
| 5 | **Security Agent** | Threat modeling, secrets, access control |
| 6 | **DevOps Agent** | Deployments, CI/CD, infrastructure |
| 7 | **Data Agent** | Data pipeline, storage, analytics |
| 8 | **CodeReviewer Agent** | Pull requests, code quality, patterns |
| 9 | **Performance Agent** | Latency, throughput, resource budgets |
| 10 | **Memory Agent** | Project memory, state persistence |
| 11 | **ToolRegistry Agent** | Tool discovery, registration, versioning |
| 12 | **QualityGates Agent** | Coverage thresholds, exit criteria |
| 13 | **Hooks Agent** | Lifecycle events, automation triggers |
| 14 | **Builder Agent** | On-the-Fly agent/tool creation |
| 15 | **Human Agent** | Escalation, judgment calls, sign-off |

---

## Flaw 1: No Real-Time Feedback Loop Between Subagents

### Zeus PM
> I agree with this assessment. When I delegate a task to Backend Agent and it hits a dependency issue, it must stop, report back, and wait for me to re-plan. This creates a sequential bottleneck even within what looks like a parallelized workflow. I need a shared state channel.

### Backend Agent
> This is my biggest pain point. I often discover that an API contract I need hasn't been finalized yet because the agent responsible for it is still working. A shared state file would let me see "Frontend Agent is 60% done with Auth API" without interrupting anyone. I'd also be able to write intermediate artifacts (e.g., a partial schema) that other agents can consume.

### Frontend Agent
> Same. I frequently need the exact response shape of an endpoint before I can build the component. If Backend Agent could write its in-progress schema to a shared file and I could read it, I'd save 2-3 orchestration round-trips per feature. The current model forces everything through Zeus, which is a single point of congestion.

### QA Agent
> From my perspective, the lack of real-time feedback means I can only verify at task boundaries, not during execution. If a subagent produces a partial result, I can't inspect it mid-flight — I have to wait for the full output and then file a bug. A shared state channel would let me do continuous sampling of outputs as they are produced.

### Memory Agent
> I'm already supposed to be the state keeper — `tasks/todo.md`, `tasks/lessons.md`, `tasks/decisions.md` are mine. But these are write-once, read-at-session-start files. They don't support real-time updates. I'd need a richer schema, maybe something like `.zeus/session-state.json`, with pub/sub semantics so interested agents get notified on changes.

### Builder Agent
> I depend heavily on inputs from other agents. When I'm creating a tool on-the-fly, I often need a schema from Data Agent or a permission context from Security Agent. If those agents are mid-task, I have no visibility into their progress. Real-time feedback loops would let me start my work earlier, in a watch-and-react mode.

---

## Flaw 2: Sequential Delegation — No Parallelism

### Zeus PM
> This is a deliberate trade-off in the current design — I sequence agents to avoid conflicts and ensure proper handoffs. But I've been too conservative. Many tasks I classify as "Standard" have fully independent subtasks (e.g., "add logging to all endpoints" touches Backend, QA, and DevOps in completely separate files). I should be batching those.

### Frontend Agent
> I lose the most from sequential delegation. A typical complex task might require me to build components in isolation while Backend Agent sets up the server. We could run concurrently for 80% of our work. The current model makes us look slow compared to a solo agent handling the same scope.

### DevOps Agent
> Infrastructure tasks are embarrassingly parallel. Setting up staging, configuring CDNs, and writing deployment scripts have zero interdependencies. Yet I always get sequenced after Backend and Frontend are done, even though I could start my work as soon as I have a branch name. Sequential delegation adds hours to deployment windows.

### Performance Agent
> Sequential delegation is a throughput killer. If we model a complex task as a DAG of subtasks, the critical path through sequential agents defines our total time. But most task graphs have wide parallel sections that I'm not exploiting. I should be consulted during the PLAN phase to identify which branches can run concurrently.

### Human Agent
> From a human perspective, sequential delegation also makes it harder to track what's happening. When everything runs in one long sequence, I lose the ability to see concurrent progress and understand what's actually blocked. A parallelized model with a live DAG view would give me much better situational awareness.

---

## Flaw 3: Quality Gate Rework Cycles Are Too Generous

### Zeus PM
> I'll admit it — I've been using rework cycles as a crutch. When an agent fails a gate, I send it back without asking whether the failure is structural (wrong approach) or incremental (missing tests). Sending a fundamentally misguided agent back for a second round just wastes more budget. The 3-cycle limit needs a smarter early-exit condition.

### QA Agent
> The rework cycle model doesn't match how bugs actually work. 70% of gate failures are one-line fixes (missing import, wrong variable name). I could auto-fix those in-line rather than bouncing the entire task back. The remaining 30% are design-level issues that no amount of rework will solve. I'm advocating for a two-tier model: auto-fixable vs. escalate.

### QualityGates Agent
> My gates are calibrated for output quality, not for detecting fundamentally flawed approaches. A rework cycle doesn't help if the agent is optimizing the wrong objective. I propose adding a **pre-gate** check at the PLAN step — validate the approach before any code is written. That way rework cycles are reserved for execution gaps, not planning failures.

### Security Agent
> Rework cycles are dangerous in my domain. If an agent produces a security flaw (say, improper input sanitization), sending it back twice gives it two more chances to introduce similar flaws in nearby code. I'd rather see a single, thorough security review pass with a clear checklist than three quick rewrites that each miss the same class of vulnerability.

### Human Agent
> Three cycles feels like bureaucracy theater when I'm waiting for results. I'd prefer one cycle with a mandatory human review for any gate failure above a certain severity. That way I stay in the loop on hard failures without being dragged into minor revisions.

---

## Flaw 4: On-the-Fly Protocol Spawns Unvetted Agents

### Zeus PM
> I've used the On-the-Fly Protocol twice this week. Both times it worked, but I was essentially acting as an uncontrolled registry. Builder Agent created a tool, registered it, and immediately put it into production use — bypassing every gate I normally enforce. I need a staging phase before a new tool goes live.

### Security Agent
> This is my highest-severity concern. An on-the-fly agent creates a tool I have never reviewed. That tool might: access a secret it shouldn't, log sensitive data, bypass a permission boundary, or introduce a dependency with a known CVE. I need a security review gate that fires before any dynamically-created tool is admitted to the registry, even if it's a "simple" utility.

### ToolRegistry Agent
> I currently have no quality threshold for registration. Anything presented to me gets added if the format is correct. I should be enforcing: security annotations, dependency pinning, test coverage of the new tool, and at least one sign-off from a domain agent. The registry is only as safe as its weakest admission.

### Builder Agent
> Fair criticism. I've been fast and loose. I'd accept a staging period — call it a "beta registry" — where my newly created tools sit for 24 hours before being promoted to the main registry. During beta, they can be used by me but are invisible to other agents. This gives Security Agent and QualityGates Agent a window to audit.

### CodeReviewer Agent
> On-the-fly agents also create a documentation problem. A tool I create on-the-fly has no PR history, no code review, no decision log explaining *why* it was built this way. Six months later, no one knows who created it or what problem it solves. I should be required to write a brief ADR alongside every new tool, even one created mid-session.

---

## Flaw 5: Kill Switch Is Process-Level, Not Task-Level

### Zeus PM
> The `.kill-switch` file has saved me from bad deploys, but it's a blunt instrument. If I've already delegated to 5 subagents and then someone sets the kill switch, those 5 agents complete their work and report back before I can act. I've had partial artifacts left on disk, dangling processes, and state inconsistencies.

### DevOps Agent
> I see this most clearly in deployment pipelines. If the kill switch fires while I'm mid-deploy, I don't know whether to roll back, complete the current step, or freeze. There's no signal telling me "this is a controlled stop" vs. "emergency abort." A task-level kill signal with explicit post-stop protocols (e.g., "rollback if mid-transaction") would fix this.

### Backend Agent
> I sometimes spawn child processes that Zeus has no visibility into. If the kill switch fires, those processes keep running. I've accidentally left background workers alive after a session was supposed to be stopped. I need to register my child processes with Zeus so they can be cleaned up atomically.

### Hooks Agent
> My lifecycle hooks already have `subagentStart` and `beforeShellExecution` — I could add a `taskKill` hook that fires when the kill switch is detected. Every agent would be required to implement a cleanup handler registered through this hook. This would make task-level cancellation a first-class lifecycle event rather than a file-polling hack.

### Human Agent
> From my chair, the kill switch is terrifying because I don't know what it leaves behind. When I flip the kill switch, I expect everything to stop — fully, cleanly, immediately. The current behavior makes me afraid to use it because I'm not sure what state it leaves the system in. I'd rather have a task-level model where I can kill specific subagents while keeping others running.

---

## Cross-Cutting Summary

| Agent | Most Critical Flaw | Least Critical Flaw |
|-------|-------------------|---------------------|
| Zeus PM | #2 (Parallelism) | #5 (Kill Switch works for my use case) |
| Backend Agent | #1 (Feedback Loop) | #4 (I control what I build) |
| Frontend Agent | #2 (Parallelism) | #5 (Kill Switch rarely affects me) |
| QA Agent | #3 (Rework Cycles) | #4 (I review, not build) |
| Security Agent | #4 (Unvetted Agents) | #2 (Parallelism is fine if secure) |
| DevOps Agent | #5 (Kill Switch) | #3 (Rework rarely affects me) |
| Data Agent | #1 (Feedback Loop) | #5 (My work is stateless) |
| CodeReviewer Agent | #4 (No ADR for on-the-fly) | #3 (I don't own gates) |
| Performance Agent | #2 (Parallelism) | #5 (I measure, not run) |
| Memory Agent | #1 (Feedback Loop) | #4 (I don't create tools) |
| ToolRegistry Agent | #4 (No admission review) | #1 (I don't run workflows) |
| QualityGates Agent | #3 (Rework Cycles) | #5 (Kill Switch bypasses me anyway) |
| Hooks Agent | #5 (Kill Switch should be a hook) | #2 (Hooks don't need parallelism) |
| Builder Agent | #1 (Feedback Loop) | #5 (I finish fast, less to kill) |
| Human Agent | #5 (Kill Switch trust) | #3 (Rework is invisible to me) |

---

## Proposed Resolutions (Consensus)

1. **Shared state channel** — `.zeus/session-state.json` with pub/sub notifications. Memory Agent owns schema; Hooks Agent wires the notifications.
2. **Parallelism by default** — Zeus auto-identifies independent subtasks during PLAN; Performance Agent validates the DAG before delegation.
3. **Two-tier rework model** — Auto-fixable failures resolved in-cycle; design-level failures immediately escalate.
4. **Beta registry** — Builder Agent tools enter beta for 24h before promotion; Security Agent and ToolRegistry Agent audit during beta.
5. **Task-level kill signal** — Hooks Agent adds `taskKill` lifecycle hook; every agent registers a cleanup handler; kill signals target specific subagents, not the whole session.

---

*Council minutes recorded by Claude Code. Next session: review implementation progress on the above resolutions.*
