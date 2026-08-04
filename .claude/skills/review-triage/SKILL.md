---
name: review-triage
description: Use when reviewing someone else's pull request and deciding how many minutes it deserves and where to aim them. Checks reviewability preconditions first and drafts early pushback, grants a licence to skim only for provably cheap zones, otherwise delegates to the owning domain skill and returns the residual that only a human can cover.
---

# Review Triage

Produces a review budget and a target: how many minutes this PR deserves, and which specific
questions to spend them on.

**Asymmetric loss — the rule everything else serves.** The user's habitual error is
over-spending, so the skill's value is licence to stop. But a wrong "safe to skim" can let a
severe bug reach production. So: **be sound on shallow, conservative on deep.** Telling the user
to look when they needn't have costs minutes. The reverse costs an incident. Never trade the
second for the first.

The three consequences of that rule, in order of how easily they erode:

1. **Licence comes only from the cheap-zone whitelist** (`cheap-zones.md`) — from positively
   locating a changed path inside a zone with a recorded structural argument. Never from
   "no red flags fired": a red-flag list is finite, and the bug that hurts is the one nobody
   listed.
2. **A clean delegated review does not grant licence.** If a domain review returns no findings,
   that is absence of evidence laundered through an agent. It shrinks the residual list; it
   never empties it.
3. **Quote evidence, don't assert verdicts.** Every gate finding and every residual item names a
   file, line, or commit and shows the text. The user is judging the evidence, not accepting a
   ruling.

Run steps in order. Step 1 short-circuits — do not gather diff content or delegate anything for
a PR that fails the gate.

**Out of scope.** Whether a human reviews at all — one always does, and the user is that human;
only the depth is in question. Author-side self-triage of the user's own PRs. Ranking a queue of
PRs against a shared budget. Assembling a reviewer stack.

## Step 0 — Gather

If no PR was named, ask for a link or number.

**Check the repo first.** Step 3's path map and `dangers.md` are camunda/camunda-specific. If the
PR is in another repo, say so now — the gate, cheap zones, and budget still work, but delegation
is uncovered, and the user should learn that before you spend a triage on it, not two steps later.

Then:

```bash
gh pr view <N> --repo <owner>/<repo> \
  --json title,body,url,additions,deletions,files,statusCheckRollup,author,isDraft
gh pr view <N> --repo <owner>/<repo> --json commits \
  --jq '.commits[] | "=== \(.oid[0:8]) \(.messageHeadline)\n\(.messageBody)"'
gh api repos/<owner>/<repo>/pulls/<N>/files --paginate \
  --jq '.[] | "\(.additions+.deletions)\t\(.status)\t\(.filename)"'
```

Read commit bodies and the PR description in full before the gate — they *are* the gate's
subject. Fetch the patch (`gh pr diff`) only once past the gate, or for the specific hunks a
gate finding needs to quote.

## Step 1 — Reviewability gate

Cheapest step and the highest-value outcome: a hard block costs zero review minutes, and being
wrong only mildly annoys an author.

Two passes. **Pass A (hard blocks)** needs only Step 0's metadata — commit bodies, description,
file list, check status. If any fires, stop there: don't fetch the patch, don't run Pass B.
**Pass B (highlights)** runs only when no hard block fired, and may fetch the patch.

**Pass A — hard block.** Stop, spend no further minutes, draft the pushback:

| # | Condition | How to check |
|---|-----------|--------------|
| 1 | Commit bodies explain *what*, not *why* | Body absent, or restates the headline, or lists changed files without a reason for the change. **Judge the substantive commits only** — skip review-iteration fixups ("Apply suggestions from code review", "fix typo", "address feedback"). A long review conversation produces many empty-bodied fixups and is a sign of a *well*-reviewed PR; blocking on those inverts the signal |
| 2 | PR description doesn't say why the change is necessary, or doesn't reference an issue | No rationale paragraph; no `#N` / `Closes #N` / issue link |
| 3 | Behavior change with no tests at all | Executable source changed (code, config that alters runtime behavior, build logic), and zero test files added or modified. **Not applicable** when no executable source changed, or when the only executable change is *declarative registration* whose sole failure mode is a build break already covered by a green check — a sidebar entry, a card array, a module list. Firing on those blocks nearly every documentation PR |
| 4 | Too large to review as one unit | >1000 changed lines **and** it decomposes — see `splits.md`. Large-but-atomic is **not** a block. **This is the one gate step that requires judgment** rather than a mechanical read: deciding whether a commit delivers standalone value means reading its body. That is allowed here because the block's cost is recoverable — the author is asked to split, not turned away. Hold #1–#3 to the literal bar; #4 gets to think |

