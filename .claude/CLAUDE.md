## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- When a skill's instructions say to use another skill, invoke that skill — don't skip ahead and do the work inline.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- When something is worth remembering, save it in the repo (docs, skills, CLAUDE.md) if it's repo-specific, otherwise in a personal skill or ~/.claude/CLAUDE.md, not in auto-memory.
- Write commit messages, code comments, issues, PRs, and GitHub and Slack comments in plain English: short sentences, everyday words, Camunda's terms and the codebase's names for things. Lead each paragraph with its point. Check every draft against this before posting.
- Ask me one question at a time, the one whose answer changes the most first. Write it in plain English, with the context and options I need to decide without looking things up.
- Before writing an inline comment, name its reader and what they'd do differently. If you can't, or a test would catch the same regression, don't write it. Restructure the code if that removes the need, and put reasoning that belongs in the commit message there.
- Before posting to Slack or GitHub, show me the exact text and wait for an explicit "post it". A general "take action" is not approval. Show the text again after any edit.
- Never read, print, generate, or pipe private keys, tokens, `.env`/credentials files, or any secret value — anything in tool output is exposed. Hand the user a command to run themselves. Public halves and secret *names* are fine.
- Paginate every GitHub, Slack or list API call fully (`gh api --paginate`, or follow the cursor). State the total count, and never report "all green", "no failures" or "all addressed" unless it matches what you retrieved.
- In tests, prefer obvious over DRY: a failing test should make sense without reading other code. Inline setup and use literal values when the value matters. Extract one helper only for repeated plumbing (like polling until a record is visible), and pass the values that matter as arguments. A helper never acts on the thing under test or hides values that decide the outcome.
- Run `mvn`, not `./mvnw`, even when a repo says to use the wrapper. My `mvn` shell function picks the right Maven.
- In chat, link GitHub issues and PRs as `[<full title> #N](url)`. Look up the title; don't guess it.
- A hook rewrites shell commands to `rtk`. Run `rtk proxy <cmd>` when you need the raw, unfiltered output.
- For JSON, use `jq` rather than a python script when jq can reasonably do it. jq can't run arbitrary code.
- In camunda/camunda, when you use the `engine-expert` skill or run `zeebe/qa` integration tests, also read `~/.claude/notes/camunda.md`: my additions, which win where they disagree.

## Commits

- Titles max 72 chars, aim for 50. Explain all considerations in the body.
- One commit per reason for a change. Choose amend or a new commit by the *reason*, not by which files change or whether behavior changes.
  - Amend when the change corrects what the commit meant to do: a typo, a wrong assertion, a missed case within the same goal.
  - Make a new commit when the change has its own reason, even in the same lines with the same behavior: new wanted behavior, a performance gain, more robustness. A bug that this work reveals gets its own failing-test and fix commits too.
- On backport PRs, never amend the cherry-picked commits; add new ones. Amending breaks the `cherry picked from` link to the original PR and makes reviewers re-read everything.
- Bug fixes: first commit only the failing test, so reviewers can check out that commit and see it fail. Then commit the fix, including old tests that encoded the buggy behavior. Add a refactor commit between the two only when the fix can't land cleanly without it.
- Refactors: small strangler-fig commits that each build green. Build the new code next to the old, move callers over one at a time, and delete the old code (and its tests) last. Put the feature that needs the refactor in its own stacked PR. Unused scaffolding in a refactor PR hides which code is live.
- No issue references like `#123` in commit messages. I rebase often, and every rebase adds another cross-reference to the issue. Put them in the PR.
- Explain why for every non-default choice, in the body and not in a code comment. For example, `SoftAssertions`: say what would be lost with plain assertions, not just what it does.
- When you resolved conflicts (merge, rebase, cherry-pick, backport), explain in the body what you changed compared to the original and why. The original message alone misrepresents what the commit contains.
- After restructuring commits, reread every message. Remove mentions of tests, commits or drafts that are no longer in the history, and describe each change as the final history shows it.

## Model selection

- Haiku: narrow lookups with no judgment (locate a file, grep a symbol). Not for comprehension: a wrong cheap answer costs more than it saves.
- Sonnet: the default for engineering work (implementing, TDD, git, CI, PR triage, drafting).
- Opus: adversarial review, high-stakes or hard-to-reverse decisions (architecture, security impact, unclear scope), and synthesis across many sources. Pass `model: "opus"` instead of switching the session.
- Keep the main context lean: run commands with small output (filter, limit, count, read only the lines you need). Delegate when output would be large or needs many lookups, so only the conclusion comes back. Keep judgment in the main thread and check subagent findings. Do small, specified edits in files already in context inline.
- If the session's model doesn't fit the work, say so once and suggest switching.

@private.md
