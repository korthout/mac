---
name: feedback-review-nit-budget
description: Cap inline 🔧 suggestions at 0–5 most relevant per PR review; diagnose root cause if there are more
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 19d7fc05-7140-4c5b-b7a1-e296c05eacca
---

When reviewing a PR, **limit inline 🔧 suggestions to the 0–5 most relevant ones.** Don't dump every polish-level nit you noticed — pick the ones that genuinely improve the PR or prevent a future bug.

**Why:** The camunda/camunda PR review wiki says *"Focus on meaningful issues; postpone minor improvements to separate PRs"* and *"Approve changes once they definitely improve the code, even if imperfect — not perfect, but good enough."* My instinct is to file everything I see; the project norm is to trust the author and approve when the change is a net positive.

**How to apply:**
- Pick the top 0–5 🔧 nits by impact (correctness > maintainability > readability > style polish). Skip the rest, or roll several minor ones into a single "consider a follow-up polish pass" comment.
- If I'd genuinely want to file more than ~5, that's a signal — diagnose root cause:
  1. **PR scope too big?** Suggest the author split the PR into smaller ones.
  2. **Messy but not the author's fault?** (pre-existing debt) Tell the author you noticed it and there's an opportunity for follow-up cleanup.
  3. **Author being sloppy?** Tell them the repo is large with many contributors, so cleanliness in code *and* commit messages matters.
- See [[reference-review-emoji-code]] for emoji prefixes.
