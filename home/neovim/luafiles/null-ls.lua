-- luacheck: globals vim

local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	sources = {
		formatting.prettier,
		formatting.black,
		formatting.stylua,
		formatting.shfmt,
		formatting.gofumpt,
		formatting.nixfmt,
		formatting.csharpier,

		-- moved out of none-ls core into none-ls-extras
		require("none-ls.diagnostics.eslint_d"),
		require("none-ls.diagnostics.ruff"),

		diagnostics.golangci_lint,
		diagnostics.pylint,
	},
	on_attach = function(current_client, bufnr)
		if current_client:supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})

-- rustfmt was removed from none-ls; format Rust through rust-analyzer instead
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = "*.rs",
	callback = function(args)
		vim.lsp.buf.format({ name = "rust-analyzer", bufnr = args.buf })
	end,
})
