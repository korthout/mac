---
name: feedback-review-approve-when-no-blockers
description: "PR reviews without blockers/❌ change requests should be submitted as APPROVE, not COMMENT"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b02fb479-6086-43f9-85f4-860fe121675a
---

If a PR review contains no blockers (❌) or hard change requests, submit it as `event: APPROVE`, not `event: COMMENT`.

**Why:** A COMMENT review without blockers leaves the author wondering whether you'd approve once they address the soft feedback — it signals indecision. Approving with suggestions communicates "ship it; here's stuff to consider" clearly.

**How to apply:** Before posting a review via `POST /repos/{owner}/{repo}/pulls/{n}/reviews`, scan the planned comments. If none are ❌ or "must change before merge" 🔧, set `"event": "APPROVE"`. 🔧 recommendations, 💭 follow-up suggestions, ❓ questions, and 👍 praise alone don't justify withholding approval. Relates to [[reference-review-emoji-code]] and [[reference-review-general-comment-template]].
