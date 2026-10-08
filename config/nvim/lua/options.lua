local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 2
opt.softtabstop = -1
opt.shiftwidth = 2
opt.expandtab = true

opt.smartindent = true
opt.wrap = false
opt.inccommand = "split"

opt.swapfile = false
opt.backup = false

opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.undofile = true

opt.completeopt = {
  "menu",
  "menuone",
  "noselect",
}

opt.shortmess:append("c")
opt.updatetime = 250
opt.scrolloff = 8

opt.clipboard = "unnamedplus"

local is_ssh_or_tmux = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil or vim.env.TMUX ~= nil

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
    if is_ssh_or_tmux and (vim.v.event.operator == "y" or vim.v.event.operator == "d") then
      require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
})

vim.o.cmdheight = 0
