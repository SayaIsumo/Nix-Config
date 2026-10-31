-- luacheck: globals vim

local keymap = vim.keymap

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspKeymaps", {}),
	callback = function(args)
		local opts = { noremap = true, silent = true, buffer = args.buf }

		-- set keybindings
		keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts)
		keymap.set("n", "gD", vim.lsp.buf.definition, opts)
		keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
		keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
		keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
		keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
		keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
		keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
		keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
		keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)
		keymap.set("n", "<leader><CR>", "<cmd>Lspsaga term_toggle<CR>", opts)
	end,
})

vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = { vim.env.VIMRUNTIME },
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})

-- rust-analyzer is handled by rustaceanvim
vim.lsp.enable({
	"clangd",
	"pyright",
	"lua_ls",
	"ts_ls",
	"cssls",
	"html",
	"gopls",
	"nil_ls",
	"metals",
	"tailwindcss",
	"roslyn_ls",
})
