if vim.fn.has("nvim-0.12") == 0 then
  error("Neovim 0.12+ is required. Run scripts/bootstrap-nvim.sh from the dotfiles repository.")
end

local has_ui2, ui2 = pcall(require, "vim._core.ui2")
if has_ui2 then
  ui2.enable({})
end

require("options")
require("keymaps")
require("commands")

