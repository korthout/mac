---
name: pdp-confidence-update
description: Use ONLY when Nico explicitly invokes it (typically via /pdp-confidence-update) to write, prepare, or reconstruct the weekly PDP confidence update for a project channel. Do NOT trigger automatically from general Slack/status questions. Reconstructs the channel since the last `!pdp progress` post and drafts a ready-to-post update in Nico's house style.
---

# PDP Confidence Update

Reconstruct what happened in a PDP project Slack channel since the last confidence update, then
draft a **ready-to-post** `!pdp progress N` update in the house style. Default project:
**#prj-pdp-3462-real-time-agent-visibility** (channel `C0AH08C7UA2`) — confirm if invoked for another.

The confidence update is **stakeholder- and team-facing**, and it is a **coordination tool**, not just
a status readout: it can carry direct asks (@-mentions) and use the confidence number itself as a lever
(see "Confidence as a lever").

This skill is chosen deliberately (slash), never auto-run.

**See `example.md`** (in this skill dir) for a real annotated run — the reconstruction-doc skeleton plus a
gold-standard posted update showing inline issue links, an @-mention CTA, and confidence-as-a-lever. Read it
when you want a concrete model of the output; the steps below are the abstract procedure.

## Step 0 — Lock the variables first (grill)

Before reading anything, resolve these with the user. If the plan is fuzzy or the user wants it,
invoke the **grill-me** skill to walk the decision tree; otherwise confirm inline:

1. **Iteration** in scope — name, date range, and which release it feeds (e.g. "July M1, Jun 30–Jul 13, → 8.10.0-alpha4").
2. **Baseline** — the last `!pdp progress N` actually posted (ask for the permalink, or find it — Step 1).
3. **Framing** — does the rating track **epic/project confidence** or **this-iteration delivery**? This
   *changes the number*. Nico rates **epic/project**. Do not assume — confirm.
4. **Sources** — Slack channel is the spine. Confirm Slack MCP is authenticated (`/mcp`); use Glean only
   as secondary, subject to the anti-hallucination rule below.
5. **Output** — reconstruction doc + ready-to-post draft (default), or reconstruction only.

## Step 1 — Find the baseline & recall the last run

- Latest `!pdp progress N` in the channel (posted by the "Weekly PDP epic update" bot; CloudBot mirrors it
  to `product-hub#3462`). Read its rationale in full — the new update must not contradict it. Reconstruct
  forward from its timestamp.
- **Read the most recent doc in `previous-runs/`** (this skill dir). It holds the *full reasoning* behind
  the last update — why risks were rated as they were, what was deferred, the number deliberation, and the
  "Actual outcome" note (what was really posted, since Nico often edits the number/adds links). The terse
  Slack post won't have any of this. Use it for continuity: carry forward open risks, check whether flagged
  items resolved, and don't re-litigate settled framing.

## Step 2 — Reconstruct the window (baseline → now)

- Read the channel verbatim over the window (`slack_read_channel` with `oldest=<baseline ts>`).
- Read the substantive **threads**: daily-sync notes, design/technical discussion threads, QA updates,
  status posts. Pull PR/issue numbers and states from verbatim messages.
- Verify the load-bearing claims against **artifacts** (PR/issue state, TestRail, release tags): Did the
  code freeze deliver? Did the release ship? What actually merged vs. slipped?

## Step 3 — Anti-hallucination rule (CRITICAL — do not skip)

The daily-sync **"Quick recap / Summary"** blocks (and Glean recaps) are **AI-generated and have invented
facts** — past runs produced a fake "medical leave" and fake "on-call" that reached a draft before Nico
caught them. Therefore:

- **Never assert a recap-only claim** — especially capacity, leave, dates, ownership — without a
  **verbatim human message**, a **real artifact**, or **Nico's confirmation**. Mark unverified items
  `[UNVERIFIED]` in the reconstruction and **ask Nico** before they enter a stakeholder post.
- Two people with confusingly similar names — keep them distinct:
  **Dmitri Nikonov** (connectors) vs **Dmytro "Dima" Melnychuk** (engine).

## Step 4 — Write the reconstruction doc

