## Rules

- Answer questions — don't assume they imply an action. Only act when explicitly asked.
- Check available skills before starting a task. Update skill definitions when receiving feedback during execution.
- When a skill's instructions say to use another skill, invoke that skill — don't skip ahead and do the work inline.
- Verify claims against actual code and changes. Don't speculate — update your analysis when given counter-evidence.
- I have my own git commit style: before any git commit, amend or history rewrite, use the `commit-style` skill.
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

## Model selection

- Haiku: narrow lookups with no judgment (locate a file, grep a symbol). Not for comprehension: a wrong cheap answer costs more than it saves.
- Sonnet: the default for engineering work (implementing, TDD, git, CI, PR triage, drafting).
- Opus: adversarial review, high-stakes or hard-to-reverse decisions (architecture, security impact, unclear scope), and synthesis across many sources. Pass `model: "opus"` instead of switching the session.
- Keep the main context lean: run commands with small output (filter, limit, count, read only the lines you need). Delegate when output would be large or needs many lookups, so only the conclusion comes back. Keep judgment in the main thread and check subagent findings. Do small, specified edits in files already in context inline.
- If the session's model doesn't fit the work, say so once and suggest switching.

@private.md
