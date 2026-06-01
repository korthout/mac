---
name: Document conflict resolution in commits
description: Any commit that involved resolving conflicts (merge, rebase, cherry-pick, backport) must document the resolution in its commit message body
type: feedback
originSessionId: fb352ce8-6734-41c3-976c-345465c3afd1
---
If you resolved conflicts while producing a commit, document the resolution in that commit's message body. Applies equally to merges, rebases, cherry-picks, and backports — not only to backport PRs.

**Why:** A commit message that reuses the upstream/original text verbatim lies about what the commit actually contains. The diff alone doesn't tell future readers *why* it differs from the patch it came from — which lines were dropped, which symbols were renamed, which version slot was left empty, what didn't exist on this branch. Reviewers, git blame archaeology, and incident response all need that "why" written down. Cherry-pick provenance lines (`(cherry picked from commit …)`) prove origin; the resolution paragraph proves what was changed to make it fit.

**How to apply:** Whenever conflict markers appeared, or you had to edit beyond auto-merge to make the change apply (delete code that wouldn't compile, restructure for missing APIs, rename to fit existing conventions, leave intentional gaps), amend the commit message before pushing. Include: (1) what doesn't exist on the target side and, if known, the commit/PR that removed or changed it, (2) what was dropped or rewritten from the original change, (3) any intentional divergence and why. For backports specifically, this documentation belongs in the *initial* backport commit, before review — review-time fixes still go in NEW commits per `feedback_backport_no_amend`.
