return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = false,
    },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    config = function()
      local C = require("catppuccin.palettes").get_palette "latte"
      require("catppuccin").setup({
        flavour = "latte",
        auto_integrations = true,
        integrations = {
          lualine = {
            normal = {
              a = { bg = C.blue, fg = C.mantle, gui = "bold" },
              b = { bg = C.surface0, fg = C.blue },
              c = { bg = C.mantle, fg = C.text },
            },

            insert = {
              a = { bg = C.green, fg = C.base, gui = "bold" },
              b = { bg = C.surface0, fg = C.green },
            },

            terminal = {
              a = { bg = C.green, fg = C.base, gui = "bold" },
              b = { bg = C.surface0, fg = C.green },
            },

            command = {
              a = { bg = C.peach, fg = C.base, gui = "bold" },
              b = { bg = C.surface0, fg = C.peach },
            },
            visual = {
              a = { bg = C.mauve, fg = C.base, gui = "bold" },
              b = { bg = C.surface0, fg = C.mauve },
            },
            replace = {
              a = { bg = C.red, fg = C.base, gui = "bold" },
              b = { bg = C.surface0, fg = C.red },
            },
            inactive = {
              a = { bg = C.mantle, fg = C.blue },
              b = { bg = C.mantle, fg = C.surface1, gui = "bold" },
              c = { bg = C.mantle, fg = C.overlay0 },
            },
          },
        },
      })
    end,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
