-- lvim-icons.svg: the svg (COLRv1 color-font) render-mode runtime.
-- svg mode emits, instead of a Nerd Font glyph, a TEXT ligature sequence — an emoji base +
-- Unicode variation selectors — that a shaping-capable terminal substitutes with a full
-- colour vector glyph baked into the shipped COLRv1 font. Because it is plain text it works
-- anywhere text does (statuslines, trees, the fzf picker TUI) — which is why icons use this,
-- not the kitty graphics protocol (lvim-image's domain).
--
-- Two things gate svg mode, and only ONE is probeable:
--   • The FONT must be installed — checked with `fc-list` (cached). This we can know.
--   • The TERMINAL must shape COLRv1 ligatures — NO terminal advertises this, so it cannot
--     be probed. We keep a conservative known-good allowlist for mode = "auto", and honour
--     config.svg.assume_supported for the user's explicit word.
-- When the font is missing, svg/auto degrade to "font" wholesale (health warns). When a
-- single icon has no svg mapping, the resolver falls back to its font glyph per-icon.
--
-- Colours are baked into the font, so per-glyph palette theming does not apply; instead the
-- build pipeline ships one glyph-sequence set per lvim-colorscheme brightness variant and
-- the runtime selects the set matching the active variant (so svg icons still track theme).
--
---@module "lvim-icons.svg"

local M = {}

-- Terminals known to shape COLRv1 ligatures (for mode = "auto"). Matched against $TERM and a
-- couple of terminal-specific env vars. Deliberately conservative: a false negative just
-- means font mode (safe), a false positive would leak the raw base emoji.
---@type table<string, boolean>
local KNOWN_GOOD_TERM = {
    ["xterm-kitty"] = true,
    ["wezterm"] = true,
    ["alacritty"] = true,
    ["foot"] = true,
    ["konsole"] = true,
    ["gnome"] = true,
}

---@type boolean?  cached fc-list probe result (nil = not yet probed)
local _font_installed = nil

--- Whether the configured svg font family is installed (cached `fc-list` probe). The single
--- thing about svg mode we can reliably know at runtime.
---@param force boolean?  re-run the probe instead of using the cache
---@return boolean
function M.font_installed(force)
    if _font_installed ~= nil and not force then
        return _font_installed
    end
    if vim.fn.executable("fc-list") == 0 then
        _font_installed = false
        return false
    end
    local family = require("lvim-icons.config").svg.font_family
    -- `fc-list : family` prints one line per matching face; empty output = not installed.
    local out = vim.fn.system({ "fc-list", ":", "family" })
    _font_installed = out:lower():find(family:lower(), 1, true) ~= nil
    return _font_installed
end

--- Whether the current terminal is on the COLRv1-shaping allowlist (or the user vouched for
--- it via config.svg.assume_supported). Used only to resolve mode = "auto".
---@return boolean
function M.terminal_supported()
    if require("lvim-icons.config").svg.assume_supported then
        return true
    end
    local term = (vim.env.TERM or ""):lower()
    for key in pairs(KNOWN_GOOD_TERM) do
        if term:find(key, 1, true) then
            return true
        end
    end
    -- Terminal-specific env hints some emulators set even under a generic $TERM.
    if vim.env.KITTY_WINDOW_ID or vim.env.WEZTERM_PANE or vim.env.ALACRITTY_WINDOW_ID then
        return true
    end
    return false
end

--- Resolve config.mode to the EFFECTIVE render mode for this session.
---   "font"          → "font"
---   "svg"           → "svg" when the font is installed, else "font"
---   "auto"          → "svg" only when the font is installed AND the terminal is known-good
---@return "font"|"svg"
function M.active_mode()
    local mode = require("lvim-icons.config").mode
    if mode == "font" then
        return "font"
    end
    if not M.font_installed() then
        return "font"
    end
    if mode == "svg" then
        return "svg"
    end
    if mode == "auto" then
        return M.terminal_supported() and "svg" or "font"
    end
    return "font"
end

--- The active theme variant whose glyph set svg sequences are drawn from. config.svg.variant
--- wins; otherwise it follows the active lvim-colorscheme style (its `lvim_<variant>` suffix),
--- falling back to the &background value.
---@return string  "soft"|"dark"|"darker"|"light" (or the raw background name)
function M.variant()
    local cfg = require("lvim-icons.config").svg
    if cfg.variant then
        return cfg.variant
    end
    local ok, lcs = pcall(require, "lvim-colorscheme.config")
    if ok and lcs then
        local style = (vim.o.background == "light") and lcs.light_style or lcs.style
        if type(style) == "string" then
            -- "lvim_dark" → "dark", "lvim_soft" → "soft", …
            return (style:gsub("^lvim_", ""))
        end
    end
    return (vim.o.background == "light") and "light" or "dark"
end

--- The svg ligature glyph for an icon `name` in the active variant, or nil when the icon has
--- no svg mapping (the resolver then falls back to the font glyph for it). These are COLRv1
--- LIGATURE SEQUENCES (a base emoji + Unicode variation selectors), which are codepoint
--- sequences by nature — a variation selector is not a printable glyph — and the data is
--- GENERATED by the font build pipeline, so materialising the sequence with nr2char here is
--- correct and is NOT the banned icon-glyph function (simple Nerd icons are literal glyphs).
---@param name string  the icon's stable id (spec.name)
---@return string?      the ligature text, or nil if unmapped
function M.sequence(name)
    local ok, svg = pcall(require, "lvim-icons.data.svg")
    if not ok or type(svg) ~= "table" then
        return nil
    end
    local entry = svg[name]
    if not entry then
        return nil
    end
    -- Prefer the active variant's sequence; fall back to the entry's base `seq`.
    local seq = (entry.variants and entry.variants[M.variant()]) or entry.seq
    if type(seq) ~= "table" or #seq == 0 then
        return nil
    end
    local parts = {}
    for i, cp in ipairs(seq) do
        parts[i] = vim.fn.nr2char(cp)
    end
    return table.concat(parts)
end

return M
