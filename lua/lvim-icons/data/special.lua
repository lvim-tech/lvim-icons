-- lvim-icons.data.special: OS / filesystem "kind" icons — not name/extension driven.
-- Returned by the resolver when a caller passes an `opts.kind` (or the directory/link
-- hints), for tree/browser cells: directories (open & closed), symlinks (and broken ones),
-- executables, and the generic file fallback. Same spec shape as data/extensions.lua.
--
---@module "lvim-icons.data.special"

---@type table<string, LvimIconSpec>
return {
    directory = { glyph = "", role = "blue", brand = "#7ebae4", name = "folder" },
    directory_open = { glyph = "", role = "blue", brand = "#7ebae4", name = "folder-open" },
    directory_empty = { glyph = "󰉖", role = "blue", brand = "#7ebae4", name = "folder-empty" },
    symlink = { glyph = "", role = "cyan", brand = "#56b3b4", name = "symlink" },
    symlink_dir = { glyph = "󰠹", role = "cyan", brand = "#56b3b4", name = "symlink-dir" },
    symlink_broken = { glyph = "", role = "red", brand = "#cb4f4f", name = "symlink-broken" },
    executable = { glyph = "", role = "green", brand = "#89e051", name = "executable" },
    file = { glyph = "", role = "fg", brand = "#6d8086", name = "file" },
    file_empty = { glyph = "", role = "fg", brand = "#6d8086", name = "file-empty" },
}
