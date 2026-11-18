#!/usr/bin/env bash
# Refresh the bundled Material Icon Theme (svg mode) from npm: every icon SVG, the theme's own manifest
# (material-icons.json — the same file VS Code reads, so names / extensions / folders resolve 1:1) and its
# licence. Run from anywhere; needs npm and tar.
#
#   scripts/update-material.sh            # the version pinned below
#   scripts/update-material.sh 5.41.0     # another version
set -euo pipefail

version="${1:-5.40.0}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="$root/assets/material"
tmp="$(mktemp -d)"
trap 'rm -r "$tmp"' EXIT

(cd "$tmp" && npm pack --silent "material-icon-theme@$version" >/dev/null && tar xzf "material-icon-theme-$version.tgz")

mkdir -p "$dest"
find "$dest" -maxdepth 1 -name '*.svg' -delete
cp "$tmp"/package/icons/*.svg "$dest/"
cp "$tmp/package/dist/material-icons.json" "$dest/"
cp "$tmp/package/LICENSE" "$dest/LICENSE"
printf '%s\n' "$version" >"$dest/VERSION"
echo "Material Icon Theme $version: $(find "$dest" -maxdepth 1 -name '*.svg' | wc -l) icons in $dest"
