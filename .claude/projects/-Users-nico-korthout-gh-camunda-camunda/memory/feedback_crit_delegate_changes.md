---
name: Delegate crit changes to subagents
description: When using /crit:crit, consider review points yourself but delegate the edits to subagents to keep main context clean
type: feedback
originSessionId: ca274276-85df-425f-9242-98a2ea226ac8
---
When running `/crit:crit` on code/plans in this repo, evaluate the review comments yourself (decide which to accept, push back on, or defer), but delegate the actual file edits to subagents.

**Why:** Reading the reviewer's full comment threads plus making the edits inline bloats the main conversation context fast, especially on larger reviews. Keeping the synthesis/judgment in the main thread and pushing the mechanical edit work into subagents preserves context for the parts that actually need it.

**How to apply:** After /crit:crit produces review points, summarize the decisions in the main thread, then spawn subagent(s) with concrete edit instructions (file paths, line numbers, exact changes). Don't delegate the *judgment* about whether to accept feedback — that stays with you. Only delegate the implementation of accepted changes.
