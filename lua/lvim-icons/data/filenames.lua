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
    ["CONTRIBUTING.md"] = { cp = 0xF02D2, role = "cyan", brand = "#519aba", name = "readme" },
    ["AUTHORS"] = { cp = 0xF0219, role = "yellow", brand = "#cbcb41", name = "authors" },

    -- ── Ruby / Python / PHP project files ─────────────────────────────────────
    ["Gemfile"] = { cp = 0xE739, role = "red", brand = "#701516", name = "ruby" },
    ["Gemfile.lock"] = { cp = 0xE739, role = "fg", brand = "#701516", name = "ruby" },
    ["Rakefile"] = { cp = 0xE739, role = "red", brand = "#701516", name = "ruby" },
    ["requirements.txt"] = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    ["pyproject.toml"] = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    ["Pipfile"] = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    ["setup.py"] = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    ["composer.json"] = { cp = 0xE73D, role = "purple", brand = "#a074c4", name = "php" },

    -- ── CI / infra / containers ───────────────────────────────────────────────
    ["Vagrantfile"] = { cp = 0xE62A, role = "cyan", brand = "#1563ff", name = "vagrant" },
    ["Procfile"] = { cp = 0xE607, role = "purple", brand = "#a074c4", name = "heroku" },
    ["Jenkinsfile"] = { cp = 0xE767, role = "red", brand = "#d33833", name = "jenkins" },
    [".gitlab-ci.yml"] = { cp = 0xF296, role = "orange", brand = "#e24329", name = "gitlab" },
    [".travis.yml"] = { cp = 0xE77E, role = "red", brand = "#cb4f4f", name = "travis" },
    ["flake.nix"] = { cp = 0xF313, role = "blue", brand = "#7ebae4", name = "nix" },
    ["shell.nix"] = { cp = 0xF313, role = "blue", brand = "#7ebae4", name = "nix" },
    ["default.nix"] = { cp = 0xF313, role = "blue", brand = "#7ebae4", name = "nix" },

    -- ── Node / JS tooling ─────────────────────────────────────────────────────
    ["bun.lockb"] = { cp = 0xE76F, role = "fg", brand = "#fbf0df", name = "bun" },
    [".babelrc"] = { cp = 0xE639, role = "yellow", brand = "#f5da55", name = "babel" },
    ["babel.config.js"] = { cp = 0xE639, role = "yellow", brand = "#f5da55", name = "babel" },
    ["webpack.config.js"] = { cp = 0xF072B, role = "cyan", brand = "#519aba", name = "webpack" },
    ["vite.config.js"] = { cp = 0xF0A21, role = "purple", brand = "#646cff", name = "vite" },
    ["vite.config.ts"] = { cp = 0xF0A21, role = "purple", brand = "#646cff", name = "vite" },
    ["tailwind.config.js"] = { cp = 0xF13FF, role = "cyan", brand = "#38bdf8", name = "tailwind" },
    [".prettierignore"] = { cp = 0xE6B4, role = "cyan", brand = "#56b3b4", name = "prettier" },
    [".eslintignore"] = { cp = 0xE655, role = "purple", brand = "#4b32c3", name = "eslint" },
}
