vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
	formatters_by_ft = {
		terraform = { "terraform_fmt" },
		["terraform-vars"] = { "terraform_fmt" },

		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },

		ansible = { "prettier" },
		k8s = { "yamlfmt" },
		helm = { "yamlfmt" },
		yaml = { "prettier" },

		javascript = { "biome" },
		javascriptreact = { "biome" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
	},

	default_format_opts = {
		lsp_format = "fallback",
	},

	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end, {
	desc = "Format buffer",
})

vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform-vars",
	},

	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = "yaml",
		[".*/kubernetes/.*%.ya?ml"] = "k8s",
		[".*/k8s/.*%.ya?ml"] = "k8s",
		[".*/playbooks/.*%.ya?ml"] = "ansible",
		[".*/roles/.*/tasks/.*%.ya?ml"] = "ansible",
	},
})
