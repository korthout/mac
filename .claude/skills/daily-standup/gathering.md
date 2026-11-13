# Gathering sources

Read this file in step 2 of `SKILL.md`. It holds the briefs for each source. Window = `[H, yesterday]` inclusive, computed in step 1.

## Contract for every subagent

Return **structured facts with provenance, not prose bullets**:
- the verbatim substance (a quote or close paraphrase, never "discussed X")
- the actual actor, when it differs from Nico or from the git commit author. Mark it `unverified` when the thread is ambiguous.
- for Slack: public or DM, plus `channel_id`/`message_ts` for public channels
- for GitHub: number, title, URL, verdict, and the date of the action

Over-include on *which* items to report, but keep each one to a sentence or two. Prose bullets lose the facts the rubric needs, and the main thread can't recover them. Aim for about 1,000 words for Slack and 700 for GitHub and conversations, plus half that for each extra working day in the window. Going over is fine when the extra facts could change a bullet, since fewer corrections beat a shorter report (2026-10-23). Refer to Nico's own long posts in one line with a link, not their full text.

Run the git log first, because its hits feed the GitHub subagent. Then launch the GitHub, Slack, Conversations and Calendar subagents in parallel in one message, with `run_in_background: false`. In each brief, replace every `<placeholder>` defined in `private.md` with its value. A literal placeholder makes a search return nothing, without an error.

If Nico said he is out of time, extend the window to include today for git, GitHub and conversations too. The done / didn't-get-to report needs today's work.

## Git commits (inline)

For each `~/gh/**/.git` (depth ≤ 3):

```bash
git log --all --author="korthout" --author="Nico Korthout" --since="<window-start> 00:00" --until="<window-end> 23:59:59" --pretty=format:"%h %ad %s" --date=short
```

Skip repos with no hits. Pass the repos with hits, and any PR numbers or SHAs, to the GitHub subagent.

## GitHub and authorship (one subagent)

1. Search with `curl` and the headers `-H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github+json"`. Don't call `gh` itself, because it fails through Claude Code's proxy on macOS. Run both `commenter:korthout` and `reviewed-by:korthout` with `org:camunda` (not one repo: `camunda-docs` approvals were missed on 2026-09-23) and `updated:>=<window-start>`. Never use a closed `updated:<a>..<b>` range: a later touch moves `updated_at` past the window and drops an in-window review (2026-08-06). Paginate fully.
2. For each hit, keep only reviews (`/pulls/<n>/reviews`, `submitted_at`) and comments (`/issues/<n>/comments`, `created_at`) dated inside the window.
3. Also call `mcp__claude_ai_Glean__user_activity` for the window. Approvals are often missing from `/search/issues`.
4. Resolve authorship of any commit or PR that might be someone else's work, such as a squash-merge Nico only merged. Use `git branch --contains` and the PR's `user.login`.

## Slack (one subagent)

Give it the window and the current P1/P2/P3 descriptions. After an ISO-week rollover, also give it last week's P-tasks, taken from the last history file's headers.

1. Call `slack_search_public_and_private` with `filters="from:<@<nico-slack-id>> on:<date>"`, `sort="timestamp"`, `response_format="concise"`, `limit=20`, once per day in the window (weekend days are cheap and catch weekend work) and once for today. Run the same searches with `<@<nico-slack-id>>` (mentions of Nico) instead of `from:`, to catch questions addressed to him that he hasn't answered yet (2026-11-03). Follow `cursor` until there is no next page. **Collect the complete list before applying keep/drop.** Filtering mid-pagination dropped real items on 2026-09-23. Concise results have no permalinks: for each kept public-channel item, get `message_ts` and the permalink with a targeted search (`keywords` plus `in:<#channel>`, `include_context=false`), and read the thread for others' replies (outcomes, agreement). Don't use Glean `search` for this: its pass-through to Slack stopped after 27 hits and cut threads to their first replies, missing Nico's key replies (2026-11-02).
2. Cross-check with `mcp__claude_ai_Glean__user_activity` for the same window. Only a Zoom *recording* proves a meeting was held; a Zoom meeting entry alone may just be scheduled (2026-11-12).
3. Separately, return Nico's messages from **today so far** (from step 1), especially daily-sync notes and promised follow-ups. Today's plan depends on them. Lead each with its action items (who does what) and decisions, then the context needed to judge them. Include new topics others opened today in the P-task channels; they may need a slot in today's syncs (2026-10-22). Also list new assignments to Nico today, such as `#cve-*` or `#inc-*` channels where he was made incident commander: they shape Today even when Yesterday has nothing on them (2026-10-29). Find these with `slack_search_channels` (keywords `inc`, then `cve`): read any channel created in the window or today that Nico joined (2026-10-30).
4. Keep: support and incident channels (`#inc-*`, `support-*`), `#cve-*`, team planning and DRI posts, substantive cross-team threads, escalations, and anything touching the P-tasks. Drop: one-word replies, Geekbot self-messages, social DMs, and threads on Nico's own open PRs. But report plans with colleagues (coworking, drinks) in one line each, with who joins.
5. Cluster multi-message threads into one item and list which messages were merged. A cluster's permalink may point at a parent message that predates the window. That's expected.

