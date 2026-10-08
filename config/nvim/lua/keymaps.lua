vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = "Navigate Left / Tmux Pane" })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = "Navigate Down / Tmux Pane" })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = "Navigate Up / Tmux Pane" })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = "Navigate Right / Tmux Pane" })
vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', { desc = "Navigate Previous / Tmux Pane" })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><Esc>', { desc = "Clear Search Highlights" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Equalize all windows (makes them all the exact same size)
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Equalize Windows" })

-- replaces selected text WITHOUT losing what you yanked
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste over selection without losing yanked text" })

vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result cursor centered" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]],
  { desc = "Replace word cursor is on globally" })

vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle Inlay Hints" })

-- native undotree
vim.keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Toggle Builtin Undotree" })

vim.keymap.set("n", "<leader>cy", function()
  local diagnostics = vim.diagnostic.get(0, {
    lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
  })

  if vim.tbl_isempty(diagnostics) then
    vim.notify("No diagnostic on this line", vim.log.levels.INFO)
    return
  end

  local messages = vim.tbl_map(function(diagnostic)
    return diagnostic.message
  end, diagnostics)

  local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")

  local text = table.concat(messages, "\n")

  osc52_copy(vim.split(text, "\n", {
    plain = true,
  }))

  vim.notify("Diagnostic copied")
end, {
  desc = "Copy diagnostic",
})