**Pass B — highlight, then continue to Step 2.** These become review points, not blockers:

| # | Condition | How to check |
|---|-----------|--------------|
| 5 | No alternatives considered | Neither commits nor description mention a rejected approach or trade-off |
| 6 | Behavioral and structural changes mixed in one commit | A single commit contains both logic changes and renames/moves/formatting |
| 7 | CI red, or checks not run | `statusCheckRollup` has failures or is empty |
| 8 | Comments that don't earn their place | Per added comment or Javadoc, name the reader and what they'd do differently. Flag those where neither can be named — priority: comments describing *the change* rather than the code ("now we also handle X"), Javadoc restating the signature, narration of control flow the code already states. These go stale on the next edit and agent diffs are dense with them |

Keep the gate narrow. "Commit body is one line with no rationale" is checkable; "rationale is
insufficient" is not — that is the user reading it, not the gate. A gate that bounces everything
on technicalities stops being trusted.

**Draft, never post,** a pushback comment for hard blocks: name the specific commits or files,
quote the offending text verbatim, state what's missing. For block #4 the proposed splits *are*
the pushback. Match the user's review conventions if the repo documents them.

## Step 2 — Licence to skim

Read `cheap-zones.md` and partition the changed paths into **matched** and **unmatched**.

Any path outside a listed zone — including new, unfamiliar, or simply unclassified areas — is
unmatched. That default is the point: an unclassified path is unknown, not safe.

The licence is **per file, not per PR.** Matched paths are skimmable; only unmatched paths need
close reading. A PR that is mostly prose plus two lines of code is a two-line *reading* job, not a
whole-PR one. Judging the PR as an indivisible unit would compute which files are cheap and then
decline to say so.

**The licence sets reading depth — it does not scope Step 3.** Trigger and residual checks run
over the whole diff, matched files included, and anything they surface is priced. A skimmable file
can still raise a question the diff cannot answer: prose asserting a field name already shipped,
or a link no CI job validated. Restricting Step 3 to unmatched paths would suppress exactly those.
Skim the file; still ask what it claims.

- **All paths matched** → licence for the whole PR. Report the matched zones and stop.
- **Some matched** → name them as skimmable, and carry only the unmatched set forward.
- **None matched** → no licence; the whole diff carries forward.

**Consistency carve-out.** Cheap zones are cheap *in isolation*. A matched file that *describes*
non-cheap code changed in the same PR is read for agreement with that change, not skimmed —
documentation asserting behavior the accompanying code contradicts is exactly what skimming
misses. Trigger is narrow: prose plus code in one PR, where the prose covers the changed code.
Prose alone stays skimmable, and so is prose accompanied only by registration or pointer files —
a sidebar entry asserts no behavior for the prose to contradict.

Distinguish "checked and cleared" from "nothing to check": in a docs-only repo the carve-out has no
target at all. Say which, since a bare "did not fire" reads identically either way.

## Step 3 — Delegate, then extract the residual

Resolve changed paths to the domain skill that owns the danger knowledge for them, and **invoke
it** — dispatch a `general-purpose` subagent to apply that skill as a reviewer over the changed
files and return concrete findings. Brief it with the **absolute paths** of the skill file and the
matching reference files, and tell it to read them; don't assume it can resolve a repo-scoped
skill by name. Never restate a domain skill's danger list here — a copy drifts, and a stale danger
list is worse than none because it grants confidence it hasn't earned.

| Changed paths | Delegate to |
|---|---|
| `zeebe/engine/**` | `engine-expert`, plus its matching reference: event appliers or `Mutable*State` methods → `event-appliers.md` · record value types, intents, `ValueType` → `records.md` · processors, behaviors, validation, rejections → `processors.md` · engine tests → `testing.md` · authorization enums → `authz-enums.md` |
| `.claude/skills/**`, `AGENTS.md`, ADR/architecture usage | `reviewing-agent-ready-prs` |
| `.github/workflows/**`, composite actions | `ci-validation` |
| `load-tests/**` | `load-test-ops` |
| `**/client/**` frontend | `operate-frontend` / `tasklist-frontend` / `frontend-*` as applicable |
| Anything else | `dangers.md` — this skill's own thin entries for areas with no owner yet |

