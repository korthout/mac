---
name: create-tdd-plan
description: Plan a GitHub issue's TDD test coverage and workflow through a grill-me interview.
disable-model-invocation: true
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
- Red-state review of freshly-committed failing tests (see "Sequence within a PR") → **Sonnet**
- Opus for a subagent is an escape hatch, not a default — only reach for it if a specific subagent
  task turns out to genuinely need stronger reasoning.

## Completion rule

Do not write the plan file until every interview-driven section below has a resolved answer. No open
questions. If you're unsure whether something is resolved, ask — don't guess and don't finalize.

## Vocabulary

Write the plan in the codebase's own words. Before naming anything, find what the codebase already
calls it — a sibling store, an adjacent field, the surrounding javadoc — and reuse that term. Have a
grounding subagent report the existing vocabulary for the area, not just its behavior.

A plan that needs a glossary is a plan that imported vocabulary it didn't need. Coin a new term only
when the plan genuinely introduces a new concept, and say plainly that it's new.

Applies to the plan's prose and to any names it suggests. When the plan describes something built by
analogy to existing state or behavior, mirror the existing naming shape rather than inventing a
parallel one.

## Process

1. Fetch the issue (above).
2. Delegate grounding research to subagents (Haiku for locate, Sonnet for analysis) to confirm what
   already exists in the codebase relevant to this issue — existing fields, test infra, prior art,
   naming/legacy issues worth a good-scout fix, and the vocabulary the area already uses (see
   "Vocabulary").
3. Invoke the `grill-me` skill to interview the user through the **interview-driven sections** in
   the template below. Pass it this framing as its argument: "Plan the test coverage and TDD
   workflow for [issue reference]. Fixed constraints: the plan must not name production classes or
   methods to change — only the behavior/spec and the tests that cover it. Resolve, in order:
   Grounding, Out of scope, Test locations, Test List, whether this needs multiple PRs (and
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
- Sequence within a PR — Canon TDD (https://newsletter.kentbeck.com/p/canon-tdd), cycled against the
  plan's **Test List** until it's empty, with no human checkpoint between cycles:
  1. Pick the next item off the Test List — one by default. A small group of trivially-related
     variations (e.g. three boundary values on the same case) may be picked together only when
     splitting them adds no review value; note the grouping and why in the task-list row's Notes.
  2. Write the failing test(s) for the picked item(s) (delegate to a subagent), commit — the **red**
     commit.
  3. Implement to make it/them pass (delegate to a subagent), commit — the **green** commit. Do not
     refactor here — make it pass, then make it right.
  4. If the implementation now warrants refactoring, do it as its own commit — the **refactor**
     commit. Skip if there's nothing to improve.
  5. Check off the picked item(s) on the Test List. If the cycle surfaced a new scenario, append it
     to the list. If it invalidates a prior cycle's work, decide whether to push on or restart that
     cycle — record the decision and why in the Notes.
  6. Go to 1 until the Test List is empty.
  7. Red-state review: spawn 5 subagents in parallel (Sonnet), one per lens — AC coverage (every AC
     row has a test), scope adherence (behavior-only, respects "Out of scope"), red-state
     correctness (each red commit failed at the time for the intended reason, not a fixture/compile
     bug), test hygiene/convention (repo `AGENTS.md` testing conventions), commit message quality
     (repo commit guidelines). Run once, over the full red/green/refactor sequence from steps 1-6.
     Triage every finding yourself: delegate clear-cut fixes to a subagent — amend the relevant
     commit or add a new one, per the global amend-vs-new-commit rule (same intent → amend,
     different intent → new commit). Not confident it's clear-cut? Carry it forward unresolved
     instead of fixing it.
  8. Stop at `⏸ tests reviewed`, summarizing the (now fully checked-off) Test List plus any findings
     carried forward unresolved from step 7 — this doesn't add a new gate, it feeds the existing one.
  9. After it's ticked, stop at `⏸ diff reviewed` for human review of the implementation/refactor
     commits, summarize, wait.
  10. After it's ticked, open the PR as a draft targeting the parent branch, check `done`, stop.
- **Mid-PR resume:** if no gate is ticked yet, resume the loop (steps 1-6) at the first unchecked
  Test List item — earlier cycles' red/green/refactor commits are already on the branch, don't
  rewrite them. If `tests reviewed` is ticked but `done` is not, the whole loop already finished and
  passed red-state review — nothing left to implement; resume by waiting for `⏸ diff reviewed`.

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

## Test List (Canon TDD — checked off live during execution)

[Interview-driven: a checklist of test scenarios, one per expected behavior variant — not paired
with how each turns green, and not in a fixed execution order; picking the next item and grouping
trivially-related variations is an execution-time decision (see "Sequence within a PR"). Items
describe *behavior* to assert, never which production class/method implements it. Execution checks
items off and appends newly discovered ones in place, so this section is the live source of truth
for what's done and what's left — not a static spec.]

- [ ] ...

## Human review gates (per PR, before it leaves the machine)

1. **Red-state gate:** once the PR's failing tests are written, committed, and through red-state
   review (see "Sequence within a PR"), pause for human review of the test list plus any findings
   carried forward unresolved — the assertions and case coverage — before implementing. Cheapest
   point to catch a wrong assertion.
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
