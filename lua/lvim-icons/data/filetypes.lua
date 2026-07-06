-- lvim-icons.data.filetypes: neovim filetype → icon spec.
-- The last resort of the resolver chain (after filename + extension) AND the direct answer
-- when a caller passes `opts.filetype` for a buffer with no meaningful name (help, qf,
-- terminal, pickers). Keyed by the `&filetype` value. Same spec shape as
-- data/extensions.lua; many reuse a language's glyph, some are UI-only filetypes.
--
---@module "lvim-icons.data.filetypes"

---@type table<string, LvimIconSpec>
return {
    -- ── Neovim / editor UI filetypes ──────────────────────────────────────────
    help = { cp = 0xF059, role = "green", brand = "#77aa99", name = "help" },
    qf = { cp = 0xF0EDF, role = "blue", brand = "#519aba", name = "quickfix" },
    checkhealth = { cp = 0xF004, role = "red", brand = "#cb4f4f", name = "health" },
    lazy = { cp = 0xF0EA6, role = "purple", brand = "#a074c4", name = "plugins" },
    gitcommit = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    gitrebase = { cp = 0xE702, role = "orange", brand = "#f14e32", name = "git" },
    NvimTree = { cp = 0xF07C, role = "blue", brand = "#519aba", name = "folder" },
    TelescopePrompt = { cp = 0xF002, role = "blue", brand = "#519aba", name = "search" },
    terminal = { cp = 0xF489, role = "green", brand = "#89e051", name = "terminal" },

    -- ── Language filetypes not covered by an extension key ─────────────────────
    lua = { cp = 0xE620, role = "blue", brand = "#51a0cf", name = "lua" },
    python = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    rust = { cp = 0xE7A8, role = "orange", brand = "#dea584", name = "rust" },
    go = { cp = 0xE627, role = "cyan", brand = "#00add8", name = "go" },
    javascript = { cp = 0xE74E, role = "yellow", brand = "#cbcb41", name = "javascript" },
    typescript = { cp = 0xE628, role = "blue", brand = "#519aba", name = "typescript" },
    javascriptreact = { cp = 0xE7BA, role = "cyan", brand = "#20c2e3", name = "react" },
    typescriptreact = { cp = 0xE7BA, role = "cyan", brand = "#519aba", name = "react-ts" },
    markdown = { cp = 0xE73E, role = "blue", brand = "#519aba", name = "markdown" },
    vim = { cp = 0xE62B, role = "green", brand = "#019833", name = "vim" },
    sh = { cp = 0xEBCA, role = "green", brand = "#89e051", name = "shell" },
    c = { cp = 0xE61E, role = "blue", brand = "#599eff", name = "c" },
    cpp = { cp = 0xE61D, role = "blue", brand = "#f34b7d", name = "cpp" },
    json = { cp = 0xE60B, role = "yellow", brand = "#cbcb41", name = "json" },
    yaml = { cp = 0xE6B2, role = "purple", brand = "#cb171e", name = "yaml" },
    toml = { cp = 0xE6B2, role = "orange", brand = "#9c4221", name = "toml" },
    html = { cp = 0xE736, role = "orange", brand = "#e34c26", name = "html" },
    css = { cp = 0xE749, role = "purple", brand = "#563d7c", name = "css" },
    sql = { cp = 0xE706, role = "blue", brand = "#dad8d8", name = "database" },
    dockerfile = { cp = 0xF0868, role = "blue", brand = "#458ee6", name = "docker" },
    make = { cp = 0xE673, role = "orange", brand = "#6d8086", name = "makefile" },
}
