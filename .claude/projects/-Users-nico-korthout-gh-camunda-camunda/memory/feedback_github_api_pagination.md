---
name: feedback-github-api-pagination
description: "GitHub API list endpoints (check-runs, issues, comments, etc.) paginate at per_page=100; always check total_count and the Link header"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 0aca1930-d1f4-4a64-adf8-5fb03c1e4675
---

When querying GitHub API list endpoints via `curl` (check-runs, issues, comments, pull requests, workflow runs, etc.), `per_page=100` is the MAX page size — not "all results". For large monorepos like camunda/camunda, CI runs commonly emit 120–150+ check-runs, so a single request silently truncates and hides failures.

**Why:** Got bitten on PR #53272 monitoring — saw "100 checks, 0 failures" and called the fix healthy, but page 2 had 27 more checks I never inspected. User caught it.

**How to apply:**
- For check-runs, always inspect `total_count` in the JSON; if `total_count > 100`, paginate with `&page=2`, `&page=3`, … until exhausted.
- Or use the `Link: …; rel="next"` response header (visible with `curl -sI`) to detect more pages.
- A round-number count of exactly 100, 200, 300 is a smell — assume truncation until proven otherwise.
- Same trap applies to `/issues`, `/pulls`, `/comments`, `/runs`, `/jobs`, etc.

Quick pattern:
```bash
for page in 1 2 3; do
  curl -s ".../check-runs?per_page=100&page=$page" -H "..." | jq '.check_runs[] | select(.conclusion!="success" and .conclusion!="skipped" and .conclusion!=null)'
done
```
