---
name: Edit recent PR comments rather than appending corrections
description: When the user corrects you shortly after you posted a PR/review comment, edit that comment via PATCH instead of posting a follow-up
type: feedback
originSessionId: 0e493484-b681-4404-b382-1c57f334608d
---
If the user corrects something I just posted on a PR (review reply, inline comment, or PR-level comment), edit the existing comment via `PATCH /repos/{owner}/{repo}/pulls/comments/{id}` (or the issues-comments equivalent) instead of adding a follow-up "correction" comment.

**Why:** Follow-up correction comments clutter the review thread for the reviewer and leave the inaccurate version visible above the correction. The reviewer reads top-to-bottom and may act on the stale claim. The user flagged this explicitly on PR #53272 (2026-05-20) after I appended a correction to my reply to Fabio's review rather than editing the original.

**How to apply:** When the user corrects a position I just took in a freshly-posted PR comment (especially within the same conversation turn), default to editing that comment. If a comment is older or the correction is substantive enough that a reviewer might have already replied to it, ask before silently rewriting history. For deletion-then-edit flows, the API: `DELETE /repos/{owner}/{repo}/pulls/comments/{id}` to drop the stray follow-up, `PATCH .../comments/{id}` with `{body: "..."}` to amend the original.
