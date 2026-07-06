-- lvim-icons: :checkhealth lvim-icons.
-- Reports the things that make an icon provider misbehave invisibly: a glyph that is not
-- single-width (breaks every consumer's column alignment), an invalid config value, a missing
-- hard dependency (lvim-utils) or the optional gallery dependency (lvim-ui), and — for svg
-- mode — whether the COLRv1 font is actually installed, whether the terminal is on the
-- known-good shaping allowlist, and which render mode is therefore ACTIVE and why.
-- Read-only: it never mutates config or state.
--
---@module "lvim-icons.health"

local config = require("lvim-icons.config")
local resolve = require("lvim-icons.resolve")
local svg = require("lvim-icons.svg")

local M = {}

---@type table<string, boolean>
local VALID_MODE = { font = true, svg = true, auto = true }
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
            local w = vim.fn.strdisplaywidth(vim.fn.nr2char(spec.cp, 1))
            if w ~= 1 then
                bad[#bad + 1] = ("%s/%s (%s, cp=0x%X) width=%d"):format(kind, key, spec.name or "?", spec.cp, w)
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

--- Validate the config values that have a fixed domain.
---@param health table  the vim.health reporter
---@return nil
local function check_config(health)
    if VALID_MODE[config.mode] then
        health.ok(("mode = %q"):format(config.mode))
    else
        health.error(("mode = %q is invalid (font|svg|auto)"):format(tostring(config.mode)))
    end
    if VALID_COLOR_MODE[config.color_mode] then
        health.ok(("color_mode = %q"):format(config.color_mode))
    else
        health.error(("color_mode = %q is invalid (theme|brand|theme_brand)"):format(tostring(config.color_mode)))
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
    local active = svg.active_mode()
    if config.mode == "font" then
        health.info("render mode: font (svg not requested)")
        return
    end

    local font = svg.font_installed(true)
    if font then
        health.ok(("svg font %q is installed (fc-list)"):format(config.svg.font_family))
    else
        health.warn(
            ("svg font %q not found via fc-list — svg falls back to font mode"):format(config.svg.font_family)
        )
    end

    if config.svg.assume_supported then
        health.info("terminal: assume_supported = true (allowlist skipped)")
    elseif svg.terminal_supported() then
        health.ok(("terminal %q is on the COLRv1 shaping allowlist"):format(vim.env.TERM or "?"))
    else
        health.info(
            ("terminal %q is not on the shaping allowlist — set svg.assume_supported if it does shape COLRv1"):format(
                vim.env.TERM or "?"
            )
        )
    end

    if active == "svg" then
        health.ok(("active render mode: svg (variant %q)"):format(svg.variant()))
    else
        health.warn(
            ("active render mode: font (requested %q, but the svg preconditions are not met)"):format(config.mode)
        )
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
    check_svg(health)
end

return M
