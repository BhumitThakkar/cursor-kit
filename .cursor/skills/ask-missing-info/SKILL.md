---
name: ask-missing-info
description: Shared rules for asking the user clarifying questions when required information is missing, ambiguous, or contradictory before producing a deliverable. Use when the calling agent or skill has a required-inputs checklist with gaps, or when a wrong guess would change the deliverable's structure. Not for small talk or optional preferences.
---

# Ask for missing info

Shared by every agent and skill in the harness. The calling agent or skill owns **what** is required (its required-inputs checklist). This skill owns **how** to ask.

## Ask only when

- A required input is missing, ambiguous, or contradictory, **and**
- a wrong guess would change the structure or outcome of the deliverable, not just labels, wording, or layout.

Do **not** ask about: cosmetic choices, anything already stated in chat or in existing project files, or anything you can infer with high confidence (record those as assumptions instead).

## How to ask

1. **Batch.** Put all blocking questions in one message. Max 3 per round, most blocking first.
2. **User-story phrasing.** Each question reads: "As a `<role>`, I want `<goal>`. `<question>`?"
3. **Options.** Give 2 to 4 options. Mark one "(recommended)" with a one-line reason. The last option is always "You decide".
4. **Limit.** Max 2 rounds. After that, proceed and list leftovers as assumptions (see below).
5. **"You decide" or no answer:** use the recommended option and record it as an assumption.
6. Do not produce the deliverable until the first round is answered, unless the user explicitly says to proceed.
7. **Delivery.**
   - Main agent: use Cursor's ask-questions tool if available, otherwise ask in chat.
   - Subagent: you cannot talk to the user directly. Return the questions through your own return contract (defined in your agent file), then stop and wait to be resumed.

## Recording assumptions

List each as A1, A2, ... in the deliverable's Assumptions section (or in your reply if it has none), flagged for the user to confirm.

## Template

```
Before I produce the <deliverable>, I need <N> answers:

1. As a <role>, I want <goal>. <Question>?
   a) <option> (recommended: <reason>)
   b) <option>
   c) You decide
```

## Example

```
Before I produce the draft, I need 2 answers:

1. As a store owner, I want to control who can refund orders. Who may issue refunds?
   a) Support agents and managers (recommended: matches most retail setups)
   b) Managers only
   c) You decide

2. As a customer, I want to pay in the way I prefer. Is payment handled inside this system or by an external gateway?
   a) External gateway as a separate actor (recommended: keeps card handling out of scope)
   b) Inside the system
   c) You decide
```
