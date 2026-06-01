---
name: PR titles have no conventional-commit prefix
description: PR titles in this repo do not use conventional-commit prefixes; commits do
type: feedback
originSessionId: aa5fc2c8-8b3d-48ec-9451-3e6c2d7d8962
---
PR titles in the camunda-main repo should NOT include a conventional-commit prefix (no `ci:`, `feat:`, `fix:`, etc.). PRs are not conventional commits — only individual commits follow that format.

**Why:** User correction; the AGENTS.md mention of "PR title follows conventional commit format" is outdated/inaccurate per the user.

**How to apply:** When drafting any PR title in this repo, write a plain descriptive sentence (e.g., "Bump backport-action to v4.5.0 and enable summary comments") rather than `ci: ...`. Continue using conventional-commit prefixes for individual commit titles.
