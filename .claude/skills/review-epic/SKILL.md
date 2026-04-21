---
name: review-epic
description: Review a GitHub epic issue to surface unclarity, ambiguousness, or vagueness in its User Problem and User Stories sections. Use when user wants to review an epic, check an epic for gaps, or mentions "review epic".
---

Review the GitHub epic issue provided by the user. Focus exclusively on the **User Problem** and **User Stories** sections.

Produce a short list of pointed questions that surface any:
- **Unclarity**: statements that can be read in more than one way or lack enough detail to act on
- **Ambiguousness**: terms, scope boundaries, or acceptance criteria that are open to conflicting interpretations
- **Vagueness**: hand-wavy language ("should be fast", "handle edge cases", "etc.") that hides real requirements

Group questions into two sections:
1. **Blocking** — questions that would change implementation decisions or scope
2. **Clarification needed** — questions that improve understanding but won't block progress

For each question, reference what part of the issue it relates to.

Rules:
- DO NOT edit any files or enter plan mode. This is discussion only.
- Only reply with questions.
- Keep the list concise — aim for the questions that would change implementation decisions, not nitpicks.
- Keep questions short for clarity.
- Do not suggest rewrites or solutions; only ask questions.
- If a question can be answered by exploring the codebase, explore the codebase first and drop the question if resolved.
- If the issue URL is not provided, ask for it.
