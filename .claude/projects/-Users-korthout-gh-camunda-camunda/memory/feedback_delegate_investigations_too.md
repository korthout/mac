---
name: delegate-investigations-too
description: Delegate CI/log/codebase investigations to subagents (not just fixes) but judge conclusions yourself before acting
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f8856078-ed4b-4038-98e3-b54e2ab64aae
---

Delegate investigations to subagents — not just fixes. Reading CI logs, grepping codebases, tracing failures, sifting through dumps: all good subagent work. Keep judgement of *what the findings mean* and *what to do next* in the main thread.

**Why:** Same reasoning as [[feedback_crit_delegate_changes]] — subagents save context on mechanical reading/grepping. But the user is the one responsible for the call, so I shouldn't outsource the *judgment* — only the *gathering*.

**How to apply:**
- When triaging multiple CI failures, dispatch one subagent per failure (or one for all) to extract: failing test, error message, suspected root cause, and pointers to relevant files. Have them report findings, not "and here's the fix."
- When a subagent suggests a fix, read it critically — don't relay verbatim. Decide whether it's correct, whether the framing matches the user's plan, whether it requires raising with the user.
- Still do quick read-only investigations inline when they're under ~3 tool calls — delegation overhead isn't worth it for tiny lookups.

Pairs with [[feedback_crit_delegate_changes]] (delegate edits) and [[feedback_cancel_stale_verifiers]] (manage subagent lifecycle).
