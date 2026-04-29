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
3. **Workflows & feedback loops** — for multi-step or quality-critical work, are steps explicit (checklist pattern)? Is there a validator → fix → re-check loop where output quality matters?
4. **Output contracts** — where format matters, are templates or concrete input/output examples provided rather than abstract description?

### Efficiency — tokens spent achieving the goal
5. **Smart-Claude default** — flag sentences that explain something Claude already knows.
6. **Redundancy** — duplication within the skill, or content already in `~/.claude/CLAUDE.md` / project `CLAUDE.md`.
7. **Progressive disclosure** — body should be <500 lines; bulk content moves to one-level-deep reference files (no nested refs `SKILL.md → a.md → b.md`); reference files >100 lines need a table of contents.
8. **Generality** — repo/language/toolchain-specific content the skill doesn't need; replace with a "detect project conventions" step.
9. **Anti-patterns** — Windows-style paths; time-sensitive content; inconsistent terminology; offering many options instead of one default + escape hatch; voodoo constants in scripts; MCP tools referenced without the `mcp__<server>__<tool>` prefix; scripts that punt errors back to Claude.

### Discoverability — does Claude trigger it when relevant?
10. **`name`** — lowercase letters/numbers/hyphens, ≤64 chars, no reserved words (`anthropic`, `claude`); gerund or action-oriented.
11. **`description`** — third person, ≤1024 chars, states both *what the skill does* and *when to use it* with specific trigger terms.

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
