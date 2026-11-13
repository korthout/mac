---
name: start-tdd
description: Drive strict Canon TDD (https://newsletter.kentbeck.com/p/canon-tdd) on a problem, one test at a time, with a durable notes file and per-commit human review.
disable-model-invocation: true
---

# Start TDD

Runs Kent Beck's Canon TDD loop strictly: write a test list, turn exactly one item into a
runnable test, change the code to make it pass, optionally refactor, repeat until the list is
empty. No grouping several test variations into one cycle. No building ahead of what the current
test forces — even when the final design already looks obvious.

## Required input

Either a GitHub issue reference (URL or `#<number>`) or a free-form description of the problem to
solve. If neither was given, ask for one and stop.

If it's an issue, fetch it fully (`gh issue view <number> --json title,body,url,comments`) and
treat its body and comments as the source of the acceptance criteria the test list maps against.
If it's a free-form description, treat that description itself as the source of the acceptance
criteria — ask the user for anything the description leaves ambiguous during the interview below.

## Orchestrator discipline

You are the orchestrator. You never read or write code yourself — every codebase lookup, every
test, every production-code change is done by a subagent you spawn and instruct. Your own context
is for judgment, synthesis, and running the interview and the loop.

Model tier per subagent (you, the orchestrator, keep whatever model the session is already on;
don't downgrade yourself):
- Locate-only lookups ("where is X defined", "which files reference Y") → **Haiku**
- Codebase analysis / grounding research, test writing, and implementation → **Sonnet**
- Opus for a subagent is an escape hatch, not a default — only reach for it if a specific subagent
  task turns out to genuinely need stronger reasoning.

## The notes file

All decisions get written to `notes-<slug>.md` at the **repo root** — not a scratchpad. `<slug>`
comes from the issue title or the problem description. It must never be committed: it's an
untracked local file (not gitignored, so it shows up in `git status`); stage other files
explicitly by path, never `git add -A`/`.`. Tell the user this the first time you create it.

Unlike a plan file, this is not written once and then executed — it's a live record that grows
throughout the loop:
- **Vocabulary** and **Grounding** don't need to be complete at the start. Add to them as the loop
  surfaces new facts or naming.
- **Test list** is checked off live, and new items get appended in place when a cycle surfaces one.
- **Decisions log** grows one entry per decision made along the way — including the "obvious"
  calls you make yourself (see "Obvious choices" below). Write enough for each entry to be reused
  verbatim as input to a commit message, a PR description, or an ADR later.

Use this template:

````markdown
# TDD Notes — <short title>

> ⚠️ **Do NOT commit this file.** Untracked local file in the repo root. Never `git add` it;
> stage files explicitly by path rather than `git add -A`/`.`.

## Vocabulary

[Terms this problem area already uses in the codebase — reuse them rather than inventing parallel
ones. Grow this as the loop surfaces more of the codebase. Coin a new term only when the problem
genuinely introduces a new concept, and say plainly that it's new.]

## Grounding

[Facts confirmed by delegated research subagents — existing behavior, test infra to reuse,
precedent to follow. State facts, not assumptions. Grows during the loop, not just up front.

Watch for over-specifying: if a grounding fact already fixes the implementation's exact final
shape before any test has run, that's a signal the test list should be reordered so an earlier
item's minimal-to-pass implementation is narrower than the final shape, and a later item is the
one that forces generalization — not a reason to build ahead of the current test.]

## Test list

[A checklist of test scenarios, one per expected behavior variant — not paired with how each
turns green, not in a fixed execution order. Items describe *behavior* to assert, never which
production class/method implements it. Live source of truth: check items off, append newly
discovered ones in place.]

- [ ] ...

## Decisions log

[One entry per decision — including test-location choices made just before starting a test, and
any call you made yourself because it was obvious. Written so it can be reused verbatim in a
commit message, PR description, or ADR.]
````

## Process

1. Get the input (issue or free-form description).
2. Delegate grounding research to subagents (Haiku for locate, Sonnet for analysis) to confirm
   what already exists in the codebase relevant to this problem, and the vocabulary the area
   already uses.
3. Create `notes-<slug>.md` with what's known so far.
4. Interview the user (see "Test list interview" below) to build the test list. Flag any test that
   looks costly (needs a real cluster, container, external system, long-running setup) and let the
   user decide whether to include it, rather than deciding silently.
5. Run the loop (see "The loop" below) until the test list is empty.
6. Throughout, suggest opening a PR (draft, targeting the relevant parent branch) at points where
   it makes sense — often one PR is enough, but split into smaller stacked PRs when that would
   make review easier. This is a judgment call each time, not a fixed rule.

## Test list interview

Interview the user to fill in Vocabulary, Grounding, and Test list in the notes file. Same spirit
as the `grill-me` skill: ask one question at a time, wait for the answer, recompute what's still
open. Cover:
- Does the grounding research already fix the implementation's final shape? If so, flag it and
  discuss reordering the test list rather than silently building ahead (see the note in the
  template above).
- What's the full set of behaviors to cover, without redundant tests?
- Which candidate tests are costly, and should they be included?
- Anything the problem description leaves ambiguous.

**Obvious choices:** when a choice is obvious, make it yourself, tell the user, and log it in the
decisions log — don't turn every micro-decision into a question. Grilling is for alignment on
real decisions, not for busywork.

If a decision looks architectural, follow this repo's existing rule (`AGENTS.md`) to draft an ADR
via `create-architecture-decision` — use the decisions log as its input.

## The loop (Canon TDD, strict)

Repeat until the test list is empty. Never group multiple test-list items into one cycle, and
never implement more than the current test forces — even if the grounding notes already show the
full design. Test location (file, unit vs. integration) is decided now, just before writing the
item's test — not earlier.

1. **Pick the next test.** Suggest a few good candidates from the test list with your
   recommendation and why; the user picks. Log the choice and reasoning in the decisions log.
2. **Red.** Delegate writing the failing test to a subagent. Once committed, check the diff
   yourself against what you expected and adjust if needed. Then the user reviews. Delegate any
   changes the review calls for; repeat until approved. This is the **red** commit.
3. **Green.** Delegate the smallest production-code change that makes this test pass — never
   "build the full design already known to be needed." Once committed, check the diff yourself and
   adjust if needed. Then the user reviews. Delegate any changes the review calls for; repeat until
   approved. This is the **green** commit.
4. **Refactor (optional).** If the implementation now warrants refactoring, delegate it as its own
   commit, same check → review → adjust cycle as above. Skip if there's nothing to improve.
5. Check off the picked item. If the cycle surfaced a new scenario, append it to the test list. If
   it invalidates a prior cycle's work, decide with the user whether to push on or revisit that
   cycle, and log the decision.
6. Go to 1.

## Commit workflow

- Commits stay small and individually reviewable — one per red, green, or refactor step.
- Every commit must compile on its own — no "fix typo from 3 commits ago" follow-ups.
- Structural/refactoring changes are separated from behavioral changes into distinct commits.
- Decisions worth remembering go in the notes file's decisions log, and from there into commit
  messages and/or the PR description — not just left in chat.
