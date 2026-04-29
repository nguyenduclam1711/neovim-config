return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      eslint = {},
      vtsls = {
        settings = {
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      },
      -- Explicitly disable angularls if not needed
      angularls = {
        enabled = false,
      },
    },
  },
}
