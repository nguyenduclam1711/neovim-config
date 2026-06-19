return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      providers = {
        buffer = {
          -- On big files, skip the buffer source. Scanning a 20k-line buffer
          -- for completion words is the main source of suggestion lag. LSP,
          -- path and snippet completion stay active. Evaluated per request,
          -- so normal files are unaffected.
          enabled = function()
            return not vim.b.big_file
          end,
        },
      },
    },
  },
}
