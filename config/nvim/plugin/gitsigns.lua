vim.pack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

require('gitsigns').setup({
  signs                   = {
    add          = { text = "▎", hl = "GitSignsAdd" },
    change       = { text = "▎", hl = "GitSignsChange" },
    delete       = { text = "", hl = "GitSignsDelete" },
    topdelete    = { text = "", hl = "GitSignsDelete" },
    changedelete = { text = "▎", hl = "GitSignsChange" },
    untracked    = { text = "▎", hl = "GitSignsUntracked" },
  },
  current_line_blame      = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' - right after the line, 'right_align' - far right
    delay = 500,           -- Shows up after half a second of resting your cursor
  },
  watch_gitdir = {
    follow_files = true
  }
})

local gs = require 'gitsigns'
local map = vim.keymap.set

map("n", "]h", gs.next_hunk, { desc = 'Next Git hunk' })
map("n", "[h", gs.prev_hunk, { desc = 'Previous Git hunk' })

map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })
map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = 'Toggle git blame' })
map('n', '<leader>gw', gs.toggle_word_diff, { desc = 'Toggle word diff' })
