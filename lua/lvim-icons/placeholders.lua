-- lvim-icons.placeholders: the terminal side of the image render mode — kitty UNICODE PLACEHOLDERS.
--
-- Every icon image is transmitted to the terminal ONCE, as a virtual placement two cells wide and one cell
-- tall (`a=T,U=1,c=2,r=1`). After that the icon is plain text: two U+10EEEE placeholder cells (each with
-- the row/column diacritics of its place in the image) in a highlight group whose foreground IS the image
-- id. The terminal draws the picture wherever those cells are — in a buffer, a float, a statusline, a tab
-- line — so the icon goes anywhere text goes, and inside zellij / tmux too where they pass placeholders
-- through (lvim-image's `zellij_placeholders` / `tmux_placeholders`).
--
-- The foreground of the group is DATA, not a colour: anything that changes it changes the image id and the
-- icon vanishes. So the groups are registered with lvim-utils.dim as data (a backdrop veil copies them
-- verbatim) and re-asserted on every ColorScheme (`:colorscheme` clears all groups).
--
-- Images are re-rendered and re-sent under the SAME ids when the terminal's cell size changes (another font
-- or font size): the cells in the buffers keep naming the same images, which simply get new pixels.
--
---@module "lvim-icons.placeholders"

local image = require("lvim-icons.image")

local M = {}

local PLACEHOLDER = vim.fn.nr2char(0x10EEEE)
-- kitty's row/column diacritics for indices 0 and 1 (rowcolumn-diacritics.txt)
local DIA0, DIA1 = vim.fn.nr2char(0x0305), vim.fn.nr2char(0x030D)

--- The two placeholder cells of a 2x1 image: (row 0, col 0) then (row 0, col 1).
M.CELLS = PLACEHOLDER .. DIA0 .. DIA0 .. PLACEHOLDER .. DIA0 .. DIA1

--- Highlight-group prefix; the fg of every such group is an image id (see the module header).
M.HL_PREFIX = "LvimIconImg_"

---@class LvimIconsPlaceholderEntry
---@field key string    the caller's key (an icon name, plus a variant once colours are themed)
---@field path string   the SVG drawn
---@field id integer    the kitty image id
---@field hl string     the highlight group carrying the id
---@field geo string    the geometry key the current pixels were drawn for
---@field draw? fun(geo: LvimIconsImageGeometry): string  draws the pixels directly (instead of from `path`)

---@type table<string, LvimIconsPlaceholderEntry>
local entries = {}
---@type table<string, true>  highlight-group names in use (a key can map to a sanitised name only once)
local hl_names = {}
---@type boolean
local registered = false

--- The lvim-image modules this needs, or nil when lvim-image is not installed.
---@return { terminal: table, kitty: table }?
local function backend()
    local ok_t, terminal = pcall(require, "lvim-image.terminal")
    local ok_k, kitty = pcall(require, "lvim-image.protocols.kitty")
    if ok_t and ok_k then
        return { terminal = terminal, kitty = kitty }
    end
end

--- Whether icons can be drawn as placeholder images here: lvim-image is installed, the terminal renders
--- kitty unicode placeholders (kitty / Ghostty; tmux or zellij only when lvim-image is told they pass them),
--- and the cell size is known.
---@return boolean
function M.available()
    local b = backend()
    if not b then
        return false
    end
    local ok, caps = pcall(b.terminal.capabilities)
    return ok and type(caps) == "table" and caps.placeholders == true and image.geometry() ~= nil
end

---@param geo LvimIconsImageGeometry
---@return string
local function geo_key(geo)
    return ("%dx%d|%d"):format(geo.w, geo.h, geo.size)
end

--- A highlight-group name for `key` that is a valid identifier and unique.
---@param key string
---@return string
local function hl_name(key)
    local base = M.HL_PREFIX .. key:gsub("[^%w_]", "_")
    local name, n = base, 1
    while hl_names[name] do
        n = n + 1
        name = base .. "_" .. n
    end
    hl_names[name] = true
    return name
end

