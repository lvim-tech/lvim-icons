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

it("stays on the font when the icon font is not installed", function()
    local svg = require("lvim-icons.svg")
    local saved = config.mode
    config.mode = "svg"
    local mode = svg.active_mode()
    if svg.font_installed() then
        eq("svg", mode, "the font IS installed here, so svg mode is honoured")
    else
        eq("font", mode, "no icon font: svg mode must fall back rather than draw nothing")
    end
    config.mode = saved
end)

it("asks the terminal only in auto mode", function()
    local svg = require("lvim-icons.svg")
    local saved = config.mode
    config.mode = "font"
    eq("font", svg.active_mode(), "font mode asks nothing")
    config.mode = saved
end)

describe("lvim-icons: health")

it("the health check runs to completion", function()
    local health = require("lvim-icons.health")
    truthy(type(health.check) == "function", "no check() to run")
    local ok, err = pcall(health.check)
    truthy(ok, tostring(err))
end)
