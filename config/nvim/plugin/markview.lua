vim.pack.add({
  "https://github.com/OXY2DEV/markview.nvim",
})

-- Disable automatic previews.
require("markview").setup({
  preview = { enable = false }
});

vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>Markview<CR>", { desc = "Toggles `markview` previews globally." });
