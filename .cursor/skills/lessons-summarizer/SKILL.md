---
name: lessons-summarizer
description: >-
  Zeus-oriented read of tasks/lessons.md: cluster themes, surface duplicate prevention rules, and
  suggest consolidations. Default read-only; appends digest only with explicit user consent.
---

# Lessons summarizer

## When to Use

- Periodic hygiene (e.g. weekly) on **`tasks/lessons.md`** (workspace root).
- When stubs without prevention rules have accumulated — merge into real lessons or delete.
- Before archiving a milestone: extract durable prevention rules for `tasks/decisions.md` if appropriate.

## Default mode: read-only

1. Read `tasks/lessons.md` (and optionally `tasks/decisions.md` for context).
2. Group entries by **theme** (e.g. secrets in repo, missing `@Valid`, hook failures).
3. List **duplicate or near-duplicate prevention rules** with section references (heading + date).
4. Output **recommended actions**: merge pairs, supersede with a stronger rule, or delete empty stubs (list paths/lines only — **do not delete** unless user confirms).

## Optional mode: append digest (requires explicit consent)

If the user clearly asks to **append** a digest (e.g. “append a digest to lessons.md”):

1. Append a single new section at the **end** of `tasks/lessons.md`:

   `## YYYY-MM-DD — Lessons digest (manual)`

2. Include: theme bullets, proposed merges, stubs to remove (checkbox list).
3. Never remove historical lessons without human confirmation (`memory.mdc` — prefer supersede, not delete).

## Output contract (chat)

- **Themes** — bullet list with counts.
- **Top prevention rules** — up to 5 strongest, deduplicated.
- **Stubs** — list of `Session close (auto)` sections still `_TBD_` with recommendation keep/remove.
- **Suggested `tasks/decisions.md` lines** — optional, one paragraph max.

## Status

Registered in `tool-registry.mdc`; mark **`active`** after first real summarization run.
