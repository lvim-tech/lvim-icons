-- lvim-icons.resolve: the lookup chain + result materialisation.
-- Lookup order for a name/path: exact BASENAME (filenames table) → EXTENSION tail, longest
-- first so `test.tsx` can beat `tsx` (extensions table) → caller's `opts.filetype`
-- (filetypes table) → the configured default. A caller may also ask directly by `opts.kind`
-- (special table: directories/symlinks/executables) or via the `by_*` helpers.
--
-- materialise() turns a raw spec into the public result `{ glyph, hl, color, width, name, image }`,
-- applying the active render mode (in the image modes the icon's image — two placeholder cells in a group
-- whose fg is the image id — when it has an SVG, else the font glyph; hence `width` 2 vs 1) and the
-- colour mode (a palette role group, or a lazily-made brand group). No colour is inlined — `hl` is a
-- named group; `color` is the resolved hex for callers that must paint manually (statusline chunks).
-- An image icon can ONLY be painted through `hl`: its colour is the image id.
--
---@module "lvim-icons.resolve"

local config = require("lvim-icons.config")
local highlights = require("lvim-icons.highlights")
local svg = require("lvim-icons.svg")
local placeholders = require("lvim-icons.placeholders")
local material = require("lvim-icons.material")
local c = require("lvim-utils.colors")

-- The data tables are required ONCE (Lua caches the module), so setup() can merge user
-- overrides into these very tables in place and every lookup here sees them live.
local T = {
    extensions = require("lvim-icons.data.extensions"),
    filenames = require("lvim-icons.data.filenames"),
    filetypes = require("lvim-icons.data.filetypes"),
    special = require("lvim-icons.data.special"),
}

local M = {}

---@class LvimIconResult
---@field glyph string   The text to render: a Nerd Font char, or (image) two kitty placeholder cells
---@field hl    string   Highlight group to paint it with — REQUIRED for an image (its fg is the image id)
---@field color string   Resolved hex colour of the font icon (for manual painting: statusline chunks)
---@field width integer  Display-cell width of `glyph` (1 for a font glyph, 2 for an image)
---@field name  string   The stable icon id
---@field image boolean  true when `glyph` is a terminal image (image modes), false for a font glyph
---@field id    string?  the Material icon id drawn (an image only), e.g. "rust", "folder-git-open", "file"
---@field placement "real"|"virtual"  how a buffer view should put it on a line (config.placement)

---@class LvimIconTarget  what was asked for, so the image modes can resolve it with Material's own rules
---@field name?     string  a path or basename
---@field filetype? string
---@field kind?     string  a filesystem kind (directory, directory_open, symlink, …)
---@field ext?      string  an extension alone

-- kinds drawn as a folder (open or closed) in the image modes; every other kind is looked up as a file by its name
local FOLDER_KINDS = { directory = false, directory_empty = false, symlink_dir = false, directory_open = true }

--- The Material icon id for `target` (image modes), 1:1 with VS Code — nil when there is nothing to resolve.
---@param target? LvimIconTarget
---@return string?
local function material_id(target)
    if not target then
        return nil
    end
    local open = FOLDER_KINDS[target.kind or ""]
    if open ~= nil then
        return material.folder(target.name, open)
    end
    if target.ext then
        return material.extension(target.ext)
    end
    return material.file(target.name, target.filetype)
end

--- The highlight group and colour of `spec` under colour mode `mode`:
---   "theme"                 → a palette role that follows the colorscheme.
---   "brand" / "theme_brand" → the icon's real brand hue (raw, or blended toward the theme).
--- An icon with no brand hex always falls back to its theme role.
---@param spec LvimIconSpec
---@param mode string
---@return string group, string color
local function colour_of(spec, mode)
    if mode ~= "theme" and spec.brand then
        return highlights.brand_group(spec.brand, mode), highlights.brand_color(spec.brand, mode)
    end
    local role = spec.role or "fg"
    -- An override spec may name a role with no palette group (e.g. "pink"): fall back to "fg" so the
    -- highlight group (LvimIconFg) and the resolved `color` (c.fg) agree instead of silently diverging.
    if not highlights.is_role(role) then
        role = "fg"
    end
    return highlights.role_group(role), c[role] or c.fg
end

