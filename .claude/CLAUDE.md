## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- When a skill's instructions say to use another skill, invoke that skill — don't skip ahead and do the work inline.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- Commit titles max 72 chars. Explain all considerations in the body.
- When responding to review feedback, decide between amend and new commit by *semantic intent*, not file overlap. Amend when the feedback refines or corrects the same intent the original commit expressed (typo, missed edge case, fix to the same bug). Create a new commit when the feedback changes *what behavior is wanted* — even if it edits the same files — because the original commit's intent stands and the new behavior is a separate semantic step.
- When removing permissions or settings, provide a wildcard replacement.
- Never read, print, generate, or pipe private keys, tokens, `.env`/credentials files, or any secret value — anything in tool output is exposed. Hand the user a command to run themselves. Public halves and secret *names* are fine.

## GitHub CLI workaround

`gh` (and other Go-based CLIs) fail with TLS errors (`x509: OSStatus -26276`) through Claude Code's HTTPS proxy on macOS. Use `curl` with the GitHub REST API instead:
```bash
curl -s "https://api.github.com/..." -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github+json"
```

@RTK.md
