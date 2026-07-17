# Worked example — PDP-3462, 2026-07-01

A real run, lightly annotated. Two phases: the **reconstruction doc** (analysis, durable) and the
**posted update** (the gold-standard output). Use it for shape and technique, not verbatim content.

---

## Phase 1 — reconstruction doc (skeleton)

Saved as `previous-runs/2026-07-01.md` (in this skill dir). Section shape:

```
# PDP-3462 Confidence Reconstruction — 2026-07-01 (July M1)
Iteration / Channel / Window / Sources (+ note: recap blocks are AI-generated → [UNVERIFIED])

## Baseline update found        → last !pdp progress N + its rationale, verbatim
## What happened since then     → grouped by workstream (delivery, kickoff), artifact-backed
## Risks / Blockers / Capacity  → table: # | Item | Severity | Notes; note what was dropped & why
## Signals that may affect confidence → Positive / Negative split
## Open questions / ambiguities → the ones GATING the number (framing, unverified capacity, dates)
## Confidence decision          → recommendation + reasoning; record the N-vs-N±1 trade-off
## Ready-to-post update          → the draft (Phase 2)
```

Technique highlights from this run:
- The framing question ("epic/project vs iteration delivery?") was the discriminator for the number —
  surfaced as an open question, not assumed.
- Two capacity/date claims (a colleague's leave; the presentation date) existed **only in the AI recap** →
  marked `[UNVERIFIED]` and confirmed with Nico before entering the post. This is the load-bearing habit.
- A prior-post claim ("all open items resolved") was corrected precisely (one item had slipped) so the new
  post wouldn't contradict the old one.

---

## Phase 2 — the posted update (gold standard)

Nico's final posted version. Note three techniques beyond the plain template:

1. **Confidence as a lever** — dropped to **3** deliberately to push PM to align on an Alpha 5 slip, with an
   explicit clause promising the number returns to 4 once agreed. The rating *does work*, it doesn't just report.
2. **Inline issue links** even in stakeholder text, so readers can drill in.
3. **@-mention with a direct CTA** (tagging the PM to align on Alpha 5).

```
!pdp progress 3

:dart: *Context*
Weekly project update, directed at stakeholders and project members.

:question: *Why this confidence rating?*
The project is healthy and momentum is strong. 8.10-alpha3 delivers the iteration goal — conversation history end-to-end from Connector to Operate — and all the work we set out for the previous iteration is now complete (the RDBMS read path missed the Alpha 3 code freeze but has since been merged). QA against a real cluster came back clean, with no agent-specific defects. *Confidence drops to 3 because the project's scope is expanding* — the newly-locked agent definition extension element is one example. Additionally, several technical solutions are still being worked out; resolving those open problems was planned for this iteration, but it adds uncertainty. There is also a connector-engineering capacity gap later in July. None of these threaten delivery today, but together they mean the road ahead still carries real unknowns, and the project now likely continues into Alpha 5. *If slip to Alpha 5 is agreed upon with PM, confidence increases back to 4*.

:heavy_check_mark: *What has been achieved?*
8.10-alpha3 delivers working end-to-end AI agent visibility from Connector to Operate.
• Conversation history shipping in Alpha 3, fully functional end-to-end: Connector → Zeebe → ES/OS → API → Operate UI
• All previous-iteration work now complete: the RDBMS read path (which missed the Alpha 3 freeze) has since merged, so history search works regardless of secondary storage type
• QA verified 79 test cases against a real SaaS cluster with live AI agent runs; no agent-specific defects (one issue found appears broader and unrelated to this project, under QA research)
• Agent definition extension element decisions locked with PM supporting the Agentic Control Plane team
• Design direction documented and formally handed off
• This iteration already in motion: <https://github.com/camunda/camunda/issues/55033|agent-history commit/discard lifecycle> underway (first PR merged), the <https://github.com/camunda/camunda/issues/54840|job-lease concept> is broken down, and <https://github.com/camunda/camunda/issues/56083|support for other object content types> is being explored

:fast_forward: *What happens next?*
• Prepare for the internal release presentation on July 14 — our first broad feedback opportunity — and draft the Alpha 3 blog post content
• Continue this iteration's workstreams: <https://github.com/camunda/camunda/issues/55033|agent-history commit/discard lifecycle> + <https://github.com/camunda/camunda/issues/54840|job-lease concept>; <https://github.com/camunda/camunda/issues/56089|tool-results overhaul>; <https://github.com/camunda/camunda/issues/56083|non-object tool-result content types>; <https://github.com/camunda/camunda/issues/56101|multi-agent-instance details>; <https://github.com/camunda/camunda/issues/55596|documents in conversation history>; <https://github.com/camunda/camunda/issues/56102|surface-loop iterations>; <https://github.com/camunda/camunda/issues/51518|backend cleanup of agent-instance data>
• Design idempotency handling for Connector :left_right_arrow: orchestration-cluster interactions
• Fold Alpha 3 feedback into Alpha 4/5 scope

:exclamation: *Risks and mitigations*
• Expanding scope: scope is growing (e.g. the agent definition extension element, loop iterations tracking), and further internal feedback is expected to drive additional changes — it's possible that the project continues into Alpha 5
    :black_small_square: → Mitigation: Alpha 5 is available as a buffer (PM/EM had already indicated that this would be okay previously - no feature freeze for Alpha 5 (confirmed on June 12). <@U000000EXAMPLE|PM Name> let's align that we should expect this project to need Alpha5 as well. This will raise confidence back to 4.

• Connector capacity gap: a team member is on leave for part of this period, overlapping the tail of this iteration and the next up to Alpha 4.
    :black_small_square: → Mitigation: connector work is on track to complete in time; additional interaction surfaced by the ongoing idempotency research can be handled after return, with backup coverage. Alpha 5 could provide buffer if needed.

• Unresolved technical questions: several solutions are still being figured out — job-cancellation correctness (via job lease) and idempotency, multi-instance handling. Working through these is a large part of this iteration.
    :black_small_square: → Mitigation: all in progress with designs, this is expected and planned development. There is buffer in the next iteration if backend work ends up more challenging than expected.

• Design continuity: the design DRI transitioned off July 1.
    :black_small_square: → Mitigation: a design direction document was handed off as a basis to continue.

_posted by_ <@U000000EXAMPLE2|Poster Name>
```

### Draft → posted: what Nico changed

Worth internalizing — the draft handed over was `progress 4`; Nico's final edits:
- **Number 4 → 3**, used as a lever (added the "back to 4 if Alpha 5 agreed" clause in both the rationale and the scope-risk mitigation).
- **Added inline issue links** across "achieved" and "what's next".
- **Added an @-mention CTA** to the PM on the Alpha 5 alignment.
- Small factual sharpenings ("first PR merged"; "with PM supporting the Agentic Control Plane team").
