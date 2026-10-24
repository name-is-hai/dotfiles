vim.pack.add({ 
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})
local treesitter = require("nvim-treesitter")

vim.api.nvim_create_user_command("TSInstallConfigured", function()
  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify("Run scripts/bootstrap-nvim.sh to install tree-sitter and the parsers", vim.log.levels.ERROR)
    return
  end
  treesitter.install(require("dependencies").parsers, { summary = true })
end, { desc = "Install missing configured Treesitter parsers" })

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
