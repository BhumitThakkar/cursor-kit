---
name: debugging
description: Log correlation, stack trace analysis, anomaly detection, safe-pattern auto-fix, profiling, heap/thread dumps, query optimization, memory leaks, fix confidence. Use for diagnosing bugs.
---

# Debugging Skill

## When to Use

- User reports bug, exception, or performance issue; or asks for "root cause", "debug", or "profile".
- Investigating failure or regression.

## Instructions

1. **Gather**
   - Logs (with correlation ID); stack trace; metrics before/after; deploy/config changes.

2. **Analyze**
   - Follow trace to first failure; distinguish root cause from symptom.
   - Use heap/thread dumps for OOM/deadlock; EXPLAIN for slow queries.

3. **Fix**
   - **Safe patterns only** (null check, import, format): apply with high confidence.
   - **Risky or unknown**: create ticket with reproduction steps; add logging/tracing; do not auto-apply.

4. **Performance**
   - Benchmark before and after; document; get review before deploy.

5. **Confidence**
   - High: safe pattern, apply. Low: ticket + steps + logging.

## Safety Checklist

- [ ] Auto-fix only for known safe patterns
- [ ] Unknown bugs get ticket + reproduction
- [ ] Performance fixes benchmarked
