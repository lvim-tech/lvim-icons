#!/usr/bin/env bash
# Regenerate assets/nerd/ — every glyph of the Nerd Fonts symbols font as its own compressed SVG
# (`<CODEPOINT>.svgz`), the source of the image modes' Nerd icons. Needs python3 (fontTools is installed into
# a throw-away venv) and the font: given as the argument, else found with fc-match.
#
#   scripts/update-nerd.sh
#   scripts/update-nerd.sh /path/to/SymbolsNerdFont-Regular.ttf
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="$root/assets/nerd"
font="${1:-$(fc-match -f '%{file}' 'Symbols Nerd Font')}"
[[ -f "$font" ]] || {
    echo "no Symbols Nerd Font found (pass its .ttf)" >&2
    exit 1
}
tmp="$(mktemp -d)"
trap 'rm -r "$tmp"' EXIT

python3 -m venv "$tmp/venv"
"$tmp/venv/bin/pip" install --quiet --disable-pip-version-check fonttools
"$tmp/venv/bin/python" "$root/scripts/extract_nerd.py" "$font" "$tmp/svg"

mkdir -p "$dest"
find "$dest" -maxdepth 1 \( -name '*.svgz' -o -name '*.svg' \) -delete
for f in "$tmp"/svg/*.svg; do
    gzip -9 -n -c "$f" >"$dest/$(basename "$f" .svg).svgz"
done
cp "$tmp/svg/metrics.json" "$dest/metrics.json"
"$tmp/venv/bin/python" -c "
from fontTools.ttLib import TTFont; import sys
print(TTFont(sys.argv[1])['name'].getDebugName(5))" "$font" >"$dest/VERSION"
echo "$(find "$dest" -maxdepth 1 -name '*.svgz' | wc -l) Nerd glyphs ($(cat "$dest/VERSION")) in $dest"
