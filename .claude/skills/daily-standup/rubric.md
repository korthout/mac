# Stand-up rubric

The verifier checks every draft against this list. Each line comes from a correction Nico made.

For voice, length and tone, the ground truth is the entries listed in `examples.md`, not this file.

## Mapping to sections

- Map each item to P1/P2/P3 if it serves that epic, otherwise `Also`. When unsure, `Also`.
- Map by the epic's topic, not the PR title. A PR whose title doesn't name the epic can still belong to it (2026-08-06).
- When the ISO week rolled over, map Yesterday against LAST week's P-tasks (from the last history file's headers), Today against this week's.
- CVE and incident-commander work always goes to `Also`, even when a P-task reads "Fix bugs" (2026-09-22).
- P0 (e.g. medic): read `p0.md` when the window or today has a P0 day, or Yesterday clusters into on-call-shaped work (incidents, alerts, rotation swaps).
- A P-task marked `(completed <date>)` in `p-tasks.md`: header phase `(Completed)`, one bullet `- Completed - see the <date> update` in both Yesterday and Today. A P-task that completes inside the window gets `(Completed)` on its Yesterday header too (2026-10-26).

## What to include

- State the substance (the problem, decision, finding), never just "discussed X" or "gave a heads-up". Take it from the message text, not from the channel name or reactions. Keep the reason behind an ask or a question, even when trimming for length (2026-11-03).
- Verify who did the work. Git author, a squash-merge, an activity feed, or Nico's own Slack announcement is not proof. Check the PR's `user.login` and the thread; pick the right verb (reviewed/merged vs wrote/fixed) and name who supplied the fix (2026-08-14, 2026-10-05). When the thread is ambiguous about who acted, make it an assumption, don't credit Nico. Likewise check who a request is addressed to before planning it for Nico (2026-10-23). Also check that a "decision" isn't just a restatement of an earlier one.
- A handover or assignment (e.g. named next week's medic) is not an accomplishment.
- Day placement follows the action, not the message date: a message about work still to do goes to Today. A decision (including deciding not to do something) belongs to the day it was made.
- Cluster: one bullet per topic. List the merged PR, not its commits; drop trivial follow-up commits. Merge the same decision seen in two sources (two DMs) into one bullet.
- Length follows the window. A normal day stays short and readable, so cut before adding. A long update is fine only when the window is long (several days, a medic week). Even then, compress to one bullet per stream of work rather than one per event.
- Rank by substance: cross-team outcomes and decisions above reminders and procedural notes.
- WIP or newly opened PR: status only ("opened for review", "worked on it"); no mechanics, no CI noise, unless the work itself was hard or interesting.
- A doc still being written: "started drafting ... (still a work in progress)", not "drafted" (2026-09-28).
- Translate working-doc shorthand (codenames like "G1", "the MAIN-problem") into the real substance.
- Name the support tier on a support-case bullet ("Investigated an L2 support case on ...").
- Leave out by default (list under "Left out" in the review): personal/local tooling with no team outcome, one-word replies, social DMs, threads on Nico's own open PRs already covered by git, tentative staffing or backup-DRI proposals (also don't name a 1:1 topic that would reveal them), meetings Nico only watched.
- Keep light personal-life plans with colleagues (e.g. after-work drinks) — Nico likes sharing them (2026-08-14). Never mention a calendar "Private appointment". His own open-source work (e.g. backport-action) is spare time: say "In my spare time" (2026-11-12).

## Today

- A forward plan in team voice: every bullet is postable as-is. No notes to Nico inside bullets ("this carries over", "you said") (2026-10-02).
- Turn a state fact into the action Nico will take ("Follow up with the tech writer reviewing PR #X", not "PR #X awaits tech writer review").
- If the daily sync already ran today, plan from its action items (Nico posts notes in the project channel), never "Join the daily sync" (2026-10-14).
- Drop settled questions; don't write "waiting for X's answer" when Nico says it's decided and X may only object (2026-10-14). A brainstorming "wdyt?" or a post that Nico already reacted to is not a pending reply, and a one-reaction or one-line reply is too small for Today anyway (2026-10-23, 2026-11-11).
- Size Today to what fits: P-tasks rank the week, not the day. Count the free time left after today's meetings, and leave out work with no deadline today, work waiting on someone else (a pending review, an "if we agree"), and low-value carry-overs. It's Nico's feel for the day, not a fixed item count (2026-10-22). Still list today's recurring meetings from `private.md` under `Also` (2026-10-26). A meeting or pairing bullet says what it is about and why, not just who (2026-10-29).
- KTLO: Nico's team has a feature-versus-maintenance target (see `private.md`). Maintenance means bugs, tech debt, CVEs, incidents, support cases. PDP epics count as feature work. Estimate this ISO week's ratio so far from this week's history Yesterday sections plus the drafted Yesterday, list it as an assumption, and tilt Today toward the side that is behind. Record it in Notes as `- KTLO: <feature>/<maintenance> this week so far` (2026-10-29).
- Late-day run: still a forward plan. Only when Nico says he is out of time: done / didn't-get-to (`- Didn't get to: ...` per section) with a one-line note on top; the next run then opens Yesterday with one sentence pointing to that update instead of re-listing it.

## Format

- Headers: `P1 - <Epic name> (<Phase>)` — phase only if the P-task names one. Issue P-task: `P2 - [#<num>](url) <short rewritten title>`. Channel P-task: `P2 - <Epic name> (#channel-name)`, and its bullets don't repeat the channel. `Also` has no number.
- Header and first bullet on consecutive lines; exactly two blank lines (`\n\n\n`) between section blocks. Check the raw string, not the rendered preview.
- Bullets are `- `. Never `•`, never em-dash bullets, `P1 - ` uses space-hyphen-space.
- All of P1/P2/P3 always present; empty ones get `- Nothing yesterday` / `- Nothing planned today`.
- No "Yesterday:"/"Today:" headers inside the content, no emojis.
- `Also` with ~5+ items across 2+ themes: bold mini-labels (`**Security**`, `**Meetings**`), bullets right under each, one blank line between groups.
- Multi-day window: open Yesterday with one sentence on what it spans ("All of the below happened Thursday; I was out of office Friday."), two blank lines before P1.

## Links and references

- Every GitHub PR/issue, in every section including Today: `[<Full title> #<num>](url)`. In P2/P3 headers: `[#<num>](url)`. Never `[PR #num](url)`, `<url|text>`, a bare URL, or a bare `#num`.
- A bullet sourced from a public Slack channel carries `([thread](url))`, in any section. Never link a DM; name the person instead.
- Slack channels as plain `#channel-name` (no link, no backticks).
- Backticks on versions, branch names, file names, and skill/tool names.
- Colleagues by first name, no @-mentions; use the nicknames in `~/.claude/private.md`. Never write a raw `@group` handle (it pings); name it as `private.md` says.

## Blockers or risks

- State a risk as possible ("could be at risk"), not certain, unless Nico or the team already called it. After an absence, say he's still assessing it. A risk that only applies if something else slips ("at risk if X doesn't post") isn't one yet: write `None` (2026-11-11).
