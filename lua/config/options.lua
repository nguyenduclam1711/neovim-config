-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.lazyvim_eslint_auto_format = true
vim.g.lazyvim_prettier_needs_config = true
vim.g.snacks_animate = false

vim.o.wrap = true
vim.opt.swapfile = false

vim.lsp.set_log_level("OFF") -- LSP log error only

-- ─── Performance ──────────────────────────────────────────────────────────────

-- Faster completion / CursorHold events (default is 4000ms — way too slow)
vim.opt.updatetime = 200

-- Stop syntax highlighting on very long lines (e.g. minified files)
vim.opt.synmaxcol = 240

-- If highlighting takes too long, just stop (prevents freezes)
vim.opt.redrawtime = 1500

-- Don't show in-insert diagnostics — reduces constant LSP hammering
-- (also set this in your lspconfig opts.diagnostics)
vim.opt.updatetime = 200

-- Faster key sequence resolution
vim.opt.timeoutlen = 300

-- Reduce scroll context — large values cause more rendering work
vim.opt.scrolloff = 8 -- LazyVim default is fine, don't inflate this

-- Don't pass messages to ins-completion-menu (reduces flicker)
vim.opt.shortmess:append("c")