Helper classes route to the same reference as their caller. A plain accumulator or navigation
class used only by a behavior goes to `processors.md`, not to `event-appliers.md` because its name
sounds stateful.

**Triggers for "knowledge absent from the diff"** — check these mechanically against the changed
paths and hunks, and report the result either way:

- A new event-applier version, or a changed `Mutable*State` method
- A change to a **persisted** record's shape or serialization (not in-memory deployment models
  rebuilt from BPMN XML on each deployment — those carry no replay risk)
- A schema or data migration
- Anything whose correctness depends on release timing or on what is already on `stable/*`

**No domain owner.** When changed paths match neither the table nor a `dangers.md` entry, say so
plainly: *"No domain skill or danger entry covers `<paths>` — correctness here is unverified."*
Do not manufacture a correctness residual item for it, and do not silently report "no findings"
as though a review happened. A missing owner is a known gap in the skill, and the flag is the
signal to close it. If the repo isn't camunda/camunda at all, state that up front — the table and
`dangers.md` are camunda/camunda-specific, so the whole delegation step is uncovered.

Then extract the **residual**: what the delegated review structurally *cannot* cover. This is not
"what the AI didn't find" — it's the set of questions an agent reading a diff is unable to answer.

**Every category must be discharged or listed — never listed by default.** Three of the five
below would otherwise apply to every PR ever written, which inflates the budget on exactly the
reviews this skill exists to shorten. Discharge means *positive evidence that the question is
already answered*, which is not the same as absence of evidence: run the check, and if it comes
back clean, the item does not go on the list. Say which items were discharged and how — that is
as much of the answer as the items that remain.

Listed items must be specific: name the file, line, or commit and state the actual question. A
generic category name is not a residual item.

All five categories run **whether or not a domain skill exists** for the changed paths. Only
"explicitly ungated" depends on having a reference to consult; the other four are about what a
diff cannot tell you, which is true with or without a delegate.

