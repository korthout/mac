---
name: review-triage
description: Use when deciding how deeply to review a PR, which reviewers to involve, or whether to accept a large agentic PR
---

# Review Triage

## Data Gathering

Before doing anything, look up basic details about the PR. If you don't know yet which PR to triage, ask the user to provide a link or PR identifier.

## Overview

Match review effort to consequence. Treating all PRs identically wastes capacity on low-risk changes and underserves high-risk ones.

**Core principle:** Three variables determine the right review stack — blast radius, code lifespan, and team size — not diff size.

## Triage Inputs

| Variable | Low end | High end |
|----------|---------|----------|
| **Blast radius** | Config tweak, docs, dev-only | Payment path, auth, data migration |
| **Code lifespan** | Throwaway script, one-off demo | Long-lived, maintained system |
| **Team size** | Solo, no users | Multi-team, production users |

## Pre-Review Intake

**Require before accepting a PR for review:**
1. Stated purpose of the change
2. Reasonably-sized diff (reject sprawling changes upfront)
3. Test output proof (attached or linked)
4. Confirmation it actually ran

Agent PRs average 51% larger than human submissions. Reject or chunk oversized diffs — they get rubber-stamped or generate low-value back-and-forth.

## Review Tier Selection

| Risk | Signals | Stack |
|------|---------|-------|
| **Low** | Config, docs, no-op refactor, solo/dev-only | Linter + quick glance |
| **Medium** | Feature addition, test changes, library upgrade | Type check + tests + one AI reviewer |
| **High** | Payment path, auth, data migration, production multi-team | Type check + tests + dual AI reviewers + domain owner + security pass |

## Reviewer Stack (High-Risk PRs)

Use **heterogeneous reviewers** — each catches different problem classes.

Data point: across 146 PRs, 93.4% of issues were caught by exactly one of four AI tools. Reviewer diversity beats single-tool depth.

**Dual-model pattern:** Pair one reviewer calibrated for everyday correctness with one calibrated for production-severity failures. Adversarial coverage surfaces bugs no single reviewer detects.

**Caution:** Faster agent output does not reduce review load — it increases it. Maintain reviewer headcount even as generation speed improves.

## Red Flags → Extra Scrutiny or Reject

| Signal | Why it matters |
|--------|---------------|
| Large test rewrites | Agent likely rewrote tests to match broken behavior rather than catching failures |
| Removed tests or skipped linting | Deterministic gates were lowered — CI cannot be negotiated with |
| Degraded coverage thresholds | Deterministic gates lowered — treat as regression |
| Untrusted input flowing to LLM calls | Prompt injection vulnerability |
| Duplicate helpers (existing elsewhere) | Agent didn't search before creating; signals weak codebase awareness |
| No intent capture / no decision log | Reviewer is first human to see code with no context for why it exists |

**Read test changes before code changes.** Test rewrites are a leading indicator of substantive behavioral changes being hidden.

## Intent Capture

Require agents to attach a decision log stating:
- What was attempted
- What alternatives were ruled out
- Why this approach was chosen

This recovers the "missing reasoning" problem — reviewers otherwise reconstruct intent from diffs alone.

## Human Gates

| Decision | Human role |
|----------|-----------|
| "Should this change exist?" | Always human |
| High blast-radius merge | Human-in-loop (review every merge) |
| Intent alignment ("is this what we asked for?") | Always human |
| Accountability when production breaks | Human-owned |

**Human-on-loop (low risk):** Spot-check and audit the system. Sample diffs rather than reviewing every one.

**Human-in-loop (high risk):** Review every merge. Own the merge decision.

## PR Size & Split Analysis

Always compute the diff size. Only surface a split-suggestions section in the output if the diff crosses the threshold below — for smaller diffs, do this check silently and move on (do not mention it in the output).

**Step 1 — Compute total changed lines (additions + deletions):**

```bash
gh pr view <PR_NUMBER> --repo <owner>/<repo> --json additions,deletions
```

Sum `additions + deletions`. This is the same count GitHub's UI shows and is the source of truth. If `gh` isn't available or the PR isn't on GitHub, fall back to:

