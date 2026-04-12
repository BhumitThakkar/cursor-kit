---
title: Flow diagram
updated: "2026-04-11"
scope: Placeholder — regenerate with /cmd-uml-diagrams for one primary business or request flow.
---

# Flow diagram

```mermaid
flowchart TD
  Start([Start]) --> Step1[Step — infer from code]
  Step1 --> Decision{Branch?}
  Decision -->|Yes| Ok[Happy path]
  Decision -->|No| Err[Error handling]
  Ok --> End([End])
  Err --> End
```

## Evidence

- _None — template until `/cmd-uml-diagrams` is run._
