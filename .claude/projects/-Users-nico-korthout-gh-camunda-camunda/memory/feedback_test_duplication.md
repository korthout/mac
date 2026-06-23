---
name: test-duplication
description: Tests should favor readability over DRY — duplication in test code is acceptable and often preferred
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c1adab20-a9fa-45b6-8d71-f7da0661f7cc
---

**Rule:** Do not apply DRY to test code the same way as production code. Prefer explicit, self-contained tests over shared abstractions that require reading other code to understand a single test.

**Why:** Good production code is well-factored; good test code is _obvious_ (mtlynch.io/good-developers-bad-tests/). Tests are diagnostic tools — when a test fails, the reader must understand it without hunting through `setUp()` methods, helper chains, or shared constants. Eliminating duplication in tests often trades away that diagnostic clarity. The user has reinforced this: accepting redundancy is correct when it supports simplicity.

**How to apply:** Inline setup logic directly in the test body rather than extracting it to helpers. Copy-paste setup across tests rather than abstracting it. Use literal "magic" values instead of named constants when the value itself is what matters. Only extract to a helper when the code is truly irrelevant boilerplate (e.g., constructing an object whose fields don't affect the scenario under test) — and never let helpers interact with the object being tested or hide values that determine the test's outcome.
