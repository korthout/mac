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

Rules:
- Use the exact section headings from the issue template — do not skip, rename, or rephrase them.
- Fill in every field from the template. If a field is not applicable, explicitly mark it as N/A rather than omitting it.
