---
name: self-improvement
description: Agent metrics, learning from code review, tuning from accepted changes, A/B testing, failure analysis, human feedback. Use for improving agent effectiveness.
---

# Self-Improvement Skill

**Context:** The framework’s primary goal is that the system improves over time, not degrades. Self-improvement supports that by metrics, learning from feedback, and tuning skills/agents.

## When to Use

- User asks for "agent metrics", "effectiveness", "improve agents", or "feedback loop".
- Monthly/quarterly review or after repeated failures.
- **Agent skipped a relevant agent/skill:** If the user points out that a task was done without using a matching agent/skill (e.g. "why was X not used?"), treat as a learning event: ensure the "use relevant agents" rule exists and is followed for **any** task that matches an agent’s scope; add to learning log if the gap was a missing rule or checklist.

## Instructions

1. **Metrics**
   - Per agent: success rate, time, error rate; store and trend.

2. **Learning**
   - From code review: accepted vs rejected; infer patterns; suggest rule/prompt updates.
   - **Automatic (no human):** Each response’s "Improvements for self-improvement" is either (a) auto-applied when small and additive (see self-learning rule) or (b) appended to `.cursor/learning-log.md`. So the system improves over time without cron or scripts.
   - For larger or ambiguous changes: document in learning log; human can say "apply learnings" to batch-apply.

3. **Apply learnings** (consumer for learning log)
   - When the user says "apply learnings" or "process learning log": (1) Read the last N entries of `.cursor/learning-log.md`. (2) Cluster repeated or related suggestions. (3) For each cluster: if small and additive, apply to the relevant skill/rule; if large or ambiguous, output a short list for human decision. (4) Optionally mark processed entries (e.g. append "processed YYYY-MM-DD" or move to an "applied" section).

4. **A/B testing**
   - Compare strategies in safe scope; measure; choose better within safety.

5. **Reports**
   - Monthly: effectiveness report per agent.
   - **Monthly (or on demand) scope-check report:** Read `.cursor/scope-check-log.md` for the last 30 days. Produce a short report: (1) Number of turns with Main only vs with agents used. (2) List of Main-only reasons (deduplicated). (3) One paragraph: trend positive or negative; suggest one change to rules or skills if needed. Optionally write the report to `.cursor/metrics/summary.md` so the last report is stored.
   - Auto-disable if success rate <70%; human re-enable after review.

6. **Quarterly**
   - Human review of learned patterns; approve before rollout.

## Safety Checklist

- [ ] Monthly report generated
- [ ] Agents <70% success disabled
- [ ] Learned patterns reviewed quarterly
