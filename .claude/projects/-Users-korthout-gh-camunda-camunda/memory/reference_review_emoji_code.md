---
name: reference-review-emoji-code
description: camunda/camunda CONTRIBUTING.md defines an emoji code for PR reviews; use it on every review comment
metadata: 
  node_type: memory
  type: reference
  originSessionId: 19d7fc05-7140-4c5b-b7a1-e296c05eacca
---

When drafting PR review comments for camunda/camunda, **always use the project's emoji code** (defined in `CONTRIBUTING.md` → "Review emoji code"):

- 👍 `:+1:` — positive: this is great, call it out
- ❓ `:question:` — open question, needs clarification
- ❌ `:x:` — must change (error, strong convention violation) → maps to "Requesting changes"
- 🔧 `:wrench:` — well-meant suggestion or minor issue, non-blocking. **Any suggestion to change something — even if optional — is 🔧, not 💭.**
- 💭 `:thought_balloon:` — thinking out loud; sharing an observation **without** suggesting a change. If you're asking the author to do, add, rename, restructure, or even *consider* doing something, it's 🔧.

**How to apply:**
- Prefix every review comment with the emoji that matches its intent.
- Default to 🔧 for any actionable feedback, even "could be a follow-up" — those are still suggestions to act. 💭 is only for "FYI / I noticed this / no action implied."
- Approve a PR if comments are only 👍/🔧/💭 (and possibly ❓).
- For an approving general review comment, lead with `LGTM 👍` and a one-line framing like *"Minor review points below, nothing blocking"*, then 2–3 👍 callouts for genuinely well-done things. Don't skip the praise — the emoji code intentionally makes it part of the workflow.
- **`LGTM` in the general body is the trigger word for an APPROVE-event review.** When the body starts with `LGTM 👍`, the GitHub review must be submitted with `event: "APPROVE"`, not `COMMENT`. Inline 🔧/💭 comments are non-blocking and don't downgrade an approval. Submitting as `COMMENT` when the body says LGTM is a mismatch and has to be corrected.
- The full guidance lives in `CONTRIBUTING.md` of the camunda/camunda repo.
