# lvim-icons

The single icon provider of the **lvim-tech** set — resolve a filename, extension, filetype or
filesystem kind to a renderable icon `{ glyph, hl, color, width }`. Colours are configurable: each
file type in its **real brand colour** (the default), or driven from the **live lvim-utils
palette** so icons follow the active theme, or a blend of the two (see [Colours](#colours)).

Three render modes:

- **nerd** (default) — every icon a single-width Nerd Font glyph, as text, with a palette-derived
  highlight group. Works in every terminal.
- **mix** — file and folder icons as small full-colour terminal **images**, exactly the ones VS Code
  shows with the [Material Icon Theme](https://github.com/material-extensions/vscode-material-icon-theme)
  (its own manifest picks them); every other (UI) icon its Nerd glyph, as text.
- **material** — file and folder icons as in `mix`; the UI icons (branches, diagnostics, panel titles…)
  as images too: each the SVG of the very Nerd glyph the plugin uses (extracted from Symbols Nerd Font),
  in the colour the plugin gives it.

An image is two cells wide and goes through kitty **unicode placeholders**: sent once, it is then two
placeholder cells of text, so it goes wherever text goes — buffers, floats, statuslines, tab lines. Where
the terminal cannot show images, every icon is its Nerd glyph as text, whatever the mode.

[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lvim-tech/lvim-icons/blob/main/LICENSE)

## Requirements

Requires **Neovim >= 0.10** and [lvim-utils](https://github.com/lvim-tech/lvim-utils) (the palette +
highlight engine). [lvim-ui](https://github.com/lvim-tech/lvim-ui) is optional — it powers the
`:LvimIcons` gallery. Icons as images additionally need [lvim-image](https://github.com/lvim-tech/lvim-image)
(libvips draws the SVGs) and a terminal that shows kitty unicode placeholders: kitty or Ghostty —
inside tmux or zellij only when they pass them through (lvim-image's `tmux_placeholders` /
`zellij_placeholders`; a stock zellij 0.46 does not).

## Installation

### lvim-installer (recommended)

Install and manage it from the LVIM package manager — open the **Plugins** tab and install / update
/ pin it:

```vim
:LvimInstaller plugins
```

lvim-installer installs plugins through Neovim's built-in `vim.pack`, so no external plugin manager
is needed.

### Native (vim.pack)

```lua
vim.pack.add({
    { src = "https://github.com/lvim-tech/lvim-utils" },
    { src = "https://github.com/lvim-tech/lvim-icons" },
})
require("lvim-icons").setup({})
```

`setup()` is optional — the font-mode defaults work without it. Call it to change the render/colour
mode, add overrides, or register the `:LvimIcons` gallery command.

## Usage

```lua
local icons = require("lvim-icons")

local r = icons.get("src/main.rs") --  { glyph = "", hl = "LvimIconOrange", color = "#…", width = 1, name = "rust" }
-- Paint it with the highlight group (preferred):
--   nvim_buf_set_extmark(..., { virt_text = { { r.glyph, r.hl } } })
-- Or use r.color for manual painting (fzf ANSI, statusline chunks).
-- ALWAYS pad columns from r.width (1 for a font glyph, 2 for an image) — never assume 1.
-- An image (r.image == true) can only be painted through r.hl: its colour IS the image id.

icons.get(path, { filetype = ft }) -- filetype hint when the name is weak (help, qf, terminal…)
icons.get(path, { kind = "directory" }) -- a filesystem kind: directory[_open]/symlink/executable/…
icons.by_extension("tsx") -- direct table lookups (no chain)
icons.by_filename("Cargo.toml")
icons.by_filetype("help")
icons.all() -- every icon, materialised (for a custom gallery/audit)
```

Resolution order for `get()`: exact **basename** → **extension** tail (longest first, so
`test.tsx` beats `tsx`) → the passed **filetype** → the configured **default**. It always returns a
renderable result.

### Gallery

```vim
:LvimIcons
```

Opens a searchable gallery through the canonical lvim-ui picker; confirming a row yanks its glyph to
the unnamed and `+` registers — handy when authoring another plugin's UI.

## Render modes

`mode` selects how glyphs are emitted:

- `"nerd"` — every icon a Nerd glyph, as text (default).
- `"mix"` — file / folder icons as Material Icon Theme images, UI icons as Nerd glyphs.
- `"material"` — file / folder icons as in `mix`, UI icons as images of their own Nerd glyph.

The mode can be switched **live**, without a restart — `:LvimIcons mode material` (completes the three
modes) or `require("lvim-icons").set_mode("mix")`. It fires `User LvimIconsMode` (`data = { mode, previous }`):
lvim-ui panels, the lvim-hud bars and the lvim-tech plugins draw their icons again on it. The LVIM Control
Center has it as **Appearance → Icons** (saved, applied again on startup).

Images need a terminal that shows kitty unicode placeholders; anywhere else the icons are Nerd glyphs as
text (a health warning explains). A plugin asks for a UI icon with its own glyph and colour group —

```lua
require("lvim-utils.icons").ui({ glyph = "", hl = "MyPluginGit" })
```

— and gets them back unchanged in `nerd` / `mix`, or in `material` an image of that glyph filled with that
group's colour (re-filled on a theme change).

Each image is drawn into the exact pixels of its two cells (`svg.fill` sets the icon size as a
fraction of the cell height) and redrawn under the same id when the cell size changes. An icon image
is two cells wide — always align columns from the returned `width` — and its highlight group's
foreground is the image id, so it is kept out of backdrop dimming and re-asserted on `:colorscheme`.
`:checkhealth lvim-icons` reports the terminal state, the image size and the **active** mode.

### The shared icon set

The Material set is shared by every lvim program — lvim-icons here, lvim-fuzzy (`lfz`) and lvim-commander
(`lvc`) in the terminal — in ONE place: `~/.local/share/lvim-icons/material` (`$XDG_DATA_HOME`). Each one
carries the set and puts it there when it is missing or older (never a downgrade; swapped in atomically,
so two programs at once never see half a set), and each reads it from there. lvim-icons does it at
`setup()` (deferred, off the startup path); when the shared place is unusable it reads its own
`assets/material`. After `scripts/update-material.sh`, run lvim-fuzzy-ui's `scripts/pack-material.sh` so
the terminal programs carry the new version too.

### Tree guide lines

`require("lvim-icons").guide({ hl = "MyTreeGuide", under = icon })` gives the vertical line a tree draws under
an open folder as an image, in **every** mode where images can be shown (nil elsewhere: keep a text line). It
is two cells wide with a `svg.guide_px` line over the full cell height, so consecutive rows join. `under` is the
icon it runs under: an image is centred in its two cells, so the line goes down their middle; a Nerd glyph is
drawn by the terminal from the cell's left edge, so the line goes under the glyph's own ink centre, read from
`assets/nerd/metrics.json` and scaled by `svg.cell_em`.

### A glyph with no SVG

In `material` a glyph that has no Nerd SVG (a symbol outside the Nerd ranges) stays text. `ui()` marks it with
`pad = true`, so a caller can give it the two cells an image takes and keep its column —
`require("lvim-utils.icons").ui_text()` does this. Prefer Nerd glyphs for UI icons: every lvim-tech plugin
uses them, so every icon can be an image.

## Colours

`color_mode` selects where an icon's colour comes from — three modes:

- `"brand"` (default) — the icon's **real upstream brand colour**, verbatim — independent of the
  theme (the classic nvim-web-devicons look: each file type in its own brand colour).
- `"theme"` — each icon takes a palette **role** (blue/green/red/…). Self-theming: the
  `LvimIcon<Role>` groups re-derive on every colorscheme / palette sync, so icons **follow the
  active theme**.
- `"theme_brand"` — the brand colour **blended toward the theme background** by `brand_blend` (a
  mix: the brand hue, pulled into the theme so it doesn't clash). `1.0` keeps the raw brand colour,
  lower pulls it toward the background. Brand groups are created lazily and track a background flip.

The mode can also be overridden **per call**: `icons.get(name, { color_mode = "brand" })` — so a
consumer can pick a mode without touching the global config (each lvim-tech plugin exposes an
`icon_color_mode` option that forwards here).

## Adding / overriding icons

Add new file types or override built-ins at setup via `overrides` (or at runtime with
`icons.override(tbl)`). The keys are lower-case extensions / filetypes and exact filenames (and the
`special` table is keyed by kind: directory / symlink / executable / …); the spec is
`{ glyph = "<Nerd Font glyph>", role = "<palette role>", brand = "#rrggbb", name = "<id>" }`.

```lua
require("lvim-icons").setup({
    overrides = {
        extensions = {
            astro = { glyph = "", role = "orange", brand = "#ff5d01", name = "astro" },
            lua = { glyph = "", role = "red", brand = "#000080", name = "lua" }, -- recolour a built-in
        },
        filenames = {
            ["flake.nix"] = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" },
        },
        filetypes = {},
        special = {}, -- kind icons: directory / symlink / executable / default
    },
})
```

The bundled set covers ~300 extensions / filenames / filetypes (top languages, configs, data,
office, media, fonts, design, infra). Anything unmapped falls back to the `default` spec — and you
extend it here rather than editing the plugin.

## Default configuration

```lua
require("lvim-icons").setup({
    mode = "nerd", -- "nerd" | "mix" | "material"
    color_mode = "brand", -- "brand" (real per-type colours) | "theme" | "theme_brand"
    brand_blend = 0.7, -- theme_brand: keep this much brand hue (1.0 = raw, 0.0 = theme bg)
    svg = {
        dir = nil, -- your own SVGs, searched before the bundled Material set (same file names)
        fill = 0.72, -- the icon as a fraction of the cell height, centred in its two cells
        guide_px = 2, -- the thickness of a tree guide line image, in pixels
        cell_em = 0.6, -- the terminal font's cell width in ems (puts a guide under a Nerd glyph's middle)
    },
    -- how buffer views put an icon on a line, per kind: "real" (in the text) | "virtual" (inline
    -- virtual text the cursor skips); bars, winbars and tab lines always use text
    placement = {
        font = "real",
        image = "virtual",
    },
    default = { glyph = "", role = "fg", name = "default" },
    overrides = {
        extensions = {}, -- e.g. astro = { glyph = "", role = "orange", brand = "#ff5d01", name = "astro" }
        filenames = {}, -- e.g. ["flake.nix"] = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" }
        filetypes = {},
        special = {}, -- kind icons: directory / symlink / executable / default
    },
})
```

## Highlights

Font mode defines one group per palette role, all self-themed from lvim-utils and overwritable by a
colorscheme or your own `setup`:

`LvimIconRed`, `LvimIconGreen`, `LvimIconBlue`, `LvimIconCyan`, `LvimIconMagenta`, `LvimIconOrange`,
`LvimIconYellow`, `LvimIconPurple`, `LvimIconTeal`, `LvimIconFg`.

Brand mode additionally creates `LvimIconBrand_<hex>` groups on demand. In the image modes every image icon has
its own `LvimIconImg_<name>` group; its foreground is the terminal image id, not a colour — never relink
or recolour it.

## Health

```vim
:checkhealth lvim-icons
```

Reports dependency presence, config validity, a single-width audit of every glyph, and — for the
image modes — lvim-image, whether the terminal shows unicode placeholders, the image size, any mapped icon
without its SVG, and the resulting active render mode.

## Credits

The file / folder icons in `assets/material/` are from the
[Material Icon Theme](https://github.com/material-extensions/vscode-material-icon-theme) (v5.40.0),
© Material Extensions, under the MIT licence — see `assets/material/LICENSE`. The theme's own manifest
(`assets/material/material-icons.json`, the file VS Code reads) decides which icon a file or folder gets, so
they match VS Code 1:1; `scripts/update-material.sh [version]` refreshes the bundle. A directory of your own
SVGs (`svg.dir`) takes precedence by icon id (`rust.svg`, `folder-git-open.svg`, …).


The UI icons of `material` mode in `assets/nerd/` are the glyphs of Symbols Nerd Font ([Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)),
one compressed SVG per codepoint; each comes from an icon set with its own licence — see
`assets/nerd/LICENSE`. `scripts/update-nerd.sh [font.ttf]` extracts them again from a newer font.