```bash
git diff --stat <base>...<head>   # after fetching both refs locally
```

**Threshold:** total changed lines > 1000 → run Step 2 and include the split-suggestions section in the output. Total changed lines ≤ 1000 → stop here; the split-suggestions section is omitted entirely (no header, no "N/A", no mention).

**Step 2 — If over threshold, analyze the diff for logical splits.** Pull per-file stats to reason about structure:

```bash
gh pr diff <PR_NUMBER> --repo <owner>/<repo> > /tmp/pr.diff   # full patch
gh api repos/<owner>/<repo>/pulls/<PR_NUMBER>/files --paginate \
  --jq '.[] | "\(.additions+.deletions)\t\(.status)\t\(.filename)"'
git log --oneline <base>..<head>                              # commit boundaries, if cloned locally
```

Group the changed files using real signals, not arbitrary line-count buckets:
- **Separate top-level directories/modules** — e.g. `frontend/` vs `backend/`, or distinct service packages that don't share call paths
- **Generated/vendored vs hand-written** — lockfiles, generated clients, `dist/`, `*.g.dart`, snapshot files vs code a human actually wrote; generated diffs add bulk without adding review risk
- **Refactor vs behavior change** — mechanical renames/moves/formatting vs actual logic changes; refactors are lower-risk and should not be reviewed in the same pass as a behavior change they obscure
- **Independent features or fixes bundled together** — changes that don't share files or call paths and could each stand alone
- **Commit boundaries** — if the branch's commits already separate concerns (e.g. "refactor X" then "add feature Y"), that's a strong, low-effort split

Propose 2–4 splits when the diff clearly decomposes along one or more of these lines. If it genuinely doesn't decompose (e.g. one tightly-coupled change touching many files for a single reason), say so explicitly instead of forcing an artificial split — in that case omit the split-suggestions section from the output even though the threshold was crossed, and note this in the Estimated human effort driver instead (e.g. "large but atomic — could not be split further").

## Triage Result

Output **exactly** this structure, in this exact order, and nothing else — no preamble, no extra headers, no commentary before or after it. Do not reorder, rename, or drop fields; if a field's value is "none of the above," write that out explicitly (e.g. "None") rather than omitting the line.

```markdown
## Triage Result

- **PR:** <owner/repo>#<number> — <short title>
- **Intake:** :white_check_mark: Pass | :flags: Flagged | :x: Rejected — <one-line reason if Flagged/Rejected, else "meets all four bars">
- **Tier:** :large_green_circle: Low | :large_orange_circle: Medium | :red_circle: High
- **:reasonably-sized-haystacks: Stack:** <tools and reviewers to involve>
- **:red-flag: Red flags:**
  - <flag>
  - <flag>
- **:standing_person: Gate:** Human-on-loop (spot-check) | Human-in-loop (review every merge)
- **:hourglass_flowing_sand: Estimated human effort:** <range, e.g. "5–10 min"> — <one-line driver>

### Suggested PR Splits
1. **<split name>** — <what this split contains> — <why it should be split out>
2. **<split name>** — <what this split contains> — <why it should be split out>
```

Fill in every placeholder (`<...>`); for fields with `|`-separated options, choose exactly one matching the actual verdict/tier and write only that one emoji+word, not the alternatives — the emojis are part of the fixed options, not a free choice. For **Red flags**, list one triggered flag per bullet line (`- <flag>`); if none triggered, write a single line `- none` instead of a comma-separated list.

The `### Suggested PR Splits` header and its numbered list are the **only** conditional part of this template:
- Include it, in that exact position (last, after Estimated human effort), **only when** the diff exceeds 1000 changed lines *and* Step 2 above found a real decomposition. Use 2–4 numbered items, each in the form `N. **<split name>** — <contents> — <rationale>`.
- Omit it entirely — header and all — for diffs at or under 1000 changed lines, or for oversized-but-atomic diffs per Step 2. Do not replace it with "N/A" or an empty section; the template simply ends after "Estimated human effort" in that case.

## Further Reading

- [Agentic Code Review](https://addyosmani.com/blog/agentic-code-review/) — Addy Osmani. Source for all frameworks and data points in this skill.