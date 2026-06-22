#!/usr/bin/env bash
# ArchitectOS git guardrails — PreToolUse hook for Bash.
#
# Blocks irreversible / unsafe git operations before they run and tells the agent what to
# do instead. Reads the tool call as JSON on stdin; exit 2 denies the call and feeds the
# message back to the model.
#
# Disable entirely with:  export AOS_DISABLE_GIT_GUARDRAILS=1
# Allow direct work on protected branches with: export AOS_ALLOW_PROTECTED=1
#
# Protected branches: main, master, develop, release/*

set -euo pipefail

if [[ "${AOS_DISABLE_GIT_GUARDRAILS:-0}" == "1" ]]; then
  exit 0
fi

# Extract the bash command from the hook payload (python3 is present on macOS/most Linux).
CMD="$(python3 -c 'import json,sys
try:
    data = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
print((data.get("tool_input") or {}).get("command", ""))' 2>/dev/null || true)"

# Nothing to inspect, or not a git command — allow.
[[ -z "$CMD" ]] && exit 0
[[ "$CMD" == *git* ]] || exit 0

deny() {
  # stderr on a PreToolUse hook with exit 2 is shown to the model as the block reason.
  echo "🛡️  ArchitectOS git guardrail blocked this command." >&2
  echo "" >&2
  echo "$1" >&2
  echo "" >&2
  echo "Override for this session if you are sure: export AOS_DISABLE_GIT_GUARDRAILS=1" >&2
  exit 2
}

current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

is_protected() {
  case "$1" in
    main|master|develop) return 0 ;;
    release/*) return 0 ;;
    *) return 1 ;;
  esac
}

# ── 1. Force push (force-with-lease is allowed — it's the safe variant) ──────
if echo "$CMD" | grep -Eq 'git[[:space:]]+push'; then
  if echo "$CMD" | grep -Eq -- '(--force([^-]|$)|-[A-Za-z]*f)' && ! echo "$CMD" | grep -q -- '--force-with-lease'; then
    deny "Force-pushing can overwrite remote history and other people's work.
Use 'git push --force-with-lease' instead — it refuses to clobber commits you haven't seen."
  fi
fi

# ── 2. Destructive working-tree resets ──────────────────────────────────────
if echo "$CMD" | grep -Eq 'git[[:space:]]+reset[[:space:]]+(--hard|.*[[:space:]]--hard)'; then
  deny "'git reset --hard' permanently discards uncommitted work.
If you need to undo, prefer 'git stash' (recoverable) or reset a specific path.
If a hard reset is genuinely intended, ask the user to confirm first."
fi

# ── 3. Deleting untracked files ─────────────────────────────────────────────
if echo "$CMD" | grep -Eq 'git[[:space:]]+clean[[:space:]]+-[A-Za-z]*f'; then
  deny "'git clean -f' deletes untracked files irreversibly.
Run 'git clean -n' (dry run) first and confirm with the user before deleting anything."
fi

# ── 4. Skipping commit hooks ────────────────────────────────────────────────
if echo "$CMD" | grep -Eq 'git[[:space:]]+commit' && echo "$CMD" | grep -q -- '--no-verify'; then
  deny "--no-verify bypasses pre-commit and commit-msg hooks (lint, tests, secret scans).
Fix what the hooks are flagging instead of skipping them."
fi

# ── 5. Direct commit / push on a protected branch ───────────────────────────
if [[ "${AOS_ALLOW_PROTECTED:-0}" != "1" ]]; then
  if echo "$CMD" | grep -Eq 'git[[:space:]]+(commit|push)'; then
    BRANCH="$(current_branch)"
    if [[ -n "$BRANCH" ]] && is_protected "$BRANCH"; then
      deny "You are on protected branch '$BRANCH'. Don't commit or push here directly.
Create a feature branch first:  git switch -c <type>/<short-description>
Then commit there and open a PR. (Set AOS_ALLOW_PROTECTED=1 to override.)"
    fi
  fi
fi

exit 0
