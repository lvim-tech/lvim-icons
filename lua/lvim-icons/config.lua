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

---@class LvimIconsConfig
---@field mode        "font"|"svg"|"auto"  Render mode (see the module header)
---@field color_mode  "palette"|"brand"    Font-mode colour source: a palette role, or the icon's brand hex blended to bg
---@field brand_blend number               brand mode: blend factor toward the editor bg (1.0 = raw brand hex, 0.0 = bg)
---@field svg         LvimIconsSvgConfig    svg-mode options
---@field default     LvimIconSpec         The spec returned when nothing matches
---@field overrides   LvimIconsOverrides   User additions / overrides merged into the live data tables at setup

---@type LvimIconsConfig
return {
    -- Render mode. "font" is the portable default (works in every terminal); "svg" needs
    -- the shipped COLRv1 font + a shaping-capable terminal (see svg.lua / :checkhealth);
    -- "auto" resolves to "svg" only when both hold, else "font".
    mode = "font",
    -- Font-mode colour source:
    --   "palette" — each icon maps to a palette ROLE (blue/green/red/…) so icons always
    --               harmonise with the active theme (one highlight group per role).
    --   "brand"   — the upstream brand hex, blended toward the editor bg by `brand_blend`
    --               so foreign colours sit in the theme (per-icon groups, created lazily).
    color_mode = "palette",
    -- brand mode only: how much of the brand hue to keep. 1.0 = the raw brand colour,
    -- lower values pull it toward the editor background so it does not clash.
    brand_blend = 1.0,
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
    -- Returned when no filename/extension/filetype matches. `cp` is a Nerd Font codepoint;
    -- `role` a palette slot. (A plain file glyph in the neutral foreground colour.)
    default = { cp = 0xF15B, role = "fg", name = "default" },
    -- User additions / overrides, merged into the live data tables in setup(). Same spec
    -- shape as the built-ins: { cp = <codepoint>, role = "<palette role>", brand = "#hex",
    -- name = "<icon name>" }. Keyed exactly like the data tables (lower-case ext/ft, exact
    -- filename).
    overrides = {
        extensions = {},
        filenames = {},
        filetypes = {},
    },
}
