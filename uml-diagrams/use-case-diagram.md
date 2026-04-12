---
title: Use case diagram
updated: "2026-04-11"
scope: Placeholder — regenerate with /cmd-uml-diagrams from roles and primary features.
---

# Use case diagram

> **Note:** “User diagram” in UML usually means **use case** (actors + goals). If you need personas only, extend Evidence and add a journey in `flow-diagram.md`.

```mermaid
flowchart TB
  subgraph System["System boundary — name after main app"]
    UC1[Browse or landing]
    UC2[Core action — rename from routes]
  end
  Actor[Primary actor — rename from security roles]
  Actor --> UC1
  Actor --> UC2
```

## Evidence

- _None — template until `/cmd-uml-diagrams` is run._
