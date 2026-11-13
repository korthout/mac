---
name: review-triage
description: Helps decide how much time a PR review deserves and where to aim it.
disable-model-invocation: true
---

# Review Triage

This skill is a dispatcher. The full workflow — the reviewability gate, the cheap-zone licence,
domain delegation, residual extraction, budget, and output format — lives in the `review-triage`
agent (`~/.claude/agents/review-triage.md`), which also owns its reference
files at `~/.claude/agents/review-triage/`.

Dispatch the request to the `review-triage` agent via the Agent tool, passing through the PR
reference (link or number, and repo if given) verbatim.

**Output the agent's full result to the user verbatim, unedited, in the same message where you
report completion.** Do not summarize, condense, or select highlights from it — every section
(What it achieves, What it changes, Verdict, Review time budget, Aim here, and all Evidence
subsections) goes to the user exactly as the agent wrote it. This applies even when the result
arrives via an async task notification: paste it through in full rather than writing your own
summary of it.

**Learning fallback.** The agent records dangers, cheap zones, and observations as part of a
full triage run, but it isn't re-invoked just to take a note. If later in this conversation you
learn something that should update those files per the agent's Learning section — a new danger,
a demoted cheap zone, a third clean observation warranting a promotion question — the agent has
already returned and won't pick it up on its own. Edit the relevant file under
`~/.claude/agents/review-triage/` directly rather than re-invoking the agent,
which would restart a full triage from Step 0.
