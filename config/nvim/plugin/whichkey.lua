vim.pack.add({ "https://github.com/folke/which-key.nvim" })

require("which-key").setup({
  preset = "modern",
  delay = 300,
  icons = {
    mappings = true,
  },
})
