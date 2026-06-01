---
name: reference-github-rerun-failed-jobs
description: How to retrigger failed/cancelled GitHub Actions jobs via the REST API when CI shows infra/runner cancels rather than real failures
metadata: 
  node_type: memory
  type: reference
  originSessionId: 09ab432c-4106-4449-ba19-ea926152e109
---

When CI surfaces a failed or cancelled check that looks like infra/runner noise (e.g. cancelled during a setup step like "Install Playwright", a runner timeout, a flake), retry it from the API rather than asking the user to click the Re-run button.

**Endpoints** (use the `curl` + `gh auth token` workaround — Go-based `gh` fails through the proxy):

```bash
# Re-run ONLY the failed jobs in a workflow run (preferred — keeps already-green jobs)
curl -s -X POST "https://api.github.com/repos/<owner>/<repo>/actions/runs/<run_id>/rerun-failed-jobs" \
  -H "Authorization: token $(gh auth token)" \
  -H "Accept: application/vnd.github+json" -w "\nHTTP %{http_code}\n"

# Re-run the ENTIRE workflow run (use only when failed-only isn't enough)
curl -s -X POST "https://api.github.com/repos/<owner>/<repo>/actions/runs/<run_id>/rerun" \
  -H "Authorization: token $(gh auth token)" \
  -H "Accept: application/vnd.github+json" -w "\nHTTP %{http_code}\n"

# Re-run a SINGLE job (and optionally its dependents via ?enable_debug_logging or body {"enable_debug_logging": true})
curl -s -X POST "https://api.github.com/repos/<owner>/<repo>/actions/jobs/<job_id>/rerun" \
  -H "Authorization: token $(gh auth token)" \
  -H "Accept: application/vnd.github+json" -w "\nHTTP %{http_code}\n"
```

Successful trigger returns **HTTP 201** with an empty `{}` body. Anything else (403/404/422) usually means the run is too old, already running, or you don't have permission.

**How to apply:**
- When [[feedback-ci-polling-cadence]] surfaces a cancelled/failed check, inspect the job's failing step first — if it's clearly infra (setup, install, runner cancel, network) and not a real test/build failure, ask the user before reruning, or rerun directly if they've already authorized it.
- Get the `run_id` from `check_run.html_url` (`.../actions/runs/<run_id>/job/<job_id>`) or from the check-runs API's job URL.
- Prefer `rerun-failed-jobs` over `rerun` — it preserves the already-green jobs and is cheaper on CI minutes.
- The PR's check-runs list refreshes on the next poll; the rerun creates a new attempt under the same run ID (visible as `run_attempt: 2`).
