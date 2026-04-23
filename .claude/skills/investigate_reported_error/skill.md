---
name: investigate_reported_error
description: Investigate a reported error message to determine if it's a known issue and decide how to proceed. Use when user shares an error message, stack trace, or log snippet and wants to understand whether it's known. Also use when user wants to research, investigate, or rootcause an incident.
---

# Investigate Reported Error

Investigate a reported error message to determine whether it's a known issue and decide on next steps.

## Phase 0: Redact sensitive data

Before the user shares a log snippet or error message, remind them to scrub sensitive data first. Production logs often contain customer-identifying information that must not appear in conversation history, issue comments, or summaries.

Ask the user to replace the following before pasting:

| Data type | Replace with |
|-----------|-------------|
| Tenant / org / customer IDs | `[REDACTED-TENANT]` |
| User emails, names, usernames | `[REDACTED-USER]` |
| API tokens, secrets, passwords, keys | `[REDACTED-SECRET]` |
| IP addresses | `[REDACTED-IP]` |
| Process / element instance IDs | `[REDACTED-INSTANCE-ID]` |
| Cluster / node / deployment IDs | `[REDACTED-CLUSTER]` |
| Customer-identifying URLs or hostnames | `[REDACTED-HOST]` |
| Database connection strings | `[REDACTED-CONN]` |
| Any UUID that could identify a customer resource | `[REDACTED-ID]` |

Safe to keep: Java class names, method names, line numbers, thread names, Zeebe component names, log severity, timestamps (date only).

If the user has already shared unscrubbed data, **stop immediately**. Flag exactly which fields contain sensitive data so the user is aware. Do not proceed with investigation until the user acknowledges and provides a scrubbed version.

## Phase 1: Search for known issues

Search for existing GitHub issues using the information provided (error message, stack trace, component names). Search with:
- The exact error message
- Key terms from the stack trace
- Related component/area terms

For candidate issues, read the issue body to confirm it describes the same problem. Then read the issue comments to understand the issue better (e.g. prior analysis, workarounds, fix attempts).

If a known issue fully explains the root cause and matches the reported error, skip to Phase 4.

## Phase 2: Investigate root cause

Investigate relentlessly until reaching the root cause. Walk down each causal branch, resolving dependencies between questions one-by-one. If a question can be answered by exploring the codebase, explore the codebase instead of asking the user.

1. Search the codebase for the exact error message to locate where it's produced.
2. Trace the full causal chain — don't stop at the immediate crash site. Follow the data and control flow to understand why the failing state arose in the first place.
3. Identify the root cause: the deepest point where a fix or validation would prevent the error.

## Phase 3: Search for known issues again

The investigation likely uncovered new terms, component names, or root cause details. Search for known issues again using this deeper understanding. Also check `git log` for recent fixes in the same code area.

For candidate issues, read the issue body to confirm it describes the same problem. Then read the issue comments to understand the issue better (e.g. prior analysis, workarounds, fix attempts).

## Phase 4: Present findings and decide next steps

Present a concise summary:
- **Root cause**: what triggers the error and why
- **Known issues**: links to any existing GitHub issues
- **SaaS vs SM**: is this SaaS-only (caused by SaaS-specific infrastructure like GKE config, GCP services, SaaS-specific env vars) or does it affect both deployments (bug in application code that SM users could hit too)? When unsure, default to both and note it for the user to confirm.
- **Assessment**: is this expected/transient, a known bug, or a new issue?

Determine whether the error is **expected/transient** or **unexpected**:

- **Expected/transient errors** (e.g. temporary network failures, cloud provider 503s) should not be reported as bugs if they are handled by automatic retries. If the error is expected but logged at ERROR level, propose lowering the log level to WARN instead of filing an issue.
- **Unexpected errors** (genuine bugs, unhandled edge cases, design flaws) should be reported.

For expected/transient errors, also determine **who initiates the action**:
- **User-initiated**: the user can retry themselves, so application-level retry may not be needed — focus on clear error messaging and appropriate log level.
- **System-initiated**: the system must handle the retry itself, since there is no user to retry — application-level retry handling is more important.

Propose options based on this assessment (e.g. lower log level, add retry handling, report in existing issue, open new issue, fix it) and let the user decide. Do not take action until the user chooses.

When a known issue exists, offer to post a comment. Always include links to the reported error and the relevant log entry for traceability. If the issue is missing information our investigation uncovered (root cause analysis, affected code paths), include that too. If not, a comment noting that the issue was observed again is still valuable.

Draft the comment for user review before posting.

When creating issues, use the `/github_create_issue` skill.

## Rules

- Do not edit files or enter plan mode. This is investigation and discussion only.
- Verify every claim against actual code and log content — do not speculate.
- Compare stack traces carefully — do not assume a match without verifying details.
