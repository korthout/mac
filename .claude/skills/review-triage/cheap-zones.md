# Cheap zones

Zones where a licence to skim is granted. **Every** changed path in the PR must match an entry
here, or there is no licence. A path that matches nothing — including a new or unfamiliar area —
is unknown, not safe.

This list starts deliberately near-empty and grows only by ratified promotion. See the Learning
section of `SKILL.md` for the bar. Each entry must carry its structural argument, because that is
what makes it re-testable when the codebase moves underneath it.

## Entries

### Human-readable prose only

Matches `**/*.md` and `**/*.txt` **except** any path under `.claude/`, `.github/`, or
`docs/adr/`, and except `AGENTS.md`, `CLAUDE.md`, and `README.md`. Check the exclusions against
the path list before matching — the bare glob would swallow `.claude/skills/**/SKILL.md`, which
is not prose but agent input.

Cheap because the remainder is non-executable and read by no system: it cannot change program
behavior, its failures are wrong words visible to the next reader, and reverting has no state
consequence.

**Boundary.** "Read by no system" is the load-bearing clause, and it weakens in a docs-generator
repo — Docusaurus consumes frontmatter (`id`, `sidebar_label`, `slug`), and MDX can embed live JSX.
Prose body text stays cheap; a changed `slug` can break every inbound link, and embedded JSX is
code. When a diff touches frontmatter keys or JSX inside markdown, treat those hunks as unmatched
and skim only the prose around them.

Excluded markdown *is* input to something — agent instructions, workflow config, recorded
decisions. `AGENTS.md` and `.claude/**` belong to `reviewing-agent-ready-prs`.

## Promotion candidates — not yet granted

Recorded so the reasoning isn't re-derived each time, and so a promotion is a deliberate act.

- **`**/src/test/**` (test-only diffs).** Tempting: cannot break production directly. But a
  weakened or deleted assertion fails *silently* and leaves a real regression undetected later,
  which is the exact failure profile this skill exists to avoid. Would need a way to establish
  that no existing assertion was weakened before this could be granted.
- **Frontend `**/client/**`.** Plausibly loud (build and type errors) and revertable, but has an
  owning domain skill already, and the user's review load here is near zero — no evidence to
  promote on.
- **`.github/workflows/**`.** Not cheap: a broken workflow can block the merge queue for
  everyone. Owned by `ci-validation`.
