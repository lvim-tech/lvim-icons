-- lvim-icons.image: the rasteriser of the image render mode — an SVG icon becomes RGBA pixels sized to
-- EXACTLY the terminal cells it will occupy (2 cells wide, 1 tall), with the icon centred in that canvas.
--
-- Drawing the icon into the cells' own pixels is what makes this mode look right: the terminal shows the
-- image 1:1 in its two cells — it neither crops it to its ink nor pushes it to the left edge (which is
-- what it does to a colour-font glyph), so size and centring are ours to choose.
--
-- The SVG is decoded by libvips through lvim-image (an optional dependency — without it this module
-- reports itself unavailable and the resolver stays in nerd mode). Rendered canvases are cached in memory
-- per (file, canvas size, icon size); a change of the terminal's cell size (another font or font size)
-- yields a new key, so stale pixels are never reused.
--
---@module "lvim-icons.image"

local config = require("lvim-icons.config")

local M = {}

---@class LvimIconsImageGeometry
---@field cw integer  terminal cell width, px
---@field ch integer  terminal cell height, px
---@field w  integer  canvas width, px (two cells)
---@field h  integer  canvas height, px (one cell)
---@field size integer  the icon square, px

---@type table<string, string>  "<path>|<w>x<h>|<size>" → RGBA canvas
local cache = {}

--- The lvim-image modules this mode runs on, or nil when lvim-image is not installed.
---@return { terminal: table, decode: table }?
local function backend()
    local ok_t, terminal = pcall(require, "lvim-image.terminal")
    local ok_d, decode = pcall(require, "lvim-image.decode")
    if ok_t and ok_d then
        return { terminal = terminal, decode = decode }
    end
end

--- Canvas and icon size for a cell of `cw` x `ch` pixels. The icon square is `fill` of the cell height,
--- capped by the canvas width (two cells of a typical font are a little narrower than one is tall).
---@param cw integer
---@param ch integer
---@param fill number
---@return LvimIconsImageGeometry
function M.geometry_for(cw, ch, fill)
    local w, h = 2 * cw, ch
    return { cw = cw, ch = ch, w = w, h = h, size = math.max(1, math.floor(math.min(w, h * fill))) }
end

---@type LvimIconsImageGeometry|false|nil  the last measured geometry (false = unknown); nil = not measured
local current

--- The geometry for the current terminal, or nil when the cell size cannot be read. Measured once (it is an
--- ioctl on the tty, and the resolver asks for every icon it draws); `invalidate()` re-measures it.
---@return LvimIconsImageGeometry?
function M.geometry()
    if current == nil then
        local b = backend()
        local cell = b and b.terminal.cell_size()
        if cell and cell.w and cell.h and cell.w > 0 and cell.h > 0 then
            current = M.geometry_for(cell.w, cell.h, (config.svg and config.svg.fill) or 0.72)
        else
            current = false
        end
    end
    return current or nil
end

--- Forget the measured geometry, so the next `geometry()` reads the cell size again (a font change, a
--- changed `svg.fill`).
function M.invalidate()
    current = nil
end

