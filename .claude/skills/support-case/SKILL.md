---
name: support-case
description: Use when working a customer support case, to analyse the customer's concerns, root-cause the problem, or draft updates for its incident channel.
---

# Support case

Notes on open cases live in `cases/<case>.md`, which git ignores. Read the one for this case if it exists. Keep customer names and customer data only there. Delete the file when the case closes.

## Work a long-running case

Cases run for days and across many sessions, so set up for that from the start.

- **Note where the inputs are.** Record the paths to the logs, configs and code the customer provided in the case notes.
- **Persist as you go.** Write instructions, findings, open candidates and ruled-out ideas to the case notes as you go. Reread them after context compaction or in a new session.
- **Keep the main context small.** Delegate log searches and code reading to subagents, and keep only their conclusions.
- **Follow the incident channel.** Read it for new data from support and the customer.
- **Raise missing data.** When data that would clearly help the investigation is missing, say what it is and why it helps.

### Customer logs contain PII

Don't read log lines that might contain personal data.

- Search for specific words or phrases, and print only counts or matching fields, not the whole entry.
- If you need to see entries that might contain PII, write the command and hand it to the user to run and redact.
- If you see PII anyway, stop and tell the user right away.

### Look into a SaaS cluster

The incident channel has what you need to find the cluster's data.

- **Cluster facts.** Look for the CloudBot reply to `!what <clusterId>` in the channel. It lists the generation (the version), cluster plan, active cluster modifications (like raised Elasticsearch limits), the GCP project, the Kubernetes namespace (`<clusterId>-zeebe`), and links to Grafana and logs. To look at metrics or logs, ask the user once per case whether you may, and say this needs `!kube-access`. Once they agree, post `!what <clusterId>` or `!kube-access <clusterId>` in the incident channel yourself, without showing the text first, and go ahead.
- **Logs.** Read the broker logs from Cloud Logging with `gcloud logging read`. Use the project and namespace from `!what`. If `gcloud` has no active account, ask the user to run `! gcloud auth login`. Auto mode blocks reading a customer's production logs until the user tells you explicitly to run it. Ask once, don't work around it.
  - Filter on a phrase and a narrow time range, print only `timestamp` and `resource.labels.pod_name` (add `jsonPayload.message` for log lines without customer data), and count per hour or per pod with `cut | sort | uniq -c`.
  - Cloud Logging keeps about 30 days.
  - Run queries over more than a few hours in the background. They take minutes.
  - Some warnings are throttled (like `Failed to write received command`, about one line per 15s per broker). Their lines are samples: they show when something happened, not how often.
- **Kubernetes.** Run `tsh` and `kubectl` with `TELEPORT_ADD_KEYS_TO_AGENT=no`, or credentials fail with "failed to add one or more keys to the agent". The context is `camunda.teleport.sh-<worker>`, like `camunda.teleport.sh-saas-prod-worker-1`. `!kube-access` posted through the Slack tool got "you cannot access things that do not exist" (25 Nov 2026), while the same text typed by a person works. If that happens, ask the user to post it.
- **Metrics.** Grafana sits behind Okta, so you can't open it. Thanos runs in the `thanos` namespace of the worker cluster (`thanos-query-frontend`, port 9090), but the default viewer role can't port-forward to it or proxy to it, so the PromQL from the dashboards can't be run directly. Find the panels the user needs in `monitor/grafana/*.json` in camunda/camunda. Give the user a link with the namespace and the time range set (`&from=<epoch ms>&to=<epoch ms>`), name the panels, and say what each result would mean. Ask for screenshots.

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

## Root-cause a hard case

For an urgent case with a hard root cause, like one with churn risk, a long investigation pays off. One such session cost $127 and found the cause plus three ways to reproduce it. The user decides on that spend. If the session isn't on Opus, suggest switching once.

Drive to the end. Try to refute each candidate cause. Don't stop until you find the cause or run out of avenues. Reproduce the cause before you call it found.

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
