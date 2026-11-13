---
name: pr-review-comments
description: Use when drafting a review or review comments on someone else's PR.
---

# PR review comments (camunda/camunda)

This is Nico's (GitHub `korthout`) review style for camunda/camunda PRs. Use it for every review comment you draft.

## Emoji code

Start every review comment with the emoji that matches its intent. The code comes from `CONTRIBUTING.md` ("Review emoji code").

- 👍 `:+1:` Positive. Call out what is great.
- ❓ `:question:` Open question. Needs clarification.
- ❌ `:x:` Must change (error, strong convention violation). This means "Request changes".
- 🔧 `:wrench:` Suggestion or minor issue. Non-blocking.
- 💭 `:thought_balloon:` Thinking out loud. An observation with no change proposed.

### Any proposed change is 🔧, never 💭

Use 💭 only for a pure observation. The author is not expected to act on it. Examples: "interesting that this happens", "this reminds me of ...".

If you ask the author to do, add, rename, restructure, or even consider something, use 🔧. This holds for "consider X", "worth either X or Y", and "could be a follow-up".

Why: softness of tone does not separate 💭 from 🔧. Whether the comment carries a proposal does. Put the hedge in the words of the 🔧 ("non-blocking, but ..."), not in the emoji.

Check before you tag 💭: does this propose anything? If yes, it is 🔧.

## Inline comments

Keep comments short. One or two sentences is the default. Expand only for design pushback, several related points, or a real trade-off. Do not over-explain mechanical fixes.

### ❓ is a raw question

Say why you ask (what triggered the question). Do not attach your own answer. The author may have reasons you have not seen. Hearing them is worth more than your guess.

- Good: "❓ Was this documented by the Spring Security 7 migration guide? If so, it would be good to link it for additional reading."
- Good: "❓ I'm not so eager to include this, because there may be cases where there could be many keys in there. Do we need this?"
- Bad: "❓ Was this documented by the migration guide? It probably was, so consider linking it." The answer is bundled in.

### 🔧 is a direct imperative

Write "Please add X", "Please replace Y", "Please drop Z". Do not write "Would you mind ...", "Could you ...", or "Did you consider ...".

Why: once you have a proposal, state it. Keep real interrogatives for ❓. The non-blocking tone comes from explicit words ("non-blocking") and from the 🔧 itself, not from phrasing the ask as a question.

- Good: "🔧 Please add a case combining the two."
- Bad: "🔧 Could you add a case combining the two?" Same request, weaker delivery.

A 🔧 may carry the change itself. Use a GitHub ` ```suggestion ` block when the change is mechanical and you want one-click apply. Use prose with alternatives when the author should choose.

### Hedge with words

For non-blocking points, use words like "I think", "non-blocking", "Personally, I think". This softens tone without weakening the ask. Use plain declarative voice for ❌ ("This has to change") and keep it for real errors.

### Praise is specific

Name what was done well and briefly why. Generic praise adds little.

- Good: "👍 This is a great example of one of the few cases where `verify()` is actually great. [...] here we want to do two things: show what it does and show how it works."
- Bad: "👍 Looks great."

### Replies

- Open with a short acknowledgment when the author fixed something: "Good catch", "Perfect! Thanks".
- Push back when warranted. Name the principle you rely on.
- `@-mention` others when a design talk belongs upstream of the PR.

## General (top-level) comment

Use this template.

```
Thanks @<author> [🚀 or 👏, only if the PR is a treat to review]

[Optional: 👍 <one short, specific praise sentence>]

[Optional: ❓ question / 🔧 minor note, each in its own paragraph]

LGTM 👍
```

Rules:

- Always open with `Thanks @<handle>`. Use the author's GitHub handle.
- Use 🚀 or 👏 sparingly. Only for a clear scope, great tests, and a strong description. Default to a plain "Thanks @author".
- Write one blank-line-separated paragraph per emoji point. Never bunch several 👍, 🔧, or ❓ points into one running paragraph. This holds even when several points share an emoji.
- Do not add a wrap-up paragraph that repeats the main concern. The inline 🔧 comments carry the detail.
- End an approval with `LGTM 👍` alone on its line. If a ❓ is still open, end with `Otherwise 👍 LGTM`.
- Keep the tone brief and warm.

Examples:

```
Thanks @author

LGTM 👍
```

```
Thanks @author 🚀

👍 Clear note on bpmnProcessId (protocol) vs processDefinitionId (REST) split.

LGTM 👍
```

```
Thanks @author 🚀

LGTM 👍

🔧 Please do consider copilot's review comment before merging. I agree with it.
```

```
Thanks @author

❓ I have a few questions
```

```
Thanks @author 🚀

❓ One question: Do we want to allow filtering/sorting on agentInstanceKey as well?

Otherwise 👍 LGTM
```

## Nit budget: 0 to 5 inline 🔧

Post only the 0 to 5 most relevant inline 🔧 comments. Rank by impact: correctness, then maintainability, then readability, then style. Skip the rest, or roll minor ones into one "consider a follow-up polish pass" comment.

Why: the camunda/camunda review wiki says to focus on meaningful issues and postpone minor improvements to separate PRs. It also says to approve once the change definitely improves the code, even if imperfect. The urge is to file everything. The norm is to trust the author.

If you want to file more than about 5, find the root cause and say it:

1. PR scope too big? Suggest splitting it into smaller PRs.
2. Messy, but not the author's fault (existing debt)? Say you noticed it and that a follow-up cleanup is an opportunity.
3. Author being sloppy? Say the repo is large with many contributors, so clean code and clean commit messages matter.

## Submit as APPROVE when there is no blocker

If no comment is ❌ or a "must change before merge" 🔧, submit the review with `event: "APPROVE"`, not `COMMENT`. Scan your planned comments first.

Why: a `COMMENT` review without blockers leaves the author unsure if you would approve once they address the soft feedback. It reads as indecision. Approve with suggestions says "ship it, here is stuff to consider".

- 👍, 🔧, 💭, and ❓ alone do not justify withholding approval.
- `LGTM` in the general body is the trigger. A body that starts with `LGTM 👍` must be submitted as `APPROVE`. A mismatch has to be fixed.
- Inline 🔧 and 💭 do not downgrade an approval.

## Walkthroughs: share your findings first

When you review a PR commit by commit (or any code walkthrough), share your own findings before you ask what the user noticed. For each commit, file, or section:

1. State what you observed (correctness, style, risks, inconsistencies).
2. Ask if they noticed anything else.
3. Wait for the answer.
4. Move on.

Why: the user wants a review partner, not an interviewer. Asking "what do you notice?" first hands the work back and delays your value. Give your independent read first. They will add or push back.