Save the doc as `previous-runs/YYYY-MM-DD.md` **in this skill dir** (never in the working repo) — this
is the durable artifact and doubles as next run's Step 1 input, so write it here from the start rather
than drafting elsewhere and moving it later. Include: baseline found · what happened since ·
risks/blockers/capacity · confidence signals (positive / negative) · open questions & ambiguities ·
confidence recommendation. Write it before the final draft.

**Archive the outcome for the next run.** After the update is posted, append an
**"Actual outcome (posted)"** section to this same file — the number actually posted (Nico may change
it), how it was framed, links/mentions added, and continuity notes (new baseline, risks to carry
forward, items to check next time). This is what Step 1 reads back.

## Step 5 — Confidence number

Use the rubric (see reference below) **against the chosen framing**. **Recommend a number with explicit
reasoning, but Nico sets the final number.** Show the 3-vs-4 (or N-vs-N±1) trade-off honestly, mapping
the situation to the rubric wording line by line. If dropping after a delivered milestone, name it as an
*honest reassessment of the road ahead*, not a regression, so stakeholders don't misread the digit.

**Confidence as a lever.** The number is also a negotiation tool. Nico has deliberately posted a *lower*
number to force a decision (e.g. drop to 3 to push PM to align on an Alpha 5 slip), pairing it with an
explicit clause: *"If the Alpha 5 slip is agreed with PM, confidence increases back to 4."* When the
rating is genuinely borderline, ask whether it should be used this way.

## Step 6 — Draft the ready-to-post update

House style — `!pdp progress N` then these sections (see template below):
🎯 Context · ❓ Why this confidence rating? · ✔️ What has been achieved? · ⏩ What happens next? ·
❗ Risks and mitigations (each risk gets a `◦ → Mitigation:` line) · `posted by <@UTT0CLCVB|Nico Korthout>`.

- **Link issues inline**, even in stakeholder text — `<https://github.com/camunda/camunda/issues/NNNNN|short label>`
  — so readers can drill in. Gather the real issue numbers from the reconstruction.
- **@-mention people with a direct CTA** where the update needs someone to act or align.
- Keep it tight and stakeholder-readable; lead "Why this rating?" with the honest driver of the number.

## Step 7 — Hand off; do not post

Append the draft to the reconstruction doc and present it. **Nico posts it himself** (he often makes final
edits — number, links, mentions). Do **not** post to Slack unless explicitly asked.

---

## Reference: confidence rubric (1–5)

Verbatim for the two that matter most in practice:

- **3 — On track, but with caveats:** Most risks and uncertainties assessed. Capacity is available but may
  be constrained. Challenges being actively addressed with some unknowns.
- **4 — Minor risks, under control:** Minor risks and all under control. Capacity and priorities aligned
  for delivery within the expected timeframe.

Scale runs 1 (lowest / serious jeopardy) to 5 (highest / near-certain). Confirm exact wording for 1, 2, 5
from the PDP rubric if a rating hinges on them.

## Reference: house-style post template

```
!pdp progress N

:dart: *Context*
Weekly project update, directed at stakeholders and project members.

:question: *Why this confidence rating?*
<1 paragraph. Lead with the honest driver of the number. State what was delivered, then why it holds/rises/drops. If used as a lever, include the "increases back to N if X is agreed" clause.>

:heavy_check_mark: *What has been achieved?*
_<one-line headline of the delivered value>_
• <bullet, with issue links where useful>
• ...

:fast_forward: *What happens next?*
• <workstreams, with issue links>
• ...

:exclamation: *Risks and mitigations*
• <risk>
    :black_small_square: → Mitigation: <mitigation; tie to how/when confidence would change>
• ...

_posted by_ <@UTT0CLCVB|Nico Korthout>
```

## Reference: known facts

- Default channel: `#prj-pdp-3462-real-time-agent-visibility` = `C0AH08C7UA2`.
- Nico's Slack user id: `UTT0CLCVB`.
- Posting mechanism: the `!pdp progress N` command is picked up by the "Weekly PDP epic update" bot; a
  CloudBot reply mirrors the update as a comment on `camunda/product-hub#3462`.
