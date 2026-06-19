-- Balanced big-file handling.
--
-- Keep LSP, completion and tree-sitter working on large files, but switch off
-- the few features that cause most of the lag so editing and saving stay snappy.
--
-- Triggers for files >= 1MB OR > 10k lines. (Files >= 1.5MB are caught first by
-- Snacks' own big-file mode, which disables everything as a safety net.)
--
-- Required early from lua/config/options.lua so the autocmds are registered
-- before the first file (even one passed on the command line) is read.

local SIZE = 1 * 1024 * 1024 -- 1MB
local LINES = 10000
local uv = vim.uv or vim.loop
local group = vim.api.nvim_create_augroup("balanced_bigfile", { clear = true })

local function is_big(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  local stat = name ~= "" and uv.fs_stat(name) or nil
  if stat and stat.size and stat.size >= SIZE then
    return true
  end
  return vim.api.nvim_buf_line_count(buf) > LINES
end

-- Per-buffer/window performance tweaks that must be (re)applied AFTER the
-- FileType event, because that's when LazyVim sets indentexpr/foldexpr.
local function apply_perf(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  -- Pressing Enter calls indentexpr. LazyVim sets it to the tree-sitter indent
  -- function, which walks the whole tree on every new line -- the main cause of
  -- new-line lag on big files. Fall back to cheap copy-the-previous-line indent.
  vim.bo[buf].indentexpr = ""
  vim.bo[buf].autoindent = true
  vim.bo[buf].smartindent = true
  -- Manual folds: tree-sitter foldexpr also recomputes on edits.
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_set_option_value("foldmethod", "manual", { win = win, scope = "local" })
    vim.api.nvim_set_option_value("foldexpr", "0", { win = win, scope = "local" })
  end
  -- gitsigns recomputes a git diff of the buffer on every change -- expensive on
  -- a big file. Detach it (runs after gitsigns has attached on BufReadPost).
  pcall(function()
    require("gitsigns").detach(buf)
  end)
end

local function mark_big(buf)
  if not vim.b[buf].big_file then
    vim.b[buf].big_file = true
    vim.b[buf].autoformat = false -- no format-on-save (Prettier is slow on huge files)
    vim.b[buf].minihipatterns_disable = true -- stop scanning the buffer for hex/TODO patterns
    vim.b[buf].snacks_indent = false -- no indent guides
  end
  -- Schedule so this runs after the FileType autocmd has set indentexpr/foldexpr.
  vim.schedule(function()
    apply_perf(buf)
  end)
end

-- Detect on read (fires for files opened at startup and later).
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    if is_big(ev.buf) then
      mark_big(ev.buf)
    end
  end,
})

-- Re-apply tweaks whenever a big buffer is shown in a (new) window, in case
-- something resets the window/buffer options afterwards.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(ev)
    if vim.b[ev.buf].big_file then
      apply_perf(ev.buf)
    end
  end,
})

-- Trim the LSP for big buffers: drop semantic-token highlighting and inlay hints
-- (the main per-keystroke cost). Completion, hover and go-to-definition stay on.
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    if not vim.b[ev.buf].big_file then
      return
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities then
      client.server_capabilities.semanticTokensProvider = nil
    end
    pcall(function()
      vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
    end)
  end,
})

-- :BigFileTurbo — strip the CURRENT buffer to the bone for maximum
-- responsiveness: stop tree-sitter, detach all LSP clients, disable completion,
-- and fall back to cheap regex syntax. The nuclear option for a monster file
-- when balanced mode still isn't snappy enough. Reopen the file to restore.
vim.api.nvim_create_user_command("BigFileTurbo", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.b[buf].big_file = true
  vim.b[buf].completion = false
  apply_perf(buf)
  pcall(vim.treesitter.stop, buf)
  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    vim.lsp.buf_detach_client(buf, client.id)
  end
  -- Cheap regex syntax, capped per line by synmaxcol.
  vim.bo[buf].syntax = vim.bo[buf].filetype
  vim.notify("Turbo mode: tree-sitter + LSP + completion off for this buffer", vim.log.levels.INFO)
end, { desc = "Max-performance mode for the current buffer" })
