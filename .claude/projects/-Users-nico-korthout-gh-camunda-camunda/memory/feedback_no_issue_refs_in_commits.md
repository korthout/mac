---
name: no-issue-refs-in-commits
description: "Don't reference GitHub issues in commit messages; reference them in PR descriptions instead"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 33e84dcb-9e14-41d3-9177-8df81a2b5bb7
---

Don't reference GitHub issues (e.g. `#1234`, `Closes #1234`, `Relates to #1234`) in commit messages. Reference issues in the pull request description instead.

**Why:** Nico rebases often. Every rebased commit that references an issue creates a new cross-reference on that issue, flooding the issue with what looks like many commits when it's really the same commit rewritten.

**How to apply:** When writing commit messages (including amends and new commits on a branch), keep the body focused on the *why* of the change with no `#NNN` issue references. Put `Closes #NNN` / issue links in the PR body instead — PRs don't get rebased, so the reference stays stable.
