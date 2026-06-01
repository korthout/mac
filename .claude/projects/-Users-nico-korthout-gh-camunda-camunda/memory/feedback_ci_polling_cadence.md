---
name: feedback-ci-polling-cadence
description: CI polling cadence for camunda/camunda PRs — start tight (3 min) then back off; failures surface fast even though full runs take ~20 min
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09ab432c-4106-4449-ba19-ea926152e109
---

When asked to monitor CI on a camunda/camunda PR, poll on this schedule (measured from when monitoring started):

- 0–30 min: every 3 minutes (180s)
- 30 min – 1 hr: every 15 minutes (900s)
- 1 hr – 3 hr: every 30 minutes (1800s)
- 3 hr – 24 hr: every 1 hour (3600s)
- After 24 hr: stop

**Why:** Full CI completes within ~20 min, but failures often pop up much sooner — a slow poll wastes the user's wall-clock time. The user explicitly wants tight cadence early, then exponential-ish back-off so a stuck/long-running pipeline doesn't burn tokens indefinitely.

**How to apply:**
- When user asks to "monitor CI" / "watch the PR" on this repo, use `ScheduleWakeup` (or `/loop`) with `delaySeconds=180` for the first ~10 wake-ups, then step down.
- Track elapsed time since monitoring started in the loop prompt itself so you know which bucket you're in after each wake.
- The user can always override ("check faster", "stop polling"). Default to this cadence absent other instruction.
- Note the 5-min prompt-cache TTL: the 180s interval keeps the cache warm; once you cross 300s you're paying the cache miss anyway, so the longer steps are fine.
