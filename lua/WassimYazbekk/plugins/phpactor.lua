local util = require("lspconfig.util")

return {
	default_config = {
		cmd = { "phpactor", "language-server" },
		filetypes = { "php" },
		root_dir = function(pattern)
			local cwd = vim.loop.cwd()
			local root = util.root_pattern("composer.json", ".phpactor.json", ".phpactor.yml")(pattern)

			-- prefer cwd if root is a descendant
			return util.path.is_descendant(cwd, root) and cwd or root
		end,
	},
}
