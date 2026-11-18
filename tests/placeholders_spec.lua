-- The terminal side of the image mode: an icon image is sent once under a kitty image id, and from then on
-- the icon is two placeholder cells in a highlight group whose foreground IS that id. Sending is stubbed
-- here (a headless test has no terminal to draw in); what is asserted is what the terminal would be told.

local image = require("lvim-icons.image")

-- record what would be sent instead of writing escape sequences into the test output
local sent = {}
local next_id = 0x1000
package.loaded["lvim-image.protocols.kitty"] = {
    next_id = function()
        next_id = next_id + 1
        return next_id
    end,
    show_virtual = function(img, cols, rows)
        sent[#sent + 1] = { id = img.id, w = img.w, h = img.h, cols = cols, rows = rows, bytes = #img.rgba }
    end,
}
package.loaded["lvim-image.terminal"] = package.loaded["lvim-image.terminal"]
    or { capabilities = function() return {} end, cell_size = function() return nil end }

local geo = { cw = 9, ch = 25, w = 18, h = 25, size = 18 }
local orig_geometry, orig_rasterize = image.geometry, image.rasterize
image.geometry = function()
    return geo
end
image.rasterize = function(_, g)
    return string.rep("\0", g.w * g.h * 4)
end

local ph = require("lvim-icons.placeholders")

describe("lvim-icons.placeholders")

it("the two cells are placeholder + row/column diacritics for (0,0) and (0,1)", function()
    local cps = vim.fn.str2list(ph.CELLS, true)
    eq({ 0x10EEEE, 0x0305, 0x0305, 0x10EEEE, 0x0305, 0x030D }, cps)
end)

it("sends an icon once, as a 2x1 virtual placement of the exact canvas", function()
    sent = {}
    local e = ph.ensure("rust", "/icons/rust.svg")
    eq(1, #sent)
    eq({ id = e.id, w = 18, h = 25, cols = 2, rows = 1, bytes = 18 * 25 * 4 }, sent[1])
    ph.ensure("rust", "/icons/rust.svg")
    eq(1, #sent, "the second use reuses the image")
end)

it("puts the image id in the foreground of the icon's group", function()
    local e = ph.ensure("lua", "/icons/lua.svg")
    eq(e.id, vim.api.nvim_get_hl(0, { name = e.hl }).fg)
    eq(e.id, ph.groups()[e.hl].fg, "and hands it to the bound factory for re-assertion")
end)

it("gives every icon its own id and group", function()
    local a = ph.ensure("python", "/icons/python.svg")
    local b = ph.ensure("go", "/icons/go.svg")
    eq(false, a.id == b.id)
    eq(false, a.hl == b.hl)
end)

it("redraws for a new cell size under the SAME id", function()
    local e = ph.ensure("docker", "/icons/docker.svg")
    local id = e.id
    sent = {}
    geo = { cw = 10, ch = 22, w = 20, h = 22, size = 16 }
    local n = ph.refresh()
    eq(true, n >= 1)
    local again
    for _, s in ipairs(sent) do
        if s.id == id then
            again = s
        end
    end
    eq(20, again and again.w, "re-sent at the new canvas width")
    eq(id, ph.ensure("docker", "/icons/docker.svg").id)
    sent = {}
    eq(0, ph.refresh(), "nothing to redraw when the size did not change")
end)

it("keeps the id intact under a backdrop veil (its fg is data, not a colour)", function()
    local ok, dim = pcall(require, "lvim-utils.dim")
    if not (ok and dim.build) then
        return skip("keeps the id intact under a backdrop veil", "needs lvim-utils.dim")
    end
    ph.setup()
    local e = ph.ensure("veil", "/icons/veil.svg")
    local ns = vim.api.nvim_create_namespace("lvim-icons-test-veil")
    dim.build("#000000", 0.6, ns)
    local veiled = vim.api.nvim_get_hl(ns, { name = e.hl })
    eq(e.id, veiled.fg, "the veil copies the group verbatim instead of muting the id")
end)

describe("lvim-icons: image modes end to end")

it("an icon with an SVG resolves to its image; one without keeps the font glyph", function()
    local config = require("lvim-icons.config")
    local orig_available = ph.available
    ph.available = function()
        return true
    end
    local saved = config.mode
    config.mode = "mix"
    local r = require("lvim-icons").get("main.rs")
    eq(true, r.image)
    eq(ph.CELLS, r.glyph)
    eq(2, r.width)
    eq(true, vim.startswith(r.hl, ph.HL_PREFIX), "painted with the id-carrying group")
    local painted = require("lvim-icons").get("main.rs", { font = true })
    eq(false, painted.image, "font = true: a caller painting its own colour gets the font glyph")
    eq(1, painted.width)
    config.mode = saved
    ph.available = orig_available
end)

it("a theme change re-sends a recoloured icon under the SAME id", function()
    local svg = require("lvim-icons.svg")
    local c = require("lvim-utils.colors")
    local first = svg.icon("lua", "theme")
    truthy(first, "lua has an SVG")
    local saved = c.blue
    c.blue = "#123456"
    sent = {}
    svg.recolor()
    local again = svg.icon("lua", "theme")
    c.blue = saved
    eq(first.id, again.id, "the cells already on screen keep naming the same image")
    local resent = false
    for _, s in ipairs(sent) do
        resent = resent or s.id == first.id
    end
    eq(true, resent, "with new pixels sent for it")
end)

image.geometry, image.rasterize = orig_geometry, orig_rasterize
