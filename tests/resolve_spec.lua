-- The lookup chain, which every tree, picker and tab line in the set depends on for its icons:
--   an explicit kind  →  the exact filename  →  the extension (longest dotted tail first)
--   →  the filetype  →  the default.
-- Asserted by each spec's stable `name`, never by the glyph, so the test says what it means and a
-- reglyphing does not break it.

local icons = require("lvim-icons")
local resolve = require("lvim-icons.resolve")
local T = resolve.tables()

--- Add icon overrides for the duration of `fn`, then put the touched keys back.
---@param overrides table
---@param fn fun()
local function with_overrides(overrides, fn)
    local saved = {}
    for group, entries in pairs(overrides) do
        saved[group] = {}
        for key in pairs(entries) do
            saved[group][key] = T[group][key]
        end
    end
    icons.override(overrides)
    local ok, err = pcall(fn)
    for group, entries in pairs(saved) do
        for key, value in pairs(entries) do
            T[group][key] = value
        end
    end
    if not ok then
        error(err, 0)
    end
end

describe("lvim-icons.resolve: the lookup chain")

it("an exact filename beats the extension", function()
    -- package.json is npm's icon, not JSON's.
    eq("npm", resolve.spec_for("package.json").name)
    eq("npm", resolve.spec_for("/home/someone/project/package.json").name, "a full path resolves by basename")
end)

it("the extension answers when the name is not mapped", function()
    eq("lua", resolve.spec_for("init.lua").name)
    eq("lua", resolve.spec_for("/tmp/whatever/some_module.lua").name)
end)

it("the STEM of a name is never read as an extension", function()
    -- A file literally called `lua` must not become the Lua icon: the chain starts at the first
    -- DOT, so a name with no dot has no extension at all.
    local default = require("lvim-icons.config").default.name
    eq(default, resolve.spec_for("lua").name)
    eq(default, resolve.spec_for("json").name)
end)

it("a dotfile's tail IS its extension", function()
    -- `.env` splits to { "", "env" }, so the chain finds the env icon — devicons parity.
    eq(T.extensions.env.name, resolve.spec_for(".env").name)
end)

it("the longest dotted tail wins over the last extension", function()
    with_overrides({ extensions = { ["tar.gz"] = { glyph = "T", role = "red", name = "tarball" } } }, function()
        eq("tarball", resolve.spec_for("archive.tar.gz").name, "tar.gz must beat gz")
        eq(T.extensions.gz.name, resolve.spec_for("archive.gz").name, "a plain .gz still resolves to gz")
    end)
end)

it("matches an extension whatever its case", function()
    eq("lua", resolve.spec_for("FILE.LUA").name)
    eq("lua", resolve.spec_for("File.Lua").name)
end)

it("an explicit kind short-circuits the whole chain", function()
    eq(T.special.directory.name, resolve.spec_for("misleading.lua", { kind = "directory" }).name)
    eq(T.special.directory.name, resolve.spec_for("", { kind = "directory" }).name)
end)

it("the filetype is the last resort, not the first", function()
    eq(T.filetypes.help.name, resolve.spec_for("", { filetype = "help" }).name, "no name to go by")
    eq("lua", resolve.spec_for("init.lua", { filetype = "help" }).name, "a known name beats the filetype")
end)

it("always returns a renderable spec, never nil", function()
    local default = require("lvim-icons.config").default.name
    for _, name in ipairs({ "", "no-such-file.qqq", "weird.", ".", "..", "/" }) do
        local spec = resolve.spec_for(name)
        truthy(spec and spec.name, "nil spec for " .. vim.inspect(name))
        truthy(spec.glyph ~= nil, "no glyph for " .. vim.inspect(name))
    end
    eq(default, resolve.spec_for("no-such-file.qqq").name)
end)

describe("lvim-icons.override")

it("merges into a built-in spec instead of replacing it", function()
    with_overrides({ extensions = { lua = { glyph = "L" } } }, function()
        local spec = resolve.spec_for("init.lua")
        eq("L", spec.glyph, "the glyph was overridden")
        eq("lua", spec.name, "the name survived")
        eq("blue", spec.role, "the role survived")
    end)
end)

it("adds a new extension nobody shipped", function()
    with_overrides({ extensions = { zzz = { glyph = "Z", role = "fg", name = "zzz" } } }, function()
        eq("zzz", resolve.spec_for("file.zzz").name)
    end)
end)

describe("lvim-icons.resolve.materialise")

it("gives a caller everything it needs to draw one cell", function()
    local got = resolve.materialise(T.extensions.lua, { color_mode = "theme" })
    for _, key in ipairs({ "glyph", "hl", "color", "width", "name" }) do
        truthy(got[key] ~= nil, "no " .. key .. " in " .. vim.inspect(got))
    end
    eq("lua", got.name)
end)

it("colours by the palette role or by the brand, as asked", function()
    local theme = resolve.materialise(T.extensions.lua, { color_mode = "theme" })
    local brand = resolve.materialise(T.extensions.lua, { color_mode = "brand" })
    truthy(theme.hl ~= brand.hl, "theme and brand must not resolve to one group: " .. theme.hl)
end)

it("falls back to fg when an override names a role no palette has", function()
    local got = resolve.materialise({ glyph = "X", role = "chartreuse", name = "x" }, { color_mode = "theme" })
    eq(require("lvim-icons.highlights").role_group("fg"), got.hl)
    truthy(got.color ~= nil, "a colour is still resolved")
end)
