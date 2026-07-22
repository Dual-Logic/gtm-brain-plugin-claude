#!/usr/bin/env bash
# package-plugin.sh — build a clean, distributable copy of the GTM Brain plugin.
#
# Why this exists: the primary install path is the plugin MARKETPLACE / git-declared
# settings (the repo *is* the source — see README "Install"). This script produces a
# self-contained zip for archival and for any manual-upload path, and — importantly —
# it ships ONLY the plugin surface: it excludes the internal plan, git history, and
# scratch, satisfying the plan's DoD ("abandoned/experimental scaffold removed from
# the final bundle").
#
# Usage:  bash scripts/package-plugin.sh
# Output: dist/gtm-brain-plugin-<version>.zip
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="$(python3 -c "import json;print(json.load(open('.claude-plugin/plugin.json'))['version'])")"
OUT="dist/gtm-brain-plugin-${VERSION}.zip"

# What a consumer needs — the plugin surface only.
INCLUDE=(
  ".claude-plugin"
  "skills"
  "reference"
  "README.md"
  "CONNECTORS.md"
)

# Belt-and-suspenders excludes (in case a path above ever widens).
EXCLUDE=(
  "*/.git/*" "*.DS_Store" "*/docs/*" "*/dist/*" "*/scripts/*" "*/node_modules/*"
)

mkdir -p dist
rm -f "$OUT"

zip -r -q "$OUT" "${INCLUDE[@]}" -x "${EXCLUDE[@]}"

echo "Built $OUT"
echo "Contents:"
unzip -l "$OUT" | awk 'NR>3 && NF>=4 {print "  " $4}' | grep -v '^  $' || true
echo
echo "Primary install is via marketplace / git-declared settings (see README). This"
echo "zip is an archival / manual-upload artifact."
