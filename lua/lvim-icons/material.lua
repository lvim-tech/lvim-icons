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
M.BUNDLE = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h") .. "/assets/material"

--- The SHARED place of the set, one for every lvim program: lvim-icons here, lvim-fuzzy (`lfz`) and
--- lvim-commander (`lvc`) in the terminal — `$XDG_DATA_HOME/lvim-icons/material`. Each of them carries the
--- set and puts it there when it is missing or older (never a downgrade); each reads it from there.
M.SHARED = ((vim.env.XDG_DATA_HOME ~= nil and vim.env.XDG_DATA_HOME ~= "") and vim.env.XDG_DATA_HOME
    or (vim.env.HOME .. "/.local/share")) .. "/lvim-icons/material"

--- Where the set is read from: the shared place once `sync` found it current, else the bundle.
M.DIR = M.BUNDLE

---@type table|false|nil  the decoded manifest (false = unreadable)
local manifest

---@param dir string
---@return string?
local function version_of(dir)
    local f = io.open(dir .. "/VERSION", "r")
    if not f then
        return nil
    end
    local v = vim.trim(f:read("*a") or "")
    f:close()
    return v ~= "" and v or nil
end

--- `a` is a newer version than `b` (numerically, part by part: 5.40.0 > 5.9.9).
---@param a string
---@param b string
---@return boolean
local function newer(a, b)
    local pa, pb = vim.split(a, ".", { plain = true }), vim.split(b, ".", { plain = true })
    for i = 1, math.max(#pa, #pb) do
        local x, y = tonumber(pa[i]) or 0, tonumber(pb[i]) or 0
        if x ~= y then
            return x > y
        end
    end
    return false
end
M._newer = newer -- test seam

--- Copy the bundle into the shared place, atomically: into a sibling directory first, then swapped in with
--- renames, so a program reading it (or installing at the same moment) never sees half a set.
---@return boolean ok
local function install_shared()
    local parent = vim.fn.fnamemodify(M.SHARED, ":h")
    vim.fn.mkdir(parent, "p")
    local pid = vim.uv.os_getpid()
    local tmp = ("%s/.material-new-%d"):format(parent, pid)
    local old = ("%s/.material-old-%d"):format(parent, pid)
    vim.fn.delete(tmp, "rf")
    if vim.fn.mkdir(tmp, "p") == 0 then
        return false
    end
    local scan = vim.uv.fs_scandir(M.BUNDLE)
    while scan do
        local name, kind = vim.uv.fs_scandir_next(scan)
        if not name then
            break
        end
        if kind == "file" and not vim.uv.fs_copyfile(M.BUNDLE .. "/" .. name, tmp .. "/" .. name) then
            vim.fn.delete(tmp, "rf")
            return false
        end
    end
    local had = vim.uv.fs_stat(M.SHARED) ~= nil
    if had and not vim.uv.fs_rename(M.SHARED, old) then
        vim.fn.delete(tmp, "rf")
        return false
    end
    if not vim.uv.fs_rename(tmp, M.SHARED) then
        if had then
            vim.uv.fs_rename(old, M.SHARED)
        end
        vim.fn.delete(tmp, "rf")
        return false
    end
    if had then
        vim.fn.delete(old, "rf")
    end
    return true
end

local synced = false

--- Test seam: forget that `sync` ran (and the decoded manifest).
function M._reset_sync()
    synced = false
    manifest = nil
    M.DIR = M.BUNDLE
end

--- Bring the shared place up to the bundle (when it is missing there or older) and read from it when it
--- is at least as new as the bundle; else read the bundle. Once per session (cheap: two small files).
function M.sync()
    if synced then
        return
    end
    synced = true
    local bv = version_of(M.BUNDLE)
    local sv = version_of(M.SHARED)
    local have_json = vim.uv.fs_stat(M.SHARED .. "/material-icons.json") ~= nil
    if bv and (not sv or not have_json or newer(bv, sv)) then
        pcall(install_shared)
        sv = version_of(M.SHARED)
    end
    local dir = M.BUNDLE
    if sv and vim.uv.fs_stat(M.SHARED .. "/material-icons.json") and (not bv or not newer(bv, sv)) then
        dir = M.SHARED
    end
    if dir ~= M.DIR then
        M.DIR = dir
        manifest = nil
    end
end

---@return table?
local function load()
    M.sync()
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
