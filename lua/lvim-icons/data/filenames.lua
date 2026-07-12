-- lvim-icons.data.filenames: full-filename → icon spec.
-- Keyed by the EXACT basename (case-sensitive where the convention is, e.g. `Makefile`).
-- Tried BEFORE the extension chain, so `docker-compose.yml` beats the `yml` rule. Same
-- spec shape as data/extensions.lua.
--
---@module "lvim-icons.data.filenames"

---@type table<string, LvimIconSpec>
return {
    -- ── Git ───────────────────────────────────────────────────────────────────
    [".gitignore"] = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    [".gitattributes"] = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    [".gitconfig"] = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    [".gitmodules"] = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    ["COMMIT_EDITMSG"] = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },

    -- ── Docker ────────────────────────────────────────────────────────────────
    ["Dockerfile"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    ["dockerfile"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    [".dockerignore"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    ["docker-compose.yml"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    ["docker-compose.yaml"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    ["compose.yml"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    ["compose.yaml"] = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },

    -- ── Build systems ─────────────────────────────────────────────────────────
    ["Makefile"] = { glyph = "", role = "orange", brand = "#6d8086", name = "makefile" },
    ["makefile"] = { glyph = "", role = "orange", brand = "#6d8086", name = "makefile" },
    ["CMakeLists.txt"] = { glyph = "", role = "green", brand = "#649ad2", name = "cmake" },
    ["Cargo.toml"] = { glyph = "", role = "orange", brand = "#dea584", name = "rust" },
    ["Cargo.lock"] = { glyph = "", role = "fg", brand = "#dea584", name = "rust" },
    ["go.mod"] = { glyph = "", role = "cyan", brand = "#00add8", name = "go" },
    ["go.sum"] = { glyph = "", role = "fg", brand = "#00add8", name = "go" },
    ["package.json"] = { glyph = "", role = "red", brand = "#e8274b", name = "npm" },
    ["package-lock.json"] = { glyph = "", role = "fg", brand = "#7a0d21", name = "npm" },
    ["pnpm-lock.yaml"] = { glyph = "", role = "yellow", brand = "#f9ad00", name = "pnpm" },
    ["yarn.lock"] = { glyph = "", role = "blue", brand = "#2c8ebb", name = "yarn" },
    ["justfile"] = { glyph = "", role = "yellow", brand = "#6d8086", name = "just" },
    ["Justfile"] = { glyph = "", role = "yellow", brand = "#6d8086", name = "just" },

    -- ── Tooling config ────────────────────────────────────────────────────────
    [".editorconfig"] = { glyph = "", role = "fg", brand = "#6d8086", name = "editorconfig" },
    [".prettierrc"] = { glyph = "", role = "cyan", brand = "#56b3b4", name = "prettier" },
    [".eslintrc"] = { glyph = "", role = "purple", brand = "#4b32c3", name = "eslint" },
    ["stylua.toml"] = { glyph = "", role = "blue", brand = "#51a0cf", name = "lua" },
    [".luacheckrc"] = { glyph = "", role = "blue", brand = "#51a0cf", name = "lua" },
    ["tsconfig.json"] = { glyph = "", role = "blue", brand = "#519aba", name = "typescript" },
    [".nvmrc"] = { glyph = "", role = "green", brand = "#5fa04e", name = "node" },

    -- ── Docs ──────────────────────────────────────────────────────────────────
    ["README.md"] = { glyph = "󰋒", role = "yellow", brand = "#519aba", name = "readme" },
    ["readme.md"] = { glyph = "󰋒", role = "yellow", brand = "#519aba", name = "readme" },
    ["LICENSE"] = { glyph = "󰈙", role = "yellow", brand = "#cbcb41", name = "license" },
    ["LICENSE.md"] = { glyph = "󰈙", role = "yellow", brand = "#cbcb41", name = "license" },
    ["CHANGELOG.md"] = { glyph = "󰦛", role = "green", brand = "#519aba", name = "changelog" },
    ["CONTRIBUTING.md"] = { glyph = "󰋒", role = "cyan", brand = "#519aba", name = "readme" },
    ["AUTHORS"] = { glyph = "󰈙", role = "yellow", brand = "#cbcb41", name = "authors" },

    -- ── Ruby / Python / PHP project files ─────────────────────────────────────
    ["Gemfile"] = { glyph = "", role = "red", brand = "#701516", name = "ruby" },
    ["Gemfile.lock"] = { glyph = "", role = "fg", brand = "#701516", name = "ruby" },
    ["Rakefile"] = { glyph = "", role = "red", brand = "#701516", name = "ruby" },
    ["requirements.txt"] = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    ["pyproject.toml"] = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    ["Pipfile"] = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    ["setup.py"] = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    ["composer.json"] = { glyph = "", role = "purple", brand = "#a074c4", name = "php" },

    -- ── CI / infra / containers ───────────────────────────────────────────────
    ["Vagrantfile"] = { glyph = "", role = "cyan", brand = "#1563ff", name = "vagrant" },
    ["Procfile"] = { glyph = "", role = "purple", brand = "#a074c4", name = "heroku" },
    ["Jenkinsfile"] = { glyph = "", role = "red", brand = "#d33833", name = "jenkins" },
    [".gitlab-ci.yml"] = { glyph = "", role = "orange", brand = "#e24329", name = "gitlab" },
    [".travis.yml"] = { glyph = "", role = "red", brand = "#cb4f4f", name = "travis" },
    ["flake.nix"] = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" },
    ["shell.nix"] = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" },
    ["default.nix"] = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" },

    -- ── Node / JS tooling ─────────────────────────────────────────────────────
    ["bun.lockb"] = { glyph = "", role = "fg", brand = "#fbf0df", name = "bun" },
    [".babelrc"] = { glyph = "", role = "yellow", brand = "#f5da55", name = "babel" },
    ["babel.config.js"] = { glyph = "", role = "yellow", brand = "#f5da55", name = "babel" },
    ["webpack.config.js"] = { glyph = "󰜫", role = "cyan", brand = "#519aba", name = "webpack" },
    ["vite.config.js"] = { glyph = "󰨡", role = "purple", brand = "#646cff", name = "vite" },
    ["vite.config.ts"] = { glyph = "󰨡", role = "purple", brand = "#646cff", name = "vite" },
    ["tailwind.config.js"] = { glyph = "󱏿", role = "cyan", brand = "#38bdf8", name = "tailwind" },
    [".prettierignore"] = { glyph = "", role = "cyan", brand = "#56b3b4", name = "prettier" },
    [".eslintignore"] = { glyph = "", role = "purple", brand = "#4b32c3", name = "eslint" },
}
