---
name: Commit title length
description: Keep commit titles short, preferably under 50 chars (max 72)
type: feedback
originSessionId: aa5fc2c8-8b3d-48ec-9451-3e6c2d7d8962
---
Commit titles should be short — preferably under 50 characters. Hard max is 72 chars (per global CLAUDE.md). Push details into the commit body.

**Why:** User preference for scannable git log; shorter titles render fully in GitHub UI and `git log --oneline`.

**How to apply:** When drafting any commit message in this repo, target ≤50 chars for the title. Move version numbers, rationale, and "and X" clauses into the body if they push the title over.
