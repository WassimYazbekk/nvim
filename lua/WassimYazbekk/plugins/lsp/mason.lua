-- 1. Initialize Mason first (Never gate this behind other plugins!)
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	vim.notify("Mason failed to load!", vim.log.levels.WARN)
	return
end

mason.setup()

-- 2. Setup Mason-LSPConfig
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lspconfig_status then
	mason_lspconfig.setup({
		ensure_installed = {
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"phpactor",
			"graphql",
			"emmet_ls",
			"prismals",
			"gopls",
		},
		automatic_installation = true,
	})
else
	vim.notify("mason-lspconfig is not installed", vim.log.levels.WARN)
end
