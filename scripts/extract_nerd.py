#!/usr/bin/env python3
"""Extract every glyph of a Nerd Fonts symbols font into one SVG per codepoint.

The image modes of lvim-icons draw a Nerd icon from its SVG instead of from the font, so it looks exactly like
the glyph a plugin already uses, but as a terminal image with its colour baked in. Each SVG is named by its
codepoint (`F062C.svg`) — the glyph a plugin already uses names its own file.

The drawing keeps the font's proportions: every glyph sits in a square of one em (or of its own size when it is
larger), centred on the glyph, so icons keep their relative sizes and are centred like the Material icons.

It also writes metrics.json: codepoint → the horizontal centre of the glyph's ink, as a fraction of the em,
from the glyph's own origin. A terminal draws a Nerd glyph from the left edge of its cell at the font's em,
so this is where the glyph's middle lands — what a line drawn under it must hit.

Usage: extract_nerd.py FONT.ttf OUT_DIR
"""

from __future__ import annotations

import sys
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    font = TTFont(sys.argv[1])
    out = Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    upm = font["head"].unitsPerEm
    glyphs = font.getGlyphSet()
    written = 0
    metrics = {}
    for cp, name in sorted(font.getBestCmap().items()):
        glyph = glyphs[name]
        bp = BoundsPen(glyphs)
        glyph.draw(bp)
        if not bp.bounds:
            continue  # a blank glyph (a space) has nothing to draw
        x0, y0, x1, y1 = bp.bounds
        side = max(upm, x1 - x0, y1 - y0)
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        # font units are y-up from the baseline; SVG is y-down: flip, and put the square's corner at 0,0
        pen = SVGPathPen(glyphs, ntos=lambda v: f"{v:.1f}".rstrip("0").rstrip("."))
        glyph.draw(TransformPen(pen, (1, 0, 0, -1, side / 2 - cx, side / 2 + cy)))
        d = pen.getCommands()
        if not d:
            continue
        side_s = f"{side:g}"
        (out / f"{cp:04X}.svg").write_text(
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {side_s} {side_s}"><path d="{d}"/></svg>\n'
        )
        written += 1
        metrics[f"{cp:04X}"] = round((x0 + x1) / 2 / upm, 4)
    import json

    (out / "metrics.json").write_text(json.dumps(metrics, separators=(",", ":"), sort_keys=True))
    print(f"{written} glyphs → {out}")


if __name__ == "__main__":
    main()
