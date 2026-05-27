#!/usr/bin/env bash
#
# Install the project's git hooks into .git/hooks/.
#
#   ./scripts/install_git_hooks.sh
#
# Idempotent — overwrites existing hooks with the project versions. The
# canonical hook source lives in scripts/git-hooks/; the .git/hooks/ copy
# is git-ignored (git doesn't track its own hooks).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -d .git ]]; then
  echo "ERROR: not in a git repository ($(pwd))" >&2
  exit 1
fi

SRC="$ROOT/scripts/git-hooks"
DST="$ROOT/.git/hooks"

mkdir -p "$DST"
for hook in "$SRC"/*; do
  name="$(basename "$hook")"
  cp "$hook" "$DST/$name"
  chmod +x "$DST/$name"
  echo "→ installed $name"
done

echo "✓ Git hooks installed."
