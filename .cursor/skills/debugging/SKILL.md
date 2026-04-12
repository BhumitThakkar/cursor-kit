---
name: debugging
description: Correlated log analysis, safe auto-fixes, profiling, dumps, slow queries, and confidence-scored remediation.
---

# Debugging

## When to Use

- Production or staging defect with logs but unclear root cause.
- Performance regression needing evidence before code change.

## Instructions

- Follow MDC/trace IDs end-to-end before proposing fixes.
- Auto-fix only mechanical issues (imports, formatting, obvious null guards) with team approval policy.

## Safety Checklist

- [ ] Repro steps captured for non-obvious bugs
- [ ] Benchmark or plan comparison before perf claims
