return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["<C-s>"] = false,
      ["<C-h>"] = false,
      ["<C-t>"] = false,
      ["<C-l>"] = false,
      ["r"] = "actions.refresh",
      ["g."] = false,
      ["H"] = "actions.toggle_hidden",
    },
    win_options = {
      signcolumn = "yes:2",
    },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
}
