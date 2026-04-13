# Lessons

## 2026-04-12 — Config removal must follow the full chain

**What happened:** Removed `cursor-noop.ps1` and `on-task-close.ps1` from `hooks.json` but left the script files on disk and stale references in 6 other files (`tool-registry.mdc`, `zeus-pm.md`, `hooks/README.md`, `memory.mdc`, `folder-structure.md`, `cmd-initiate.ps1`, `lessons-summarizer/SKILL.md`). User caught the drift.

**Root cause:** Treated the hooks.json edit as the whole job. Did not grep for all references to the deleted items before declaring done.

**Prevention rule:** When removing any config artifact (hook, agent, skill, rule), always: (1) delete the file, (2) remove the registry row, (3) `grep` the entire `.cursor/` directory for the filename and any aliases, (4) update every hit, (5) update `folder-structure.md`. Do not ask the user whether to clean up — just do it.

**Applies to:** Zeus / Config Manager / all agents

---

## 2026-04-12 — Write the lesson when you say you will

**What happened:** ZEUS BRIEF said "this cleanup pattern is a real lesson" and listed `tasks/lessons.md` under Memory, but no lesson was actually written. The Memory additions line even said "No." User caught the contradiction.

**Root cause:** Noted the lesson mentally but did not act on it in the same turn. The ZEUS BRIEF became a statement of intent rather than a record of action.

**Prevention rule:** If the ZEUS BRIEF says a lesson should be written, write it in the same turn — before emitting the brief. If you cannot formulate the lesson yet, say "pending" in the brief and write it next turn. Never say "Yes" on Memory additions without having actually written the content.

**Applies to:** Zeus

---

## 2026-04-12 — Honor-system rules need enforcement points

**What happened:** `memory.mdc` said "write lessons after corrections" and `zeus-pm.md` had a Memory additions field in the ZEUS BRIEF — but both were self-reported with no verification. Zeus could skip lesson-writing and no gate caught it. The user had to catch it twice.

**Root cause:** The lesson-writing rule existed only as a guideline in a table. The self-review checklist in `zeus-pm.md` checked tone, classification, roster, and brief format — but had no item for "did I write a lesson when corrected?" No enforcement = no compliance.

**Prevention rule:** Any rule that depends on Zeus self-discipline must have a matching self-review checklist item in `zeus-pm.md` AND a non-negotiable line in `zeus-pm.mdc`. Both were added: (1) a "Lesson gate" checklist item that Zeus must verify before emitting the ZEUS BRIEF, and (2) a non-negotiable that Memory additions = Yes requires content already written to disk.

**Applies to:** Zeus / system design
