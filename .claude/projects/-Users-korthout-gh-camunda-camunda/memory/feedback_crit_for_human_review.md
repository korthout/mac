---
name: Crit is for human review, not agent-loop review
description: Don't have subagents use crit when I'm asking you to review changes in a loop — crit is for human-in-the-loop review
type: feedback
originSessionId: 9af71a5a-eef6-4a44-b2a2-8040ddaac1d7
---
Crit places inline review comments into `~/.crit/reviews/<id>/review.json`, which the interactive `crit` daemon loads into the user's browser. When I ask you to "review in a subagent" or "loop: review → fix → review" without mentioning crit, do NOT instruct subagents to use the `crit:crit` skill — their comments will pollute my next interactive crit session.

**Why:** The `crit:crit` skill is designed for human review; using it programmatically conflates agent feedback with user feedback in the same review file. The user saw agent comments in their browser as if they were their own.

**How to apply:**
- Default for agent review loops: have the reviewer subagent return a plain text report (file:line citations, concerns, recommendations). You judge it, then dispatch the fixer.
- Only use crit in a subagent if the user explicitly mentions crit or says they want comments visible in their crit session.
- `crit:crit-cli` (programmatic CLI) is the technical alternative if persisted inline comments are genuinely useful between agents — but still ask first; don't assume.
