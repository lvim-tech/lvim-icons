-- lvim-icons.data.extensions: file-extension → icon spec.
-- Keyed by the LOWER-CASE extension (no dot). The resolver tries the full multi-dot tail
-- first (`test.tsx`), then the last extension (`tsx`). Glyphs are stored as REAL Nerd Font
-- characters (`glyph`) right in the source.
-- `role` names a palette slot (see highlights.lua); `brand` is the upstream colour used
-- only in color_mode = "brand". `name` is the stable icon id (also the svg-overlay key and
-- the gallery label).
--
---@module "lvim-icons.data.extensions"

---@class LvimIconSpec
---@field glyph string   Nerd Font glyph (font mode)
---@field role  string   Palette role slot (blue/green/red/cyan/magenta/orange/yellow/purple/teal/fg)
---@field brand string?  Upstream brand hex (#rrggbb) — used only in color_mode = "brand"
---@field name  string   Stable icon id (svg-overlay key + gallery label)

---@type table<string, LvimIconSpec>
return {
    -- ── Lua / Vim ─────────────────────────────────────────────────────────────
    lua = { glyph = "", role = "blue", brand = "#51a0cf", name = "lua" },
    vim = { glyph = "", role = "green", brand = "#019833", name = "vim" },

    -- ── Web ───────────────────────────────────────────────────────────────────
    html = { glyph = "", role = "orange", brand = "#e34c26", name = "html" },
    htm = { glyph = "", role = "orange", brand = "#e34c26", name = "html" },
    css = { glyph = "", role = "purple", brand = "#563d7c", name = "css" },
    scss = { glyph = "", role = "magenta", brand = "#cc6699", name = "sass" },
    sass = { glyph = "", role = "magenta", brand = "#cc6699", name = "sass" },
    less = { glyph = "", role = "blue", brand = "#563d7c", name = "less" },
    js = { glyph = "", role = "yellow", brand = "#cbcb41", name = "javascript" },
    mjs = { glyph = "", role = "yellow", brand = "#cbcb41", name = "javascript" },
    cjs = { glyph = "", role = "yellow", brand = "#cbcb41", name = "javascript" },
    jsx = { glyph = "", role = "cyan", brand = "#20c2e3", name = "react" },
    ts = { glyph = "", role = "blue", brand = "#519aba", name = "typescript" },
    mts = { glyph = "", role = "blue", brand = "#519aba", name = "typescript" },
    cts = { glyph = "", role = "blue", brand = "#519aba", name = "typescript" },
    tsx = { glyph = "", role = "cyan", brand = "#519aba", name = "react-ts" },
    vue = { glyph = "", role = "green", brand = "#41b883", name = "vue" },
    svelte = { glyph = "", role = "orange", brand = "#ff3e00", name = "svelte" },
    astro = { glyph = "", role = "orange", brand = "#ff5d01", name = "astro" },

    -- ── Systems / compiled ────────────────────────────────────────────────────
    c = { glyph = "", role = "blue", brand = "#599eff", name = "c" },
    h = { glyph = "", role = "purple", brand = "#a074c4", name = "c-header" },
    cpp = { glyph = "", role = "blue", brand = "#f34b7d", name = "cpp" },
    cc = { glyph = "", role = "blue", brand = "#f34b7d", name = "cpp" },
    cxx = { glyph = "", role = "blue", brand = "#f34b7d", name = "cpp" },
    hpp = { glyph = "", role = "purple", brand = "#a074c4", name = "cpp-header" },
    rs = { glyph = "", role = "orange", brand = "#dea584", name = "rust" },
    go = { glyph = "", role = "cyan", brand = "#00add8", name = "go" },
    zig = { glyph = "", role = "orange", brand = "#f7a41d", name = "zig" },
    swift = { glyph = "", role = "orange", brand = "#e37933", name = "swift" },
    dart = { glyph = "", role = "blue", brand = "#03589c", name = "dart" },
    nim = { glyph = "", role = "yellow", brand = "#f3d400", name = "nim" },

    -- ── JVM ───────────────────────────────────────────────────────────────────
    java = { glyph = "", role = "red", brand = "#cc3e44", name = "java" },
    class = { glyph = "", role = "red", brand = "#cc3e44", name = "java" },
    kt = { glyph = "", role = "purple", brand = "#7f52ff", name = "kotlin" },
    kts = { glyph = "", role = "purple", brand = "#7f52ff", name = "kotlin" },
    scala = { glyph = "", role = "red", brand = "#cc3e44", name = "scala" },
    groovy = { glyph = "", role = "blue", brand = "#4298b8", name = "groovy" },

    -- ── Scripting / dynamic ───────────────────────────────────────────────────
    py = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    pyi = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    pyw = { glyph = "", role = "yellow", brand = "#ffbc03", name = "python" },
    rb = { glyph = "", role = "red", brand = "#701516", name = "ruby" },
    php = { glyph = "", role = "purple", brand = "#a074c4", name = "php" },
    pl = { glyph = "", role = "blue", brand = "#519aba", name = "perl" },
    r = { glyph = "", role = "green", brand = "#358a5b", name = "r" },
    jl = { glyph = "", role = "purple", brand = "#a270ba", name = "julia" },
    ex = { glyph = "", role = "purple", brand = "#a074c4", name = "elixir" },
    exs = { glyph = "", role = "purple", brand = "#a074c4", name = "elixir" },
    erl = { glyph = "", role = "magenta", brand = "#b83998", name = "erlang" },
    hs = { glyph = "", role = "purple", brand = "#a074c4", name = "haskell" },
    clj = { glyph = "", role = "green", brand = "#8dc149", name = "clojure" },
    cljs = { glyph = "", role = "blue", brand = "#519aba", name = "clojurescript" },
    elm = { glyph = "", role = "cyan", brand = "#60b5cc", name = "elm" },
    lisp = { glyph = "", role = "fg", brand = "#5a6158", name = "lisp" },

    -- ── Shell ─────────────────────────────────────────────────────────────────
    sh = { glyph = "", role = "green", brand = "#89e051", name = "shell" },
    bash = { glyph = "", role = "green", brand = "#89e051", name = "shell" },
    zsh = { glyph = "", role = "green", brand = "#89e051", name = "shell" },
    fish = { glyph = "", role = "green", brand = "#89e051", name = "shell" },
    ps1 = { glyph = "", role = "blue", brand = "#4273ca", name = "powershell" },

    -- ── Data / config formats ─────────────────────────────────────────────────
    json = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    jsonc = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    json5 = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    yaml = { glyph = "", role = "purple", brand = "#cb171e", name = "yaml" },
    yml = { glyph = "", role = "purple", brand = "#cb171e", name = "yaml" },
    toml = { glyph = "", role = "orange", brand = "#9c4221", name = "toml" },
    xml = { glyph = "", role = "orange", brand = "#e37933", name = "xml" },
    ini = { glyph = "", role = "fg", brand = "#6d8086", name = "config" },
    conf = { glyph = "", role = "fg", brand = "#6d8086", name = "config" },
    cfg = { glyph = "", role = "fg", brand = "#6d8086", name = "config" },
    env = { glyph = "", role = "yellow", brand = "#faf743", name = "env" },
    sql = { glyph = "", role = "blue", brand = "#dad8d8", name = "database" },
    graphql = { glyph = "", role = "magenta", brand = "#e10098", name = "graphql" },
    gql = { glyph = "", role = "magenta", brand = "#e10098", name = "graphql" },
    proto = { glyph = "", role = "orange", brand = "#e37933", name = "protobuf" },
    csv = { glyph = "󰺥", role = "green", brand = "#89e051", name = "csv" },

    -- ── Docs / text ───────────────────────────────────────────────────────────
    md = { glyph = "", role = "blue", brand = "#519aba", name = "markdown" },
    markdown = { glyph = "", role = "blue", brand = "#519aba", name = "markdown" },
    mdx = { glyph = "", role = "yellow", brand = "#519aba", name = "mdx" },
    txt = { glyph = "", role = "fg", brand = "#6d8086", name = "text" },
    rst = { glyph = "", role = "fg", brand = "#6d8086", name = "text" },
    org = { glyph = "", role = "green", brand = "#77aa99", name = "org" },
    tex = { glyph = "", role = "green", brand = "#3d6117", name = "tex" },
    pdf = { glyph = "", role = "red", brand = "#b30b00", name = "pdf" },
    log = { glyph = "", role = "fg", brand = "#6d8086", name = "log" },
    license = { glyph = "󰈙", role = "yellow", brand = "#cbcb41", name = "license" },

    -- ── Images ────────────────────────────────────────────────────────────────
    png = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    jpg = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    jpeg = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    gif = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    webp = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    bmp = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    ico = { glyph = "", role = "magenta", brand = "#a074c4", name = "image" },
    svg = { glyph = "󰜡", role = "orange", brand = "#ffb13b", name = "svg" },

    -- ── Archives ──────────────────────────────────────────────────────────────
    zip = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    tar = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    gz = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    xz = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    bz2 = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    ["7z"] = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },
    rar = { glyph = "", role = "orange", brand = "#eca517", name = "archive" },

    -- ── Misc ──────────────────────────────────────────────────────────────────
    lock = { glyph = "", role = "fg", brand = "#6d8086", name = "lock" },
    diff = { glyph = "", role = "orange", brand = "#e37933", name = "diff" },
    patch = { glyph = "", role = "orange", brand = "#e37933", name = "diff" },
    bin = { glyph = "", role = "fg", brand = "#6d8086", name = "binary" },
    wasm = { glyph = "", role = "purple", brand = "#654ff0", name = "wasm" },

    -- ── More languages ────────────────────────────────────────────────────────
    fs = { glyph = "", role = "blue", brand = "#378bba", name = "fsharp" },
    fsx = { glyph = "", role = "blue", brand = "#378bba", name = "fsharp" },
    fsi = { glyph = "", role = "blue", brand = "#378bba", name = "fsharp" },
    ml = { glyph = "", role = "orange", brand = "#e37933", name = "ocaml" },
    mli = { glyph = "", role = "orange", brand = "#e37933", name = "ocaml" },
    cr = { glyph = "", role = "fg", brand = "#000000", name = "crystal" },
    d = { glyph = "", role = "red", brand = "#ba595e", name = "dlang" },
    di = { glyph = "", role = "red", brand = "#ba595e", name = "dlang" },
    coffee = { glyph = "", role = "yellow", brand = "#cbcb41", name = "coffeescript" },
    pug = { glyph = "", role = "red", brand = "#a86454", name = "pug" },
    haml = { glyph = "", role = "yellow", brand = "#eaeae1", name = "haml" },
    styl = { glyph = "", role = "green", brand = "#8dc149", name = "stylus" },
    sml = { glyph = "", role = "orange", brand = "#e37933", name = "sml" },
    rkt = { glyph = "", role = "red", brand = "#3d5fa5", name = "racket" },
    scm = { glyph = "", role = "fg", brand = "#5a6158", name = "scheme" },
    fnl = { glyph = "", role = "yellow", brand = "#fff3d7", name = "fennel" },
    moon = { glyph = "", role = "cyan", brand = "#51a0cf", name = "moonscript" },
    pas = { glyph = "", role = "blue", brand = "#519aba", name = "pascal" },
    v = { glyph = "", role = "blue", brand = "#5d87bf", name = "vlang" },
    sol = { glyph = "󰞼", role = "fg", brand = "#c1c1c1", name = "solidity" },
    prisma = { glyph = "", role = "blue", brand = "#5a67d8", name = "prisma" },

    -- ── More web / frontend ───────────────────────────────────────────────────
    hbs = { glyph = "", role = "orange", brand = "#f0772b", name = "handlebars" },
    ejs = { glyph = "", role = "yellow", brand = "#cbcb41", name = "ejs" },
    postcss = { glyph = "", role = "orange", brand = "#dd3a0a", name = "postcss" },
    twig = { glyph = "", role = "green", brand = "#8dc149", name = "twig" },
    liquid = { glyph = "", role = "blue", brand = "#519aba", name = "liquid" },
    marko = { glyph = "", role = "blue", brand = "#519aba", name = "marko" },

    -- ── More config / build / infra ───────────────────────────────────────────
    nix = { glyph = "", role = "blue", brand = "#7ebae4", name = "nix" },
    tf = { glyph = "", role = "purple", brand = "#5c4ee5", name = "terraform" },
    tfvars = { glyph = "", role = "purple", brand = "#5c4ee5", name = "terraform" },
    hcl = { glyph = "", role = "purple", brand = "#5c4ee5", name = "hcl" },
    dhall = { glyph = "", role = "green", brand = "#5f8a3c", name = "dhall" },
    gradle = { glyph = "", role = "cyan", brand = "#005f87", name = "gradle" },
    bzl = { glyph = "", role = "green", brand = "#43a047", name = "bazel" },
    cmake = { glyph = "", role = "green", brand = "#649ad2", name = "cmake" },
    ninja = { glyph = "󰝴", role = "fg", brand = "#6d8086", name = "ninja" },
    editorconfig = { glyph = "", role = "fg", brand = "#6d8086", name = "editorconfig" },
    properties = { glyph = "", role = "fg", brand = "#6d8086", name = "config" },
    nginx = { glyph = "", role = "green", brand = "#009639", name = "nginx" },

    -- ── Data / serialisation ──────────────────────────────────────────────────
    jsonl = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    ndjson = { glyph = "", role = "yellow", brand = "#cbcb41", name = "json" },
    parquet = { glyph = "", role = "blue", brand = "#50a1d6", name = "parquet" },
    avro = { glyph = "", role = "blue", brand = "#50a1d6", name = "avro" },
    db = { glyph = "", role = "blue", brand = "#dad8d8", name = "database" },
    sqlite = { glyph = "", role = "blue", brand = "#0f80cc", name = "sqlite" },
    sqlite3 = { glyph = "", role = "blue", brand = "#0f80cc", name = "sqlite" },

    -- ── Office documents ──────────────────────────────────────────────────────
    doc = { glyph = "", role = "blue", brand = "#2b579a", name = "word" },
    docx = { glyph = "", role = "blue", brand = "#2b579a", name = "word" },
    odt = { glyph = "", role = "blue", brand = "#2b579a", name = "word" },
    xls = { glyph = "", role = "green", brand = "#217346", name = "excel" },
    xlsx = { glyph = "", role = "green", brand = "#217346", name = "excel" },
    ods = { glyph = "", role = "green", brand = "#217346", name = "excel" },
    ppt = { glyph = "", role = "orange", brand = "#d24726", name = "powerpoint" },
    pptx = { glyph = "", role = "orange", brand = "#d24726", name = "powerpoint" },
    odp = { glyph = "", role = "orange", brand = "#d24726", name = "powerpoint" },
    rtf = { glyph = "", role = "fg", brand = "#6d8086", name = "text" },
    epub = { glyph = "", role = "green", brand = "#85be53", name = "book" },
    adoc = { glyph = "", role = "blue", brand = "#519aba", name = "asciidoc" },

    -- ── Media: video / audio / fonts ──────────────────────────────────────────
    mp4 = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    mkv = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    webm = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    mov = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    avi = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    flv = { glyph = "", role = "orange", brand = "#fd971f", name = "video" },
    mp3 = { glyph = "", role = "cyan", brand = "#00af87", name = "audio" },
    wav = { glyph = "", role = "cyan", brand = "#00af87", name = "audio" },
    flac = { glyph = "", role = "cyan", brand = "#00af87", name = "audio" },
    ogg = { glyph = "", role = "cyan", brand = "#00af87", name = "audio" },
    m4a = { glyph = "", role = "cyan", brand = "#00af87", name = "audio" },
    ttf = { glyph = "", role = "purple", brand = "#d4bfff", name = "font" },
    otf = { glyph = "", role = "purple", brand = "#d4bfff", name = "font" },
    woff = { glyph = "", role = "purple", brand = "#d4bfff", name = "font" },
    woff2 = { glyph = "", role = "purple", brand = "#d4bfff", name = "font" },
    eot = { glyph = "", role = "purple", brand = "#d4bfff", name = "font" },

    -- ── Design ────────────────────────────────────────────────────────────────
    psd = { glyph = "", role = "blue", brand = "#0d5ba1", name = "photoshop" },
    ai = { glyph = "", role = "orange", brand = "#ff7c00", name = "illustrator" },
    blend = { glyph = "", role = "orange", brand = "#ea7600", name = "blender" },
    xcf = { glyph = "", role = "magenta", brand = "#a074c4", name = "gimp" },

    -- ── Shell / ops ───────────────────────────────────────────────────────────
    nu = { glyph = "", role = "green", brand = "#3aa675", name = "nushell" },
    bat = { glyph = "", role = "green", brand = "#89e051", name = "batch" },
    cmd = { glyph = "", role = "green", brand = "#89e051", name = "batch" },
    service = { glyph = "", role = "fg", brand = "#6d8086", name = "systemd" },
    desktop = { glyph = "", role = "blue", brand = "#563d7c", name = "desktop" },
    plist = { glyph = "", role = "fg", brand = "#6d8086", name = "plist" },

    -- ── GPU / native / scientific ─────────────────────────────────────────────
    glsl = { glyph = "", role = "blue", brand = "#5586a4", name = "shader" },
    vert = { glyph = "", role = "blue", brand = "#5586a4", name = "shader" },
    frag = { glyph = "", role = "blue", brand = "#5586a4", name = "shader" },
    comp = { glyph = "", role = "blue", brand = "#5586a4", name = "shader" },
    wgsl = { glyph = "", role = "purple", brand = "#7048e8", name = "wgsl" },
    cu = { glyph = "", role = "green", brand = "#89e051", name = "cuda" },
    ino = { glyph = "", role = "cyan", brand = "#00979d", name = "arduino" },
    ipynb = { glyph = "", role = "orange", brand = "#f57d01", name = "jupyter" },
    m = { glyph = "", role = "orange", brand = "#e16737", name = "matlab" },
}
