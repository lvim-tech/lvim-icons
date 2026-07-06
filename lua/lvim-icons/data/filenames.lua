-- lvim-icons.data.filenames: full-filename → icon spec.
-- Keyed by the EXACT basename (case-sensitive where the convention is, e.g. `Makefile`).
-- Tried BEFORE the extension chain, so `docker-compose.yml` beats the `yml` rule. Same
-- spec shape as data/extensions.lua.
--
---@module "lvim-icons.data.filenames"

---@type table<string, LvimIconSpec>
return {
    -- ── Git ───────────────────────────────────────────────────────────────────
    [".gitignore"] = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    [".gitattributes"] = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    [".gitconfig"] = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    [".gitmodules"] = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    ["COMMIT_EDITMSG"] = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },

    -- ── Docker ────────────────────────────────────────────────────────────────
    ["Dockerfile"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    ["dockerfile"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    [".dockerignore"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    ["docker-compose.yml"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    ["docker-compose.yaml"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    ["compose.yml"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    ["compose.yaml"] = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },

    -- ── Build systems ─────────────────────────────────────────────────────────
    ["Makefile"] = { cp = 0xE673, role = "orange", brand = "#6d8086", name = "makefile" },
    ["makefile"] = { cp = 0xE673, role = "orange", brand = "#6d8086", name = "makefile" },
    ["CMakeLists.txt"] = { cp = 0xE794, role = "green", brand = "#649ad2", name = "cmake" },
    ["Cargo.toml"] = { cp = 0xE7A8, role = "orange", brand = "#dea584", name = "rust" },
    ["Cargo.lock"] = { cp = 0xE7A8, role = "fg", brand = "#dea584", name = "rust" },
    ["go.mod"] = { cp = 0xE627, role = "cyan", brand = "#00add8", name = "go" },
    ["go.sum"] = { cp = 0xE627, role = "fg", brand = "#00add8", name = "go" },
    ["package.json"] = { cp = 0xE718, role = "red", brand = "#e8274b", name = "npm" },
    ["package-lock.json"] = { cp = 0xE718, role = "fg", brand = "#7a0d21", name = "npm" },
    ["pnpm-lock.yaml"] = { cp = 0xE718, role = "yellow", brand = "#f9ad00", name = "pnpm" },
    ["yarn.lock"] = { cp = 0xE718, role = "blue", brand = "#2c8ebb", name = "yarn" },
    ["justfile"] = { cp = 0xE673, role = "yellow", brand = "#6d8086", name = "just" },
    ["Justfile"] = { cp = 0xE673, role = "yellow", brand = "#6d8086", name = "just" },

    -- ── Tooling config ────────────────────────────────────────────────────────
    [".editorconfig"] = { cp = 0xE652, role = "fg", brand = "#6d8086", name = "editorconfig" },
    [".prettierrc"] = { cp = 0xE6B4, role = "cyan", brand = "#56b3b4", name = "prettier" },
    [".eslintrc"] = { cp = 0xE655, role = "purple", brand = "#4b32c3", name = "eslint" },
    ["stylua.toml"] = { cp = 0xE620, role = "blue", brand = "#51a0cf", name = "lua" },
    [".luacheckrc"] = { cp = 0xE620, role = "blue", brand = "#51a0cf", name = "lua" },
    ["tsconfig.json"] = { cp = 0xE628, role = "blue", brand = "#519aba", name = "typescript" },
    [".nvmrc"] = { cp = 0xE718, role = "green", brand = "#5fa04e", name = "node" },

    -- ── Docs ──────────────────────────────────────────────────────────────────
    ["README.md"] = { cp = 0xF02D2, role = "yellow", brand = "#519aba", name = "readme" },
    ["readme.md"] = { cp = 0xF02D2, role = "yellow", brand = "#519aba", name = "readme" },
    ["LICENSE"] = { cp = 0xF0219, role = "yellow", brand = "#cbcb41", name = "license" },
    ["LICENSE.md"] = { cp = 0xF0219, role = "yellow", brand = "#cbcb41", name = "license" },
    ["CHANGELOG.md"] = { cp = 0xF099B, role = "green", brand = "#519aba", name = "changelog" },
}
