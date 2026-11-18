-- lvim-icons.ui: the UI icons — everything that is not a file or a folder (a git branch, an LSP server, a
-- diagnostic, a panel title…). A plugin keeps its own Nerd glyph and colour group and asks here:
--
--   require("lvim-icons").ui({ glyph = "", hl = "LvimHudGit" })
--
-- In "material" mode (where the terminal shows images) the answer is an IMAGE of that very glyph — drawn from
-- its SVG (assets/nerd/, extracted from Symbols Nerd Font) and filled with the colour of the caller's group —
-- so the UI icons are images like the file icons, and each plugin keeps its colours. A theme change re-fills
-- them under the same ids. In "nerd" and "mix", or with no images, the answer is the caller's own glyph and
-- group, unchanged.
--
-- Your own SVG for a glyph: `svg.dir`/nerd/<CODEPOINT>.svg.
--
---@module "lvim-icons.ui"

local config = require("lvim-icons.config")
local placeholders = require("lvim-icons.placeholders")

local M = {}

--- The fill colour for a caller: its explicit `color`, else the foreground of its group (links followed),
--- else the editor's foreground.
---@param opts { hl?: string, color?: string }
---@return string  "#rrggbb"
local function fill_of(opts)
    if opts.color and opts.color ~= "" then
        return opts.color
    end
    local fg = opts.hl and opts.hl ~= "" and vim.api.nvim_get_hl(0, { name = opts.hl, link = false }).fg
    if not fg then
        fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg or 0xc0c0c0
    end
    return ("#%06x"):format(fg)
end

--- The UI icon for a caller's glyph (see the header).
---@param opts { glyph: string, hl?: string, color?: string }
---@return LvimIconResult
function M.get(opts)
    opts = opts or {}
    local glyph = opts.glyph or ""
    local font = {
        glyph = glyph,
        hl = opts.hl or "",
        color = opts.color,
        width = glyph ~= "" and vim.fn.strdisplaywidth(glyph) or 0,
        name = "",
        image = false,
        placement = (config.placement and config.placement.font) or "real",
    }
    local svg = require("lvim-icons.svg")
    if not svg.ui_as_images() then
        return font
    end
    local path = svg.nerd_path(glyph)
    if not path then
        -- no SVG for it (not a Nerd glyph): it stays text, but beside 2-cell images it should take two cells
        -- too, so a caller can pad it and keep its column (lvim-utils.icons.ui_text does)
        font.pad = true
        return font
    end
    local key = ("ui:%X|%s"):format(vim.fn.char2nr(glyph), opts.color or opts.hl or "")
    local e = svg.mono(key, path, function()
        return fill_of(opts)
    end)
    if not e then
        return font
    end
    return {
        glyph = placeholders.CELLS,
        hl = e.hl,
        color = fill_of(opts),
        width = 2,
        name = "",
        image = true,
        placement = (config.placement and config.placement.image) or "virtual",
    }
end

--- A tree guide line as an IMAGE — in every mode, wherever the terminal shows images: two cells, a vertical
--- line down their middle over the full cell height — put under a 2-cell icon, it falls exactly on the icon's
--- centre — in the colour of `opts.hl` (or `opts.color`). nil where no images can be shown: the caller keeps
--- its text line.
--- `opts.under` is the icon the line runs under: an image is centred in its two cells (the line goes down
--- their middle); a Nerd GLYPH is drawn by the terminal from the cell's left edge, so the line goes under the
--- glyph's own middle (its ink centre from assets/nerd/metrics.json, at the em the cell width implies —
--- `svg.cell_em` = the terminal font's cell width in ems).
---@param opts { hl?: string, color?: string, under?: { glyph?: string, image?: boolean } }
---@return LvimIconResult?
function M.guide(opts)
    opts = opts or {}
    local svg = require("lvim-icons.svg")
    if not svg.images() then
        return nil
    end
    local under = opts.under
    local centre = under and not under.image and svg.nerd_centre(under.glyph) or nil
    local at
    if centre then
        at = function(geo)
            local em = geo.cw / ((config.svg and config.svg.cell_em) or 0.6)
            return centre * em
        end
    end
    local key = ("guide|%s|%s"):format(opts.color or opts.hl or "", centre and tostring(centre) or "mid")
    local e = svg.line(key, function()
        return fill_of(opts)
    end, at)
    if not e then
        return nil
    end
    return {
        glyph = placeholders.CELLS,
        hl = e.hl,
        color = fill_of(opts),
        width = 2,
        name = "guide",
        image = true,
        placement = "real",
    }
end

return M
