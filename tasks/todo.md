# Task Board

> **Human interface to the orchestration system.**
> Machine state lives in `.zeus/state.json`. This file is for human planning and tracking.

## Implementation Roadmap

### Phase 1 — The Nerve Center (Weeks 1–2)
Goal: Journal + State Store + Contracts. No change to agent behavior yet.

- [ ] Implement `.zeus/journal/` as append-only JSONL
- [ ] Implement `.zeus/state.json` as authoritative state with contract schema
- [ ] Define execution contract schema; add to Zeus dispatch prompt
- [ ] Add Tier 0 brief validation gate to Zeus
- [ ] Write agent brief templates to `.cursor/agents/` (Part VI)
- [ ] Zeus still operates hub-and-spoke; state store is read-only context for now

### Phase 2 — The Engine (Weeks 3–4)
Goal: DAG-based planning + batch dispatch.

- [ ] Implement DAG builder in Zeus (brief → nodes + edges + confidence score)
- [ ] Implement batch dispatch (all ready nodes per turn)
- [ ] Implement progress snapshot writing by agents
- [ ] Implement synchronous lock management in state.json
- [ ] Implement DAG failure taxonomy handlers
- [ ] Implement inter-agent handoff schema in Zeus contract assembly

### Phase 3 — Quality Automation (Weeks 5–6)
Goal: Automated gate runners + tiered rework.

- [ ] Implement automated gate runners (G0–G8)
- [ ] Implement Tier 1 inline self-check in agent brief templates
- [ ] Implement rework decision tree in Zeus
- [ ] Gate logs written to `.zeus/gates/`
- [ ] Implement escalation decision tree in Zeus

### Phase 4 — Intelligence (Weeks 7–8)
Goal: Three-layer memory with retrieval. Dynamic context injection.

- [ ] Restructure `.zeus/memory/` with tagging + lesson format
- [ ] Implement retrieval index (`index.json`) + tag-filtered lesson injection
- [ ] Implement agent-effectiveness tracking
- [ ] Implement dynamic agent brief assembly (static role + contract + filtered lessons)
- [ ] Human override protocol (`.zeus/overrides/`)

### Phase 5 — Polish & Observability (Weeks 9–10)
Goal: Self-improvement + cost visibility + simulation mode.

- [ ] Self-Improvement Agent monthly runbook (concrete thresholds)
- [ ] Session report auto-generator
- [ ] Simulation mode for L3/L4 tasks
- [ ] Cost/token tracking per agent per session
- [ ] Tool registry + same-session security review

---

> **Critical gate:** Phase 2 cannot begin until Phase 1 runs flawlessly in production for one full week.