--- The width and height of an SVG's viewBox (the user units the drawing is laid out in).
---@param path string
---@return number? w, number? h
function M.viewbox(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    -- the root element carries it; 2 KiB is ample and avoids reading a large file for one attribute
    local head = f:read(2048) or ""
    f:close()
    local vb = head:match('viewBox%s*=%s*"([^"]+)"') or head:match("viewBox%s*=%s*'([^']+)'")
    if not vb then
        local w = tonumber(head:match('<svg[^>]-%swidth%s*=%s*"([%d%.]+)'))
        local h = tonumber(head:match('<svg[^>]-%sheight%s*=%s*"([%d%.]+)'))
        return w, h
    end
    local nums = {}
    for n in vb:gmatch("[-%d%.]+") do
        nums[#nums + 1] = tonumber(n)
    end
    return nums[3], nums[4]
end

--- Place an RGBA image (`sw` x `sh`) in the centre of a transparent `w` x `h` canvas. Pixels falling
--- outside the canvas are dropped.
---@param src string  RGBA bytes, row-major
---@param sw integer
---@param sh integer
---@param w integer
---@param h integer
---@return string  RGBA bytes of the canvas
function M.compose(src, sw, sh, w, h)
    local ox, oy = math.floor((w - sw) / 2), math.floor((h - sh) / 2)
    local blank_row = string.rep("\0", w * 4)
    -- the visible column span of the source within the canvas
    local sx0 = math.max(0, -ox)
    local sx1 = math.min(sw, w - ox) -- exclusive
    local left = string.rep("\0", math.max(0, ox) * 4)
    local rows = {}
    for y = 0, h - 1 do
        local sy = y - oy
        if sy >= 0 and sy < sh and sx1 > sx0 then
            local from = sy * sw * 4 + sx0 * 4
            local line = left .. src:sub(from + 1, from + (sx1 - sx0) * 4)
            rows[#rows + 1] = line .. blank_row:sub(1, w * 4 - #line)
        else
            rows[#rows + 1] = blank_row
        end
    end
    return table.concat(rows)
end

--- The RGBA canvas for the SVG at `path`, the icon `geo.size` px square and centred in `geo.w` x `geo.h`.
---@param path string
---@param geo LvimIconsImageGeometry?  defaults to the current terminal's geometry
---@return string? rgba, string? err
function M.rasterize(path, geo)
    geo = geo or M.geometry()
    if not geo then
        return nil, "terminal cell size unknown"
    end
    local key = ("%s|%dx%d|%d"):format(path, geo.w, geo.h, geo.size)
    if cache[key] then
        return cache[key]
    end
    local b = backend()
    if not b then
        return nil, "lvim-image is not installed"
    end
    local vw, vh = M.viewbox(path)
    if not (vw and vh and vw > 0 and vh > 0) then
        return nil, "no usable viewBox in " .. path
    end
    -- libvips' svgload takes a load option in the file name: render straight at the target size
    local scale = geo.size / math.max(vw, vh)
    local res, err = b.decode.to_rgba(("%s[scale=%.6f]"):format(path, scale))
    if not res then
        return nil, err
    end
    local rgba = M.compose(res.rgba, res.w, res.h, geo.w, geo.h)
    cache[key] = rgba
    return rgba
end

--- A vertical line down the MIDDLE of the 2x1 canvas — the boundary of its two cells, exactly where an icon
--- image is centred — over the full cell height, so it is unbroken from row to row. Put under a 2-cell icon,
--- the line falls on the icon's centre to the pixel. `hex` = "#rrggbb".
--- `x` moves the line's centre to that pixel column (default: the canvas middle) — e.g. the middle of a Nerd
--- glyph the terminal draws from the cell's left edge.
---@param geo LvimIconsImageGeometry
---@param hex string
---@param x? number  the line's centre, in pixels from the canvas' left edge
---@return string rgba  two cells wide
function M.vline(geo, hex, x)
    local c = hex:gsub("#", "")
    local px = string.char(tonumber(c:sub(1, 2), 16), tonumber(c:sub(3, 4), 16), tonumber(c:sub(5, 6), 16), 255)
    local t = math.max(1, math.min(geo.w, tonumber(config.svg and config.svg.guide_px) or 2))
    local centre = x or geo.w / 2
    local x0 = math.max(0, math.min(geo.w - t, math.floor(centre - t / 2 + 0.5))) -- t pixels centred there
    local row = string.rep("\0", x0 * 4) .. px:rep(t) .. string.rep("\0", (geo.w - x0 - t) * 4)
    return row:rep(geo.h)
end

--- Drop every cached canvas (after a theme change rewrote colours, or to free memory).
function M.clear()
    cache = {}
end

--- The number of cached canvases (for health / tests).
---@return integer
function M.cached()
    local n = 0
    for _ in pairs(cache) do
        n = n + 1
    end
    return n
end

return M
