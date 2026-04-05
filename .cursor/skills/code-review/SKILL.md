---
name: code-review
description: Static analysis, security scan, code smells, performance anti-patterns, SOLID, complexity, thread safety, API compatibility, licenses. Use for review gates.
---

# Code Review Skill

## When to Use

- User asks for "code review", "static analysis", "security scan", "complexity", or "merge gate".
- Before merge or as part of CI.

## Instructions

1. **Run checks**
   - Static analysis (linter, SonarQube, etc.); security scan (OWASP/dependency check).
   - Tests and coverage; compare coverage to base branch.

2. **Enforce**
   - Security: 100% pass (no critical/high). Coverage: must not decrease.
   - Performance: if regression >5%, block and request benchmark/fix.
   - Complexity: if increase >10% or method >50 lines, flag and recommend refactor.

3. **Review for**
   - God classes, long methods, N+1, thread safety, SOLID violations, API compatibility, dependency licenses.

4. **Output**
   - Pass/fail per gate; list of issues with severity; refactor suggestions.

## Safety Checklist

- [ ] Security scan passed
- [ ] Coverage not decreased
- [ ] No method >50 lines without refactor plan
- [ ] Performance regression addressed
