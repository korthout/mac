## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- When a skill's instructions say to use another skill, invoke that skill — don't skip ahead and do the work inline.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- Commit titles max 72 chars. Explain all considerations in the body.
- When responding to review feedback, decide between amend and new commit by *semantic intent*, not file overlap. Amend when the feedback refines or corrects the same intent the original commit expressed (typo, missed edge case, fix to the same bug). Create a new commit when the feedback changes *what behavior is wanted* — even if it edits the same files — because the original commit's intent stands and the new behavior is a separate semantic step.
- When removing permissions or settings, provide a wildcard replacement.
- Never read, print, generate, or pipe private keys, tokens, `.env`/credentials files, or any secret value — anything in tool output is exposed. Hand the user a command to run themselves. Public halves and secret *names* are fine.
- For any GitHub, Slack, or list API call, use full pagination by default (`gh api --paginate`, or loop until no next cursor / next page). Before reporting results, state the total count and confirm all pages were retrieved. Never report "all checks green" / "no failures" / "all comments addressed" without verifying `total_count` matches the retrieved count.

## GitHub CLI workaround

`gh` (and other Go-based CLIs) fail with TLS errors (`x509: OSStatus -26276`) through Claude Code's HTTPS proxy on macOS. Use `curl` with the GitHub REST API instead:
```bash
curl -s "https://api.github.com/..." -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github+json"
```

## Model selection

- Haiku: subagent retrieval/lookup with a narrow, well-specified target and no judgment (locate a file, grep a symbol, check whether X exists). If the task needs comprehension or synthesis, don't — a wrong cheap answer costs more to recover than it saved. Set `model: "haiku"` in the agent's frontmatter, or pass it explicitly for ad-hoc calls.
- Delegating only pays off when the subagent does its own costly retrieval, or the same task repeats enough that spin-up overhead amortizes across a fan-out. Don't delegate a handful of small, already-specified edits in files already read into context — do those inline.
- Sonnet is the default driving model for engineering work (implementation, TDD, git ops, CI debugging, PR triage, docs/issue drafting) — Opus is the exception, not Sonnet.
- Opus: adversarial review/verification, high-stakes or hard-to-reverse decisions (architecture, security/CVE impact, ambiguous scope), synthesis across many sources. Pass `model: "opus"` explicitly for these rather than defaulting the session to it.
- If an Opus session is doing routine implementation/CI/git work, or a Sonnet session keeps hitting architecture/security/adversarial-review calls, say so once and suggest switching tier — session-level, not per-message.

@RTK.md
