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

---@type table<string, boolean>  fast membership set for the roles above (built groups + a live colour)
local ROLE_SET = {}
for _, r in ipairs(ROLES) do
    ROLE_SET[r] = true
end

--- Whether `role` is one of the defined palette roles. A spec role outside this set has no built
--- highlight group (and `c[role]` is nil), so callers must fall back to "fg" to keep hl + color in sync.
---@param role string
---@return boolean
function M.is_role(role)
    return ROLE_SET[role] == true
end

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

-- ── brand groups (lazy, color_mode "brand" / "theme_brand") ─────────────────
-- A brand hex renders with a DIFFERENT fg per colour mode ("brand" = raw, "theme_brand" =
-- blended toward the theme bg), and the mode can be chosen PER CALL — so a group is keyed by
-- BOTH (hex, mode). Each distinct (hex, mode) pair seen so far is remembered; the bound
-- factory recomputes them all on every palette change (so blended groups track a bg flip).

-- Seen (hex, mode) pairs → true, keyed as "<mode>|<hex>".
---@type table<string, boolean>
local used_brands = {}

--- Group name for a (brand hex, mode). "brand" → LvimIconBrand_<hex>; "theme_brand" →
--- LvimIconBrandTheme_<hex>. Two families so the same hex can be raw in one place and blended
--- in another without clobbering.
---@param hex string
---@param mode string  "brand" | "theme_brand"
---@return string
local function brand_group_name(hex, mode)
    local h = hex:gsub("#", ""):lower()
    return (mode == "brand") and ("LvimIconBrand_" .. h) or ("LvimIconBrandTheme_" .. h)
end

--- The fg a brand hex renders with under `mode`: raw in "brand", blended toward the theme bg by
--- config.brand_blend in "theme_brand".
---@param hex string
---@param mode string  "brand" | "theme_brand"
---@return string
function M.brand_color(hex, mode)
    if mode == "brand" then
        return hex
    end
    return hl.blend(hex, c.bg, require("lvim-icons.config").brand_blend)
end

--- Rebuild every USED brand group from the live palette. Bound once in init so blended
--- ("theme_brand") groups follow a background flip; raw ("brand") groups are stable but cheap.
---@return table<string, table>
function M.build_brands()
    local groups = {}
    for pair in pairs(used_brands) do
        local mode, hex = pair:match("^(.-)|(.+)$")
        groups[brand_group_name(hex, mode)] = { fg = M.brand_color(hex, mode) }
    end
    return groups
end

--- Ensure a brand group exists for (`hex`, `mode`) and return its name. First sight registers
--- it (and applies it immediately); the bound factory keeps it fresh.
---@param hex  string  brand colour (#rrggbb)
---@param mode string  "brand" | "theme_brand"
---@return string      the highlight group name
function M.brand_group(hex, mode)
    local name = brand_group_name(hex, mode)
    local key = mode .. "|" .. hex
    if not used_brands[key] then
        used_brands[key] = true
        hl.register({ [name] = { fg = M.brand_color(hex, mode) } }, false)
    end
    return name
end

return M
