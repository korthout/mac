---
name: feedback-review-raise-topics-first
description: "During code-review walkthroughs, raise findings yourself before asking what the user noticed"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 19d7fc05-7140-4c5b-b7a1-e296c05eacca
---

When reviewing a PR commit-by-commit (or any code walkthrough), share your own findings on the commit **before** asking the user what they noticed. Then let the user respond before moving on.

**Why:** The user is using you as a review collaborator, not an interviewer. Asking "what do you notice?" first off-loads the work back onto them and delays the value you can add. They want your independent read first; they'll add or push back on it.

**How to apply:** For each commit/file/section under review: (1) state what you observed (correctness, style, risks, inconsistencies); (2) ask if they noticed anything else; (3) wait for response; (4) proceed.
