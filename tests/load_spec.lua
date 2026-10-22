-- Every module and every data table loads on its own. The data files are plain returns, so a
-- syntax slip or a duplicate key in one of 1 000+ entries would otherwise only show when a tree
-- cell asked for that one icon.

local root = PLUGIN_ROOT .. "/lua/lvim-icons"

---@return string[]
local function modules()
    local out = {}
    local function walk(dir, prefix)
        for name, kind in vim.fs.dir(dir) do
            if kind == "directory" then
                walk(dir .. "/" .. name, prefix .. name .. ".")
            elseif name:match("%.lua$") then
                local stem = name:sub(1, -5)
                out[#out + 1] = stem == "init" and prefix:sub(1, -2) or (prefix .. stem)
            end
        end
    end
    walk(root, "lvim-icons.")
    table.sort(out)
    return out
end

describe("lvim-icons: every module loads")

for _, mod in ipairs(modules()) do
    it(mod, function()
        local ok, err = pcall(require, mod)
        truthy(ok, tostring(err))
    end)
end

describe("lvim-icons: the data tables are whole")

local T = require("lvim-icons.resolve").tables()

for _, group in ipairs({ "extensions", "filenames", "filetypes", "special" }) do
    it(group .. " holds renderable specs", function()
        local n = 0
        for key, spec in pairs(T[group]) do
            n = n + 1
            truthy(type(key) == "string" and key ~= "", "a non-string key in " .. group)
            truthy(type(spec) == "table", group .. "." .. key .. " is not a table")
            truthy(type(spec.glyph) == "string" and spec.glyph ~= "", group .. "." .. key .. " has no glyph")
            truthy(type(spec.name) == "string" and spec.name ~= "", group .. "." .. key .. " has no name")
            truthy(type(spec.role) == "string" and spec.role ~= "", group .. "." .. key .. " has no role")
            if spec.brand ~= nil then
                truthy(
                    spec.brand:match("^#%x%x%x%x%x%x$") ~= nil,
                    group .. "." .. key .. " has a malformed brand hex: " .. tostring(spec.brand)
                )
            end
        end
        truthy(n > 0, group .. " is empty")
    end)
end
