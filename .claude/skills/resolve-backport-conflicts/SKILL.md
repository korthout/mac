---
name: resolve-backport-conflicts
description: Resolves cherry-pick conflicts on a camunda/camunda backport PR that the backport-action bot flagged as conflicting. Looks up the bot's instructions comment, resets the branch, and re-applies the commits, resolving conflicts as they occur.
disable-model-invocation: true
---

# Resolve backport conflicts

Resolves cherry-pick conflicts on a draft backport PR opened by `korthout/backport-action`
(see `feedback_backport_no_amend` and `feedback_document_conflict_resolution` memories).

1. If no PR was given, ask the user for the PR number or URL.

2. Find the bot's instructions comment on that PR:
   ```bash
   gh api repos/camunda/camunda/issues/<number>/comments --paginate --jq '.[].body' | grep -A5 'git cherry-pick -x'
   ```
   It looks like:
   ```bash
   git fetch origin backport-<n>-to-stable/<x.y>
   git worktree add --checkout .worktree/backport-<n>-to-stable/<x.y> backport-<n>-to-stable/<x.y>
   cd .worktree/backport-<n>-to-stable/<x.y>
   git reset --hard HEAD^
   git cherry-pick -x <sha1> <sha2> ...
   ```
   Ignore the `fetch`/`worktree add`/`cd` lines — only extract the `git reset --hard HEAD^` and
   `git cherry-pick -x <shas...>` lines.

3. Check out the PR branch locally (`gh pr checkout <number>`). Run `git status` and confirm both
   that the current branch matches the backport branch name and that the working tree is clean
   before proceeding — never run `reset --hard` on the wrong branch or over uncommitted work.

4. Run the reset and cherry-pick commands extracted in step 2.

5. For each conflict the cherry-pick stops on: resolve it, `git add` the resolved files, then run
   `git cherry-pick --continue --no-edit` (the plain `--continue` opens an editor by default —
   `--no-edit` keeps this non-interactive; HEAD is still the *previous* commit until this
   completes, so there is nothing to amend yet). Once it completes, run `git commit --amend` on
   the commit it just created to document the resolution (what was dropped/rewritten and why —
   see `feedback_document_conflict_resolution`). This is amending a commit you're still
   constructing pre-push, not the post-review "no-amend on backport branches" case in
   `feedback_backport_no_amend` — that rule is about not rewriting commits after the PR is already
   open for review.

6. Once all commits have applied cleanly, summarize what was resolved and ask the user before
   pushing (`git push --force-with-lease`) — do not push without confirmation.
