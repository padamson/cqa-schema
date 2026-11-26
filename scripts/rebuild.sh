#!/usr/bin/env bash
# scripts/rebuild.sh
#
# Rebuild the combined site (every edition + versioned schema docs) from
# the working tree into `site/`.
#
# Mirrors what `.github/workflows/docs.yml` does in CI (minus the deploy
# step), with the working tree in place of `main`. Producers (`panschema`, `mdbook-panschema`, `mdbook-listings`,
# `mdbook-admonish`) are invoked by name and resolve via $PATH — the
# consumer story, and what CI does. A wrapper that wants this script to
# use different binaries prepends to PATH before invoking it.
#
# Called by `scripts/dev.sh` for the initial build and re-invoked on
# every file change.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ts() { date '+%H:%M:%S'; }

# Every producer resolves through $PATH, here and in everything mdbook
# spawns (a shell alias never reaches either). The report names the binary
# that answered and its version, which is what catches a stale install.
hash -r 2>/dev/null || true
echo ""
echo "==> [$(ts)] Producers in use (via PATH):"
for producer in panschema mdbook-panschema mdbook-listings mdbook-admonish; do
  bin="$(command -v "$producer")" || { printf '  %-18s (not found)\n' "$producer"; continue; }
  # `|| true`: a version flag that fails would otherwise end the script
  # under `set -e`.
  ver="$("$bin" --version 2>/dev/null | head -1 || true)"
  printf '  %-18s %s at %s\n' "$producer" "${ver:-(no version)}" "$bin"
done

echo ""
echo "==> [$(ts)] Rebuild the combined site:"

# Both steps run as in .github/workflows/docs.yml, in its order, with
# --edge-from-worktree so the working tree stands in for `main`.

# 1. Versioned schema docs: site/schema/{main,current}/ and a directory
# per release tag.
panschema publish --edge-from-worktree

# 2. Every edition at site/book/<id>/, and the current one at the site
# root. The books are built in scratch copies, so nothing dev.sh watches
# is written.
mdbook-panschema editions --edge-from-worktree

echo "==> [$(ts)] Done. Reload http://localhost:${PORT:-8000}/"
