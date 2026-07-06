-- lvim-icons.data.extensions: file-extension → icon spec.
-- Keyed by the LOWER-CASE extension (no dot). The resolver tries the full multi-dot tail
-- first (`test.tsx`), then the last extension (`tsx`). Glyphs are stored as CODEPOINTS
-- (`cp`) and materialised with nr2char at load, so the source survives editing (canon §16).
-- `role` names a palette slot (see highlights.lua); `brand` is the upstream colour used
-- only in color_mode = "brand". `name` is the stable icon id (also the svg-overlay key and
-- the gallery label).
--
---@module "lvim-icons.data.extensions"

---@class LvimIconSpec
---@field cp    integer  Nerd Font codepoint (font mode glyph)
---@field role  string   Palette role slot (blue/green/red/cyan/magenta/orange/yellow/purple/teal/fg)
---@field brand string?  Upstream brand hex (#rrggbb) — used only in color_mode = "brand"
---@field name  string   Stable icon id (svg-overlay key + gallery label)

---@type table<string, LvimIconSpec>
return {
    -- ── Lua / Vim ─────────────────────────────────────────────────────────────
    lua = { cp = 0xE620, role = "blue", brand = "#51a0cf", name = "lua" },
    vim = { cp = 0xE62B, role = "green", brand = "#019833", name = "vim" },

    -- ── Web ───────────────────────────────────────────────────────────────────
    html = { cp = 0xE736, role = "orange", brand = "#e34c26", name = "html" },
    htm = { cp = 0xE736, role = "orange", brand = "#e34c26", name = "html" },
    css = { cp = 0xE749, role = "purple", brand = "#563d7c", name = "css" },
    scss = { cp = 0xE603, role = "magenta", brand = "#cc6699", name = "sass" },
    sass = { cp = 0xE603, role = "magenta", brand = "#cc6699", name = "sass" },
    less = { cp = 0xE758, role = "blue", brand = "#563d7c", name = "less" },
    js = { cp = 0xE74E, role = "yellow", brand = "#cbcb41", name = "javascript" },
    mjs = { cp = 0xE74E, role = "yellow", brand = "#cbcb41", name = "javascript" },
    cjs = { cp = 0xE74E, role = "yellow", brand = "#cbcb41", name = "javascript" },
    jsx = { cp = 0xE7BA, role = "cyan", brand = "#20c2e3", name = "react" },
    ts = { cp = 0xE628, role = "blue", brand = "#519aba", name = "typescript" },
    mts = { cp = 0xE628, role = "blue", brand = "#519aba", name = "typescript" },
    cts = { cp = 0xE628, role = "blue", brand = "#519aba", name = "typescript" },
    tsx = { cp = 0xE7BA, role = "cyan", brand = "#519aba", name = "react-ts" },
    vue = { cp = 0xE6A0, role = "green", brand = "#41b883", name = "vue" },
    svelte = { cp = 0xE697, role = "orange", brand = "#ff3e00", name = "svelte" },
    astro = { cp = 0xE6B3, role = "orange", brand = "#ff5d01", name = "astro" },

    -- ── Systems / compiled ────────────────────────────────────────────────────
    c = { cp = 0xE61E, role = "blue", brand = "#599eff", name = "c" },
    h = { cp = 0xE61E, role = "purple", brand = "#a074c4", name = "c-header" },
    cpp = { cp = 0xE61D, role = "blue", brand = "#f34b7d", name = "cpp" },
    cc = { cp = 0xE61D, role = "blue", brand = "#f34b7d", name = "cpp" },
    cxx = { cp = 0xE61D, role = "blue", brand = "#f34b7d", name = "cpp" },
    hpp = { cp = 0xE61D, role = "purple", brand = "#a074c4", name = "cpp-header" },
    rs = { cp = 0xE7A8, role = "orange", brand = "#dea584", name = "rust" },
    go = { cp = 0xE627, role = "cyan", brand = "#00add8", name = "go" },
    zig = { cp = 0xE6A9, role = "orange", brand = "#f7a41d", name = "zig" },
    swift = { cp = 0xE755, role = "orange", brand = "#e37933", name = "swift" },
    dart = { cp = 0xE798, role = "blue", brand = "#03589c", name = "dart" },
    nim = { cp = 0xE677, role = "yellow", brand = "#f3d400", name = "nim" },

    -- ── JVM ───────────────────────────────────────────────────────────────────
    java = { cp = 0xE738, role = "red", brand = "#cc3e44", name = "java" },
    class = { cp = 0xE738, role = "red", brand = "#cc3e44", name = "java" },
    kt = { cp = 0xE634, role = "purple", brand = "#7f52ff", name = "kotlin" },
    kts = { cp = 0xE634, role = "purple", brand = "#7f52ff", name = "kotlin" },
    scala = { cp = 0xE737, role = "red", brand = "#cc3e44", name = "scala" },
    groovy = { cp = 0xE775, role = "blue", brand = "#4298b8", name = "groovy" },

    -- ── Scripting / dynamic ───────────────────────────────────────────────────
    py = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    pyi = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    pyw = { cp = 0xE73C, role = "yellow", brand = "#ffbc03", name = "python" },
    rb = { cp = 0xE739, role = "red", brand = "#701516", name = "ruby" },
    php = { cp = 0xE73D, role = "purple", brand = "#a074c4", name = "php" },
    pl = { cp = 0xE769, role = "blue", brand = "#519aba", name = "perl" },
    r = { cp = 0xE881, role = "green", brand = "#358a5b", name = "r" },
    jl = { cp = 0xE624, role = "purple", brand = "#a270ba", name = "julia" },
    ex = { cp = 0xE62D, role = "purple", brand = "#a074c4", name = "elixir" },
    exs = { cp = 0xE62D, role = "purple", brand = "#a074c4", name = "elixir" },
    erl = { cp = 0xE7B1, role = "magenta", brand = "#b83998", name = "erlang" },
    hs = { cp = 0xE777, role = "purple", brand = "#a074c4", name = "haskell" },
    clj = { cp = 0xE768, role = "green", brand = "#8dc149", name = "clojure" },
    cljs = { cp = 0xE76A, role = "blue", brand = "#519aba", name = "clojurescript" },
    elm = { cp = 0xE62C, role = "cyan", brand = "#60b5cc", name = "elm" },
    lisp = { cp = 0xE690, role = "fg", brand = "#5a6158", name = "lisp" },

    -- ── Shell ─────────────────────────────────────────────────────────────────
    sh = { cp = 0xEBCA, role = "green", brand = "#89e051", name = "shell" },
    bash = { cp = 0xEBCA, role = "green", brand = "#89e051", name = "shell" },
    zsh = { cp = 0xEBCA, role = "green", brand = "#89e051", name = "shell" },
    fish = { cp = 0xEBCA, role = "green", brand = "#89e051", name = "shell" },
    ps1 = { cp = 0xEBC7, role = "blue", brand = "#4273ca", name = "powershell" },

    -- ── Data / config formats ─────────────────────────────────────────────────
    json = { cp = 0xE60B, role = "yellow", brand = "#cbcb41", name = "json" },
    jsonc = { cp = 0xE60B, role = "yellow", brand = "#cbcb41", name = "json" },
    json5 = { cp = 0xE60B, role = "yellow", brand = "#cbcb41", name = "json" },
    yaml = { cp = 0xE6B2, role = "purple", brand = "#cb171e", name = "yaml" },
    yml = { cp = 0xE6B2, role = "purple", brand = "#cb171e", name = "yaml" },
    toml = { cp = 0xE6B2, role = "orange", brand = "#9c4221", name = "toml" },
    xml = { cp = 0xE619, role = "orange", brand = "#e37933", name = "xml" },
    ini = { cp = 0xE615, role = "fg", brand = "#6d8086", name = "config" },
    conf = { cp = 0xE615, role = "fg", brand = "#6d8086", name = "config" },
    cfg = { cp = 0xE615, role = "fg", brand = "#6d8086", name = "config" },
    env = { cp = 0xF462, role = "yellow", brand = "#faf743", name = "env" },
    sql = { cp = 0xE706, role = "blue", brand = "#dad8d8", name = "database" },
    graphql = { cp = 0xE662, role = "magenta", brand = "#e10098", name = "graphql" },
    gql = { cp = 0xE662, role = "magenta", brand = "#e10098", name = "graphql" },
    proto = { cp = 0xE60B, role = "orange", brand = "#e37933", name = "protobuf" },
    csv = { cp = 0xF0EA5, role = "green", brand = "#89e051", name = "csv" },

    -- ── Docs / text ───────────────────────────────────────────────────────────
    md = { cp = 0xE73E, role = "blue", brand = "#519aba", name = "markdown" },
    markdown = { cp = 0xE73E, role = "blue", brand = "#519aba", name = "markdown" },
    mdx = { cp = 0xE73E, role = "yellow", brand = "#519aba", name = "mdx" },
    txt = { cp = 0xF15C, role = "fg", brand = "#6d8086", name = "text" },
    rst = { cp = 0xF15C, role = "fg", brand = "#6d8086", name = "text" },
    org = { cp = 0xE633, role = "green", brand = "#77aa99", name = "org" },
    tex = { cp = 0xE69B, role = "green", brand = "#3d6117", name = "tex" },
    pdf = { cp = 0xF1C1, role = "red", brand = "#b30b00", name = "pdf" },
    log = { cp = 0xF4ED, role = "fg", brand = "#6d8086", name = "log" },
    license = { cp = 0xF0219, role = "yellow", brand = "#cbcb41", name = "license" },

    -- ── Images ────────────────────────────────────────────────────────────────
    png = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    jpg = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    jpeg = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    gif = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    webp = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    bmp = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    ico = { cp = 0xF1C5, role = "magenta", brand = "#a074c4", name = "image" },
    svg = { cp = 0xF0721, role = "orange", brand = "#ffb13b", name = "svg" },

    -- ── Archives ──────────────────────────────────────────────────────────────
    zip = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    tar = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    gz = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    xz = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    bz2 = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    ["7z"] = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },
    rar = { cp = 0xF1C6, role = "orange", brand = "#eca517", name = "archive" },

    -- ── Misc ──────────────────────────────────────────────────────────────────
    lock = { cp = 0xF023, role = "fg", brand = "#6d8086", name = "lock" },
    diff = { cp = 0xF440, role = "orange", brand = "#e37933", name = "diff" },
    patch = { cp = 0xF440, role = "orange", brand = "#e37933", name = "diff" },
    bin = { cp = 0xF471, role = "fg", brand = "#6d8086", name = "binary" },
    wasm = { cp = 0xE6A1, role = "purple", brand = "#654ff0", name = "wasm" },
}
