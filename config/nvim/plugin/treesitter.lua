vim.pack.add({ 
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})
local treesitter = require("nvim-treesitter")

local parsers = {
  "bash",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "regex",
  "rust",
  "terraform",
  "vim",
  "vimdoc",
  "yaml",
}

treesitter.install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
