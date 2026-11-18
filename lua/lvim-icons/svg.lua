-- lvim-icons.svg: the image side of lvim-icons — every icon drawn from an SVG as a small terminal IMAGE, two
-- cells wide, through kitty unicode placeholders (placeholders.lua sends it, image.lua draws it).
--
-- The render MODE decides which icons are images:
--   "nerd"     none — every icon is its Nerd Font glyph, as text
--   "mix"      file / folder icons from the Material Icon Theme (material.lua, 1:1 with VS Code); every
--              other (UI) icon its Nerd glyph, as text
--   "material" file / folder icons as in "mix"; the UI icons drawn from their own Nerd glyph's SVG
--              (assets/nerd/, extracted from Symbols Nerd Font), in the colour they have as a glyph
--
-- Images are drawn only where the terminal can show them: lvim-image installed, a terminal that renders kitty
-- unicode placeholders (kitty, Ghostty; tmux / zellij when lvim-image is told they pass them through) and a
-- known cell size. Anywhere else every icon is its Nerd glyph, as text, whatever the mode.
--
-- A file in the user's `svg.dir` replaces a bundled one: `<material id>.svg`, `nerd/<CODEPOINT>.svg`.
--
---@module "lvim-icons.svg"

local config = require("lvim-icons.config")
local placeholders = require("lvim-icons.placeholders")

local M = {}

--- The plugin root (…/lvim-icons), from this file's location: lua/lvim-icons/svg.lua.
local ROOT = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")

--- The bundled Material Icon Theme directory.
M.ASSETS = ROOT .. "/assets/material"
--- The bundled Nerd glyph directory (`<CODEPOINT>.svgz`).
M.NERD = ROOT .. "/assets/nerd"

local MODES = { nerd = true, mix = true, material = true }

--- The configured render mode ("nerd" when unset or unknown).
---@return "nerd"|"mix"|"material"
function M.mode()
    return MODES[config.mode] and config.mode or "nerd"
end

--- Whether icons are drawn as images here (the terminal can show them).
---@return boolean
function M.images()
    return placeholders.available()
end

--- The EFFECTIVE render mode: the configured one where its images can be drawn, "nerd" (every icon a glyph,
--- as text) where they cannot.
---@return "nerd"|"mix"|"material"
function M.active_mode()
    local mode = M.mode()
    if mode ~= "nerd" and M.images() then
        return mode
    end
    return "nerd"
end

--- Whether file / folder icons are drawn as images ("mix", "material").
---@return boolean
function M.files_as_images()
    return M.active_mode() ~= "nerd"
end

--- Whether UI icons are drawn as images ("material").
---@return boolean
function M.ui_as_images()
    return M.active_mode() == "material"
end

-- ── reading and colouring SVGs ───────────────────────────────────────────────

--- The text of an SVG file; a `.svgz` is decompressed.
---@param path string
---@return string?
function M.read(path)
    if path:sub(-5) == ".svgz" then
        local res = vim.system({ "gzip", "-dc", path }, { text = true }):wait()
        return res.code == 0 and res.stdout or nil
    end
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local text = f:read("*a")
    f:close()
    return text
end

--- Write `text` to `file` in the cache unless it is there already (files are named by their content).
---@param file string
---@param text string
---@return string? file
local function cached(file, text)
    if not vim.uv.fs_stat(file) then
        vim.fn.mkdir(vim.fs.dirname(file), "p")
        local w = io.open(file, "w")
        if not w then
            return nil
        end
        w:write(text)
        w:close()
    end
    return file
end

--- A copy of the one-colour SVG at `path` (a Nerd glyph) filled with `hex`.
---@param path string
---@param hex string  "#rrggbb"
---@return string? file
function M.filled(path, hex)
    local name = vim.fn.fnamemodify(path, ":t"):gsub("%.svgz?$", "")
    local file = ("%s/lvim-icons/fill/%s-%s.svg"):format(vim.fn.stdpath("cache"), name, hex:gsub("#", ""))
    if vim.uv.fs_stat(file) then
        return file
    end
    local text = M.read(path)
    return text and cached(file, require("lvim-icons.recolor").fill(text, hex)) or nil
end

--- The SVG to draw for a Material icon at `path` in colour `mode`: the file itself in "brand", else a
--- recoloured copy (named by its content, so an unchanged palette reuses it).
---@param path string
---@param mode string
---@return string? file, string? err
function M.coloured(path, mode)
    if mode ~= "theme" and mode ~= "theme_brand" then
        return path
    end
    local text = M.read(path)
    if not text then
        return nil, "cannot read " .. path
    end
    local out, sig = require("lvim-icons.recolor").apply(text, mode)
    if sig == "" then
        return path -- no colour in it to map
    end
    local file = ("%s/lvim-icons/svg/%s-%s.svg"):format(
        vim.fn.stdpath("cache"),
        vim.fn.fnamemodify(path, ":t:r"),
        vim.fn.sha256(mode .. "|" .. sig):sub(1, 12)
    )
    return cached(file, out)
end

-- ── finding SVGs ─────────────────────────────────────────────────────────────

---@type table<string, string|false>  lookup key → SVG path (false = none); asked per icon drawn
local paths = {}

--- Forget the resolved SVG paths (after `svg.dir` changed).
function M.reset()
    paths = {}
end

--- `svg.dir`/`sub`/`file`, when it exists.
---@param sub string
---@param file string
---@return string?
local function user_file(sub, file)
    local dir = config.svg and config.svg.dir
    if not (dir and dir ~= "") then
        return nil
    end
    local p = vim.fs.normalize(dir) .. (sub ~= "" and ("/" .. sub) or "") .. "/" .. file
    return vim.uv.fs_stat(p) and p or nil
