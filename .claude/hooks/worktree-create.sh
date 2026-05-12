#!/usr/bin/env bash
# WorktreeCreate hook
#
# Enforces:
#   1. worktrees live in the directory ABOVE the repository
#   2. worktree folder names are prefixed with the repository's directory name
#   3. final format: "<repo-dir>-<worktree-name>"
#
# Reads the hook payload as JSON on stdin (fields: cwd, name, branch).
# Creates the worktree and prints its absolute path on stdout so Claude
# Code can switch into it.

set -euo pipefail

input=$(cat)

cwd=$(printf '%s' "$input"    | jq -r '.cwd // empty')
name=$(printf '%s' "$input"   | jq -r '.name // .worktreeName // empty')
branch=$(printf '%s' "$input" | jq -r '.branch // .worktreeBranch // empty')

# Resolve the repository top-level — cwd may be a subdirectory.
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || repo_root="$cwd"
else
  repo_root=$(git rev-parse --show-toplevel)
fi

repo_dir=$(basename "$repo_root")
parent_dir=$(dirname  "$repo_root")
prefix="$repo_dir"

# Fall back to a timestamped name when Claude did not supply one.
if [ -z "$name" ]; then
  name="wt-$(date +%Y%m%d-%H%M%S)"
fi

# If a caller already prefixed the name themselves, don't double it.
clean_name="${name#${prefix}-}"
folder="${prefix}-${clean_name}"
worktree_path="${parent_dir}/${folder}"

args=("$worktree_path")
if [ -n "$branch" ]; then
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    args+=("$branch")
  else
    args+=("-b" "$branch")
  fi
fi

# Create the worktree. stderr surfaces to the user;
# stdout carries the path back to Claude Code per the WorktreeCreate hook contract.
git -C "$repo_root" worktree add "${args[@]}" >&2

printf '%s\n' "$worktree_path"
