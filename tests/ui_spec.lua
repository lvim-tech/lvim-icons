-- UI icons (not files): a plugin's own Nerd glyph + colour group in "nerd" / "mix"; in "material" a Material
-- Design Icons image filled with that group's colour. Sending is stubbed (no terminal in a headless test).

local sent = {}
local next_id = 0x2000
package.loaded["lvim-image.protocols.kitty"] = {
    next_id = function()
        next_id = next_id + 1
        return next_id
    end,
    show_virtual = function(img)
        sent[#sent + 1] = img.id
    end,
}

local image = require("lvim-icons.image")
local ph = require("lvim-icons.placeholders")
local ui = require("lvim-icons.ui")
local config = require("lvim-icons.config")

local orig = { geometry = image.geometry, rasterize = image.rasterize, available = ph.available }
image.geometry = function()
    return { cw = 9, ch = 25, w = 18, h = 25, size = 18 }
end
image.rasterize = function(_, g)
    return string.rep("\0", g.w * g.h * 4)
end
ph.available = function()
    return true
end

local BRANCH = vim.fn.nr2char(0xF062C) -- nf-md-source_branch

describe("lvim-icons.ui")

it("nerd and mix keep the caller's own glyph and group", function()
    for _, mode in ipairs({ "nerd", "mix" }) do
        config.mode = mode
        local r = ui.get({ glyph = BRANCH, hl = "Directory" })
        eq(false, r.image, mode)
        eq(BRANCH, r.glyph, mode)
        eq("Directory", r.hl, mode)
    end
end)

it("material draws the glyph's own SVG as an image, filled with the caller's colour", function()
    config.mode = "material"
    vim.api.nvim_set_hl(0, "LvimIconsTestUi", { fg = 0x33aa55 })
    sent = {}
    local r = ui.get({ glyph = BRANCH, hl = "LvimIconsTestUi" })
    eq(true, r.image)
    eq(2, r.width)
    eq("#33aa55", r.color)
    eq(1, #sent)
    local cached = vim.fn.glob(vim.fn.stdpath("cache") .. "/lvim-icons/fill/F062C-33aa55.svg")
    truthy(cached ~= "", "the Nerd SVG (decompressed from .svgz) filled with the colour")
    truthy(table.concat(vim.fn.readfile(cached), "\n"):find('fill="#33aa55"', 1, true), "filled")
end)

it("a theme change re-fills the image under the SAME id", function()
    config.mode = "material"
    vim.api.nvim_set_hl(0, "LvimIconsTestUi2", { fg = 0x112233 })
    local first = ui.get({ glyph = BRANCH, hl = "LvimIconsTestUi2" })
    vim.api.nvim_set_hl(0, "LvimIconsTestUi2", { fg = 0x445566 })
    sent = {}
    require("lvim-icons.svg").recolor()
    local again = ui.get({ glyph = BRANCH, hl = "LvimIconsTestUi2" })
    local fg = vim.api.nvim_get_hl(0, { name = again.hl }).fg
    eq(first.hl, again.hl, "the same group")
    eq(true, vim.tbl_contains(sent, fg), "the same image id re-sent with the new colour")
    eq("#445566", again.color)
end)

it("a glyph with no SVG, or no images at all, stays the glyph", function()
    config.mode = "material"
    eq(false, ui.get({ glyph = "x", hl = "Directory" }).image, "no SVG for an ASCII letter")
    ph.available = function()
        return false
    end
    local r = ui.get({ glyph = BRANCH, hl = "Directory" })
    ph.available = function()
        return true
    end
    eq(false, r.image, "no images")
    eq(BRANCH, r.glyph)
end)

describe("lvim-icons: the guide line")

it("is two cells, with the line exactly on their middle, over the full height", function()
    local geo = { cw = 9, ch = 25, w = 18, h = 25, size = 18 }
    local rgba = require("lvim-icons.image").vline(geo, "#102030")
    eq(18 * 25 * 4, #rgba, "two cells wide")
    local function px(x, y)
        local i = (y * 18 + x) * 4
        return rgba:sub(i + 1, i + 4)
    end
    eq("\16\32\48\255", px(8, 0), "the pixel left of the middle, top row")
    eq("\16\32\48\255", px(9, 0), "and right of it: 2 px centred on the cell boundary")
    eq("\16\32\48\255", px(9, 24), "the bottom row: unbroken from line to line")
    eq("\0\0\0\0", px(7, 12), "transparent elsewhere")
    eq("\0\0\0\0", px(10, 12))
end)

it("under a Nerd glyph, the line goes under the glyph's own middle", function()
    local svg = require("lvim-icons.svg")
    local centre = svg.nerd_centre(vim.fn.nr2char(0xF07C)) -- nf-fa-folder_open
    truthy(centre and centre > 0.4 and centre < 0.6, "metrics for the open folder: " .. tostring(centre))
    local geo = { cw = 9, ch = 25, w = 18, h = 25, size = 18 }
    local x = centre * (geo.cw / 0.6)
    local rgba = require("lvim-icons.image").vline(geo, "#102030", x)
    local function lit(px)
        local i = (12 * 18 + px) * 4
        return rgba:sub(i + 4, i + 4) == "\255"
    end
    local cols = {}
    for c = 0, 17 do
        if lit(c) then
            cols[#cols + 1] = c
        end
    end
    eq(2, #cols, "2 px")
    truthy(math.abs((cols[1] + cols[2] + 1) / 2 - x) <= 0.5, ("centred on %.2f: %s"):format(x, vim.inspect(cols)))
end)

it("is an image in every mode where images can be shown, none where they cannot", function()
    for _, mode in ipairs({ "nerd", "mix", "material" }) do
        config.mode = mode
        eq(true, ui.guide({ hl = "Directory" }).image, mode)
    end
    ph.available = function()
        return false
    end
    eq(nil, ui.guide({ hl = "Directory" }), "no images: the caller keeps its text line")
    ph.available = function()
        return true
    end
    config.mode = "material"
    vim.api.nvim_set_hl(0, "LvimIconsTestGuide", { fg = 0x405060 })
    local r = ui.guide({ hl = "LvimIconsTestGuide" })
    eq(true, r and r.image)
    eq(2, r.width)
    eq("#405060", r.color)
end)

describe("lvim-icons.recolor.fill")

it("fills a one-colour SVG, with or without a fill of its own", function()
    local recolor = require("lvim-icons.recolor")
    local out = recolor.fill('<svg viewBox="0 0 24 24"><path d="M0 0"/></svg>', "#abcdef")
    truthy(out:find('<svg fill="#abcdef"', 1, true), out)
    out = recolor.fill('<svg fill="#000000" viewBox="0 0 24 24"><path fill="#111111" d="M0 0"/></svg>', "#abcdef")
    eq(nil, out:find("#000000", 1, true))
    eq(nil, out:find("#111111", 1, true))
end)

config.mode = "nerd"
image.geometry, image.rasterize, ph.available = orig.geometry, orig.rasterize, orig.available