--- (Re)draw `e` at `geo` and send it to the terminal under its id.
---@param e LvimIconsPlaceholderEntry
---@param geo LvimIconsImageGeometry
---@return boolean ok, string? err
local function send(e, geo)
    local rgba, err
    if e.draw then
        rgba = e.draw(geo) -- drawn directly (not from an SVG): e.g. a guide line, full cell height
    else
        rgba, err = image.rasterize(e.path, geo)
    end
    if not rgba then
        return false, err
    end
    local b = backend()
    if not b then
        return false, "lvim-image is not installed"
    end
    b.kitty.show_virtual({ id = e.id, kind = "rgba", rgba = rgba, w = geo.w, h = geo.h }, 2, 1)
    e.geo = geo_key(geo)
    return true
end

--- The image for `key`, drawn from the SVG at `path` — transmitted on first use, then reused. Returns the
--- entry (its `hl` group and the `CELLS` to print), or nil + reason when it cannot be drawn. With `draw`, the
--- pixels come from `draw(geo)` (RGBA of the 2x1 canvas) and `path` only names what is drawn: a different
--- `path` under the same key re-draws the image under the same id.
---@param key string
---@param path string
---@param draw? fun(geo: LvimIconsImageGeometry): string
---@return LvimIconsPlaceholderEntry? entry, string? err
function M.ensure(key, path, draw)
    local e = entries[key]
    if e and e.path == path then
        return e
    end
    local b = backend()
    if not b then
        return nil, "lvim-image is not installed"
    end
    local geo = image.geometry()
    if not geo then
        return nil, "terminal cell size unknown"
    end
    local id = e and e.id or b.kitty.next_id()
    local hl = e and e.hl or hl_name(key)
    e = { key = key, path = path, draw = draw, id = id, hl = hl, geo = "" }
    local ok, err = send(e, geo)
    if not ok then
        return nil, err
    end
    entries[key] = e
    vim.api.nvim_set_hl(0, hl, { fg = id })
    return e
end

--- Re-draw and re-send every image whose pixels were made for another cell size (after a font change).
--- Ids are kept, so the placeholder cells already on screen keep pointing at the right images.
---@return integer  how many were re-sent
function M.refresh()
    local geo = image.geometry()
    if not geo then
        return 0
    end
    local key, n = geo_key(geo), 0
    for _, e in pairs(entries) do
        if e.geo ~= key then
            if send(e, geo) then
                n = n + 1
            end
        end
    end
    return n
end

--- Re-send EVERY image (the terminal lost them: a new terminal attached to a multiplexer session, or the
--- images were deleted). The pixels come from the rasteriser cache when nothing changed.
---@return integer
function M.retransmit()
    local geo = image.geometry()
    if not geo then
        return 0
    end
    local n = 0
    for _, e in pairs(entries) do
        if send(e, geo) then
            n = n + 1
        end
    end
    return n
end

--- The highlight groups of every image, for the bound factory (re-asserted on ColorScheme / palette sync).
---@return table<string, vim.api.keyset.highlight>
function M.groups()
    local out = {}
    for _, e in pairs(entries) do
        out[e.hl] = { fg = e.id }
    end
    return out
end

--- The number of images sent (for health / tests).
---@return integer
function M.count()
    local n = 0
    for _ in pairs(entries) do
        n = n + 1
    end
    return n
end

--- One-time wiring: the id-carrying groups survive a backdrop veil and `:colorscheme`, and a font change
--- re-draws the images at the new cell size. Idempotent.
function M.setup()
    if registered then
        return
    end
    registered = true
    local ok_dim, dim = pcall(require, "lvim-utils.dim")
    if ok_dim and dim.preserve then
        dim.preserve("^" .. M.HL_PREFIX, { data = true })
    end
    local ok_hl, hl = pcall(require, "lvim-utils.highlight")
    if ok_hl and hl.bind then
        hl.bind(M.groups)
    else
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("LvimIconsPlaceholdersHl", { clear = true }),
            callback = function()
                for name, opts in pairs(M.groups()) do
                    vim.api.nvim_set_hl(0, name, opts)
                end
            end,
        })
    end
    vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("LvimIconsPlaceholders", { clear = true }),
        -- a font (size) change resizes the cells: the terminal reports it as a resize
        callback = function()
            image.invalidate()
            M.refresh()
        end,
    })
end

return M
