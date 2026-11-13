---
name: commit-style
description: Nico's personal git commit style. Use before every git commit, amend, rebase, squash or cherry-pick, and before writing or rewording commit messages.
---

# Commit style

- Titles max 72 chars, aim for 50. Explain all considerations in the body.
- One commit per reason for a change. Choose amend or a new commit by the *reason*, not by which files change or whether behavior changes.
  - Amend when the change corrects what the commit meant to do: a typo, a wrong assertion, a missed case within the same goal.
  - Make a new commit when the change has its own reason, even in the same lines with the same behavior: new wanted behavior, a performance gain, more robustness. A bug that this work reveals gets its own failing-test and fix commits too.
- On backport PRs, never amend the cherry-picked commits; add new ones. Amending breaks the `cherry picked from` link to the original PR and makes reviewers re-read everything.
- Bug fixes: first commit only the failing test, so reviewers can check out that commit and see it fail. Then commit the fix, including old tests that encoded the buggy behavior. Add a refactor commit between the two only when the fix can't land cleanly without it.
- Refactors: small strangler-fig commits that each build green. Build the new code next to the old, move callers over one at a time, and delete the old code (and its tests) last. Put the feature that needs the refactor in its own stacked PR. Unused scaffolding in a refactor PR hides which code is live.
- No issue references like `#123` in commit messages. I rebase often, and every rebase adds another cross-reference to the issue. Put them in the PR.
- Explain why for every non-default choice, in the body and not in a code comment. For example, `SoftAssertions`: say what would be lost with plain assertions, not just what it does.
- When you resolved conflicts (merge, rebase, cherry-pick, backport), explain in the body what you changed compared to the original and why. The original message alone misrepresents what the commit contains.
- After restructuring commits, reread every message. Remove mentions of tests, commits or drafts that are no longer in the history, and describe each change as the final history shows it.
