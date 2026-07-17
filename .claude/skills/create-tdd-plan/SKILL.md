---
name: create-tdd-plan
description: Plan test coverage and the TDD workflow for a GitHub issue through a grill-me interview, then produce an execution-ready plan doc (grounding, test locations, red/green steps, PR breakdown, review gates, task-list bookkeeping) at the repo root. Use when asked to plan a TDD implementation, plan which tests to add for an issue, or scope out test coverage before writing code.
---

# Create TDD Plan

Plans **what to test and in what order**, never **what production code to write**. The plan this
produces stays a test/behavior spec; implementation is left free to refactor.

## Required input

A GitHub issue reference (URL or `#<number>`) is mandatory. If none was given, ask for one and stop
— do not fall back to an ad hoc description.

Fetch the issue fully (`gh issue view <number> --json title,body,url,comments`) before doing anything
else; treat its body and comments as the source of the acceptance criteria this plan will map tests
against.

## Orchestrator discipline

You are the orchestrator. You never read code yourself — every codebase lookup is done by a
subagent you spawn and instruct. Your own context is for judgment, synthesis, and running the
interview only. During *this* planning run, that means grounding research only (locate + analyze);
no test or implementation code exists yet to write. The same never-write-code-yourself rule also
governs whoever later *executes* the plan this skill produces (see "Executing this plan" in the
template below) — that's where test-writing and implementation subagents come in.

Model tier per subagent (you, the orchestrator, keep whatever model the session is already on —
usually Opus; don't downgrade yourself):
- Locate-only lookups ("where is X defined", "which files reference Y") → **Haiku**
- Codebase analysis / broader grounding research (how does existing code behave, what test infra
  already exists) → **Sonnet**
- Test writing and implementation, both red-state and green-state, during plan *execution* →
  **Sonnet**
- Opus for a subagent is an escape hatch, not a default — only reach for it if a specific subagent
  task turns out to genuinely need stronger reasoning.

## Completion rule

Do not write the plan file until every interview-driven section below has a resolved answer. No open
questions. If you're unsure whether something is resolved, ask — don't guess and don't finalize.

## Process

1. Fetch the issue (above).
2. Delegate grounding research to subagents (Haiku for locate, Sonnet for analysis) to confirm what
   already exists in the codebase relevant to this issue — existing fields, test infra, prior art,
   naming/legacy issues worth a good-scout fix.
3. Invoke the `grill-me` skill to interview the user through the **interview-driven sections** in
   the template below. Pass it this framing as its argument: "Plan the test coverage and TDD
   workflow for [issue reference]. Fixed constraints: the plan must not name production classes or
   methods to change — only the behavior/spec and the tests that cover it. Resolve, in order:
   Grounding, Out of scope, Test locations, TDD workflow steps, whether this needs multiple PRs (and
   if so how they split), and the AC-to-coverage mapping."
4. Once every section is resolved (completion rule above), write the plan to
   `plan-<issue-number>-<slug>.md` at the **repo root** — not a scratchpad. It needs to survive
   across sessions and show up in `git status` for standalone review. Use the template below.
5. Tell the user the file is untracked and must never be staged with `git add -A`/`.` — stage other
   files explicitly by path.

## Plan template

Fixed boilerplate sections below are copied as-is. Interview-driven sections carry a `[placeholder]`
describing exactly what content goes there and where — resolve those through the grill-me interview,
not by guessing.

````markdown
# TDD Plan — #<issue-number>: <short title>

**Scope of this plan:** test coverage + TDD workflow. Production classes are intentionally
not named — tests describe *behavior*, implementation stays free to refactor.

> ⚠️ **Do NOT commit this file.** It is an untracked local planning file in the repo root (not
> gitignored, so it appears in `git status`). Never `git add` it; stage files explicitly by path
> rather than `git add -A`/`.`. It must not appear in any PR diff.

## Executing this plan (keep context small)

- **Delegate everything to subagents; keep the main thread for judgment.** The orchestrator never
  reads or writes code directly — subagents locate code, gather grounding facts, write the failing
  tests, and implement to green. Model tier: Haiku for locate-only lookups, Sonnet for analysis and
  all test/implementation work; Opus is the orchestrator's own tier, not a subagent default.
- **One PR per fresh session.** Each PR is single-concern; this file is the durable handoff. Start a
  clean session, load only this plan + the one PR's slice, take it through both review gates, end
  the session.

## Task list — self-serve (resume here after any context clear)

[Interview-driven: one entry per PR decided during the PR-breakdown discussion below. Even a
single-PR plan gets one entry. Use this exact row shape per PR:]

- [ ] ⏸ tests reviewed  ·  [ ] ⏸ diff reviewed  ·  [ ] done → draft PR: <link>
  (Notes: deviations from this plan, or things noticed during test-writing/implementation that
  matter for a later step — fill in as they happen, leave blank until then.)

**Protocol for whoever executes this list:**
- On start, find the **first PR whose `done` is unchecked** — that is the PR to work. Ignore later
  PRs.
- Branch off the **previous PR's branch** (the one above it in this list), not `main` — except the
  first PR in the stack.
- Never tick a **⏸ gate** yourself — the human ticks it after reviewing. Stop at an unchecked gate.
- Sequence within a PR:
  1. Write the failing tests (delegate to a subagent), commit → stop at `⏸ tests reviewed`,
     summarize the test list, wait.
  2. After it's ticked, implement to green (delegate to a subagent) → stop at `⏸ diff reviewed`,
     summarize, wait.
  3. After it's ticked, open the PR as a draft targeting the parent branch, check `done`, stop.
- **Mid-PR resume:** if `tests reviewed` is ticked but `done` is not, the red tests are already
  committed on the branch — check it out and resume at step 2, don't rewrite the tests.

## Grounding (confirmed in codebase)

[Interview-driven: facts confirmed by delegated research subagents — existing fields/behavior this
plan builds on, existing test infra to reuse, precedent to follow. State facts, not assumptions.]

## Out of scope (flag in PR description)

[Interview-driven: deliberate gaps — behavior intentionally not covered by this plan's tests, with
the reason. These get called out in the PR description so reviewers don't file them as bugs.]

## Test locations

[Interview-driven: table below, one row per test/test-group]

|  Test  |  File  |  Level  |
|--------|--------|---------|
| ... | ... | ... |

## TDD workflow (red → green per step)

[Interview-driven: numbered steps, each naming the red state and what turns it green. Steps should
describe *behavior* to assert, never which production class/method implements it.]

## Human review gates (per PR, before it leaves the machine)

1. **Red-state gate:** once the PR's failing tests are written (but not yet green), pause for human
   review of the test list — the assertions and case coverage — before implementing. Cheapest point
   to catch a wrong assertion.
2. **Green-state gate:** after tests pass and the build is green, pause for human review of the full
   local diff/commits. Address feedback, then open the PR.

## PR breakdown (stacked, each independently green)

[Interview-driven: only if the interview concluded this needs multiple PRs. One paragraph per PR:
its scope, why it's split from its neighbors, and its dependency on the PR before it. No
commit-by-commit enumeration — that's decided live, per the commit workflow below.]

## Commit workflow

Applies when executing any PR in the task list above:
- Commits stay small and individually reviewable.
- Every commit must compile on its own — no "fix typo from 3 commits ago" follow-ups.
- Structural/refactoring changes are separated from behavioral changes into distinct commits.

## AC → coverage map

[Interview-driven: one line per acceptance criterion from the issue, pointing at the test(s) that
cover it. Anything without a test here is either in "Out of scope" above, or a gap to go fix.]
````
