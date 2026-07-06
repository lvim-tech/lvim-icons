-- lvim-icons.resolve: the lookup chain + result materialisation.
-- Lookup order for a name/path: exact BASENAME (filenames table) → EXTENSION tail, longest
-- first so `test.tsx` can beat `tsx` (extensions table) → caller's `opts.filetype`
-- (filetypes table) → the configured default. A caller may also ask directly by `opts.kind`
-- (special table: directories/symlinks/executables) or via the `by_*` helpers.
--
-- materialise() turns a raw spec into the public result `{ glyph, hl, color, width, name }`,
-- applying the active render mode (svg sequence when available for the icon, else the font
-- glyph — hence `width` 2 vs 1) and the colour mode (a palette role group, or a lazily-made
-- brand group). No colour is inlined — `hl` is a named group; `color` is the resolved hex for
-- callers that must paint manually (fzf ANSI, statusline chunks).
--
---@module "lvim-icons.resolve"

local config = require("lvim-icons.config")
local highlights = require("lvim-icons.highlights")
local svg = require("lvim-icons.svg")
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
---@field glyph string   The glyph to render (a Nerd Font char, or an svg ligature sequence)
---@field hl    string   Highlight group to paint it with (preferred over `color`)
---@field color string   Resolved hex colour (for manual painting: fzf ANSI, statusline chunks)
---@field width integer  Display-cell width of `glyph` (1 in font mode, 2 in svg mode)
---@field name  string   The stable icon id

--- Turn a raw spec into the public result, honouring the active render + colour modes.
---@param spec LvimIconSpec
---@return LvimIconResult
function M.materialise(spec)
    -- Render mode → glyph + width. In svg mode, use the icon's ligature sequence when it has
    -- one; otherwise fall back to its font glyph for THIS icon (per-icon graceful degradation).
    local glyph, width
    if svg.active_mode() == "svg" then
        local seq = svg.sequence(spec.name)
        if seq then
            glyph, width = seq, 2
        else
            glyph, width = vim.fn.nr2char(spec.cp, 1), 1
        end
    else
        glyph, width = vim.fn.nr2char(spec.cp, 1), 1
    end

    -- Colour mode → highlight group + resolved hex.
    local group, color
    if config.color_mode == "brand" and spec.brand then
        group = highlights.brand_group(spec.brand)
        color = require("lvim-utils.highlight").blend(spec.brand, c.bg, config.brand_blend)
    else
        local role = spec.role or "fg"
        group = highlights.role_group(role)
        color = c[role] or c.fg
    end

    return { glyph = glyph, hl = group, color = color, width = width, name = spec.name }
end

--- The extension chain for a basename: try the longest dotted tail first, then shorter ones,
--- down to the final extension (so a compound key like `test.tsx` wins over `tsx`).
---@param basename string
---@return LvimIconSpec?
local function match_extension(basename)
    local parts = vim.split(basename, ".", { plain = true })
    -- Start at 2 so a leading dot (dotfiles) or the stem is never treated as an extension.
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
---@return LvimIconResult
function M.by_extension(ext)
    return M.materialise(T.extensions[(ext or ""):lower()] or config.default)
end

--- Direct filename lookup (no chain). Returns the default when unmapped.
---@param filename string  exact basename
---@return LvimIconResult
function M.by_filename(filename)
    return M.materialise(T.filenames[filename or ""] or config.default)
end

--- Direct filetype lookup (no chain). Returns the default when unmapped.
---@param ft string  &filetype value
---@return LvimIconResult
function M.by_filetype(ft)
    return M.materialise(T.filetypes[ft or ""] or config.default)
end

--- Direct filesystem-kind lookup (directory/symlink/executable/…). Default when unmapped.
---@param kind string
---@return LvimIconResult
function M.by_kind(kind)
    return M.materialise(T.special[kind or ""] or config.default)
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
