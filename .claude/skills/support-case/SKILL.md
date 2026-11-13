---
name: support-case
description: Use when working a customer support case, to analyse the customer's concerns or draft updates for its incident channel.
---

# Support case

Notes on open cases live in `cases/<case>.md`, which git ignores. Read the one for this case if it exists. Keep customer names and customer data only there. Delete the file when the case closes.

## Analyse each concern as a whole

A customer question is often an unspoken "is this a bug?". Don't only answer it literally. For each concern, work out:

- what the customer wants to achieve
- what the product offers for that today
- whether the current behavior is a bug or by design. Find evidence of intent: code comments, config, history.
- whether the product should change

Put this in a table per concern before you draft answers for support.

Also check:

- **The process.** Scanner or pentest findings go through the security testing findings process (Infosec point of contact), not a regular support incident. Raise it with support as a question ("did you consider handling this as a security testing finding?"), not as a directive.
- **Workarounds.** Check that a proposed workaround has a real effect. Setting flags on a cookie that is never read only quiets a scanner and adds no protection. Say so, or drop the workaround.
- **Suspected bugs.** Confirm them with domain experts before telling support it's a bug. For Core Features, post to #support-sparring-core-features, to the group without tagging anyone.

## Keep the incident channel updated

Support and others follow the case in its `#inc-support-*` channel. Work done only in side threads or in chat leaves them unable to act or plan.

After real progress (a finding, a question asked elsewhere, a decision), draft a short update with:

- what we know
- what's still open, and where (link side threads)
- what we need from whom, or that nothing is needed yet
- the next step

Mark anything not yet confirmed as not for the customer.

Back claims with shareable links: Jira tickets, Slack permalinks, code permalinks. If you can't source a claim, tone it down ("as far as we can tell", "seems"). When you ask something, say why. Concrete signals, like churn risk with a link to the source, help readers prioritize.

Leave out caveats and promises a standard process already covers, like "don't promise a release date". End with the concrete next action instead, like "I'll open an issue for the fix and link it here".

Keep the asks lean:

- Ask only for what unblocks the investigation now. Questions that only shape the final customer answer wait until that answer is written. Say "nothing to ask the customer for now" when that's the case.
- Prefer asking support for information they likely have, like Jira ticket contents we can't read, over a new round-trip to the customer.