## Conversations (one subagent)

```bash
find ~/.claude/projects -maxdepth 2 -name "*.jsonl" -newermt "<window-start> 00:00" ! -newermt "<day-after-window-end> 00:00"
```

This is top-level only; exclude `subagents/`. mtime only nominates candidates, because a resume or worktree operation touches it. Confirm each candidate has at least one message `timestamp` inside the window (`jq -r '.timestamp' f.jsonl | sort -u`). Return the in-window timestamps, the topic or decision in close paraphrase, and the repo or module involved.

## Calendar (one subagent, `model: "haiku"`)

The raw output carries full attendee lists, so keep it out of the main thread. The subagent runs `mcp__claude_ai_Microsoft_365__outlook_calendar_search` with `query="*"`, `order="oldest"`, `limit=25`. Set `afterDateTime` to the window start and `beforeDateTime` to the end of the current ISO week. Paginate on `nextOffset` until `totalResultCount` is reached. Start and end times are in the mailbox time zone. It returns one line per event: date, start and end, subject, organizer, `isOrganizer`, `showAs`, and any agenda link from the summary. Skip Lunch and "Private appointment"; list Focus Time compactly, because it shows free time. If the tool fails, read today's agenda from the Outlook Calendar digest DM (`slack_read_channel` `<calendar-digest-dm>`, limit 1; times are epoch, local midnight is the `date^` value) and note the gap as an assumption (2026-11-13).

The main thread applies these rules to the list:

- **Yesterday:** an event shows what was scheduled, not what was attended.
  - Treat a meeting Nico organized, or one he accepted with `showAs: busy`, as held.
  - Treat `tentative` as skipped.
  - Any event, whatever its status, counts as held when something shows Nico attended: a Zoom recording, a recap, or a Slack message.
  - Search Slack for recap-bot posts about held meetings, not `from:` Nico, because the bot posts under its own name. Map a recap to its P-task, name the other person who attended (no link), and state the decision and the follow-up.
  - For overlapping events, assume the one Nico organized.
  - A held meeting with no recap and no thread still goes in Yesterday as "Joined X", without an invented outcome. Ask for the outcome in an assumption (2026-10-23). A sync Nico organizes should have AI-generated notes posted in its channel; if they are missing, say so in an assumption so he can still post them. An untitled Zoom meeting right after a sync is likely a follow-up session (e.g. an onboarding): ask about it in an assumption (2026-10-30). Action items in AI notes may already be done: check them against recent history Yesterday sections before planning them (2026-11-13).
- **Today:** meetings Nico organizes, kickoffs, and syncs with an agenda doc are strong plan signals. Read the linked agenda or pre-read when it shows what he must prepare. Large docs: save the result and extract only the latest meeting entry (e.g. with `jq`).
- **Rest of week:** an `Absent`/`oof` day means anything due "this week" happens today or moves to the next working day. Focus Time blocks show room for deep P-task work.

## Cross-checks (main thread, after gathering)

- **Previous plan.** Read the `## Today` and `## Notes` of `history/<H>.md`. For each planned item that `## Notes` doesn't mark `Dropped`, `Delegated` or `Done`, find the activity that confirms it.
  - Confirmed: report it in Yesterday.
  - No trace: add an assumption with a default ("No trace of X; assumed not done and carried into Today"). Never copy the plan into Yesterday unconfirmed.
- **Forgotten items.** Read only `## Today` and `## Notes` of the 4 history files before `H` (`ls history | grep -v "^$(date +%F)" | tail -5 | head -4`). Collect planned items and `Didn't get to` bullets, and dedupe them by PR or issue number. Drop any that later activity, a later Yesterday, or a Notes tag resolves, and any with a `Deferred until` date in the future. Also run `grep -h "Deferred until" history/*.md` and catch deferrals whose date has passed. Whatever remains becomes an assumption, never a draft bullet.
- **Late DMs.** Right before step 6, read DMs to Nico since the Slack subagent ran (`slack_search_public_and_private`, `to:<@<nico-slack-id>> is:dm on:<today>`). Asks arriving during the run shape Today (2026-11-11).
