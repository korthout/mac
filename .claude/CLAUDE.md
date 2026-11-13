## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- When a skill's instructions say to use another skill, invoke that skill — don't skip ahead and do the work inline.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- When something is worthwhile to remember in future sessions, don't store in auto-memory for the project. Instead, consider whether it applies only to this repo, then store it in the repo (e.g. docs, skills, CLAUDE.md), otherwise consider storing it in a personal skill or ~/.claude/CLAUDE.md.
- Write commit messages, code comments, issue descriptions, pull request bodies, and comments on GitHub and Slack in the following way. Use simple, plain English. Use short sentences. Use everyday words, ubiquitous language used at Camunda, and name concepts from this codebase directly.
- Before writing an inline comment, name the reader and what they would do differently for having read it. If you can't name both, don't write it. Same if a test would catch the same regression. If restructuring the code removes the need, do that instead of writing the comment. If it belongs in the commit message, put it there instead — don't just skip it.
- Commit titles max 72 chars. Explain all considerations in the body.
- When responding to review feedback, decide between amend and new commit by *semantic intent*, not file overlap. Amend when the feedback refines or corrects the same intent the original commit expressed (typo, missed edge case, fix to the same bug). Create a new commit when the feedback changes *what behavior is wanted* — even if it edits the same files — because the original commit's intent stands and the new behavior is a separate semantic step.
- On posts made for the user (GitHub issues, PRs, comments; not Slack), end with `*Posted by an AI agent (Claude Code) on behalf of @korthout*`. `@korthout` is their GitHub handle; elsewhere use their handle there.
- At Camunda, reach people about work (incidents, coordination, asks) with a mention in a public channel, never a Slack DM. For an incident, that is its own incident channel. If you can't post there (not a member), ask the user to join it; don't fall back to a DM or another channel.
- Never read, print, generate, or pipe private keys, tokens, `.env`/credentials files, or any secret value — anything in tool output is exposed. Hand the user a command to run themselves. Public halves and secret *names* are fine.
- For any GitHub, Slack, or list API call, use full pagination by default (`gh api --paginate`, or loop until no next cursor / next page). Before reporting results, state the total count and confirm all pages were retrieved. Never report "all checks green" / "no failures" / "all comments addressed" without verifying `total_count` matches the retrieved count.

## Model selection

- Haiku: subagent retrieval/lookup with a narrow, well-specified target and no judgment (locate a file, grep a symbol, check whether X exists). If the task needs comprehension or synthesis, don't — a wrong cheap answer costs more to recover than it saved. Set `model: "haiku"` in the agent's frontmatter, or pass it explicitly for ad-hoc calls.
- Delegating only pays off when the subagent does its own costly retrieval, or the same task repeats enough that spin-up overhead amortizes across a fan-out. Don't delegate a handful of small, already-specified edits in files already read into context — do those inline.
- Sonnet is the default driving model for engineering work (implementation, TDD, git ops, CI debugging, PR triage, docs/issue drafting) — Opus is the exception, not Sonnet.
- Opus: adversarial review/verification, high-stakes or hard-to-reverse decisions (architecture, security/CVE impact, ambiguous scope), synthesis across many sources. Pass `model: "opus"` explicitly for these rather than defaulting the session to it.
- If an Opus session is doing routine implementation/CI/git work, or a Sonnet session keeps hitting architecture/security/adversarial-review calls, say so once and suggest switching tier — session-level, not per-message.

@RTK.md
