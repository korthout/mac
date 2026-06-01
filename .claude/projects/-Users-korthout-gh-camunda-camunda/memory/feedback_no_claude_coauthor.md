---
name: no-claude-coauthor
description: Never add Co-Authored-By Claude trailer to git commits
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 370f872b-5bdd-4b45-a940-f5e2a4180469
---

Do not add the `Co-Authored-By: Claude ...` trailer (or any Claude/Anthropic co-author trailer) to commit messages.

**Why:** User explicitly does not want Claude listed as co-author on commits in this repo.

**How to apply:** When creating any git commit (regular, amend, backport, etc.), omit the Co-Authored-By Claude line that the default commit workflow suggests. Standard commit message body only.
