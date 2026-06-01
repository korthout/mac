---
name: feedback-review-thought-vs-suggestion
description: "💭 is for pure observation with no actionable proposal; anything that proposes a change (even softly, even \"consider...\") is 🔧"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 51f4d128-1ac5-4674-ac0a-1b38d7af5cec
---

In camunda/camunda PR reviews, 💭 is reserved for pure observations or musings that do NOT propose a change. The moment a comment contains a concrete suggestion — "consider", "worth either X or Y", "suggest adding" — it becomes 🔧, regardless of how softly it's hedged. "Soft suggestion" is still a suggestion.

**Why:** I repeatedly used 💭 to hedge suggestions that I wanted to feel non-blocking. The user corrected this — softness of tone is not what distinguishes 💭 from 🔧. The distinguishing feature is whether the comment carries a proposal at all. Hedging belongs in the prose of a 🔧 ("non-blocking, but…"), not in the emoji.

**How to apply:** Before tagging a comment 💭, check: does it propose anything? Does it suggest the author do X? If yes — even "consider X" — use 🔧. Reserve 💭 for true musings: "interesting that this happens", "this reminds me of…", observations about the change that the author isn't expected to act on.

Related: [[reference_review_emoji_code]], [[reference_review_inline_comment_style]], [[feedback_review_nit_budget]].