--- Turn a raw spec into the public result, honouring the active render + colour modes.
--- `opts.color_mode` overrides the global config colour mode for THIS call (so a consumer can
--- pick "theme"/"brand"/"theme_brand" per plugin without touching the global config).
--- `target` says what was asked for: in the image modes the IMAGE is chosen from it by Material's rules (the font
--- glyph, colour and `name` still come from `spec`).
---@param spec LvimIconSpec
---@param opts { color_mode?: string, font?: boolean }?
---@param target? LvimIconTarget
---@return LvimIconResult
function M.materialise(spec, opts, target)
    local mode = (opts and opts.color_mode) or config.color_mode
    local group, color = colour_of(spec, mode)

    -- "mix" / "material" (where the terminal can show it): the Material Icon Theme's image for the target
    -- (1:1 with VS Code), its colour mode mapped onto the SVG's own colours (recolor.lua). "nerd", or nothing
    -- to resolve: the glyph. `opts.font`: the caller paints the icon itself (a colour of its own) — only a
    -- glyph can be painted, so it gets the glyph.
    local img, id
    if not (opts and opts.font) and svg.files_as_images() then
        id = material_id(target)
        img = id and svg.icon(id, mode) or nil
    end

    if img then
        return {
            glyph = placeholders.CELLS,
            hl = img.hl,
            color = color,
            width = 2,
            name = spec.name,
            image = true,
            id = id,
            placement = (config.placement and config.placement.image) or "virtual",
        }
    end
    return {
        glyph = spec.glyph,
        hl = group,
        color = color,
        width = 1,
        name = spec.name,
        image = false,
        placement = (config.placement and config.placement.font) or "real",
    }
end

--- The extension chain for a basename: try the longest dotted tail first, then shorter ones,
--- down to the final extension (so a compound key like `test.tsx` wins over `tsx`).
---@param basename string
---@return LvimIconSpec?
local function match_extension(basename)
    local parts = vim.split(basename, ".", { plain = true })
    -- Start at 2 so the STEM of a normal name (`init` in `init.lua`) is never treated as an
    -- extension. A dotfile splits to { "", "bashrc" }, so `.bashrc` DOES enter the chain as the
    -- extension "bashrc" and `.env` resolves via T.extensions.env — intended (devicons parity).
    for i = 2, #parts do
        local ext = table.concat(parts, ".", i):lower()
        local spec = T.extensions[ext]
        if spec then
            return spec
        end
    end
    return nil
end

--- Raw spec for a name/path via the full lookup chain. Returns the default spec if nothing
--- matches (never nil), so callers always get a renderable icon.
---@param name string             a path or bare filename
---@param opts { filetype?: string, kind?: string }?
---@return LvimIconSpec
function M.spec_for(name, opts)
    opts = opts or {}
    -- A filesystem-kind request (directory/symlink/executable) short-circuits the chain.
    if opts.kind then
        return T.special[opts.kind] or config.default
    end
    local basename = vim.fn.fnamemodify(name or "", ":t")
    if basename ~= "" then
        ---@type LvimIconSpec?
        local spec = T.filenames[basename]
        if spec then
            return spec
        end
        spec = match_extension(basename)
        if spec then
            return spec
        end
    end
    if opts.filetype and T.filetypes[opts.filetype] then
        return T.filetypes[opts.filetype]
    end
    return config.default
end

-- ── direct lookups (public helpers) ────────────────────────────────────────

--- Direct extension lookup (no chain). Returns the default when unmapped.
---@param ext string  extension without a dot
---@param opts { color_mode?: string }?
---@return LvimIconResult
function M.by_extension(ext, opts)
    return M.materialise(T.extensions[(ext or ""):lower()] or config.default, opts, { ext = ext })
end

--- Direct filename lookup (no chain). Returns the default when unmapped.
---@param filename string  exact basename
---@param opts { color_mode?: string }?
---@return LvimIconResult
function M.by_filename(filename, opts)
    return M.materialise(T.filenames[filename or ""] or config.default, opts, { name = filename })
end

--- Direct filetype lookup (no chain). Returns the default when unmapped.
---@param ft string  &filetype value
---@param opts { color_mode?: string }?
---@return LvimIconResult
function M.by_filetype(ft, opts)
    return M.materialise(T.filetypes[ft or ""] or config.default, opts, { filetype = ft })
end

--- Direct filesystem-kind lookup (directory/symlink/executable/…). Default when unmapped.
---@param kind string
---@param opts { color_mode?: string }?
---@return LvimIconResult
function M.by_kind(kind, opts)
    return M.materialise(T.special[kind or ""] or config.default, opts, { kind = kind })
end

--- Every distinct icon spec across the data tables, keyed by icon name (deduped). For the
--- gallery command and the health audit.
---@return table<string, LvimIconSpec>
function M.all_specs()
    local out = {}
    for _, tbl in pairs(T) do
        for _, spec in pairs(tbl) do
            out[spec.name] = spec
        end
    end
    return out
end

--- The live data tables (for setup() to merge overrides into, and for health to audit).
---@return table<string, table<string, LvimIconSpec>>
function M.tables()
    return T
end

return M
