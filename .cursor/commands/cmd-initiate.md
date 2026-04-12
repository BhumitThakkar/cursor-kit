---
description: System boot command. Type /cmd-initiate to validate the full Pantheon setup, wake Zeus, verify hooks and agents, and report anything missing before a session begins.
---

# /cmd-initiate — Pantheon System Boot

## What this command does

When invoked, run the following steps **in order**. Do not skip a step if a previous one has issues — complete all steps and report everything at the end.

---

## Step 1 — Run the boot script

From the **workspace root**, run:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .cursor/hooks/cmd-initiate.ps1
```

Capture the full output. It will contain a structured report.

---

## Step 2 — Parse and display the report

Present the script output in this format to the user:

```
PANTHEON BOOT REPORT
====================

STRUCTURE CHECK
  [PASS/FAIL per file]

HOOKS CHECK
  [PASS/FAIL per hook script]

MEMORY CHECK
  [PASS/FAIL per tasks/ file]

ZEUS STATUS
  [Ready / Issues found]

ACTION REQUIRED
  [List any missing files or failed checks with exact remediation steps]
  [or: "All systems nominal — Zeus is ready."]
```

---

## Step 3 — Zeus self-check

After the script output, Zeus must respond with the following statement (Zeus speaks in first person):

> "I am Zeus. I have read tasks/lessons.md and tasks/decisions.md.
> Active lessons loaded: [N]
> Active decisions loaded: [N]
> Incomplete tasks from previous session: [N or 'none']
> I am ready to orchestrate."

If any memory file is empty or missing, Zeus states that clearly instead of fabricating a count.

---

## Step 4 — Final status

End with one of:

- `SYSTEM READY — Pantheon is fully operational.`
- `SYSTEM DEGRADED — [N] issues found. Resolve before starting work.`
- `SYSTEM CRITICAL — Core files missing. Run remediation steps above.`
