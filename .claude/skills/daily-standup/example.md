# Example: 2026-05-21 stand-up

Verbatim reference. When a style question isn't clear from `SKILL.md`, match this example.

---

**For "What did you work on yesterday?":**

P1 - AI Visibility & Explainability (Implement)
- Merged [PR #53272](https://github.com/camunda/camunda/pull/53272) - AgentInstance.UPDATE processor + applier (incl. changedAttributes, status transitions, authorization)
- Rewrote [Track multiple element instances per agent instance #51513](https://github.com/camunda/camunda/issues/51513) description and worked out a plan to split the remaining work into 6 small PRs via a dual-field bridge
- Reviewed [PR #52912](https://github.com/camunda/camunda/pull/52912) (agent metric processors); aligned with author on splitting CREATE/UPDATE into stacked PRs
- Drafted the implementation plan for the elementInstanceKeys piece of [#51513](https://github.com/camunda/camunda/issues/51513)

P2 - Business ID Visibility & Filtering
- Nothing yesterday

P3 - [#8991](https://github.com/camunda/camunda/issues/8991) Partitions unhealthy with many timers
- Nothing yesterday

Also
- Worked on [PR #53028](https://github.com/camunda/camunda/pull/53028) and took over PR #52988 and PR #53078 from Stephan and Deepthi (same case)
- Downgraded failsafe to `3.5.2` on `stable/8.8` and `stable/8.9`
- #cve-2026-4046-medium-core-features (glibc iconv) - comes from the Minimus base image, Renovate handles it; checked exposure in camunda + identity
- Merged the iteration-auditor skill ([team-core-features-charlie PR #2](https://github.com/camunda/team-core-features-charlie/pull/2)) via the new Claude Code plugin marketplace
- Drafted a personal `reviewing-agent-ready-prs` skill to keep Agent-Ready PRs aligned with the shared Agent-Ready intentions

---

**For "What will you work on today?":**

P1 - AI Visibility & Explainability (Implement)
- Implement [Track multiple element instances per agent instance #51513](https://github.com/camunda/camunda/issues/51513)

P2 - Business ID Visibility & Filtering
- Nothing planned today

P3 - [#8991](https://github.com/camunda/camunda/issues/8991) Partitions unhealthy with many timers
- Breakdown to something tangeable (currently continues to result in too large PRs >5k lines)

Also
- #inc-support-32932-version-of-8-8-that-does-not-have-memory-allocation-issue

---

## What to notice

- Both blobs start straight with `P1 - …`. No "Yesterday" or "Today" header inside the content — Geekbot's prompts provide that framing.
- `P1` header includes the phase `(Implement)` because the underlying P-task is "Drive Implement phase for AI Visibility & Explainability epic".
- `P2` header has no phase because the P-task says "Assist Business ID Visibility & Filtering epic" — no phase keyword.
- `P3` header rewrites the verbose issue title to `[#8991](url) Partitions unhealthy with many timers` — the issue number is a link even in the header.
- No blank line between a section header and its first bullet — the bullets start on the very next line.
- Empty P-sections are still present, with `- Nothing yesterday` or `- Nothing planned today`.
- Links use `[full title #num](url)` for the headline issue/PR, shorter `[PR #num](url)` mid-bullet, `[#num](url)` in P2/P3 headers.
- Backticks on `3.5.2`, `stable/8.8`, `reviewing-agent-ready-prs`.
- Plain `#cve-...` / `#inc-...` channel references — no link, no backticks.
- One bullet covers the three handed-over PRs together with `(same case)` and `from Stephan and Deepthi`.
- Bullets use ASCII `-`, hyphens (not em-dashes) separate header from phase.
