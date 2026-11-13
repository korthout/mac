---
name: create-pr
description: "Use when asked to open, create, draft, or write a PR or PR description, or to edit an existing PR body."
---

# Create a PR

Follow these steps in order. Each one exists because a past PR got it wrong.

## 1. Title


In camunda/camunda, `<type>: <description>`, Conventional Commits, no scope (e.g. `fix: stop the due date checker from blocking the actor`). In camunda/camunda a CI check lints PR titles for release notes. Nico disagrees with that decision but follows it. Don't go back to the old "no prefix" rule. In other repos, don't use Conventional Commits in PR titles.

Name the effect, not the mechanism, same as a commit header.

## 2. Body structure: use the repo template

If the repo has `.github/pull_request_template.md`, read it first and fill in its sections. Don't swap in a generic Summary/Test-plan body.

- **Checklist items that don't apply:** tick them (`- [x]`). Do not delete them, even though the template says to. A ticked line shows the item was considered.
- **Related issues** (camunda/camunda): link the issue, not a PR. Use `closes #N` only when the PR fully resolves it, and `relates to #N` when it's one of several PRs. With no issue, tick the "does not need a linked issue" box. Issue refs go here, never in commit messages, because Nico rebases often and each rebased commit adds another cross-reference to the issue.
- End with `*Posted by an AI agent (Claude Code) on behalf of @korthout*`.

## 3. Description content: high level, three parts

The reader should get the intent in about 15 seconds. Cover:

1. **What it achieves.** Open with 1 or 2 sentences, written from the user's point of view: "You can now do X" or "X no longer breaks when Y". If the subject of the first sentence is a class, command or flag, rewrite it around what gets better for the user.
2. **Context, and why it's needed.** What's wrong or missing, and why it matters.
3. **What it changed to get there, at a high level.** Describe the change as one thing, in prose.
4. **Proof that the change works.** Include the most direct proof that you have that shows that this change achieves what the PR claims.

Leave out:

- **File lists or per-file edits.** The "Files changed" tab shows them.
- **Per-commit changelogs.** The Commits tab shows them. Mention a single commit only to give a reading order or to point at the crux.
- **Rationale already written in a commit body,** such as ADR citations or "did X instead of Y". Repeat it only if it matters at PR scope (e.g. why this PR is split from a sibling).
- **A "review feedback" section.** After a review, change the description only where it became wrong. The per-comment history belongs on the review threads.

Worth adding when relevant: non-obvious decisions and the alternatives you rejected, what is risky and what is mechanical, scope (what it deliberately does not do), and real validation evidence (not "ran tests").

**Links:** when the description mentions a file or directory that the PR does *not* change, link it with a permalink at a pushed SHA (`git rev-parse origin/main`; use `/tree/` for directories). Changed files need no link. Write commit SHAs bare, not in backticks, so GitHub links them.

Use plain English and short sentences, per CLAUDE.md.

## 4. No hard-wrap: check right before posting

GitHub shows every newline inside a paragraph as a line break, so each paragraph must be one line. Heredocs and prose reused from commit bodies (wrapped at ~72 chars) are what cause this. As a separate step right before the `gh` call, re-open the body and check for newlines inside paragraphs. Do this every time, even when you're sure you didn't wrap.

## 5. Sign-off before `gh pr create`

Show the final title and body in chat and wait for Nico's approval or edits before you open the PR. Drafting the description and opening the PR are two steps with a checkpoint between them.

- This rule holds even when a plan, another skill, or the task says "open the PR" as its last step. When their steps and this rule conflict, this rule wins.
- "Draft the PR" means draft the description for sign-off, not `gh pr create --draft`.
- If Nico says "open it" after seeing a draft, that is approval for *that* draft. If you changed the body after he saw it (added a line, filled the checklist), show the changes first.
- For camunda/camunda bug fixes, ask whether to backport. If yes, add the `backport stable/X.Y` labels when you create the PR.

Once you have approval: push the branch, then `gh pr create --body-file <file>`. Write the body file in the scratchpad, not in the repo.
