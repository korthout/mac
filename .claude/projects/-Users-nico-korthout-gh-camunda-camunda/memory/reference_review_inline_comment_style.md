---
name: reference-review-inline-comment-style
description: "House style for writing individual inline PR review comments in camunda/camunda — short, hedged, with raw questions and specific praise"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 19d7fc05-7140-4c5b-b7a1-e296c05eacca
---

When writing **inline** PR review comments in camunda/camunda, match this style (extracted from 25+ of korthout's own inline comments). The general-comment template lives in [[reference-review-general-comment-template]]; emoji prefixes in [[reference-review-emoji-code]]; volume cap in [[feedback-review-nit-budget]].

**1. `❓` are raw questions — do NOT bundle a proposed answer.**
Explain *why you're asking* (context, what triggered the question) but leave the answer to the author. They may have reasoning you haven't considered; surfacing it is more valuable than substituting yours.

✅ *"❓ Was this documented by the Spring Security 7 migration guide? If so, it would be good to link it for additional reading."*
✅ *"❓ I'm not so eager to include this, because there may be cases where there could be many keys in there. Do we need this?"*
❌ *"❓ Was this documented by the migration guide? It probably was, so consider linking it."* — bundles the answer

**2. `🔧` suggestions CAN carry a proposed change** — prose, fenced code, or GitHub's native ` ```suggestion ` block (one-click apply by the author). Use ` ```suggestion ` when the change is mechanical and you want zero friction. Use prose + alternatives when the author should choose between options.

**3. Default to short — 1–2 sentences.** Many of the best comments are one line:
- *"🔧 Please also update the test method name."*
- *"We can't test this in the engine."*

Expand only when the topic genuinely needs it (design pushback, multiple related observations, a nuanced trade-off). Don't over-explain mechanical fixes.

**4. Hedge non-blocking points.** "I think", "Would be nice to", "Perhaps", "Personally, I think" — softens tone without weakening substance. Especially appropriate for 🔧 and 💭. Declarative voice is fine for ❌ ("This has to change"), reserved for genuine errors.

**5. `👍` praise is specific** — name what was done well and (briefly) why. Generic "nice work!" adds little.
✅ *"👍 This is a great example of one of the few cases where `verify()` is actually great. […] here we want to do two things: show what it does and show how it works."*
❌ *"👍 Looks great."*

**Bonus — replies:**
- Open with a quick acknowledgment when the author addressed feedback: "Good catch", "Perfect! Thanks", "Yeah. That's a good point."
- Push back when warranted, citing principles by name (e.g., the bpmn-io "Empower the user" principle).
- Pull in additional stakeholders with `@-mentions` for design conversations that belong upstream of the PR.
