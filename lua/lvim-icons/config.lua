-- lvim-icons: the live configuration table.
-- Holds the defaults; setup() merges user overrides into it IN PLACE (via
-- lvim-utils.utils.merge), so every require("lvim-icons.config") reader sees the
-- effective values. The resolver, the highlight factory and the svg runtime all read
-- this table live — no snapshots — so a control-center toggle takes effect with no
-- restart.
--
-- Three render modes:
--   • "nerd" (default) — every icon a single-width Nerd Font glyph, as text, + a palette-derived
--     highlight group (colours track the live theme).
--   • "mix"            — file / folder icons as Material Icon Theme images (1:1 with VS Code), two
--     cells wide, through kitty unicode placeholders (see svg.lua); UI icons stay Nerd glyphs.
--   • "material"       — file / folder icons as in "mix"; the UI icons as images of their own Nerd
--     glyph, in their owner's colour (see ui.lua).
--   Images only where the terminal shows them; anywhere else every icon is its Nerd glyph, as text.
--
---@module "lvim-icons.config"

---@class LvimIconsSvgConfig
---@field dir  string?  A directory of your own SVGs, searched before the bundled assets/material/ (same file names)
---@field fill number   The icon square as a fraction of the cell height (capped by the 2-cell width)
---@field guide_px integer  the thickness of a tree guide line image, in pixels
---@field cell_em number    the terminal font's cell width in ems (where a guide under a Nerd glyph goes)

---@class LvimIconsPlacement
---@field font  "real"|"virtual"  a Nerd Font glyph
---@field image "real"|"virtual"  an svg-mode image

---@class LvimIconsOverrides
---@field extensions table<string, LvimIconSpec>  Extension → spec overrides/additions
---@field filenames  table<string, LvimIconSpec>  Full-filename → spec overrides/additions
---@field filetypes  table<string, LvimIconSpec>  Neovim filetype → spec overrides/additions
---@field special    table<string, LvimIconSpec>  Kind (directory/symlink/executable/…) → spec overrides

---@class LvimIconsConfig
---@field mode        "nerd"|"mix"|"material"  Render mode (see the module header)
---@field color_mode  "theme"|"brand"|"theme_brand"  Icon colour source (see the value comment below)
---@field brand_blend number               theme_brand: how much of the brand hue to keep (1.0 = raw brand, 0.0 = theme bg)
---@field svg         LvimIconsSvgConfig    svg-mode options
---@field placement   LvimIconsPlacement    how buffer views put an icon on a line, per kind of icon
---@field default     LvimIconSpec         The spec returned when nothing matches
---@field overrides   LvimIconsOverrides   User additions / overrides merged into the live data tables at setup

---@type LvimIconsConfig
return {
    -- Render mode: "nerd" (every icon a Nerd glyph, as text — the portable default), "mix" (file /
    -- folder icons as Material images, the rest Nerd glyphs) or "material" (file / folder icons Material,
    -- UI icons images of their Nerd glyph). Images need lvim-image and a terminal that shows kitty
    -- unicode placeholders (see svg.lua / :checkhealth); everywhere else icons are Nerd glyphs.
    mode = "nerd",
    -- Icon colour source (Nerd glyphs; also the image recolouring — see recolor.lua):
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
        -- A directory of your own SVGs (e.g. a licensed icon set), searched before the bundled ones:
        -- `<material id>.svg` (`rust.svg`, `folder-git.svg`), `nerd/<CODEPOINT>.svg`.
        dir = nil,
        -- The icon: the icon square as a fraction of the cell HEIGHT, drawn centred in its two cells (capped
        -- by their width). 0.72 leaves a margin above and below, so icons on adjacent lines do not touch.
        fill = 0.72,
        -- "material": the thickness of a tree guide line (drawn as an image under the icons), in pixels.
        guide_px = 2,
        -- The terminal font's cell width as a fraction of its em (0.6 for most coding fonts): a guide line under
        -- a Nerd glyph is drawn at the glyph's own middle, which the terminal places at this scale.
        cell_em = 0.6,
    },
    -- How a BUFFER view (a file tree, a picker list) puts an icon on a line, per kind of icon:
    --   "virtual" — inline virtual text (an extmark): drawn in place, but not part of the buffer text — the
    --               cursor skips it, and it never ends up in a yank, a search or an edit.
    --   "real"    — the icon is text of the line, as icons always were.
    -- Status bars, winbars and tab lines have no extmarks and no cursor: there the icon is always text.
    -- (lvim-utils.icons.text / .mark apply this for a consumer.)
    placement = {
        font = "real",
        image = "virtual",
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
