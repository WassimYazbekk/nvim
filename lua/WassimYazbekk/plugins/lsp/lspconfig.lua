-- Import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

local keymap = vim.keymap -- For conciseness

-- Enable keybinds only when LSP server is available
local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Set keybinds
	keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts)
	keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
	keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
	keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
	keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts)

	-- TypeScript specific keymaps
	if client.name == "ts_ls" then
		keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- Rename file and update imports
		keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- Organize imports
		keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- Remove unused variables
	end

	keymap.set("n", "<leader>gj", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- Go to definition
	keymap.set("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) -- Find references
end

-- Use Neovim 0.11+ LspAttach event to cleanly handle keybind hooks
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client then
			on_attach(client, ev.buf)
		end
	end,
})

-- Enable autocompletion capabilities
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Configure LSP global defaults across all servers
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- Individual server extra overrides using Neovim 0.11 native configurations
vim.lsp.config("emmet_ls", {
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
})

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	-- Replaced old root_pattern with native vim.fs.root
	root_markers = { "go.work", "go.mod", ".git" }, 
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

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

-- List of all servers you want enabled and active
local servers = {
	"html",
	"cssls",
	"phpactor",
	"tailwindcss",
	"emmet_ls",
	"gopls",
	"lua_ls",
	"ts_ls",
}

-- Enable each configuration globally
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
