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
    help = { glyph = "", role = "green", brand = "#77aa99", name = "help" },
    qf = { glyph = "󰻟", role = "blue", brand = "#519aba", name = "quickfix" },
    checkhealth = { glyph = "", role = "red", brand = "#cb4f4f", name = "health" },
    gitcommit = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    gitrebase = { glyph = "", role = "orange", brand = "#f14e32", name = "git" },
    terminal = { glyph = "", role = "green", brand = "#89e051", name = "terminal" },

    -- ── Language filetypes not covered by an extension key ─────────────────────
    lua = { glyph = "", role = "blue", brand = "#51a0cf", name = "lua" },
    python = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    rust = { glyph = "", role = "orange", brand = "#dea584", name = "rust" },
    go = { glyph = "", role = "cyan", brand = "#00add8", name = "go" },
    javascript = { glyph = "", role = "yellow", brand = "#cbcb41", name = "javascript" },
    typescript = { glyph = "", role = "blue", brand = "#519aba", name = "typescript" },
    javascriptreact = { glyph = "", role = "cyan", brand = "#20c2e3", name = "react" },
    typescriptreact = { glyph = "", role = "cyan", brand = "#519aba", name = "react-ts" },
    markdown = { glyph = "", role = "blue", brand = "#519aba", name = "markdown" },
    vim = { glyph = "", role = "green", brand = "#019833", name = "vim" },
    sh = { glyph = "", role = "green", brand = "#89e051", name = "shell" },
    c = { glyph = "", role = "blue", brand = "#599eff", name = "c" },
    cpp = { glyph = "", role = "blue", brand = "#f34b7d", name = "cpp" },
    json = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    yaml = { glyph = "", role = "purple", brand = "#cb171e", name = "yaml" },
    toml = { glyph = "", role = "orange", brand = "#9c4221", name = "toml" },
    html = { glyph = "", role = "orange", brand = "#e34c26", name = "html" },
    css = { glyph = "", role = "purple", brand = "#563d7c", name = "css" },
    sql = { glyph = "", role = "blue", brand = "#dad8d8", name = "database" },
    dockerfile = { glyph = "󰡨", role = "blue", brand = "#458ee6", name = "docker" },
    make = { glyph = "", role = "orange", brand = "#6d8086", name = "makefile" },
}
