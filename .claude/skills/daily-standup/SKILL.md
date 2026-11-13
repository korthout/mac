---
name: daily-standup
description: Produces Nico's daily stand-up / Geekbot reply.
disable-model-invocation: true
---

# Daily Standup

Produce and post Nico's three Geekbot replies (Yesterday, Today, Blockers or risks) in his style, with **one review by Nico at the end**. Do all the gathering and judgment yourself. Turn every open question into an assumption that he reviews alongside the draft, instead of asking mid-run. Two things drive this design. Waiting on Nico mid-run lets the 1h prompt cache expire. And the north star is fewer corrections per review.

Files:
- `rubric.md`: the rules a draft must pass. Run it as a checklist on every draft.
- `p0.md`: medic and on-call rules, read only when `rubric.md` points there.
- `gathering.md`: the briefs for each source. Read it in step 2.
- `p-tasks.md`: this week's P1/P2/P3.
- `examples.md`: the posted entries Nico picked as the reference for voice, length and tone. Read them before drafting.
- `history/<date>.md`: what was posted, plus private Notes and Corrections.
- `drafts/<date>.md`: the draft as first shown to Nico, kept so it can be diffed against what was posted.
- `private.md`: Slack IDs, colleague nicknames, recurring meetings and team norms that other files refer to.

**Privacy.** Files not in this skill's `.gitignore` are public. Keep out of them names and nicknames, who Nico meets, team names, Slack IDs, incident or case numbers, internal targets, personal life, and dated absences or duty weeks (a lesson about one drops its date). Put these in `private.md` (stable), `p-tasks.md` (this week) or history Notes (one-off), and refer to them or use a generic example (`#inc-1234`).

## Process

### 0. Resume or start

If `drafts/<today>.md` exists and `history/<today>.md` doesn't, a previous run was interrupted. Read the Geekbot DM first and skip any reply already posted today. Then show the draft again (step 6) without re-gathering.

### 1. Upfront: only what can't be inferred

Questions asked before gathering are cheap, because there's no context yet to lose. Ask in one plain chat message, only when needed, then wait:
- **ISO week rolled over** (`date +%G-W%V` ≠ `iso_week:` in `p-tasks.md`): ask for the new P1/P2/P3 as free text, and whether a P0 duty (e.g. medic) applies this week. Save them in the file's existing format, updating `updated:` and `iso_week:`. Use `%G`, not `%Y`, which wraps wrongly at year boundaries.
- **The window or today includes a medic day** and no handover summary is in history yet: ask for Nico's medic handover summary. It already holds alert owners and support-case tiers that Slack gets wrong.

Read `private.md`. If it's missing (e.g. a fresh clone), ask for the values its references need and recreate it.

Apply anything Nico passed when invoking the skill, e.g. "out of time" (see the Today rules in `rubric.md`) or "medic today". Everything else becomes an assumption. That includes later days of a medic week: read `## Notes` of the last history file, and assume the duty continues if it says so.

Compute the window: `H=$(ls history | grep -v "^$(date +%F)" | tail -1 | sed 's/\.md$//')`. The window is `[H, yesterday]` inclusive, because `H`'s stand-up covered the day before `H`. With no prior file, the window is just yesterday. This self-corrects across weekends and absences. If it spans more than 2 working days, note that as an assumption and check the calendar for `Absent` days.

### 2. Gather

Follow `gathering.md`, including its cross-checks.

### 3. Draft all three replies

Apply `rubric.md` throughout.
- **Yesterday:** only confirmed activity in the window, mapped to sections, clustered and ranked.
- **Today:** a forward plan built from these sources:
  - carry-overs from the previous-plan check
  - open follow-ups, such as PRs awaiting review or merge, promised replies, and unmerged fixes
  - today's calendar, especially meetings Nico organizes and their agendas
  - today's sync notes
  - the P-task focus

  **Decide today vs later this week.** Use the calendar's free time and Focus blocks, deadlines (e.g. a kickoff tomorrow), and `Absent` days. Put what fits today in the plan. List what you moved to later as an assumption.
- **Blockers or risks:** `None`, unless the sources show a real blocker, such as a dependency waiting on another team or an Absent day before a deadline. If there is one, draft one or two plain sentences.
- **Notes (private, not posted):** tag what you inferred: `- Dropped: <item> (<reason>)`, `- Delegated: <item> to <person>`, `- Deferred until <date>: <item>`, `- Done: <item>`. For a multi-day P0, add `- P0: <duty> runs the whole week of <date>` so the next run continues it.

### 4. Verify

Check the raw strings against every line of `rubric.md`, including the `\n\n\n` gaps. Then get an independent review of the drafts against the rubric and the gathered sources: does each bullet hold up, was anything sourced dropped, and is any bullet in the wrong section? Use the `advisor` tool if it's available. Otherwise use an Opus subagent (`model: "opus"`), giving it `rubric.md`, `private.md`, the drafts and the gathered facts. Fold in the feedback that holds up.

### 5. Save the draft

Write the drafts, assumptions and "left out" list to `drafts/<today>.md` before showing anything. If the session gets interrupted, step 0 resumes from this file.

### 6. The one review

