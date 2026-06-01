---
name: Use repo PR template for camunda/camunda
description: PRs in camunda/camunda must use .github/pull_request_template.md structure
type: feedback
originSessionId: aa5fc2c8-8b3d-48ec-9451-3e6c2d7d8962
---
When opening PRs against `camunda/camunda`, always use the repo's PR template at `.github/pull_request_template.md` for the body. Sections: `## Description`, `## Checklist` (with the backport-enablement item), `## Related issues` (`closes #...`).

**Why:** Repo convention; reviewers expect the standard structure (and the backport checklist matters for CI/bug-fix PRs in this monorepo).

**How to apply:** Read `.github/pull_request_template.md` before drafting any PR body in this repo and fill in those sections — don't substitute a generic Summary/Test-plan body. Drop the "Enable backports" checklist line if the PR clearly doesn't need it (per the template's own "delete options that are not relevant" note).
