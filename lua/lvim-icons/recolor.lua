-- lvim-icons.recolor: the colour modes of the svg render mode, applied to the SVG source before it is drawn.
--
--   "brand"       the SVG's own colours, untouched (Material's per-language colours).
--   "theme"       every colour is replaced by the theme role of its hue family (a grey → `fg`), so an
--                 orange icon stays orange, but the theme's orange — icons follow the active colorscheme.
--   "theme_brand" every colour is blended toward the editor background by `brand_blend`, as nerd mode
--                 does with a brand hex (highlights.brand_color).
--
-- Only colour VALUES in paint attributes are rewritten (`fill`, `stroke`, `stop-color`, `flood-color`,
-- `color`, and the same properties inside `style`); fragment references like `href="#a"` are left alone.
--
---@module "lvim-icons.recolor"

local c = require("lvim-utils.colors")
local hl = require("lvim-utils.highlight")

local M = {}

-- Below this saturation a colour reads as grey and maps to `fg`.
local GREY = 0.18

--- "#rgb" / "#rrggbb" → r, g, b in 0..255 (nil when not a hex colour).
---@param hex string
---@return integer?, integer?, integer?
local function rgb(hex)
    local h = hex:gsub("^#", "")
    if #h == 3 then
        h = h:gsub(".", "%0%0")
    end
    if #h ~= 6 or h:find("%X") then
        return nil
    end
    return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

--- Hue (0..360) and saturation (0..1, HSL) of a colour.
---@param r integer
---@param g integer
---@param b integer
---@return number hue, number sat
local function hue_sat(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local l = (max + min) / 2
    local d = max - min
    if d == 0 then
        return 0, 0
    end
    local s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    local h
    if max == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
        h = (b - r) / d + 2
    else
        h = (r - g) / d + 4
    end
    return h * 60, s
end

-- The hue family of a colour, by fixed bands of the colour wheel (degrees, upper bound exclusive). A colour is
-- classified by WHAT it is (orange, blue, …) and then takes the theme's role of that name — not the palette
-- colour nearest in hue: a palette's roles are semantic, not evenly spread (lvim's `magenta` is a terracotta
-- closer in hue to an orange than its `orange` is), so "nearest" would turn an orange icon magenta.
local BANDS = {
    { 10, "red" },
    { 45, "orange" },
    { 70, "yellow" },
    { 160, "green" },
    { 185, "teal" },
    { 200, "cyan" },
    { 250, "blue" },
    { 290, "purple" },
    { 345, "magenta" },
    { 361, "red" },
}

--- The theme role for `hex`: its hue family (`fg` for a grey).
---@param hex string
---@return string role
function M.nearest_role(hex)
    local r, g, b = rgb(hex)
    if not r then
        return "fg"
    end
    local h, s = hue_sat(r, g, b)
    if s < GREY then
        return "fg"
    end
    for _, band in ipairs(BANDS) do
        if h < band[1] then
            return band[2]
        end
    end
    return "red"
end

--- The colour `hex` becomes under `mode`.
---@param hex string
---@param mode string  "brand" | "theme" | "theme_brand"
---@return string
function M.map(hex, mode)
    if mode == "theme" then
        local role = M.nearest_role(hex)
        return (c[role] or c.fg or hex):lower()
    elseif mode == "theme_brand" then
        local r, g, b = rgb(hex)
        if not r then
            return hex
        end
        return hl.blend(("#%02x%02x%02x"):format(r, g, b), c.bg, require("lvim-icons.config").brand_blend):lower()
    end
    return hex
end

-- paint properties whose value may be a colour
local PROPS = { "fill", "stroke", "stop%-color", "flood%-color", "color" }

--- `svg` with every paint colour mapped through `mode`. Returns the text and the list of distinct
--- (from → to) pairs, sorted (a stable signature of the result for caching).
---@param svg string
---@param mode string
---@return string text, string signature
function M.apply(svg, mode)
    if mode ~= "theme" and mode ~= "theme_brand" then
        return svg, ""
    end
    local seen = {}
    local function sub(hex)
        local to = M.map(hex, mode)
        seen[hex:lower()] = to
        return to
    end
    for _, prop in ipairs(PROPS) do
        -- attribute form: fill="#abc"
        svg = svg:gsub("(%f[%w%-]" .. prop .. '%s*=%s*["\'])(#%x+)', function(lead, hex)
            return lead .. sub(hex)
        end)
        -- style form: style="fill:#abc;stroke:#def"
        svg = svg:gsub("(%f[%w%-]" .. prop .. "%s*:%s*)(#%x+)", function(lead, hex)
            return lead .. sub(hex)
        end)
    end
    local pairs_ = {}
    for from, to in pairs(seen) do
        pairs_[#pairs_ + 1] = from .. ">" .. to
    end
    table.sort(pairs_)
    return svg, table.concat(pairs_, ",")
end

--- `svg` painted entirely in `hex` — a one-colour icon (a Nerd glyph): every paint colour becomes
--- `hex`, and the root gets `fill` so a shape with no fill of its own (the default black) takes it too.
---@param svg string
---@param hex string
---@return string
function M.fill(svg, hex)
    for _, prop in ipairs(PROPS) do
        svg = svg:gsub("(%f[%w%-]" .. prop .. '%s*=%s*["\'])#%x+', "%1" .. hex)
        svg = svg:gsub("(%f[%w%-]" .. prop .. "%s*:%s*)#%x+", "%1" .. hex)
    end
    -- the root's own fill (replace one it has, else add one)
    local root = svg:match("<svg[^>]*>")
    if root then
        local new
        if root:find("%sfill%s*=") then
            new = root:gsub('(%sfill%s*=%s*["\'])[^"\']*', "%1" .. hex, 1)
        else
            new = root:gsub("^<svg", '<svg fill="' .. hex .. '"', 1)
        end
        svg = svg:gsub(vim.pesc(root), (new:gsub("%%", "%%%%")), 1)
    end
    return svg
end

return M
