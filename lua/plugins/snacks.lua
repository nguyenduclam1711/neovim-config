return {
  "folke/snacks.nvim",
  opts = {
    quickfile = {},
    -- Snacks' built-in big-file mode is left at its default (1.5MB), where it
    -- disables everything. It acts as a safety net for truly huge files.
    -- Files between ~1MB and 1.5MB are handled by the lighter, balanced
    -- handler in lua/config/bigfile.lua, which keeps LSP/completion/tree-sitter.
  },
}
