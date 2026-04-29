---
name: reproduce_bug
description: Produce a deterministic local reproducer for a bug described by the user. Use when the user shares an incident, bug report, or behavior description and wants to reproduce it locally. Output is a reproducer (test or script) for later root-cause analysis — RCA itself is out of scope.
---

# Reproduce Bug

Turn a bug description into a deterministic, locally runnable reproducer. Stop once one exists — or once you've established it can't be built. Don't propose or apply fixes; don't do RCA beyond confirming the failure mode matches.

## Phase 0: Redact

If the description contains production data (customer IDs, tokens, emails, IPs, hostnames, connection strings), stop and ask the user to scrub it — or flag exactly which fields are sensitive if it's already shared. Class/method/component names and line numbers are safe.

## Phase 1: Understand the report

Extract: expected behavior, actual behavior, reproduction steps, environment (versions, config), and scope (one-off vs consistent, timing-sensitive vs deterministic). If a load-bearing detail is missing, ask one targeted question rather than guessing.

## Phase 2: Pick the smallest viable reproducer

Detect project conventions first — read `CLAUDE.md` / `AGENTS.md` / `README` and locate similar existing tests in the relevant module. Reuse the project's test framework and harnesses; don't introduce new ones.

If the report names a version or commit, anchor to it (check it out, or pin the dependency) before building the reproducer. Reproducing against `main` risks a passing run because the bug was already fixed there.

Prefer in order:

1. Existing test harness (integration or unit test modeled on a similar one).
2. Script using the project's API or client library.
3. Full application setup — only if genuinely required.

You may deviate from the reporter's exact steps (API instead of UI, client instead of curl) if it produces the same observable outcome with less setup. The reproducer must demonstrate the bug, not mirror the report.

## Phase 3: Build, run, verify

Run the reproducer and confirm it fails *for the reason described*, not just that it errors. A wrong-reason failure (bad setup, missing dep, unrelated assertion) is not a reproducer — fix the setup until the failure mode matches.

Assert the *expected* behavior, not the observed buggy behavior — so applying the future fix flips the test from red to green. A reproducer that asserts the bug will pass forever, including after the fix.

Run it 3+ times. Inconsistent failures aren't disqualifying — note the failure rate and flag the reproducer as flaky in the report.

Once it fails reliably for the right reason, minimize: strip setup, fixtures, and steps until removing more changes the failure mode. Smallest surface area is the best handoff for RCA.

The reproducer is meant to fail. Place it in the project's test tree alongside similar tests (not a scratch file outside it), and don't add skip/disable annotations (`@Disabled`, `@Ignore`, `xfail`, `.skip`, `it.skip`) to keep CI green — a failing reproducer blocking merge is the artifact, not a problem to route around.

## Phase 4: Stop and report

Stop on one of:

1. **Reproduced** — deterministic failure matching the report. Report file path, how to run, observed failure, and any assumptions (e.g. "used Java client instead of UI").
2. **Cannot reproduce** — after the described path plus 1–2 reasonable variations, behavior matches expected. Report what was tried, what was observed, and possible explanations (already fixed / environment-specific / misdescribed) without committing to one.
3. **Blocked** — a specific missing detail or unavailable resource. Ask the user one targeted question; don't guess and keep trying.

Discipline: two failed reproduction attempts → escalate. Reproducing is bounded — if it's not working, the description, code, or environment is the reason, and the user needs to weigh in.