| Category | List it only when | Discharge check |
|---|---|---|
| **Knowledge absent from the diff** — release state, `stable/*` contents, in-flight work the diff cannot contain | A trigger fires (list above, under Step 3's path map). Sharpest instance: whether a new applier version reaches every newer minor before its initial release — nothing in the diff says, and getting it wrong kills partitions unrecoverably | Trigger presence is a **path and content check, not a judgment**: run it and show the result. No trigger → not listed. Never discharge a *fired* trigger — it is irreducible |
| **Explicitly ungated by the domain skill** — a reference states no automated gate covers this | The delegated reference says so. E.g. `Mutable*State` methods have no golden file and `event-appliers.md` says "extra care required" | The changed paths don't reach anything the reference marks ungated. List it even when the delegated review was clean. **No domain skill exists for these paths** → neither list nor discharge; report it under "no domain owner" below |
| **Tacit history** — "we tried this and reverted it" | A prior attempt or revert touching these paths exists | `git log --all -i --grep=revert -- <paths>` plus recent history on the changed files. Nothing found → discharge. **If something is found, fetch its rationale** — a revert headline carries no information; the value is in *why* it was reverted and which coverage it declared missing, which is what tells you whether this PR recreates it. Stopping at the `git log` finds a hit you cannot act on. Squash merges and backport cherry-picks mean the revert commit often has no PR of its own — then walk backward: find the commit it reverted, `gh api repos/<slug>/commits/<sha>/pulls` to get the *introducing* PR, and search for the umbrella revert PR from there |
| **Should this exist** | A near-duplicate exists, or the change introduces a concept whose fit is unclear | Duplicate half: grep for existing helpers with the same shape. Domain-model half: delegate to `design-alignment-reviewer` rather than listing it — that agent exists for this. List only what it flags |
| **Intent alignment** — is this what was asked for? An agent reconstructs intent *from the diff*, so it cannot see a coherent solution to the wrong problem | The PR description doesn't map its changes onto the linked issue's stated outcome, or the mapping has gaps | Description ties changes to the issue's acceptance criteria and they line up → discharge. (A missing description or issue link already hard-blocked at #2) |

## Step 4 — Budget

Hard block → 0 min, post the pushback. Full licence → ≤5 min skim.

Otherwise **estimate each item and sum**, rather than mapping item count to a range. Item count
conflates costs that differ by an order of magnitude: "confirm the new applier version is on
8.9's branch" is 2 minutes of `git` and it's settled; "does this concept fit the domain model" is
20 minutes of thinking. A summed budget is also auditable afterwards — the user can see which
estimate was wrong and correct it. A count-based range cannot be checked against anything.

Price all three of these, not just the residual:

- Residual items
- Verifying delegated findings, where a finding needs the user's confirmation
- Fired Pass B highlights — each is a review point the user has to write up. Reporting a highlight
  and pricing it at zero is how the budget drifts from what the review actually costs

**Open-ended items are priced by their scoping step, not guessed whole.** When an item means "go
verify this against running code" — read and run existing tests, build a scenario, reproduce a case
— the total is genuinely unknown, and a floor picked by analogy is a guess wearing an honest
format. Instead: name the concrete scoping action, price *that*, and leave the remainder open.
`Scope it first: run MultiInstanceIncidentTest against this branch and read what it covers — 10
min. Beyond that, unbounded until scoped.` A number derived from a named action is auditable; a
floor chosen by feel is not, however cautious it looks.

If the total exceeds ~45 minutes, say so and suggest splitting the review across sessions rather
than quietly emitting a number the user won't honour.

## Output

```markdown
## Triage Result

- **PR:** <owner/repo>#<N> — <title>
- **What it achieves:** <why this PR exists>
- **What it changes:** <how it gets there>
- **Verdict:** Blocked | Licence to skim | License to skim parts | Review required — <one-line reason>
- **Review time budget:** <summed, per Step 4> — <driver>

### Aim here
1. **<file:line or symbol, or "draft comment">** — <the question or action, one line> — <minutes>
2. ...

### Drafted pushback
<Only when hard-blocked. Ready to post, not posted.>

## Evidence

Everything below supports the verdict above. Nothing here needs reading to act on it.

### Gate
<Hard blocks with quoted evidence, then fired highlights. One line — "Clean" — if nothing fired.>

### Skimmable
<Matched paths and the zone each matched. Note any held back by the consistency carve-out, and
whether the carve-out cleared or had no target. Omit when nothing matched.>

### Delegated findings
<Domain skill invoked, and what it found. "No findings" is a valid result — it does not
reduce the budget below the residual. Flag paths with no domain owner here.>

### Residual — the case behind each Aim here item
- **<category>:** <the full case, naming file/line/commit and the evidence>

Discharged: <category — evidence that discharged it>
```

**`Aim here` is the deliverable; the `Evidence` half exists to be checked, not read.** The aim
block must be complete enough to act on without scrolling — a scan of those lines tells the user
which file to open and what to ask there. Rules:

- One line per thing to actually do, ordered by minutes descending. Cap at 4; if there are more,
  the review needs splitting and Step 4 already says so.
- Name a concrete target: `File.java:methodName`, a commit, or "draft comment to author". Never a
  bare category name — "tacit history" is not somewhere to look.
- State the question, not the background. The case for *why* it matters belongs in `Residual`.
- Include drafting work as its own line. Writing the review comment is time spent.

Omit `Drafted pushback` unless hard-blocked, `Skimmable` when no path matched, and
`Aim here` / `Delegated findings` / `Residual` when blocked or fully licensed. Never write "N/A" —
omit the section. Always state what was discharged and why; that is as much of the answer as what
remains.

Keep `Gate` to a single word when nothing fired. A clean gate is reassurance, and reassurance
placed above the aim block is what forces a full read to find the actual work.

## Learning

The lists grow with use, under deliberately unequal bars — adding a danger costs minutes, adding
a cheap zone permanently widens the licence.

- **Danger → `dangers.md`.** One incident is enough. Add it.
- **Cheap zone → `cheap-zones.md`.** Requires a written structural argument: failures there are
  loud (build or test breaks, not silent divergence), it is off persistence/replay and hot
  paths, and it is revertable. Elicit that reasoning from the user and record it beside the
  entry — a bare path list rots invisibly, a recorded reason is re-testable. Propose promotions
  when a pattern appears; the user ratifies. Never self-promote.
- **Demotion.** Any incident where a zone's diff produced a real bug removes it immediately. No
  bar, no discussion.
- When this skill's own `dangers.md` entries cluster in one area, that's the signal to propose a
  proper domain skill instead of growing the file.
