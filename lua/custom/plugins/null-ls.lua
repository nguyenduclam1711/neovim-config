return {
	"jose-elias-alvarez/null-ls.nvim",
	config = function()
		-- Switch for controlling whether you want autoformatting.
		--  Use :KickstartFormatToggle to toggle autoformatting on or off
		local format_is_enabled = true
		vim.api.nvim_create_user_command("FormatToggle", function()
			format_is_enabled = not format_is_enabled
			print("Setting autoformatting to: " .. tostring(format_is_enabled))
		end, {})

		-- Create an augroup that is used for managing our formatting autocmds.
		--      We need one augroup per client to make sure that multiple clients
		--      can attach to the same buffer without interfering with each other.
		local _augroups = {}
		local get_augroup = function(client)
			if not _augroups[client.id] then
				local group_name = "kickstart-lsp-format-" .. client.name
				local id = vim.api.nvim_create_augroup(group_name, { clear = true })
				_augroups[client.id] = id
			end

			return _augroups[client.id]
		end

		-- Whenever an LSP attaches to a buffer, we will run this function.
		--
		-- See `:help LspAttach` for more information about this autocmd event.
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach-format", { clear = true }),
			-- This is where we attach the autoformatting for reasonable clients
			callback = function(args)
				local client_id = args.data.client_id
				local client = vim.lsp.get_client_by_id(client_id)
				local bufnr = args.buf

				-- Setup null-ls
				local null_ls = require("null-ls")
				null_ls.setup({
					sources = {
						null_ls.builtins.formatting.stylua,
						null_ls.builtins.formatting.gofumpt,
						null_ls.builtins.code_actions.gomodifytags,
						null_ls.builtins.formatting.shfmt,
						null_ls.builtins.diagnostics.golangci_lint,
						null_ls.builtins.formatting.prettier.with({
							runtime_condition = function(utils)
								local eslint_client =
									vim.lsp.get_active_clients({ bufnr = args.buf, name = "eslint" })[1]
								return eslint_client == nil
							end,
						}),
						null_ls.builtins.formatting.eslint_d.with({
							runtime_condition = function(utils)
								local eslint_client =
									vim.lsp.get_active_clients({ bufnr = args.buf, name = "eslint" })[1]
								return eslint_client ~= nil
							end,
						}),
						null_ls.builtins.diagnostics.eslint_d.with({
							runtime_condition = function(utils)
								local eslint_client =
									vim.lsp.get_active_clients({ bufnr = args.buf, name = "eslint" })[1]
								return eslint_client ~= nil
							end,
						}),
					},
				})

				-- Enable formatting provider for eslint lsp
				if client.name == "eslint" then
					client.server_capabilities.documentFormattingProvider = true
				end

				-- Only attach to clients that support document formatting
				if not client.server_capabilities.documentFormattingProvider then
					return
				end

				-- Create an autocmd that will run *before* we save the buffer.
				--  Run the formatting command for the LSP that has just attached.
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = get_augroup(client),
					buffer = bufnr,
					callback = function()
						if not format_is_enabled then
							return
						end

						vim.lsp.buf.format({
							async = false,
							filter = function(c)
								return c.id == client.id
							end,
						})
					end,
				})
			end,
		})
	end,
}
