---
name: github_create_issue
description: Create a GitHub issue by first gathering context from the user, then build a shared understanding before drafting and submitting the issue with gh CLI.
---

Help me create a new GitHub issue. Follow this process:

## Phase 1: Gather context and check for duplicates

If the user has not yet described the issue, ask them to describe it. Otherwise, use the information they have already provided.

If no prior research was done in this conversation, use the `github-issue-searcher` agent to check for existing issues that may cover the same problem before proceeding. If a likely duplicate exists, surface it and ask how to proceed.

## Phase 2: Build a shared understanding

Use the grill me skill to reach a shared understanding.

Key branches to resolve (as applicable to the issue type):

- **Issue Type**: which issue template to use (check `.github/ISSUE_TEMPLATE/` in the repo)
- **Title**: concise, max 65 chars
- **Template Fields**: cover all needed info (depends on issue template, e.g. bug needs affected-version)
- **Scope**: is the issue framed correctly (narrow vs broad)
- **Alternatives**: were other approaches considered, briefly document rejected ones
- **Labels**: which labels to apply
- **Projects**: which projects to add, always suggest `Core Features`
- **Checklist items**: follow-up tasks to track in the issue

## Phase 3: Confirm and create

Once all branches are resolved, present a final summary of the issue and ask for confirmation. Then create the issue using `gh issue create`.

## Formatting rules

- **Match the actual rendered format**: before writing the issue body, check a recent issue created from the same template (e.g. `gh issue list --label kind/bug --limit 1` then `gh issue view <number> --json body`) to see exactly how GitHub renders the template fields. Reproduce that format exactly.
- **Dropdown fields as HTML comments**: YAML form dropdown fields (Component, Affected version, Severity, Likelihood) are rendered as HTML comments at the top of the body. Use the exact format from the template YAML (e.g. `<!-- Zeebe- -->`, `<!-- -8.8 -->`, `<!-- Medium- -->`, `<!-- Low_ -->`). The heading for each dropdown is also a comment (e.g. `### <!-- Component -->`). These comments are invisible when rendered on GitHub — that is intentional. GitHub parses these to automatically apply labels and populate template fields, so they must be exact.
- **Preserving HTML comments in shell**: `<!--` contains `!` which zsh history expansion will escape to `\!` inside heredocs and command substitutions. To avoid this, write the issue body to a file using the Write tool (not a shell heredoc), then use `python3 -c "import json; ..."` to JSON-encode it for the API. Never use `jq --arg` or shell heredocs for bodies containing HTML comments.
- **Section headings**: use `##` for content sections (Description, Steps to reproduce, etc.), matching the rendered output.
- Use the exact section headings from the issue template — do not skip, rename, or rephrase them.
- Fill in every field from the template. If a field is not applicable, explicitly mark it as N/A rather than omitting it.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Including raw UUIDs or customer IDs from logs | Every UUID must be evaluated — redact if customer-facing |
| Copying log messages verbatim without scanning for PII | Scan for embedded IDs, emails, hostnames first |
| Skipping the draft review step | Always present the full draft and wait for explicit approval before creating |
| Leaving placeholder values (e.g. version "8.8.21") when the actual value is available | Populate from logs or context if available |
| Using `fix:` or conventional-commit prefix in title | Issue titles are descriptive sentences, not commit messages |
| Wrapping component in title, e.g. `[Gateway] ...` | No brackets or component prefix — just a plain descriptive sentence |
| Adding `type: bug` as a label | "Bug" is a GitHub Issue Type, not a label — set it via GraphQL after creation |
