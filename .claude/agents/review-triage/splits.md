# Split analysis — hard block #4

Read only when total changed lines exceed 1000. Below that, the diff is reviewable as one unit
and the block does not apply.

Its job is to make "too large to review as one unit" checkable. Size alone is not the block —
**size plus decomposability** is. A large diff that genuinely cannot be split is not a block; it
is an expensive review, and that belongs in the budget driver instead.

## Step 1 — Total changed lines

```bash
gh pr view <N> --repo <owner>/<repo> --json additions,deletions
```

Sum them. This matches what GitHub's UI shows. Not on GitHub, or `gh` unavailable:

```bash
git diff --stat <base>...<head>   # both refs fetched locally first
```

## Step 2 — Does it decompose?

```bash
gh api repos/<owner>/<repo>/pulls/<N>/files --paginate \
  --jq '.[] | "\(.additions+.deletions)\t\(.status)\t\(.filename)"'
git log --oneline <base>..<head>   # commit boundaries, if cloned locally
```

Group by real structure, not line-count buckets:

- **Separate modules** that don't share call paths
- **Generated or vendored vs hand-written** — lockfiles, generated clients, snapshots. These add
  bulk without adding review risk, so separating them can drop the diff under the threshold
  entirely
- **Refactor vs behavior change** — mechanical renames and moves obscure the logic change they
  travel with, which is exactly why they shouldn't share a review pass
- **Independent features or fixes bundled together** — no shared files or call paths, each could
  stand alone
- **Commit boundaries** — but only when the commits are **independently mergeable**: each could
  land on its own, in any order, and leave the branch working. Commits that are *dependency-
  ordered steps of one change* — capability added dead in commit 2, wired up in commit 3, dead
  code removed in commit 4 — are not a split signal. They are good commit hygiene on an atomic
  change, and splitting them yields stacked PRs where the early ones are unmergeable on their own

**Tiebreaker.** Well-separated commits and "one tightly-coupled change for a single reason" often
both appear to hold — a careful author produces exactly that. When they conflict, **single reason
wins**: ask whether each proposed split delivers standalone value, or merely a prefix of one
change. If the latter, the diff is atomic no matter how tidy its commits are. Blocking a clean,
well-sequenced bugfix into stacked prefix-PRs is the technicality-bounce that destroys trust in
the gate.

## Outcome

**Decomposes** → hard block. Propose 2–4 splits, each as
`**<name>** — <contents> — <why separate>`. These *are* the pushback comment.

**Doesn't decompose** (one tightly-coupled change touching many files for a single reason) → not
a block. Say so explicitly and record it as the budget driver, e.g. "large but atomic — cannot be
split further."
