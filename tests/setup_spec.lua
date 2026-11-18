-- setup(), the render mode, and health.

local icons = require("lvim-icons")
local config = require("lvim-icons.config")

describe("lvim-icons.setup")

it("merges the options into the live config", function()
    local before = config.brand_blend
    icons.setup({ color_mode = "theme", brand_blend = 0.25 })
    eq("theme", config.color_mode)
    eq(0.25, config.brand_blend)
    icons.setup({ brand_blend = before })
end)

it("runs twice without stacking autocmds", function()
    icons.setup({})
    local before = #vim.api.nvim_get_autocmds({ event = "ColorScheme" })
    icons.setup({})
    eq(before, #vim.api.nvim_get_autocmds({ event = "ColorScheme" }))
end)

it("applies the overrides it is given at setup time", function()
    icons.setup({ overrides = { extensions = { qqq = { glyph = "Q", role = "fg", name = "qqq" } } } })
    eq("qqq", require("lvim-icons.resolve").spec_for("file.qqq").name)
    require("lvim-icons.resolve").tables().extensions.qqq = nil
end)

describe("lvim-icons: the render mode never over-promises")

it("stays on the font where the terminal cannot show the images", function()
    local svg = require("lvim-icons.svg")
    local placeholders = require("lvim-icons.placeholders")
    local saved = config.mode
    config.mode = "mix"
    eq(placeholders.available() and "mix" or "nerd", svg.active_mode(), "images only when placeholders can be drawn")
    if not placeholders.available() then
        local r = require("lvim-icons").get("main.rs")
        eq(false, r.image, "a headless run has no terminal: the font glyph, not an image")
        eq(1, r.width)
    end
    config.mode = saved
end)

it("font = true always gets the glyph", function()
    eq(false, require("lvim-icons").get("main.rs", { font = true }).image)
end)

it("every icon the Material manifest defines has its bundled SVG", function()
    local svg = require("lvim-icons.svg")
    local missing = {}
    for _, id in ipairs(require("lvim-icons.material").ids()) do
        if not svg.find(id) then
            missing[#missing + 1] = id
        end
    end
    eq({}, missing)
end)

describe("lvim-icons: health")

it("the health check runs to completion", function()
    local health = require("lvim-icons.health")
    truthy(type(health.check) == "function", "no check() to run")
    local ok, err = pcall(health.check)
    truthy(ok, tostring(err))
end)

it("nerd mode never draws an image, even where the terminal could", function()
    local placeholders = require("lvim-icons.placeholders")
    local saved, orig = config.mode, placeholders.available
    placeholders.available = function()
        return true
    end
    config.mode = "nerd"
    eq("nerd", require("lvim-icons.svg").active_mode())
    eq(false, require("lvim-icons").get("main.rs").image)
    eq(false, require("lvim-icons").ui({ glyph = "", hl = "Directory" }).image)
    config.mode, placeholders.available = saved, orig
end)

describe("lvim-icons.set_mode")

it("switches the mode live and tells every view", function()
    local li = require("lvim-icons")
    local seen
    local id = vim.api.nvim_create_autocmd("User", {
        pattern = "LvimIconsMode",
        callback = function(e)
            seen = e.data
        end,
    })
    li.set_mode("nerd")
    eq(true, li.set_mode("material"))
    eq("material", li.mode())
    eq("material", seen and seen.mode)
    eq("nerd", seen and seen.previous)
    seen = nil
    eq(true, li.set_mode("material"), "the same mode")
    eq(nil, seen, "no event when nothing changed")
    eq(false, li.set_mode("svg"), "an unknown mode is refused")
    eq("material", li.mode())
    li.set_mode("nerd")
    vim.api.nvim_del_autocmd(id)
end)
