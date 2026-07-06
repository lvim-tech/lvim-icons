-- lvim-icons: the single icon provider for the lvim-tech set — filename / extension /
-- filetype / filesystem-kind → { glyph, hl, color, width }. A curated Nerd Font data set
-- whose colours come from the LIVE lvim-utils palette (not hardcoded per icon), with a second
-- render mode (svg) that emits COLRv1 colour-font ligatures for terminals that shape them
-- (see svg.lua), auto-falling back to font mode. Every other lvim-tech plugin resolves its
-- file/ft icons here (soft dependency: consumers pcall-require and degrade to one glyph).
--
-- The resolver returns `width` from day one (1 in font mode, 2 in svg mode) so every consumer
-- aligns columns from it and is svg-ready without a change. Colours self-theme: the role
-- groups and any brand groups re-derive on ColorScheme / palette sync via the bound factories.
--
--   require("lvim-icons").get("init.lua")              -- → { glyph, hl, color, width, name }
--   require("lvim-icons").get(path, { filetype = ft }) -- filetype hint when the name is weak
--   require("lvim-icons").by_extension("rs")           -- direct table lookups
--   :LvimIcons                                          -- searchable gallery (yank a glyph)
--
---@module "lvim-icons"

local config = require("lvim-icons.config")
local resolve = require("lvim-icons.resolve")
local highlights = require("lvim-icons.highlights")
local svg = require("lvim-icons.svg")
local hl = require("lvim-utils.highlight")
local merge = require("lvim-utils.utils").merge

local M = {}

---@type boolean  one-time setup (highlight binds, command) done
local registered = false

-- ── public resolver API ─────────────────────────────────────────────────────

--- Resolve an icon for a path or bare filename through the full lookup chain
--- (filename → extension → filetype → default). Always returns a renderable result.
---@param name string                         a path or bare filename
---@param opts { filetype?: string, kind?: string }?  filetype hint / a filesystem-kind request
---@return LvimIconResult
function M.get(name, opts)
    return resolve.materialise(resolve.spec_for(name, opts))
end

--- Direct extension lookup (no chain), e.g. `by_extension("tsx")`.
---@param ext string
---@return LvimIconResult
function M.by_extension(ext)
    return resolve.by_extension(ext)
end

--- Direct filename lookup (no chain), e.g. `by_filename("Cargo.toml")`.
---@param filename string
---@return LvimIconResult
function M.by_filename(filename)
    return resolve.by_filename(filename)
end

--- Direct filetype lookup (no chain), e.g. `by_filetype("help")`.
---@param ft string
---@return LvimIconResult
function M.by_filetype(ft)
    return resolve.by_filetype(ft)
end

--- Direct filesystem-kind lookup (directory/directory_open/symlink/executable/…).
---@param kind string
---@return LvimIconResult
function M.by_kind(kind)
    return resolve.by_kind(kind)
end

--- Every icon, materialised — for consumers building their own gallery/audit.
---@return LvimIconResult[]
function M.all()
    local out = {}
    for _, spec in pairs(resolve.all_specs()) do
        out[#out + 1] = resolve.materialise(spec)
    end
    table.sort(out, function(a, b)
        return a.name < b.name
    end)
    return out
end

--- The effective render mode after fallback resolution ("font" or "svg"). For consumers /
--- health that need to know what is actually being emitted.
---@return "font"|"svg"
function M.active_mode()
    return svg.active_mode()
end

--- A lookup map keyed by data-table KEY (extension / filename / filetype), each entry
--- materialised — for consumers that need the WHOLE table at once (e.g. building a static
--- key→glyph map for an fzf awk transformer) rather than resolving one name at a time.
---@return table<string, { icon: string, color: string, hl: string, name: string }>
function M.get_icons()
    local T = resolve.tables()
    local out = {}
    for _, key in ipairs({ "extensions", "filenames", "filetypes" }) do
        for k, spec in pairs(T[key]) do
            local r = resolve.materialise(spec)
            out[k] = { icon = r.glyph, color = r.color, hl = r.hl, name = r.name }
        end
    end
    return out
end

-- ── overrides ────────────────────────────────────────────────────────────────

--- Merge user additions / overrides into the live data tables (same shape as the built-ins).
--- Called by setup() with config.overrides, and available at runtime for late additions.
---@param overrides LvimIconsOverrides
---@return nil
function M.override(overrides)
    if not overrides then
        return
    end
    local T = resolve.tables()
    for _, key in ipairs({ "extensions", "filenames", "filetypes" }) do
        if type(overrides[key]) == "table" then
            merge(T[key], overrides[key])
        end
    end
end

-- ── gallery command ──────────────────────────────────────────────────────────

--- Open the searchable icon gallery through the canonical lvim-ui picker. Each row shows the
--- glyph + its name; confirming yanks the glyph to the unnamed and `+` registers (handy when
--- authoring another plugin's UI). Never a raw float / vim.ui.* — canon.
---@return nil
function M.gallery()
    local ok, ui = pcall(require, "lvim-ui")
    if not ok then
        vim.notify("lvim-icons: lvim-ui is required for the gallery", vim.log.levels.WARN)
        return
    end
    local icons = M.all()
    ---@type { label: string, icon: string, glyph: string }[]
    local items = {}
    for _, it in ipairs(icons) do
        items[#items + 1] = { label = it.name, icon = it.glyph, glyph = it.glyph }
    end
    ui.select({
        title = "Icons",
        items = items,
        callback = function(confirmed, index)
            if not confirmed or not index then
                return
            end
            local glyph = items[index].glyph
            vim.fn.setreg('"', glyph)
            vim.fn.setreg("+", glyph)
            vim.notify(("lvim-icons: yanked %s (%s)"):format(glyph, items[index].label))
        end,
    })
end

-- ── setup ────────────────────────────────────────────────────────────────────

--- Merge user options into the live config, apply overrides, bind the self-theming highlight
--- factories and register `:LvimIcons`. Optional — the font-mode defaults work without it.
---@param opts LvimIconsConfig?
---@return nil
function M.setup(opts)
    if opts then
        merge(config, opts)
    end
    M.override(config.overrides)

    if registered then
        return
    end
    registered = true

    -- Self-theme: role groups + any brand groups re-derive on ColorScheme / palette sync.
    hl.setup()
    hl.bind(highlights.build)
    hl.bind(highlights.build_brands)

    vim.api.nvim_create_user_command("LvimIcons", function()
        M.gallery()
    end, { desc = "lvim-icons: open the icon gallery" })
end

return M
