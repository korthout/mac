---
name: daily-standup
description: Produces Nico's daily stand-up reply — "Yesterday", "Today", and "Blockers or risks" sections in his house style, organized by his current P1/P2/P3 epics with everything else under "Also" — then posts each as a separate Geekbot reply in his Slack DM once he agrees on the wording. Use when Nico asks to write his daily stand-up, stand-up message, Geekbot reply, or to summarize yesterday's work for stand-up.
---

# Daily Standup

Produce Nico's two Slack stand-up replies (yesterday + today) in his exact style.

## Process

1. **Load P-tasks.** Read `~/.claude/skills/daily-standup/p-tasks.md`. If the file is missing OR its `iso_week:` frontmatter differs from today's ISO week (`date +%G-W%V`), ASK Nico for the new P1, P2, P3 as free text — then save with today's `updated:` and `iso_week:`. Otherwise reuse silently.

2. **Gather yesterday's activity.** Yesterday = today minus 1 calendar day, local time.
   - **Git commits.** For each `~/gh/**/.git` (depth ≤ 3): `git log --all --author="korthout" --author="Nico Korthout" --since="<YYYY-MM-DD> 00:00" --until="<YYYY-MM-DD> 23:59:59" --pretty=format:"%h %s"`. Skip repos with no hits.
   - **Conversations.** `find ~/.claude/projects -maxdepth 2 -name "*.jsonl" -newermt "<YYYY-MM-DD> 00:00" ! -newermt "<next-day> 00:00"` — top-level only, exclude `subagents/`. Delegate summarization to ONE general-purpose subagent that returns one short bullet per session (first user message + a few subsequent user turns is enough). This keeps main context light.
   - **Slack activity (via Glean MCP).** Catches "Also" work that git misses: support cases, incident response, planning posts, CI/build chatter, cross-team threads. Call `mcp__claude_ai_Glean__search` with `query="*"`, `app="slack"`, `from="Nico Korthout"`, `after="<yesterday-minus-1>"`, `before="<today>"` (the `after`/`before` window is exclusive on both sides — widen by one day on each side to include yesterday), `num_results=50`. If the response has `hasMoreResults: true` or returns a `cursor`, paginate with the cursor until exhausted. Then filter:
     - **Keep:** support/incident channels (`#inc-*`, `support-*`), CVE channels (`#cve-*`), team DRI/planning posts (iteration planning, rotation swaps, retros), substantive cross-team threads where Nico contributed analysis, escalations.
     - **Drop:** threads on his own open PRs (already covered by git), personal/reunion/birthday DMs, one-word replies ("Makes sense", "Thanks"), Geekbot self-messages, social chitchat in DMs.
     - Cluster multi-message threads into one bullet — link the parent thread, not each reply.
   - **GitHub activity (optional).** If a PR is referenced but its title/state matters, fetch via `curl -s "https://api.github.com/repos/<owner>/<repo>/pulls/<num>" -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github+json"` (Go-based `gh` fails through Claude Code's proxy on macOS — always curl).

3. **Ask Nico for today's plan.** One open-ended question. He may say "nothing for P2", give an issue number, or describe a task informally.

4. **Ask Nico about blockers or risks.** One open-ended question, e.g. "Any blockers or risks?" He may say there are none, or describe them freely. This is raw free text — it does not get organized into P1/P2/P3.

5. **Synthesize** the Yesterday and Today sections. Map each activity item to P1 / P2 / P3 if it relates to that epic; otherwise to **Also**. When unsure, prefer **Also**. Drop trivial follow-up commits (test imports, lint fixups, minor renames) that belong to a larger merged PR — list the PR, not its commits. The blockers/risks item needs no P1/P2/P3 mapping — light cleanup of Nico's wording only.

6. **Agree, then post — one item at a time, in order.** For each of the three items below: show the drafted blob, wait for Nico to agree (iterate on wording if he asks for changes), then immediately post it as its own Geekbot reply to the DM conversation at https://camunda.slack.com/archives/D07RWKK2UTG (channel ID `D07RWKK2UTG`) via `mcp__claude_ai_Slack__slack_send_message`. Do not draft all three before posting any — each is agreed and posted before moving to the next.

   a. **Yesterday** — the P1/P2/P3/Also blob for "What did you work on yesterday?".
   b. **Today** — the P1/P2/P3/Also blob for "What will you work on today?".
   c. **Blockers or risks** — if Nico gave actual blockers/risks text, post it as-is via Slack (free text, not organized by P1/P2/P3, no bold Geekbot label). If Nico said there are none, do NOT post anything via Slack for this item — the Slack integration appends a "Sent using @Claude" signature to every message it sends, and on a lone `.` that signature dominates the reply and renders as a garbled/unresolved mention in Geekbot's compiled thread report. Instead, tell Nico he needs to reply `.` to the "Any blockers or risks?" question himself in the DM.

   Drop the bold `**For "..."**` labels used in earlier versions of this skill when *posting* — those were only needed when Nico copy-pasted manually. Use them only when *drafting* a blob for his review, so he knows which Geekbot question it answers.

7. **Archive.** Write the three agreed items to `~/.claude/skills/daily-standup/history/<YYYY-MM-DD>.md`, where the date is today's date (the day the stand-up is posted), under plain `## Yesterday` / `## Today` / `## Blockers or risks` headers (a plain header is clearer to skim later than the Geekbot framing). Overwrite silently if the file already exists (a re-run same-day supersedes the earlier draft). This builds a dated archive of what Nico reported each day — useful later for performance-review prep.

## Style guide

**Section headers** — one per P-section, NO blank line between the header and its first bullet (bullets follow immediately on the next line):

- `P1 - <Epic name> (<Phase>)` — include phase in parentheses if the P-task description names one (e.g. "Drive Implement phase" → `(Implement)`); omit if the P-task doesn't name a phase.
- `P3 - [#<num>](url) <short title>` when the P-task is a single issue — linked number first, then a short human-readable title (rewrite — do NOT paste the raw issue title verbatim). The issue number is always a markdown link, even in a header — never a bare `#<num>`.
- `Also` — no number, no phase.

A blank line still separates each P-section block from the next (header + its bullets is one block).

**Bullets** — ASCII hyphen + space: `- item`. **NEVER `•`**. **NEVER em-dash `—` bullets**. Nico's clipboard mojibakes Unicode bullets.

**Empty P-section** — one bullet:

- Yesterday: `- Nothing yesterday`
- Today: `- Nothing planned today`

Always include all three P-sections even if empty.

**Links** — GitHub-flavored markdown `[text](url)`. Every issue/PR reference gets a link — no exceptions, including section headers. Three acceptable forms:

- **Preferred:** `[<Full PR or issue title> #<num>](url)` when the title carries information the reader needs. Example: `[Track multiple element instances per agent instance #51513](https://github.com/camunda/camunda/issues/51513)`.
- **Shorthand:** `[PR #<num>](url)` when mid-bullet and the surrounding text already conveys the topic. Example: "took over [PR #53028](url)".
- **Header form:** `[#<num>](url)` — bare linked number, used only in `P2`/`P3` section headers (see Section headers above).
- **NEVER** Slack-mrkdwn `<url|text>`. **NEVER** bare URLs. **NEVER** `#num` or `(#num)` without a link — this includes section headers, not just prose.

**Inline code (backticks)** — apply consistently to:

- version numbers: `` `3.5.2` ``
- branch names: `` `stable/8.8` ``, `` `main` ``
- file names: `` `fetch_audit_data.ts` ``
- skill/plugin/tool names: `` `reviewing-agent-ready-prs` ``, `` `gh auth refresh` ``

**Slack channel references** — when an item maps to a Slack channel (CVEs, incidents, project channels), write the channel as plain `#channel-name` — Slack auto-links it. Don't link or backtick. Examples: `#cve-2026-4046-medium-core-features`, `#inc-support-32932-version-of-8-8-that-does-not-have-memory-allocation-issue`.

**Colleagues** — first names only, in parentheticals when crediting a hand-off: `(from Stephan and Deepthi)`. Don't @-mention.

**Tone** — concise plain English. Semicolons OK. **No emojis. No section headers like "Yesterday:" or "Today:" inside the content** — Geekbot's prompts provide the framing.

**Clustering** — one bullet per coherent topic. Group related PRs into one bullet ("Took over PR #X, PR #Y, PR #Z (same case)"). Don't list every commit. List the merged PR or user-visible outcome.

**Issue-title rewriting** — when a P-task description is verbose (e.g. `[Bug] Explore solutions for and start breaking down Partitions gets unhealthy if many timers are scheduled #8991`), rewrite to a short header (`P3 - [#8991](https://github.com/camunda/camunda/issues/8991) Partitions unhealthy with many timers`).

## P-tasks file format

`~/.claude/skills/daily-standup/p-tasks.md`:

```markdown
---
updated: 2026-05-22
iso_week: 2026-W21
---

- P1: Drive Implement phase for AI Visibility & Explainability epic
- P2: Assist Business ID Visibility & Filtering epic
- P3: [Bug] Explore solutions for and start breaking down Partitions gets unhealthy if many timers are scheduled #8991
```

Refresh trigger: `date +%G-W%V` differs from frontmatter `iso_week`. Compute ISO week with `%G-W%V` (NOT `%Y-W%V` — `%Y` wraps wrong at year boundaries).

## Reference example

See `example.md` for a complete worked stand-up (Nico's 2026-05-21 output) — use it to disambiguate any style question this guide doesn't cover.

## Common mistakes

| Mistake                                                   | Fix                                                                                  |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `•` bullets                                               | `-` — Nico's clipboard mojibakes them                                                |
| Slack-mrkdwn `<url\|text>` links                          | `[text](url)` markdown                                                               |
| Listing every commit                                      | Cluster to the merged PR / outcome                                                   |
| Skipping P2/P3 when empty                                 | Include with `- Nothing yesterday` / `- Nothing planned today`                       |
| Adding "Yesterday:" / "Today:" inside the content         | Don't — Geekbot prompts provide framing                                              |
| Forgetting backticks on versions / branches / skill names | Apply consistently                                                                   |
| Em-dashes in section headers (`P1 — …`)                   | Space-hyphen-space: `P1 - …`                                                         |
| Pasting raw verbose issue title for P3                    | Rewrite: `P3 - [#<num>](url) <short title>`                                          |
| Linking with `(#51513)` instead of `[#51513](url)`        | Always provide the URL — including in P2/P3 section headers, not just prose         |
| Including a trivial fix-up commit as its own bullet       | Drop it — list only the parent PR                                                    |
| Producing a single combined message                       | Output TWO separable blobs; Nico posts them as separate Geekbot replies              |
| Skipping Slack — relying only on git                      | Support cases and planning posts have zero commits; always run the Glean Slack query |
| Stopping at the first 50 Slack results                    | Paginate until `hasMoreResults` is absent or cursor returns empty                    |
| Blank line between a section header and its first bullet  | No blank line — bullets follow the header on the very next line                     |
| Drafting all three items before posting any                | Agree then post one at a time: Yesterday, then Today, then Blockers or risks         |
| Posting `.` via Claude when there are no blockers/risks     | Don't — the auto-appended "Sent using @Claude" signature garbles a lone `.` in Geekbot's report. Tell Nico to post `.` himself instead |
| Organizing blockers/risks into P1/P2/P3                    | It's raw free text, no epic mapping                                                  |
