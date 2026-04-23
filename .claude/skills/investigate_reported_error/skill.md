---
name: investigate_reported_error
description: Investigate a reported error message to determine if it's a known issue and decide how to proceed. Use when user shares an error message, stack trace, or log snippet and wants to understand whether it's known.
---

# Investigate Reported Error

Investigate a reported error message to determine whether it's a known issue and decide on next steps.

## Phase 1: Understand the error

1. Search the codebase for the exact error message to locate where it's produced.
2. Read the surrounding code to understand:
   - What condition triggers the error
   - Whether it's expected/transient or indicates a real fault
   - The broader flow it's part of

## Phase 2: Search for known issues

Use the `github-issue-searcher` agent to search for existing GitHub issues covering the same error. Search with:
- The exact error message
- Key terms from the error and surrounding code
- Related component/area terms

For candidate issues, read the issue body to confirm it describes the same problem. Then read the issue comments to understand the issue better (e.g. prior analysis, workarounds, fix attempts).

Also check `git log` for recent fixes in the same code area.

## Phase 3: Present findings

Present a concise summary:
- **Root cause**: what triggers the error and why
- **Known issues**: links to any existing GitHub issues
- **Assessment**: is this expected/transient, a known bug, or a new issue?

## Phase 4: Decide next steps

Determine whether the error is **expected/transient** or **unexpected**:

- **Expected/transient errors** (e.g. temporary network failures, cloud provider 503s) should not be reported as bugs if they are handled by automatic retries. If the error is expected but logged at ERROR level, propose lowering the log level to WARN instead of filing an issue.
- **Unexpected errors** (genuine bugs, unhandled edge cases, design flaws) should be reported.

For expected/transient errors, also determine **who initiates the action**:
- **User-initiated**: the user can retry themselves, so application-level retry may not be needed — focus on clear error messaging and appropriate log level.
- **System-initiated**: the system must handle the retry itself, since there is no user to retry — application-level retry handling is more important.

Propose options based on this assessment (e.g. lower log level, add retry handling, report in existing issue, open new issue, fix it) and let the user decide. Do not take action until the user chooses.

When a known issue exists, offer to post a comment. Always include links to the reported error and the relevant log entry for traceability. If the issue is missing information our investigation uncovered (root cause analysis, affected code paths, solution ideas), include that too. If not, a comment noting that the issue was observed again is still valuable.

Draft the comment for user review before posting.

When creating issues, use the `/github_create_issue` skill.

## Rules

- Do not edit files or enter plan mode. This is investigation and discussion only.
- Verify every claim against actual code and log content — do not speculate.
- Compare stack traces carefully — do not assume a match without verifying details.
