---
name: Backport PRs — don't amend cherry-picked commits
description: On backport PRs, review fixes go in NEW commits — never amend the cherry-picked commits
type: feedback
originSessionId: 3504dfcc-6080-4003-9cce-f4e0e669ef9b
---
On backport PRs (branches like `backport-NNNNN-to-stable/X.Y`), review fixes must land as new commits. Do NOT amend the cherry-picked commits, even when the fix edits the same files.

**Why:** The cherry-picked commits carry `(cherry picked from commit <sha>)` trailers tying them to the original PR. Amending mutates the SHA and breaks that provenance link — and rewriting history on an open PR forces reviewers to re-read everything from scratch.

**How to apply:** Overrides the general "amend the previous commit when review feedback edits the same files" rule whenever the current branch is a backport branch. Default to a new commit; one combined commit is fine if all fixes are the same flavor.
