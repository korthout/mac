## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- Commit titles max 72 chars. Explain all considerations in the body.
- When removing permissions or settings, provide a wildcard replacement.

## GitHub CLI workaround

`gh` (and other Go-based CLIs) fail with TLS errors (`x509: OSStatus -26276`) through Claude Code's HTTPS proxy on macOS. Use `curl` with the GitHub REST API instead:
```bash
curl -s "https://api.github.com/..." -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github+json"
```

@RTK.md
