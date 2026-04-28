return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    diagnostics = {
      virtual_text = false,
      update_in_insert = false,
      underline = false,
      severity_sort = false,
    },
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
