#!/usr/bin/env bash
# SessionStart hook: surface the current branch's WIP doc into context.
# Pairs with the /wip skill. Branch-scoped artifacts live (gitignored) under
# .claude/artifacts/<branch>/ ; the working memo is wip.md.
set -uo pipefail
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
branch="$(git -C "$dir" branch --show-current 2>/dev/null)"
# Not a git repo / detached HEAD: nothing to do.
if [ -z "$branch" ]; then
  exit 0
fi
# Integration/母体ブランチには WIP メモを持たせない。
case "$branch" in
  develop | main | master) exit 0 ;;
esac
