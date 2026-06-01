---
name: Error reporting threshold
description: Only report errors as bugs if they are unexpected — expected transient errors with retries should lower log level to warning instead
type: feedback
originSessionId: c3d97f9d-1499-4a7a-bf06-e2f74d3a6c8c
---
Reported errors should only be filed as issues if they are unexpected. Expected/transient errors (e.g. cloud provider 503s, temporary network failures) that are handled by automatic retries should not be reported as bugs — instead, the log level should be lowered to WARN.

**Why:** Not every error in logs is a bug. Transient errors that self-resolve through retries are operational noise, not defects. Filing issues for them creates unnecessary work.

**How to apply:** During error investigation (especially the `/investigate_reported_error` skill), assess whether the error is expected/transient and retried. If so, propose lowering the log level instead of filing an issue.
