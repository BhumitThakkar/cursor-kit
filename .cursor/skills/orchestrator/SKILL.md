---
name: orchestrator
description: Multi-agent workflow execution, automatic rollback, health monitoring, retry logic, circuit breaker, resource throttling, agent coordination. Use when coordinating pipelines or enforcing deploy/retry/rollback policies.
---

# Orchestrator Skill

## When to Use

- User asks to "run the pipeline", "coordinate agents", "deploy with checks", or "rollback".
- Workflow involves multiple steps (e.g. build → test → deploy).
- You need to enforce retry limits, deploy caps, or rollback on failure.

## Instructions

1. **Before starting a workflow**
   - Resolve which agents/steps are in scope.
   - Check deploy count for the day (if applicable); if at limit (e.g. 10/day), block and alert.
   - Ensure emergency kill switch is documented (e.g. env var or script).

2. **During execution**
   - For each step: run step, on failure retry up to 3 times with backoff. On 3rd failure, stop and create alert/ticket for human.
   - If step is "deploy", run health checks (e.g. every 30s); if error rate > threshold, trigger rollback and notify.
   - Use circuit breaker: after N consecutive failures for a step, open circuit and do not retry until cooldown.

3. **After test failure (e.g. post-deploy)**
   - Trigger automatic rollback (revert deploy or mark release bad).
   - Log reason and notify; do not continue pipeline.

4. **Handoffs between agents**
   - Pass: ticket IDs, branch, API spec path, ADR references.
   - Avoid redoing work: check existing artifacts (OpenAPI, ADR, tests) before asking an agent to regenerate.

## Safety Checklist

- [ ] Retries ≤ 3 then human alert
- [ ] Auto-rollback on test failure
- [ ] Deploy rate ≤ 10/day (or configured)
- [ ] Kill switch documented and respected
