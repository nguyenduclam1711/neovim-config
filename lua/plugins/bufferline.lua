return {
  "akinsho/bufferline.nvim",
  dependencies = { "catppuccin/nvim" },
  -- `opts` as a function so it merges with LazyVim's defaults and runs after
  -- catppuccin is set up (catppuccin must load first or highlights are wrong).
  opts = function(_, opts)
    local latte = require("catppuccin.palettes").get_palette("latte")
    opts.highlights = require("catppuccin.special.bufferline").get_theme({
      -- Applied to selected/visible buffer labels, numbers and diagnostics.
      styles = { "bold", "italic" },
      custom = {
        all = {
          -- Active buffer name in the mauve accent so it stands out.
          -- Emphasis must go via `style`, not bold/italic (the theme resets those).
          buffer_selected = { fg = latte.mauve, style = { "bold", "italic" } },
          -- Match the left indicator bar to the accent.
          indicator_selected = { fg = latte.mauve, style = { "bold" } },
          indicator_visible = { fg = latte.mauve },
          -- Modified dot: green when active, subtler peach otherwise.
          modified_selected = { fg = latte.green },
          modified = { fg = latte.peach },
        },
      },
    })
  end,
}
