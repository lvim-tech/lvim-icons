-- The image render mode's rasteriser: an SVG icon drawn into the pixels of exactly two terminal cells,
-- the icon centred. What the terminal shows is these pixels 1:1, so the geometry IS the look.

local image = require("lvim-icons.image")

local MATERIAL = require("lvim-icons.svg").ASSETS

--- The RGBA pixel at (x, y) of a canvas `w` wide, as a 4-byte string.
---@param rgba string
---@param w integer
---@param x integer
---@param y integer
---@return string
local function px(rgba, w, x, y)
    local i = (y * w + x) * 4
    return rgba:sub(i + 1, i + 4)
end

describe("lvim-icons.image: geometry")

it("the canvas is two cells wide and one tall", function()
    local g = image.geometry_for(9, 25, 0.72)
    eq(18, g.w)
    eq(25, g.h)
end)

it("the icon is `fill` of the cell height, capped by the canvas width", function()
    eq(18, image.geometry_for(9, 25, 0.72).size, "25 * 0.72 = 18, the width is 18")
    eq(15, image.geometry_for(9, 25, 0.6).size, "25 * 0.6 = 15")
    eq(18, image.geometry_for(9, 25, 0.95).size, "capped at the 18-px canvas width")
end)

describe("lvim-icons.image: compose")

it("centres the icon in the canvas and leaves the rest transparent", function()
    local red = "\255\0\0\255"
    local src = red:rep(2 * 2) -- 2x2
    local out = image.compose(src, 2, 2, 6, 4)
    eq(6 * 4 * 4, #out, "a full canvas")
    eq(red, px(out, 6, 2, 1), "top-left of the icon at (2,1)")
    eq(red, px(out, 6, 3, 2), "bottom-right of the icon at (3,2)")
    eq("\0\0\0\0", px(out, 6, 0, 0), "a corner stays transparent")
    eq("\0\0\0\0", px(out, 6, 5, 3), "the opposite corner stays transparent")
end)

it("drops what does not fit instead of wrapping it into the next row", function()
    local src = ("\1\1\1\255"):rep(4 * 1) -- 4x1, wider than the canvas
    local out = image.compose(src, 4, 1, 2, 1)
    eq(2 * 4, #out)
    eq("\1\1\1\255", px(out, 2, 0, 0))
    eq("\1\1\1\255", px(out, 2, 1, 0))
end)

describe("lvim-icons.image: viewBox")

it("reads the viewBox size of an SVG", function()
    local path = vim.fn.tempname() .. ".svg"
    vim.fn.writefile({ '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 24"><path d="M0 0h1v1z"/></svg>' }, path)
    local w, h = image.viewbox(path)
    eq(16, w)
    eq(24, h)
end)

describe("lvim-icons.image: rasterize (libvips)")

it("draws a real SVG into the exact canvas, centred", function()
    local ok, decode = pcall(require, "lvim-image.decode")
    if not (ok and decode.available and decode.available()) then
        return skip("draws a real SVG", "needs lvim-image with libvips")
    end
    local path = MATERIAL .. "/database.svg"
    if not vim.uv.fs_stat(path) then
        return skip("draws a real SVG", "bundled SVG missing (" .. path .. ")")
    end
    local geo = image.geometry_for(9, 25, 0.72)
    local rgba, err = image.rasterize(path, geo)
    eq(nil, err)
    eq(geo.w * geo.h * 4, #rgba, "exactly the canvas")
    eq("\0\0\0\0", px(rgba, geo.w, 0, 0), "the margin above the icon is transparent")
    local before = image.cached()
    image.rasterize(path, geo)
    eq(before, image.cached(), "a second call is served from the cache")
end)