end

--- The SVG of Material icon `id` (cached lookup), or nil.
---@param id string
---@return string?
function M.path(id)
    local key = "material:" .. id
    if paths[key] == nil then
        paths[key] = M.find(id) or false
    end
    return paths[key] or nil
end

--- Look the SVG of Material icon `id` up on disk (uncached): `svg.dir` first, then the bundle.
---@param id string
---@return string?
function M.find(id)
    local user = user_file("", id .. ".svg")
    if user then
        return user
    end
    local bundled = require("lvim-icons.material").path(id)
    return (bundled and vim.uv.fs_stat(bundled)) and bundled or nil
end

--- The SVG of the Nerd glyph `glyph` (cached lookup), or nil when it has none.
---@param glyph? string
---@return string?
function M.nerd_path(glyph)
    if not glyph or glyph == "" then
        return nil
    end
    local cp = vim.fn.char2nr(glyph)
    if cp < 0x80 then
        return nil
    end
    local hex = ("%04X"):format(cp)
    local key = "nerd:" .. hex
    if paths[key] == nil then
        local bundled = M.NERD .. "/" .. hex .. ".svgz"
        paths[key] = user_file("nerd", hex .. ".svg") or (vim.uv.fs_stat(bundled) and bundled) or false
    end
    return paths[key] or nil
end

---@type table<string, number>|false|nil  "F07C" → the glyph's ink centre, as a fraction of the em
local nerd_metrics

--- Where the middle of Nerd glyph `glyph` lands, as a fraction of the em from the glyph's origin (the cell's
--- left edge, where a terminal draws it) — from assets/nerd/metrics.json. nil when unknown.
---@param glyph? string
---@return number?
function M.nerd_centre(glyph)
    if not glyph or glyph == "" then
        return nil
    end
    if nerd_metrics == nil then
        nerd_metrics = false
        local f = io.open(M.NERD .. "/metrics.json", "r")
        if f then
            local ok, data = pcall(vim.json.decode, f:read("*a"))
            f:close()
            nerd_metrics = ok and type(data) == "table" and data or false
        end
    end
    return nerd_metrics and nerd_metrics[("%04X"):format(vim.fn.char2nr(glyph))] or nil
end

-- ── images, kept in step with the theme ──────────────────────────────────────

---@type table<string, fun()>  every image in use → how to draw it again (after a theme change)
local redraw = {}

--- The image of Material icon `name` (an icon id) in colour `mode`, or nil when it has no SVG.
---@param name string
---@param mode? string  "brand" | "theme" | "theme_brand" (default: config.color_mode)
---@return LvimIconsPlaceholderEntry?
function M.icon(name, mode)
    mode = mode or config.color_mode
    local path = M.path(name)
    local file = path and M.coloured(path, mode)
    if not file then
        return nil
    end
    local key = name .. "|" .. mode
    redraw[key] = function()
        M.icon(name, mode)
    end
    return (placeholders.ensure(key, file))
end

--- The image of a one-colour SVG at `path`, filled with the colour `color()` gives NOW, under `key` — kept:
--- after a theme change it is filled again with the then-current colour, under the same id.
---@param key string
---@param path string
---@param color fun(): string  "#rrggbb"
---@return LvimIconsPlaceholderEntry?
function M.mono(key, path, color)
    local file = M.filled(path, color())
    if not file then
        return nil
    end
    redraw[key] = function()
        M.mono(key, path, color)
    end
    return (placeholders.ensure(key, file))
end

--- A guide line image (image.vline) in the colour `color()` gives NOW, its centre at the pixel `at(geo)`
--- gives (nil: the canvas middle), under `key` — kept in step with the theme like `mono`.
---@param key string
---@param color fun(): string  "#rrggbb"
---@param at? fun(geo: LvimIconsImageGeometry): number?
---@return LvimIconsPlaceholderEntry?
function M.line(key, color, at)
    local hex = color()
    local geo = require("lvim-icons.image").geometry()
    local x = at and geo and at(geo) or nil
    -- thickness and position are part of what is drawn: a change redraws under the same id
    local px = tostring(config.svg and config.svg.guide_px or 2)
    local e = placeholders.ensure(key, ("vline:%s|%s|%s"):format(hex, px, x and ("%.1f"):format(x) or "mid"), function(g)
        return require("lvim-icons.image").vline(g, hex, at and at(g) or nil)
    end)
    redraw[key] = function()
        M.line(key, color, at)
    end
    return e
end

--- Redraw every image in use for the current theme, under the same ids, so the cells already on screen show
--- the new colours at once.
function M.recolor()
    for _, fn in pairs(redraw) do
        fn()
    end
end

---@type boolean
local hooked = false

--- Follow the theme: on every palette sync (and `background` flip) redraw the images. Idempotent.
function M.setup()
    if hooked then
        return
    end
    hooked = true
    local ok, colors = pcall(require, "lvim-utils.colors")
    if ok and colors.on_change then
        colors.on_change(function()
            vim.schedule(M.recolor)
        end)
    end
    vim.api.nvim_create_autocmd({ "ColorScheme", "OptionSet" }, {
        group = vim.api.nvim_create_augroup("LvimIconsSvgRecolor", { clear = true }),
        callback = function(ev)
            if ev.event == "OptionSet" and ev.match ~= "background" then
                return
            end
            vim.schedule(M.recolor)
        end,
    })
end

return M
