-- image modes picks icons the way VS Code does with the Material Icon Theme: from the theme's own manifest.
-- Every expected id below is read off assets/material/material-icons.json.

local material = require("lvim-icons.material")

describe("lvim-icons.material: folders")

it("a known folder name has its own icon, open and closed", function()
    eq("folder-git", material.folder(".git"))
    eq("folder-git-open", material.folder(".git", true))
    eq("folder-src", material.folder("src"))
    eq("folder-claude", material.folder(".claude"), "hidden folders are names like any other")
    eq("folder-node", material.folder("node_modules"))
end)

it("matches the folder's own name, from a path, ignoring case and a trailing slash", function()
    eq("folder-docs", material.folder("/home/someone/project/Docs/"))
end)

it("an unknown folder is the theme's default folder", function()
    eq("folder", material.folder("zzz-unknown"))
    eq("folder-open", material.folder("zzz-unknown", true))
end)

describe("lvim-icons.material: files")

it("an exact file name beats its extension", function()
    eq("nodejs", material.file("package.json"), "not json")
    eq("git", material.file(".gitignore"))
    eq("docker", material.file("Dockerfile"))
end)

it("the longest extension wins", function()
    eq("test-ts", material.file("app.test.ts"))
    eq("typescript-def", material.file("types.d.ts"))
    eq("typescript", material.file("main.ts"))
    eq("rust", material.file("src/main.rs"))
end)

it("the filetype answers when the name does not", function()
    eq("python", material.file("script", "python"))
end)

it("anything else is the theme's default file", function()
    eq("file", material.file("x.qqq"))
    eq("file", material.file(""))
end)

it("every id resolves to a bundled SVG", function()
    for _, id in ipairs({ "folder-git-open", "test-ts", "nodejs", "file", "folder" }) do
        local path = material.path(id)
        truthy(path and vim.uv.fs_stat(path), id .. " → " .. tostring(path))
    end
end)

describe("lvim-icons: the image modes resolve through the manifest")

it("a directory kind gets the Material folder of its name", function()
    local svg = require("lvim-icons.svg")
    local asked = {}
    local orig_icon, orig_images, orig_mode = svg.icon, svg.images, svg.mode
    svg.icon = function(id)
        asked[#asked + 1] = id
        return nil
    end
    svg.images = function()
        return true
    end
    svg.mode = function()
        return "mix"
    end
    local icons = require("lvim-icons")
    icons.get(".git", { kind = "directory" })
    icons.get(".git", { kind = "directory_open" })
    icons.get("app.test.ts")
    svg.icon, svg.images, svg.mode = orig_icon, orig_images, orig_mode
    eq({ "folder-git", "folder-git-open", "test-ts" }, asked)
end)

describe("lvim-icons.material: the shared place")

it("puts the bundle into the shared place and reads from there", function()
    material._reset_sync()
    vim.fn.delete(material.SHARED, "rf")
    material.sync()
    truthy(vim.uv.fs_stat(material.SHARED .. "/material-icons.json"), "installed")
    eq(material.SHARED, material.DIR, "read from the shared place")
    truthy(vim.uv.fs_stat(material.path("rust")), "an SVG from there")
end)

it("rewrites an older shared set, never a newer one", function()
    local function version()
        local f = assert(io.open(material.SHARED .. "/VERSION"))
        local v = vim.trim(f:read("*a"))
        f:close()
        return v
    end
    local function set_version(v)
        local f = assert(io.open(material.SHARED .. "/VERSION", "w"))
        f:write(v .. "\n")
        f:close()
    end
    local bundle = vim.trim(assert(io.open(material.BUNDLE .. "/VERSION")):read("*a"))
    set_version("0.1.0")
    material._reset_sync()
    material.sync()
    eq(bundle, version(), "older → replaced")
    set_version("999.0.0")
    material._reset_sync()
    material.sync()
    eq("999.0.0", version(), "newer → kept")
    eq(material.SHARED, material.DIR, "and read")
    truthy(material._newer("5.40.0", "5.9.9"))
end)
