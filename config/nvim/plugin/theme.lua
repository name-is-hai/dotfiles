vim.pack.add({
  {
    src = "https://github.com/marekh19/meowsoot.nvim",
    name = "meowsoot"
  },
  {
    src = "https://github.com/nvim-tree/nvim-web-devicons",
    name = "nvim-web-devicons",
  },
  {
    src = "https://github.com/nvim-lualine/lualine.nvim",
  },
})

vim.opt.termguicolors = true
require("meowsoot").setup({
  transparent = true,
  -- style = "night"
})

vim.cmd.colorscheme("meowsoot")

require("lualine").setup({
  options = {
    icons_enabled = true,
    globalstatus = true,
    component_separators = "",
    section_separators = {
      left = "",
      right = "",
    },
    disabled_filetypes = {
      statusline = {
        "snacks_dashboard",
        "snacks_picker_list",
      },
    },
  },

  sections = {
    lualine_a = {
      "mode",
    },

    lualine_b = {
      "branch",
      "diff",
      "diagnostics",
    },

    lualine_c = {
      {
        "filename",
        path = 1,
        symbols = {
          modified = " ●",
          readonly = " ",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
    },

    lualine_x = {
      "encoding",
      "fileformat",
      "filetype",
    },

    lualine_y = {
      "progress",
    },

    lualine_z = {
      "location",
    },
  },

  -- inactive_sections = {
  --   lualine_a = {},
  --   lualine_b = {},
  --   lualine_c = {
  --     "filename",
  --   },
  --   lualine_x = {
  --     "location",
  --   },
  --   lualine_y = {},
  --   lualine_z = {},
  -- },

  extensions = {
    "quickfix",
    "man",
    "trouble",
  },
})
