---
name: reference-review-general-comment-template
description: "Template structure to use for the general (top-level) PR review comment in camunda/camunda, matching the user's house style"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 19d7fc05-7140-4c5b-b7a1-e296c05eacca
---

When drafting the general review comment for a camunda/camunda PR, follow this template (matches korthout's own house style across 8+ recent reviews):

```
Thanks @<author> [🚀 or 👏 if the PR is particularly nice — sparingly]

[Optional: 👍 <one short, specific praise sentence>]

[Optional: ❓ <question> / 🔧 <minor non-blocking note> — each its own short paragraph]

LGTM 👍   ← for approvals; or "Otherwise 👍 LGTM" if there are still ❓
```

**Conventions:**
- **Always open with `Thanks @<handle>`** — never skip; addresses the author by GitHub handle.
- **Decoration emojis (🚀, 👏)** are sparing — only for PRs that are genuinely a treat to review (clear scope, great tests, strong description). Default to plain "Thanks @author".
- **Compact paragraphs**, one per emoji-prefixed point. **No wrap-up paragraph** at the bottom restating the main concern — the inline 🔧s carry the detail.
- **`LGTM 👍` stands alone at the end** for approvals. If there are unresolved ❓, use `Otherwise 👍 LGTM`.
- **Tone is brief and warm.** Even substantive reviews keep each paragraph short.
- Combine with [[reference-review-emoji-code]] for inline-comment prefixes and [[feedback-review-nit-budget]] for the 🔧 cap.

**Examples (from korthout's own reviews):**

Routine approval, nothing to flag:
```
Thanks @pranjalg13

LGTM 👍
```

Approval with one praise callout:
```
Thanks @ce-dmelnych 🚀

👍 Clear note on bpmnProcessId (protocol) vs processDefinitionId (REST) split.

LGTM 👍
```

Approval with a non-blocking suggestion:
```
Thanks @fabiopaini-camunda 🚀

LGTM 👍

🔧 Please do consider copilot's review comment before merging. I agree with it.
```

Pending question, no approval yet:
```
Thanks @fabiopaini-camunda

❓ I have a few questions
```

Approval with deferred question:
```
Thanks @fabiopaini-camunda 🚀

❓ One question: Do we want to allow filtering/sorting on agentInstanceKey as well?

Otherwise 👍 LGTM
```
