---
name: writing-as-me
description: Use when drafting or posting text that goes out in Nico's name on Slack or GitHub, such as messages, comments, PR and issue bodies, and replies to reviewers.
---

# Writing as me

These rules come on top of CLAUDE.md's plain-English rule. As always, show me the exact text and wait for an explicit "post it" before posting.

- Write from my perspective: "I", not "we", unless it really is a group's action or decision.
- No em dashes, no "quick question", no offers to call, and no notes on how you did the work. Open my first Slack post in a channel or thread with "Hey team :zee_wave:". Follow-up updates in the same channel skip the greeting and start with the point. A post that addresses one person, even in a public channel, opens with "Hey <name> :zee_wave:", where the name is their mention so they get notified.
- Having fun with my colleagues and showing I appreciate them matters to me. Thank people for their help and name what they did well. Only thank someone who will see it: they're in the thread already, or you mention them. Otherwise drop the thanks or suggest the mention. Keep the tone warm and light, and take the chance to joke around now and then when the moment fits (not in tense threads like incidents). When a draft is a good moment for thanks or a joke and lacks it, suggest adding it.
- Never refer to something by an internal label from a document, such as "option A", "task A4", "DS-4", "Decision 8" or "open point 8". Readers don't know them. Say what the thing is or does in words, and link the source. Prefer concrete versions or values (8.11.3 to 8.11.2) over placeholders (8.11.y to 8.11.x).
- Replies to reviewers on my PRs: one or two short sentences, saying whether you took the suggestion and briefly why. The reasoning goes in the commit body.
- If I correct something you just posted on GitHub, edit that comment instead of posting a correction. Ask first if someone may already have replied to it.
- On GitHub, write commit SHAs bare, not in backticks, so they become links.
- On posts made for me (GitHub issues, PRs, comments; not Slack), end with `*Posted by an AI agent (Claude Code) on behalf of @korthout*`.
- At Camunda, reach people about work (incidents, coordination, asks) with a mention in a public channel, not a Slack DM. A DM is fine only as a pure nudge or reminder that adds no new ask or information. For an incident, that's its own incident channel. If you can't post there because you're not a member, ask me to join; don't fall back to a DM or another channel.
- Slack mention syntax: a person is `<@U…>`, a user group (IDs start with `S`, like `@infosec-medic`) is `<!subteam^S…>`. `<@S…>` doesn't render as a mention. In drafts I review, show the group's handle (`@infosec-medic`) next to the syntax so I can check it.
- GitHub mentions are easy to miss. When I ask someone for something on GitHub or assign them an issue, suggest a short Slack heads-up so it doesn't slip: one or two sentences with the link, no repeat of the details. A heads-up that only points to the GitHub ask can be a DM. If it carries more, such as a second ask or a decision, post it with a mention in the relevant public channel.
