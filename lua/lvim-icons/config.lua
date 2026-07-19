-- lvim-icons: the live configuration table.
-- Holds the defaults; setup() merges user overrides into it IN PLACE (via
-- lvim-utils.utils.merge), so every require("lvim-icons.config") reader sees the
-- effective values. The resolver, the highlight factory and the svg runtime all read
-- this table live — no snapshots — so a control-center toggle takes effect with no
-- restart.
--
-- Two render modes live behind one resolver:
--   • "font" (default) — a single-width Nerd Font glyph + a palette-derived highlight
--     group. Colors track the live theme.
--   • "svg"            — full-colour COLRv1 vector glyphs shaped by the terminal from an
--     emoji-base + variation-selector ligature (see svg.lua). Falls back to "font" per
--     icon when no svg mapping exists, and wholesale when the font is not installed.
--   • "auto"           — "svg" only when the font is installed AND the terminal is on the
--     known-good allowlist; otherwise "font".
--
---@module "lvim-icons.config"

---@class LvimIconsSvgConfig
---@field font_family      string   Font family name probed with `fc-list` (must match the shipped font)
---@field assume_supported boolean  Skip the terminal allowlist — the user vouches their terminal shapes COLRv1 ligatures
---@field variant          string?  Force a theme variant ("soft"|"dark"|"darker"|"light"); nil = follow lvim-colorscheme

---@class LvimIconsOverrides
---@field extensions table<string, LvimIconSpec>  Extension → spec overrides/additions
---@field filenames  table<string, LvimIconSpec>  Full-filename → spec overrides/additions
---@field filetypes  table<string, LvimIconSpec>  Neovim filetype → spec overrides/additions
---@field special    table<string, LvimIconSpec>  Kind (directory/symlink/executable/…) → spec overrides

---@class LvimIconsConfig
---@field mode        "font"|"svg"|"auto"  Render mode (see the module header)
---@field color_mode  "theme"|"brand"|"theme_brand"  Icon colour source (see the value comment below)
---@field brand_blend number               theme_brand: how much of the brand hue to keep (1.0 = raw brand, 0.0 = theme bg)
---@field svg         LvimIconsSvgConfig    svg-mode options
---@field default     LvimIconSpec         The spec returned when nothing matches
---@field overrides   LvimIconsOverrides   User additions / overrides merged into the live data tables at setup

---@type LvimIconsConfig
return {
    -- Render mode. "font" is the portable default (works in every terminal); "svg" needs
    -- the shipped COLRv1 font + a shaping-capable terminal (see svg.lua / :checkhealth);
    -- "auto" resolves to "svg" only when both hold, else "font".
    mode = "font",
    -- Icon colour source (font mode):
    --   "brand"       — the icon's REAL upstream brand colour, verbatim — INDEPENDENT of the
    --                   theme (the classic nvim-web-devicons look). THE DEFAULT.
    --   "theme"       — each icon takes a palette ROLE colour (blue/green/red/…). Self-theming:
    --                   the LvimIcon<Role> groups re-derive on every colorscheme / palette sync,
    --                   so icons follow the active theme.
    --   "theme_brand" — the brand colour blended toward the theme background by `brand_blend`
    --                   (a MIX: the brand hue, but pulled into the theme so it does not clash).
    color_mode = "brand",
    -- theme_brand only: how much of the brand hue to keep. 1.0 = the raw brand colour, lower
    -- values pull it toward the editor background. (Ignored by "theme" and "brand".)
    brand_blend = 0.7,
    svg = {
        -- The font family the shipped COLRv1 glyphs live in; probed once with `fc-list`.
        font_family = "LvimIcons",
        -- Set true when you KNOW your terminal shapes COLRv1 ligatures (kitty/WezTerm/…)
        -- but it is not on the built-in allowlist — skips the $TERM check for "auto".
        assume_supported = false,
        -- Force a theme-variant glyph set. nil follows the active lvim-colorscheme
        -- brightness variant (Soft/Dark/Darker/Light) so svg icons track the theme.
        variant = nil,
    },
    -- Returned when no filename/extension/filetype matches. `glyph` is a real Nerd Font
    -- character; `role` a palette slot. (A plain file glyph in the neutral foreground colour.)
    default = { glyph = "", role = "fg", name = "default" },
    -- User additions / overrides, merged into the live data tables in setup(). Same spec
    -- shape as the built-ins: { glyph = "<nerd glyph>", role = "<palette role>", brand = "#hex",
    -- name = "<icon name>" }. Keyed exactly like the data tables (lower-case ext/ft, exact
    -- filename).
    overrides = {
        extensions = {},
        filenames = {},
        filetypes = {},
        special = {}, -- kind icons (directory / symlink / executable / …); merged like the others
    },
}