Send one chat message, rendered as normal markdown (no code fence, and not via `AskUserQuestion`). It contains:
1. **The full draft of all three replies**, each under a bold label (`**For "What changed since the last update?"**`, and so on). Nico reviews the full text, so never summarize or abbreviate it. Copy it verbatim from `drafts/<today>.md` and post from that same file, so the reviewed text is the posted text (2026-10-20).
2. **Assumptions:** a numbered list. Each item states the default you took ("3. No trace of the PR #X review; assumed not done, carried into Today"). Nico corrects by number.
3. **Left out:** one line per notable item you cut, with the reason, so Nico can pull it back.
4. **Focus block:** one or two lines suggesting what to use the morning Focus Time block for: the one thing from Today that would make the day a success once done, and that needs deep work (designing, coding, writing), not replies or reviews. If the block has already passed, suggest it for the next one. Not posted (2026-11-13).
5. One closing line: reply `post`, or give corrections.

On corrections, apply them and list what changed. For small, specific changes, show only the changed lines. Show the **full** revised draft (no code fence) after larger changes, or when it was last shown 3+ turns ago, with the change list below it (2026-10-23). A tool-call rejection that carries edit instructions is an edit request, not approval (2026-10-12). Carry a correction into another section only when it changes what that section says. A higher risk doesn't change a plan whose session stays the same (2026-11-02). Post only after an explicit go.

If a correction gives a P-task's tracking issue or says a P-task is completed, update `p-tasks.md` right away. Append `#<num>`, or `(completed <date>)`. Then re-render the headers in the current draft.

### 7. Post

Post through `mcp__claude_ai_Slack__slack_send_message` to the Geekbot DM `<geekbot-dm>`, without the bold labels. Before each send, re-check the `\n\n\n` gaps in the raw string, because corrections can break them, and any time-of-day wording ("In this morning's sync") that the review may have outlived.
1. Read the DM first (`slack_read_channel`). Geekbot's latest message must be today's first question, "What changed since the last update? (progress, completion, or delays)". The other two are "What are you working on next?" (Today) and "Any blockers or risks?". If the questions differ from these, stop and ask Nico. If the check-in was dismissed or expired during the review, wait for the next "Starting Daily check-in" prompt.
2. Post Yesterday, then read the DM until Geekbot asks the next question. Then post Today the same way. If Geekbot says nothing was recorded, re-post the identical text once the session is live again.
3. Blockers: if Nico already answered in the DM, skip this step. If the agreed text isn't `None`, post it. If it is `None`, post nothing, and don't post `.` yourself, because the "Sent using @Claude" signature garbles it. Tell Nico to reply `.` himself, then continue without waiting.

A posted message can't be edited, since there is no edit tool. If a mistake is found after posting, ask Nico whether to post a correction.

### 8. Archive and learn (no questions)

1. Write `history/<today>.md`. Overwrite silently if it exists. Use this structure:

   ```markdown
   ---
   corrections: <N>
   ---
   ## Yesterday
   ## Today
   ## Blockers or risks
   ## Notes
   ## Corrections
   ```

   - `## Notes` holds the tags from step 3, updated with what Nico said. Write `- None` if empty.
   - `## Corrections` holds each change between `drafts/<today>.md` and the posted text, plus each assumption Nico overrode. Write each as one line tagged `rule-gap`, `source-gap` or `one-off`. `N` is their count.
2. Learn from each correction:
   - `rule-gap` (would recur): add or edit one dated line in `rubric.md`. Apply the Privacy rule to any line added to a tracked file.
   - `source-gap` (a gathering miss): fix `gathering.md`.
   - Process problem: fix this file.
   - `one-off` (a fact no source could know): Notes only.

   Quality comes first, then size. Watch the size of every file a run reads in full (`SKILL.md`, `rubric.md`, `gathering.md`, `examples.md`, `p-tasks.md`, `private.md`): each added line costs context on every run. Before adding a line, weigh it against the existing ones. Add only lessons that are general and likely to recur, and keep narrow ones in Notes. Merge or shorten rather than append, and cut a line that a newer one makes redundant. Files read only in part (`history/`, `drafts/`) don't need this (2026-10-22).
3. Report in one line: this run's corrections, and the trend over the last 5 `corrections:` values.
4. If today's posted entry fits a slot in `examples.md` clearly better than the current example, ask in one line whether to swap, with the reason. Only ask on a clear win. This question doesn't block anything, because everything is already posted and archived. A swap changes `examples.md`, so apply the Privacy rule.

### 9. Trim the skill

Quality comes before size, but cuts needn't be lossless. Re-read the files a run reads in full, and look for:
- duplicates across files, lines a newer one made redundant, and history notes no longer needed
- content that only some runs need (load it conditionally)
- rules whose benefit doesn't pay for their size: weigh how much a rule prevents against a rough estimate of how often it applies. A rule for one rare situation is a candidate to drop.
- steps that cost more context than needed: look back at this run's tool output and subagent reports, and find a cheaper way to get the same facts.

Quality means the output still meets the skill's goals: accurate, in Nico's voice, few corrections.

Propose the cuts in one message with the bytes each saves, and apply them after Nico agrees. Name every rule you drop, and ask separately about any you're unsure of. If nothing is worth cutting, say so in one line. Apply the Privacy rule to every edit, and flag any private information already in a tracked file.
