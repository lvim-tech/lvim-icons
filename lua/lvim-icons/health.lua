-- lvim-icons: :checkhealth lvim-icons.
-- Reports the things that make an icon provider misbehave invisibly: a glyph that is not
-- single-width (breaks every consumer's column alignment), an invalid config value, a missing
-- hard dependency (lvim-utils) or the optional gallery dependency (lvim-ui), and — for svg
-- mode — whether lvim-image is there, whether the terminal shows kitty unicode placeholders,
-- the cell size the images are drawn for, and which render mode is therefore ACTIVE and why.
-- Read-only: it never mutates config or state.
--
---@module "lvim-icons.health"

local config = require("lvim-icons.config")
local resolve = require("lvim-icons.resolve")
local svg = require("lvim-icons.svg")
local highlights = require("lvim-icons.highlights")

local M = {}

---@type table<string, boolean>
local VALID_MODE = { nerd = true, mix = true, material = true }
---@type table<string, boolean>
local VALID_COLOR_MODE = { theme = true, brand = true, theme_brand = true }

--- Audit every data-table glyph for single display width (canon: single-width Nerd Font only).
---@param health table  the vim.health reporter
---@return nil
local function check_glyphs(health)
    local bad, total = {}, 0
    for kind, tbl in pairs(resolve.tables()) do
        for key, spec in pairs(tbl) do
            total = total + 1
            local w = vim.fn.strdisplaywidth(spec.glyph or "")
            if w ~= 1 then
                bad[#bad + 1] = ("%s/%s (%s, glyph=%s) width=%d"):format(
                    kind,
                    key,
                    spec.name or "?",
                    spec.glyph or "?",
                    w
                )
            end
        end
    end
    if #bad == 0 then
        health.ok(("all %d glyphs are single-width"):format(total))
    else
        health.warn(("%d of %d glyphs are not single-width:"):format(#bad, total))
        for _, b in ipairs(bad) do
            health.warn("  " .. b)
        end
    end
end

--- Audit every spec's `role` against the defined palette roles. An unknown role (only reachable via
--- a user override) renders through a cleared highlight group, so its `hl` consumer shows the icon
--- invisible while `color` falls back to fg — the two disagree. resolve now normalises to "fg", but a
--- warning tells the user their override role was not honoured as written.
---@param health table  the vim.health reporter
---@return nil
local function check_roles(health)
    local bad = {}
    for kind, tbl in pairs(resolve.tables()) do
        for key, spec in pairs(tbl) do
            if type(spec.role) == "string" and not highlights.is_role(spec.role) then
                bad[#bad + 1] = ("%s/%s role=%q"):format(kind, key, spec.role)
            end
        end
    end
    if #bad == 0 then
        health.ok("all icon roles resolve to a palette group")
    else
        health.warn(("%d spec(s) name an unknown role (rendered as fg):"):format(#bad))
        for _, b in ipairs(bad) do
            health.warn("  " .. b)
        end
    end
end

--- Validate the config values that have a fixed domain.
---@param health table  the vim.health reporter
---@return nil
local function check_config(health)
    if VALID_MODE[config.mode] then
        health.ok(("mode = %q"):format(config.mode))
    else
        health.error(("mode = %q is invalid (nerd|mix|material)"):format(tostring(config.mode)))
    end
    if VALID_COLOR_MODE[config.color_mode] then
        health.ok(("color_mode = %q"):format(config.color_mode))
    else
        health.error(("color_mode = %q is invalid (theme|brand|theme_brand)"):format(tostring(config.color_mode)))
    end
    for _, kind in ipairs({ "font", "image" }) do
        local v = config.placement and config.placement[kind]
        if v == "real" or v == "virtual" then
            health.ok(("placement.%s = %q"):format(kind, v))
        else
            health.error(("placement.%s = %q is invalid (real|virtual)"):format(kind, tostring(v)))
        end
    end
    if type(config.brand_blend) ~= "number" or config.brand_blend < 0 or config.brand_blend > 1 then
        health.warn(("brand_blend = %s should be a number in 0..1"):format(tostring(config.brand_blend)))
    end
end

--- Report hard + optional dependencies.
---@param health table  the vim.health reporter
---@return nil
local function check_deps(health)
    if pcall(require, "lvim-utils.colors") then
        health.ok("lvim-utils found (palette + highlight)")
    else
        health.error("lvim-utils not found — the palette and self-theming are unavailable")
    end
    if pcall(require, "lvim-ui") then
        health.ok("lvim-ui found (:LvimIcons gallery)")
    else
        health.warn("lvim-ui not found — the :LvimIcons gallery is disabled (resolver still works)")
    end
end

--- Report svg-mode readiness and the resulting ACTIVE render mode with the reason.
---@param health table  the vim.health reporter
---@return nil
local function check_svg(health)
    if svg.mode() == "nerd" then
        health.info("render mode: nerd (every icon a Nerd glyph, as text — no images)")
        return
    end
    local ok_t, terminal = pcall(require, "lvim-image.terminal")
    if not ok_t then
        health.warn("lvim-image not found — icons are drawn as images through it, so every icon stays a glyph")
        return
    end
    health.ok("lvim-image found")
    local ok_c, caps = pcall(terminal.capabilities)
    if ok_c and type(caps) == "table" and caps.placeholders then
        health.ok("the terminal shows kitty unicode placeholders")
    else
        health.warn(
            "the terminal does not show kitty unicode placeholders (kitty / Ghostty; inside tmux or zellij set "
                .. "lvim-image's tmux_placeholders / zellij_placeholders where they pass them) — Nerd glyphs are used"
        )
    end
    local image = require("lvim-icons.image")
    local geo = image.geometry()
    if geo then
        health.ok(("icons drawn %dx%d px in a %dx%d canvas (cell %dx%d, svg.fill = %s)"):format(
            geo.size, geo.size, geo.w, geo.h, geo.cw, geo.ch, tostring(config.svg.fill)
        ))
    else
        health.warn("the terminal cell size is unknown — images cannot be sized")
    end
    local material = require("lvim-icons.material")
    if not material.available() then
        health.error("assets/material/material-icons.json is missing or unreadable — run scripts/update-material.sh")
        return
    end
    local ids, missing = material.ids(), {}
    for _, id in ipairs(ids) do
        if not svg.find(id) then
            missing[#missing + 1] = id
        end
    end
    local f = io.open(material.DIR .. "/VERSION", "r")
    local version = f and vim.trim(f:read("*a")) or "?"
    if f then
        f:close()
    end
    if #missing == 0 then
        health.ok(("Material Icon Theme %s: every icon has its SVG (%d)"):format(version, #ids))
    else
        health.warn(("no SVG file for: %s (they keep their font glyph)"):format(table.concat(missing, ", ")))
    end
    if svg.mode() == "material" then
        local nerd = vim.fn.glob(svg.NERD .. "/*.svgz", false, true)
        if #nerd > 0 then
            health.ok(("Nerd glyph SVGs for the UI icons: %d (assets/nerd)"):format(#nerd))
        else
            health.warn("no Nerd glyph SVGs in assets/nerd — UI icons stay glyphs; run scripts/update-nerd.sh")
        end
    end
    local active = svg.active_mode()
    if active ~= "nerd" then
        health.ok(("active render mode: %s (%d images sent)"):format(active, require("lvim-icons.placeholders").count()))
    else
        health.warn(("active render mode: nerd — %s asked for, but the terminal cannot show images"):format(svg.mode()))
    end
end

--- Entry point for `:checkhealth lvim-icons`.
---@return nil
function M.check()
    local health = vim.health
    health.start("lvim-icons")
    check_deps(health)
    check_config(health)
    check_glyphs(health)
    check_roles(health)
    check_svg(health)
end

return M
