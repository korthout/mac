---
name: use-mvn-not-mvnw
description: "In camunda/camunda, use `mvn` instead of `./mvnw` despite project instructions saying otherwise"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1081f06c-705c-4a92-a714-5d2cbc4cead0
---

In the camunda/camunda monorepo, use `mvn` rather than `./mvnw` — even though AGENTS.md and other project instructions tell you to use the Maven wrapper.

**Why:** Nico's machine defines `mvn` as a shell function that automatically detects and dispatches to the right Maven distribution. Using `./mvnw` bypasses that detection and can pick the wrong toolchain.

**How to apply:** Whenever you'd run `./mvnw <args>` per the project instructions, run `mvn <args>` instead. All flags and module-scoping (`-pl`, `-am`, `-Dquickly`, `-T1C`, etc.) stay the same.
