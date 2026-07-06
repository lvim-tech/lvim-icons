# lvim-icons

The single icon provider of the **lvim-tech** set — resolve a filename, extension, filetype or
filesystem kind to a renderable icon `{ glyph, hl, color, width }`. Colours are configurable: each
file type in its **real brand colour** (the default), or driven from the **live lvim-utils
palette** so icons follow the active theme, or a blend of the two (see [Colours](#colours)).

Two render modes behind one resolver:

- **font** (default) — a single-width Nerd Font glyph + a palette-derived highlight group. Works in
  every terminal.
- **svg** — full-colour **COLRv1** vector glyphs, emitted as a plain-text ligature (an emoji base +
  Unicode variation selectors) that a shaping-capable terminal substitutes with the coloured glyph.
  Because it is plain text it works everywhere text does — statuslines, trees, even a fuzzy-finder
  TUI. Falls back to font mode automatically when the font is not installed (and per-icon when an
  icon has no svg mapping yet).

[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lvim-tech/lvim-icons/blob/main/LICENSE)

## Requirements

Requires **Neovim >= 0.10** and [lvim-utils](https://github.com/lvim-tech/lvim-utils) (the palette +
highlight engine). [lvim-ui](https://github.com/lvim-tech/lvim-ui) is optional — it powers the
`:LvimIcons` gallery. svg mode additionally needs the shipped COLRv1 font installed and a terminal
that shapes COLRv1 ligatures (kitty, WezTerm, Alacritty, foot, Konsole, GNOME Terminal).

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
-- ALWAYS pad columns from r.width (1 in font mode, 2 in svg mode) — never assume 1.

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

- `"font"` — Nerd Font glyphs (portable default).
- `"svg"` — COLRv1 ligatures when the font is installed, else font mode (a health warning explains).
- `"auto"` — svg only when the font is installed **and** the terminal is on the known-good shaping
  allowlist; otherwise font. Set `svg.assume_supported = true` to vouch for a terminal that shapes
  COLRv1 but is not on the allowlist.

Terminal COLRv1 shaping cannot be detected at runtime (no terminal advertises it), so `auto` stays
conservative and `:checkhealth lvim-icons` reports the font/terminal state and the **active** mode.
In svg mode glyphs are two cells wide — always align columns from the returned `width`.

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
`icons.override(tbl)`). The keys are lower-case extensions / filetypes and exact filenames; the
spec is `{ cp = <Nerd Font codepoint>, role = "<palette role>", brand = "#rrggbb", name = "<id>" }`.

```lua
require("lvim-icons").setup({
    overrides = {
        extensions = {
            astro = { cp = 0xE6B3, role = "orange", brand = "#ff5d01", name = "astro" },
            lua = { cp = 0xE620, role = "red", brand = "#000080", name = "lua" }, -- recolour a built-in
        },
        filenames = {
            ["flake.nix"] = { cp = 0xF313, role = "blue", brand = "#7ebae4", name = "nix" },
        },
        filetypes = {},
    },
})
```

The bundled set covers ~300 extensions / filenames / filetypes (top languages, configs, data,
office, media, fonts, design, infra). Anything unmapped falls back to the `default` spec — and you
extend it here rather than editing the plugin.

## Default configuration

```lua
require("lvim-icons").setup({
    mode = "font", -- "font" | "svg" | "auto"
    color_mode = "brand", -- "brand" (real per-type colours) | "theme" | "theme_brand"
    brand_blend = 0.7, -- theme_brand: keep this much brand hue (1.0 = raw, 0.0 = theme bg)
    svg = {
        font_family = "LvimIcons", -- fc-list probe target
        assume_supported = false, -- skip the terminal allowlist (your terminal shapes COLRv1)
        variant = nil, -- nil = follow the active lvim-colorscheme variant
    },
    default = { cp = 0xF15B, role = "fg", name = "default" },
    overrides = {
        extensions = {}, -- e.g. astro = { cp = 0xE6B3, role = "orange", brand = "#ff5d01", name = "astro" }
        filenames = {}, -- e.g. ["flake.nix"] = { cp = 0xF313, role = "blue", brand = "#7ebae4", name = "nix" }
        filetypes = {},
    },
})
```

## Highlights

Font mode defines one group per palette role, all self-themed from lvim-utils and overwritable by a
colorscheme or your own `setup`:

`LvimIconRed`, `LvimIconGreen`, `LvimIconBlue`, `LvimIconCyan`, `LvimIconMagenta`, `LvimIconOrange`,
`LvimIconYellow`, `LvimIconPurple`, `LvimIconTeal`, `LvimIconFg`.

Brand mode additionally creates `LvimIconBrand_<hex>` groups on demand.

## Health

```vim
:checkhealth lvim-icons
```

Reports dependency presence, config validity, a single-width audit of every glyph, and — for svg
mode — whether the font is installed, whether the terminal is known-good, and the resulting active
render mode.
