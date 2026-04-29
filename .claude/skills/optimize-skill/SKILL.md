---
name: optimize-skill
description: Refines an existing skill for effectiveness (does it achieve its goal?), efficiency (tokens spent doing so), and discoverability (does Claude trigger it when relevant?). Use when the user wants to optimize, refactor, audit, or tighten a skill, or invokes optimize-skill.
---

The user names a target skill (path or name). Optimize against three axes, in strict priority order: **effectiveness > efficiency > discoverability**. Cut tokens that don't earn their keep; add only what's missing for the skill to achieve its stated goal. A terse skill that fails at its goal is worse than a verbose one that succeeds.

Authoritative reference for skill authoring: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

## Phase 0: Confirm the goal

Resolve the target. If given a path, use it. If given a name, search in order: `~/.claude/skills/<name>/SKILL.md`, then project `.claude/skills/<name>/SKILL.md`, then plugin skill directories. If multiple match or none do, ask the user before continuing.

Read the target's frontmatter and intro. State, in one sentence, the **outcome the skill produces** — what it achieves for the user, not the workflow it follows to get there. ("Produces a refactored module with passing tests" — not "runs lint, then edits, then runs tests.") Then list sibling files (reference docs, scripts, examples) in scope. Then **STOP** and ask the user to confirm or correct the goal before auditing — auditing against the wrong goal wastes far more tokens than a confirmation turn. If the body contradicts the `description` or the goal is too vague to audit against, surface that in the same prompt.

## Phase 1: Audit

Read the full SKILL.md and every sibling file in scope before auditing — you can't flag what you haven't seen. For large skills (multiple files, or SKILL.md >200 lines), dispatch parallel sub-agents — one per axis (effectiveness, efficiency, discoverability) — and brief each with the concrete file paths to read. For small single-file skills, audit inline. Findings must cite a concrete location in the skill. Group findings by axis; effectiveness gaps outrank everything else.

### Effectiveness — does the skill achieve its goal?
1. **Goal achievement** — walk a realistic invocation end-to-end. List failure modes the current text fails to prevent (missing guards, ambiguous steps, unstated preconditions, body that doesn't deliver what `description` promises).
2. **Degrees of freedom** — is specificity calibrated to fragility? Narrow-bridge tasks (destructive ops, exact sequences) need low-freedom scripts; open-field tasks need high-freedom heuristics. Flag mismatches both ways (over-constrained *and* under-specified).
3. **Workflows & feedback loops** — for multi-step or quality-critical work, are steps explicit (checklist pattern)? Is there a validator → fix → re-check loop where output quality matters? For batch or destructive operations, prefer plan-validate-execute (emit a structured plan file → validate with a script → execute) over a single-shot run. For workflows that branch on input type or task variant, surface the decision point explicitly (conditional-workflow pattern: "creating new? → X. editing existing? → Y.") instead of a flat sequence that hides the fork.
4. **Output contracts** — where output *structure* matters, are templates provided? Calibrate strictness: rigid templates ("ALWAYS use this exact structure") for fixed shapes; default-with-judgment templates for adaptive work. Where output *style* matters more than structure (commit messages, prose tone, code review voice), prefer 2–3 concrete input/output example pairs over abstract description — examples teach style faster than rules. Mismatches both ways are failure modes.
5. **Bundled resources** — would the skill be more reliable with a script (deterministic steps), template (fixed output format), or reference file (conditional deep-dive)? Flag missing resources, not just bloated ones. For each existing reference to a script or file, the skill must state execution intent: *Run X* (execute, most common) vs *See X for the algorithm* (read as reference). Ambiguity here is a real failure mode.
6. **Evaluations** — best practices treats evals as foundational ("Build evaluations BEFORE writing extensive documentation"). Ask: can the user name one realistic invocation where the skill's value is testable? If not, the skill may be solving an imagined problem. Surface this as a finding and propose 2–3 concrete test scenarios (input + expected behavior). Don't gate the audit on the user producing evals — but flag their absence.

### Efficiency — tokens spent achieving the goal
7. **Smart-Claude default** — flag sentences that explain something Claude already knows.
8. **Redundancy** — duplication within the skill, or content already in `~/.claude/CLAUDE.md` / project `CLAUDE.md`.
9. **Progressive disclosure** — body should be <500 lines; bulk content moves to one-level-deep reference files (no nested refs `SKILL.md → a.md → b.md`); reference files >100 lines need a table of contents. For multi-domain skills (one skill covering finance + sales + product, or several distinct sub-tasks), partition references by domain (`reference/finance.md`, `reference/sales.md`) so unrelated context stays unloaded when not needed.
10. **Generality** — repo/language/toolchain-specific content the skill doesn't need; replace with a "detect project conventions" step.
11. **Anti-patterns** — flag any of:
    - Windows-style paths (use forward slashes everywhere, including on Windows)
    - Time-sensitive content (collapse legacy info into a `<details>` "old patterns" block when historical context is load-bearing; otherwise delete)
    - Inconsistent terminology (pick one term per concept and stick to it)
    - Many options offered instead of one default + escape hatch
    - Non-descriptive filenames (`doc2.md` instead of `form_validation_rules.md`) — Claude navigates the skill dir like a filesystem, so names are search keys
    - Voodoo constants in scripts (every magic number needs a justifying comment)
    - MCP tools referenced without a fully-qualified prefix (Claude Code runtime: `mcp__<server>__<tool>`; markdown-doc convention: `ServerName:tool_name`) — pick the one that matches where the skill is invoked
    - Scripts that punt errors back to Claude instead of solving them

### Discoverability — does Claude trigger it when relevant?
12. **`name`** — lowercase letters/numbers/hyphens, ≤64 chars, no XML tags, no reserved words (`anthropic`, `claude`); gerund or action-oriented.
13. **`description`** — third person, non-empty, ≤1024 chars, no XML tags, states both *what the skill does* and *when to use it* with specific trigger terms.

Synthesize into one edit plan: removals, additions, restructures, file splits. Sequence the plan effectiveness-first. If the plan contains only trivial efficiency tweaks and no effectiveness or discoverability gaps, **STOP** and tell the user the skill is already strong.

## Phase 2: Edit

Apply the plan with the Edit tool. Batch independent edits as parallel tool calls in a single message; sequence dependent edits.

- Preserve `name` and the skill's directory path — they're the trigger surface; renaming breaks invocation.
- Update `description` only when the trigger surface or capability genuinely changed; keep it third-person, what + when.
- Additions must serve the stated goal, not expand it.
- Split into sibling reference files when SKILL.md approaches 500 lines, or when a section is only needed conditionally.

## Phase 3: Review

Re-audit in priority order. For large skills, dispatch parallel sub-agents (one per axis, same as Phase 1). For small single-file skills, review inline.

1. **Effectiveness regression** — re-walk a realistic invocation. Did any cut remove a guard that prevented a failure mode? Do additions genuinely strengthen the skill or just bloat it?
2. **Efficiency** — any new redundancy, over-explanation, or under-used content that should be split out?
3. **Discoverability** — does `description` still match how the user would invoke it? Any repo-specific assumption surviving or introduced?

Fix flagged regressions, then **STOP** and present the diff for final approval — the one human-in-the-loop checkpoint. Call out: deleted content the user might rely on, non-trivial additions, and any `description` change.
