-- The colour modes of the image icons: the SVG's own colours ("brand"), every colour moved to the palette
-- role nearest in hue ("theme"), or blended toward the background ("theme_brand").

local recolor = require("lvim-icons.recolor")
local c = require("lvim-utils.colors")

describe("lvim-icons.recolor: nearest role")

it("keeps the hue family: a Material orange is the theme's orange, its blue the theme's blue", function()
    eq("orange", recolor.nearest_role("#ff7043"), "Material rust")
    eq("blue", recolor.nearest_role("#42a5f5"), "Material lua")
    eq("green", recolor.nearest_role("#4caf50"), "Material folder-src")
end)

it("maps a grey to the foreground", function()
    eq("fg", recolor.nearest_role("#90a4ae"), "Material file (blue-grey, low saturation)")
    eq("fg", recolor.nearest_role("#777"))
end)

describe("lvim-icons.recolor: apply")

local SVG = '<svg viewBox="0 0 16 16"><defs><linearGradient id="g"><stop stop-color="#42a5f5"/></linearGradient></defs>'
    .. '<path fill="#ff7043" d="M0 0h1"/><path style="fill:#4caf50;stroke:#fff" d="M1 1h1"/>'
    .. '<use href="#abcdef"/></svg>'

it("brand leaves the SVG untouched", function()
    local out, sig = recolor.apply(SVG, "brand")
    eq(SVG, out)
    eq("", sig)
end)

it("theme rewrites every paint colour to a palette colour", function()
    local out = recolor.apply(SVG, "theme")
    truthy(out:find('fill="' .. c.orange:lower() .. '"', 1, true), "fill attribute → theme orange")
    truthy(out:find("fill:" .. c.green:lower(), 1, true), "style fill → theme green")
    truthy(out:find('stop-color="' .. c.blue:lower() .. '"', 1, true), "gradient stop → theme blue")
    truthy(out:find("stroke:" .. c.fg:lower(), 1, true), "white stroke → the foreground")
end)

it("never touches a fragment reference", function()
    local out = recolor.apply(SVG, "theme")
    truthy(out:find('href="#abcdef"', 1, true), "href is not a colour")
end)

it("the signature names the mapping, so the same palette gives the same file", function()
    local _, a = recolor.apply(SVG, "theme")
    local _, b = recolor.apply(SVG, "theme")
    eq(a, b)
    truthy(a ~= "", "a non-empty signature")
end)

it("theme_brand blends toward the background instead of replacing the hue", function()
    local out = recolor.apply('<path fill="#ff7043"/>', "theme_brand")
    local hex = out:match('fill="(#%x+)"')
    truthy(hex and hex ~= "#ff7043", "a blended colour, not the raw brand one")
end)

describe("lvim-icons.svg: coloured files")

it("brand draws the bundled file; theme a recoloured copy in the cache, reused for the same palette", function()
    local svg = require("lvim-icons.svg")
    local path = svg.find("rust")
    truthy(path, "rust is bundled")
    eq(path, svg.coloured(path, "brand"))
    local a = svg.coloured(path, "theme")
    truthy(a ~= path and vim.startswith(a, vim.fn.stdpath("cache")), "a copy in the cache")
    eq(a, svg.coloured(path, "theme"), "the same palette reuses the same file")
end)

it("a light background takes the manifest's light icon where there is one", function()
    local material = require("lvim-icons.material")
    local saved = vim.o.background
    vim.o.background = "light"
    local light = material.file("Cargo.toml")
    vim.o.background = "dark"
    local dark = material.file("Cargo.toml")
    vim.o.background = saved
    eq(true, vim.endswith(light, "_light"), "light: " .. tostring(light))
    eq(false, vim.endswith(dark, "_light"), "dark: " .. tostring(dark))
end)
