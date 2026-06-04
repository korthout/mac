---
name: reviewing-agent-ready-prs
description: Use when reviewing a PR in camunda/camunda that touches AGENTS.md, skills under .claude/skills/, the way the project uses ADRs, or the way the project uses architecture docs (not new ADRs or architecture docs themselves) — i.e., Agent-Ready initiative PRs
---

# Reviewing Agent-Ready PRs

## Overview

Cross-team initiative in camunda/camunda where contributors review each other's PRs about *how we work with agents*. The value is **pattern consistency** across these meta-PRs — spotting when PR #5 contradicts what was agreed in PR #2.

**Core principle:** check alignment against the shared design doc and prior decisions *before* raising anything. Don't unilaterally judge — raise inconsistencies to the user.

## When to Use

In camunda/camunda, when a PR touches:
- `AGENTS.md` (root or scoped)
- Any file under `.claude/skills/` (skill definitions)
- The *way ADRs are used* — process, templates, conventions — but **not** new ADRs themselves
- The *way architecture docs are used* — but **not** new architecture docs themselves
- A proposal about Agent-Ready ways-of-working

**Out of scope:** new ADRs, new architecture docs, ordinary feature/bugfix PRs.

If you're unsure whether a PR is in scope, ask the user before reviewing (see step 1).

## Workflow

Follow these steps in order. Do not skip ahead.

1. **Confirm scope with the user.** Say: "This looks like an Agent-Ready PR — should I review it under that workflow?" Do **not** assume. Do **not** start reviewing yet. Wait for confirmation.
2. **Record the PR** in `data/agent-ready-prs.md` under *Reviewed PRs* (PR number, link, date, one-line scope).
3. **Check the shared design doc for alignment:** https://docs.google.com/document/d/1cUB363AJquRixECWDu1-1eBjrXOdUxidniYuOIg2qaQ/ — you may need WebFetch or to ask the user to summarize the relevant section if access fails.
4. **If something seems out of alignment**, check `data/agent-ready-prs.md` → *Decisions* for a prior call that explains it.
5. **If still unresolved**, search the comments and review comments of prior Agent-Ready PRs listed in the tracker. Use `curl` + the GitHub REST API (`gh` fails under the proxy on macOS; the user's global instructions document this).
6. **Raise inconsistencies to the user.** Frame as `❓` per the repo review emoji code. Do **not** silently resolve. Do **not** pre-decide. Don't post the review until the user has weighed in on the inconsistency.
7. **Record any decision** the user makes during the review back into `data/agent-ready-prs.md` → *Decisions* (dated, linked to the triggering PR).

The standard camunda/camunda review style still applies on top of this — emoji code (👍/❓/❌/🔧/💭), general-comment template, inline-comment style, nit budget. Those live in the user's project memory and are complementary, not replaced by this skill.

## Red Flags — STOP

If you catch yourself thinking any of these, you're about to violate the workflow:

| Rationalization | Reality |
|-----------------|---------|
| "This is obviously fine, I'll just review it" | Step 1 first. The scope check is the point. |
| "Diff is small, I can skip the Google Doc" | Step 3 is mandatory regardless of size. |
| "I'll flag this inconsistency directly as a `❌`" | Steps 4–5 first. It might already be decided. |
| "I'll just decide this one myself, it's minor" | Never. Raise to the user. The whole point is consistency. |
| "I'll record the PR later" | Record at the time. Later is never. |
| "User didn't ask me to follow the workflow this time" | The trigger is the PR scope, not the user's framing. |

## Quick Reference

- **Tracker file:** `data/agent-ready-prs.md` (inside this skill directory)
- **Source-of-truth design doc:** https://docs.google.com/document/d/1cUB363AJquRixECWDu1-1eBjrXOdUxidniYuOIg2qaQ/
- **First action on every Agent-Ready PR:** ask the user to confirm scope.
- **Default disposition on any apparent inconsistency:** raise as `❓` to the user, never resolve unilaterally.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Diving into a code review without confirming scope | Step 1: confirm with user first |
| Skipping the Google Doc check because the PR is small | Always check, regardless of size |
| Unilaterally judging that something is inconsistent | Check tracker decisions first, then raise to user |
| Posting the review before the user resolves an inconsistency | Block on user input for any `❓` you'd raise |
| Forgetting to record the PR or the decision | Record both at the time of review |
| Treating this as a replacement for code-review style | This workflow runs *alongside* the standard review style |
