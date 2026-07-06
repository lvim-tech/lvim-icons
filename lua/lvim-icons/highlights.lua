-- lvim-icons.highlights: the icon highlight groups, self-themed from the shared palette.
-- Two families:
--   • ROLE groups (color_mode = "palette") — one group per palette slot (LvimIconBlue,
--     LvimIconRed, …), NOT one per icon, so the ColorScheme rebuild stays cheap. Bound via
--     lvim-utils.highlight.bind so they re-derive on every palette sync / ColorScheme.
--   • BRAND groups (color_mode = "brand") — one group per DISTINCT brand hex, created
--     lazily the first time an icon of that brand is resolved, then blended toward the live
--     editor bg by config.brand_blend. A single bound factory recomputes every used brand
--     group when the palette changes, so brand icons track a background flip too.
-- build() must be a function so each call reads the current palette (colors.on_change fires
-- → the bound factory re-runs with fresh values). No colour is ever inlined in resolve/UI —
-- callers reference a NAMED group returned here.
--
---@module "lvim-icons.highlights"

local c = require("lvim-utils.colors")
local hl = require("lvim-utils.highlight")

local M = {}

-- The palette roles an icon spec may name. Each maps to a live palette colour; the group is
-- `LvimIcon` + Titlecased role. `fg` is the neutral foreground (default / text-ish icons).
---@type string[]
local ROLES = { "red", "green", "blue", "cyan", "magenta", "orange", "yellow", "purple", "teal", "fg" }

--- Highlight group name for a palette role (e.g. "blue" → "LvimIconBlue").
---@param role string
---@return string
function M.role_group(role)
    return "LvimIcon" .. role:sub(1, 1):upper() .. role:sub(2)
end

--- Build the role → highlight-opts map from the LIVE palette. Bound in init via hl.bind so
--- it is applied now (default = overwritable) and re-applied on palette sync / ColorScheme.
---@return table<string, table>
function M.build()
    local groups = {}
    for _, role in ipairs(ROLES) do
        -- `c[role]` resolves through the colors __index to the live hex for that slot.
        groups[M.role_group(role)] = { fg = c[role] or c.fg }
    end
    return groups
end

-- ── brand groups (lazy, color_mode = "brand") ──────────────────────────────

-- Distinct brand hexes seen so far → true. The bound factory below recomputes a group for
-- each on every palette change; new hexes are added (and applied once) on first resolve.
---@type table<string, boolean>
local used_brands = {}

--- Group name for a brand hex ("#dea584" → "LvimIconBrand_dea584").
---@param hex string
---@return string
local function brand_group_name(hex)
    return "LvimIconBrand_" .. hex:gsub("#", ""):lower()
end

--- Rebuild every USED brand group from the live bg + config.brand_blend. Bound once in init.
---@return table<string, table>
function M.build_brands()
    local cfg = require("lvim-icons.config")
    local groups = {}
    for hex in pairs(used_brands) do
        -- blend toward the live editor bg: 1.0 keeps the raw brand hue, lower pulls it to bg.
        groups[brand_group_name(hex)] = { fg = hl.blend(hex, c.bg, cfg.brand_blend) }
    end
    return groups
end

--- Ensure a brand group exists for `hex` and return its name. First sight of a hex registers
--- it (and applies it immediately with the current bg); the bound factory keeps it fresh.
---@param hex string  brand colour (#rrggbb)
---@return string     the highlight group name
function M.brand_group(hex)
    local name = brand_group_name(hex)
    if not used_brands[hex] then
        used_brands[hex] = true
        local cfg = require("lvim-icons.config")
        hl.register({ [name] = { fg = hl.blend(hex, c.bg, cfg.brand_blend) } }, false)
    end
    return name
end

return M
