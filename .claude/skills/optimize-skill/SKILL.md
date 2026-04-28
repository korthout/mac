---
name: optimize-skill
description: Slim, generalize, and tune a skill; keep a single human checkpoint at final approval. Use when the user wants to optimize/refactor a skill or invokes optimize-skill.
---

The user names a target skill (path or name). Optimization is bidirectional: cut what doesn't serve the skill's goal, and add what's missing. Calibrate length against a known-short skill (e.g. `~/.claude/skills/grill-me/SKILL.md`).

## Phase 0: Confirm the goal

Read the skill's frontmatter `description` and intro. If the goal is vague, missing, or contradicted by the body, **STOP** and clarify with the user — rewrite `description` first. List sibling files in the skill directory (references, scripts, examples) and include them in scope.

## Phase 1: Analyze

Dispatch parallel sub-agents:

1. **Redundancy** — duplication within the skill, content already in `~/.claude/CLAUDE.md`, verbose blocks the agent could derive itself.
2. **Generality** — repo/language/toolchain-specific content. Replace with a "detect project conventions" step that reads `CLAUDE.md` / `AGENTS.md` / `README`.
3. **Extractability** — parts that should become reusable agents in `~/.claude/agents/` (narrow purpose, strict output contract). Don't extract for its own sake.
4. **Per-statement audit** — judge each statement against:
   - **Usefulness** — would the skill still work without it?
   - **Efficiency** — fewest tokens for the purpose?
   - **Autonomousness** — does it block safe action with unnecessary confirmations?
   - **Human-in-the-loop** — preserves a stop *only* at the highest-impact step (flag missing and over-eager stops)?
5. **Gaps** — concrete statements missing that would help the skill achieve its goal (missing guards, clarifying constraints, steps that prevent common failure modes).

Synthesize into one edit plan covering removals and additions. If the plan is empty or all suggestions are trivial, **STOP** and tell the user the skill is already optimal.

## Phase 2: Edit

Apply the plan via parallel rewrites where edits don't conflict. Additions must serve the stated goal, not expand it. Preserve `name`; update `description` only if the trigger surface genuinely changed. Never rename or move the skill file/directory — path is the trigger.

## Phase 3: Review

Dispatch parallel sub-agents:

1. **Goal effectiveness** — can the rewrite still achieve the stated goal end-to-end? Do additions genuinely strengthen it, or do they bloat?
2. **Generality + trigger fidelity** — any repo-specific assumptions surviving or introduced; does `description` still match how the user would invoke it?

Fix flagged regressions. Then **STOP** and present the diff to the user for final approval — the highest-impact human-in-the-loop checkpoint. Flag any deleted content the user might rely on, and any non-trivial additions.

## Rules

- Result should be short (~80 lines max). Justify if longer.
