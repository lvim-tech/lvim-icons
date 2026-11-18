-- lvim-icons.material: the image modes' file / folder icon lookup — the Material Icon Theme's own manifest
-- (assets/material/material-icons.json, the very file VS Code reads), so a file or folder gets exactly the
-- icon it gets in VS Code with that theme.
--
-- Lookup, as VS Code does it:
--   file    exact file name → extension, LONGEST first (`test.ts` before `ts`, `d.ts` before `ts`) →
--           language id (≈ Neovim filetype) → the default `file` icon
--   folder  exact folder name → the default `folder`; an OPEN folder uses the `…Expanded` tables
--           (`folder-git-open`)
-- Names and extensions are matched lower-cased (the manifest's keys are). On a light background the
-- manifest's `light` tables are consulted first.
--
-- The manifest is decoded lazily, on the first lookup (≈4 ms), so nerd mode never pays for it.
--
---@module "lvim-icons.material"

local M = {}

--- The bundled theme directory (…/lvim-icons/assets/material).
M.DIR = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h") .. "/assets/material"

---@type table|false|nil  the decoded manifest (false = unreadable)
local manifest

---@return table?
local function load()
    if manifest == nil then
        manifest = false
        local f = io.open(M.DIR .. "/material-icons.json", "r")
        if f then
            local ok, data = pcall(vim.json.decode, f:read("*a"))
            f:close()
            if ok and type(data) == "table" then
                manifest = data
            end
        end
    end
    return manifest or nil
end

--- Whether the manifest is there and readable.
---@return boolean
function M.available()
    return load() ~= nil
end

--- Look `key` up in table `field`, the light variant first on a light background.
---@param m table
---@param field string
---@param key string
---@return string?
local function pick(m, field, key)
    if vim.o.background == "light" then
        local light = m.light and m.light[field]
        if light and light[key] then
            return light[key]
        end
    end
    local t = m[field]
    return t and t[key] or nil
end

--- The icon id for a FILE named `name` (a path or a basename), with an optional filetype hint.
---@param name? string
---@param filetype? string
---@return string? id
function M.file(name, filetype)
    local m = load()
    if not m then
        return nil
    end
    local base = vim.fn.fnamemodify(name or "", ":t"):lower()
    if base ~= "" then
        local id = pick(m, "fileNames", base)
        if id then
            return id
        end
        -- every dotted tail, longest first: "a.test.ts" → "test.ts", "ts". A dotfile's own name counts as an
        -- extension too (".eslintrc" → "eslintrc"), as in VS Code.
        local parts = vim.split(base, ".", { plain = true })
        for i = 2, #parts do
            id = pick(m, "fileExtensions", table.concat(parts, ".", i))
            if id then
                return id
            end
        end
    end
    if filetype and filetype ~= "" then
        local id = pick(m, "languageIds", filetype)
        if id then
            return id
        end
    end
    return m.file
end

--- The icon id for a file EXTENSION alone (without the dot).
---@param ext string
---@return string? id
function M.extension(ext)
    local m = load()
    if not m then
        return nil
    end
    return pick(m, "fileExtensions", (ext or ""):lower()) or m.file
end

--- The icon id for a FOLDER named `name` (a path or a basename), open or closed.
---@param name? string
---@param open? boolean
---@return string? id
function M.folder(name, open)
    local m = load()
    if not m then
        return nil
    end
    local base = vim.fn.fnamemodify((name or ""):gsub("/+$", ""), ":t"):lower()
    if base ~= "" then
        local id = pick(m, open and "folderNamesExpanded" or "folderNames", base)
        if id then
            return id
        end
    end
    return open and m.folderExpanded or m.folder
end

--- The SVG file of icon `id`, from the manifest's own icon definitions.
---@param id string
---@return string? path
function M.path(id)
    local m = load()
    local def = m and m.iconDefinitions and m.iconDefinitions[id]
    if not (def and def.iconPath) then
        return nil
    end
    -- "./../icons/rust.svg" — the bundle keeps the SVGs flat beside the manifest
    return M.DIR .. "/" .. vim.fn.fnamemodify(def.iconPath, ":t")
end

--- Every icon id the manifest defines (for health / tests).
---@return string[]
function M.ids()
    local m = load()
    local out = {}
    for id in pairs(m and m.iconDefinitions or {}) do
        out[#out + 1] = id
    end
    table.sort(out)
    return out
end

return M
