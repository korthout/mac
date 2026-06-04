---
name: daily-standup
description: Use when Nico asks to write his daily stand-up, stand-up message, Geekbot reply, or to summarize yesterday's work for stand-up. Produces both "Yesterday" and "Today" sections in Nico's house style, organized by his current P1/P2/P3 epics with everything else under "Also". Posted in Slack #team-core-features-charlie.
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

4. **Synthesize** both sections. Map each activity item to P1 / P2 / P3 if it relates to that epic; otherwise to **Also**. When unsure, prefer **Also**. Drop trivial follow-up commits (test imports, lint fixups, minor renames) that belong to a larger merged PR — list the PR, not its commits.

5. **Output** two clearly-separable blobs preceded by bold labels that Nico discards when pasting:

   ```
   **For "What did you work on yesterday?":**

   P1 - …

   ---

   **For "What will you work on today?":**

   P1 - …
   ```

   Nico copies each blob to the matching Geekbot question — they go in as separate messages.

## Style guide

**Section headers** — one per P-section, blank line after:

- `P1 - <Epic name> (<Phase>)` — include phase in parentheses if the P-task description names one (e.g. "Drive Implement phase" → `(Implement)`); omit if the P-task doesn't name a phase.
- `P3 - #<num> <short title>` when the P-task is a single issue — number first, then a short human-readable title (rewrite — do NOT paste the raw issue title verbatim).
- `Also` — no number, no phase.

**Bullets** — ASCII hyphen + space: `- item`. **NEVER `•`**. **NEVER em-dash `—` bullets**. Nico's clipboard mojibakes Unicode bullets.

**Empty P-section** — one bullet:

- Yesterday: `- Nothing yesterday`
- Today: `- Nothing planned today`

Always include all three P-sections even if empty.

**Links** — GitHub-flavored markdown `[text](url)`. Two acceptable forms:

- **Preferred:** `[<Full PR or issue title> #<num>](url)` when the title carries information the reader needs. Example: `[Track multiple element instances per agent instance #51513](https://github.com/camunda/camunda/issues/51513)`.
- **Shorthand:** `[PR #<num>](url)` when mid-bullet and the surrounding text already conveys the topic. Example: "took over [PR #53028](url)".
- **NEVER** Slack-mrkdwn `<url|text>`. **NEVER** bare URLs. **NEVER** `(#num)` without a link.

**Inline code (backticks)** — apply consistently to:

- version numbers: `` `3.5.2` ``
- branch names: `` `stable/8.8` ``, `` `main` ``
- file names: `` `fetch_audit_data.ts` ``
- skill/plugin/tool names: `` `reviewing-agent-ready-prs` ``, `` `gh auth refresh` ``

**Slack channel references** — when an item maps to a Slack channel (CVEs, incidents, project channels), write the channel as plain `#channel-name` — Slack auto-links it. Don't link or backtick. Examples: `#cve-2026-4046-medium-core-features`, `#inc-support-32932-version-of-8-8-that-does-not-have-memory-allocation-issue`.

**Colleagues** — first names only, in parentheticals when crediting a hand-off: `(from Stephan and Deepthi)`. Don't @-mention.

**Tone** — concise plain English. Semicolons OK. **No emojis. No section headers like "Yesterday:" or "Today:" inside the content** — Geekbot's prompts provide the framing.

**Clustering** — one bullet per coherent topic. Group related PRs into one bullet ("Took over PR #X, PR #Y, PR #Z (same case)"). Don't list every commit. List the merged PR or user-visible outcome.

**Issue-title rewriting** — when a P-task description is verbose (e.g. `[Bug] Explore solutions for and start breaking down Partitions gets unhealthy if many timers are scheduled #8991`), rewrite to a short header (`P3 - #8991 Partitions unhealthy with many timers`).

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
| Pasting raw verbose issue title for P3                    | Rewrite: `P3 - #<num> <short title>`                                                 |
| Linking with `(#51513)` instead of `[#51513](url)`        | Always provide the URL                                                               |
| Including a trivial fix-up commit as its own bullet       | Drop it — list only the parent PR                                                    |
| Producing a single combined message                       | Output TWO separable blobs; Nico posts them as separate Geekbot replies              |
| Skipping Slack — relying only on git                      | Support cases and planning posts have zero commits; always run the Glean Slack query |
| Stopping at the first 50 Slack results                    | Paginate until `hasMoreResults` is absent or cursor returns empty                    |
