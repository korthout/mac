---
name: github-commit-refs
description: How to reference commits in GitHub issue/PR comments so they auto-link
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c7e48cde-ceb1-4384-bd10-db726160fc5c
---

Don't wrap commit SHAs in backticks in GitHub issue or PR text. Write them bare (e.g. 8b807311021) so GitHub's UI automatically renders them as clickable links.

**Why:** Backticks render the SHA as inline code, which prevents GitHub from auto-linking it to the commit.

**How to apply:** Any time writing a commit SHA into a GitHub issue body, comment, or PR description.
