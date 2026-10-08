vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

---@type snacks.Config
require("snacks").setup({
  bigfile = {
    enabled = true,
  },

  quickfile = {
    enabled = true,
  },

  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys",  gap = 1 },
    },
  },

  notifier = {
    enabled = true,
    timeout = 5000,
  },

  image = {
    enabled = true,
  },

  indent = {
    animate = {
      enabled = false,
    },

    indent = {
      enabled = true,
      char = "▏",
      hl = "LineNr",
      only_scope = false,
      only_current = true,
    },

    scope = {
      enabled = true,
      char = "▏",
      underline = false,
      hl = "Function",
    },

    chunk = {
      enabled = false,
    },
  },

  scope = {
    enabled = true,
  },

  explorer = {
    enabled = true,
    replace_netrw = true,
  },

  picker = {
    enabled = true,

    sources = {
      files = {
        hidden = true,
      },

      explorer = {
        jump = { close = true },
        layout = {
          layout = {
            position = "float",
            width = 0.4,
            height = 0.8,
            border = "rounded",
            -- title = "{source} {live} {flags}",
            -- title_pos = "center",
          }
        }
        -- layout = function()
        --   require("sticky_term").hide("agent")
        --   return {
        --     preset = 'sidebar',
        --     preview = false,
        --     layout = {
        --       position = 'right',
        --       width = (vim.g.explorer_size or {}).width,
        --     },
        --   }
        -- end,
        -- on_close = function(picker)
        --   vim.g.explorer_size = picker.layout.root:size()
        -- end,
      },
    },
  },

  statuscolumn = {
    enabled = true,
    left = {
      "mark",
      "sign",
    },
    right = {
      "fold",
      "git",
    },
    folds = {
      open = false,
      git_hl = false,
    },
    git = {
      patterns = {
        "GitSign",
      },
    },
  },
})

local map = vim.keymap.set

local sticky_term = require("sticky_term")

local function get_explorer_position()
  local cfg = Snacks.picker.config.get({ source = "explorer" })
  local layout = Snacks.picker.config.layout(cfg)
  local pos = layout and layout.layout and layout.layout.position or (layout and layout.position)
  return pos or "float"
end

local toggle_agent_terminal = sticky_term.create({
  name = "agent",
  count = 99,
  win = {
    position = "right",
    width = 0.4,
  },
  before_open = function()
    local agent_pos = sticky_term.get_position("agent")
    if agent_pos ~= "float" then
      for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
        local picker_pos = picker.resolved_layout and picker.resolved_layout.layout and
            picker.resolved_layout.layout.position
        if picker_pos == agent_pos then
          picker:close()
        end
      end
    end
  end,
})

local function toggle_explorer()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
    return
  end
  local exp_pos = get_explorer_position()
  sticky_term.hide_if_same_side("agent", exp_pos)
  Snacks.explorer()
end

-- Explorer and main pickers
map("n", "<leader>e", toggle_explorer, { desc = "File explorer", })
map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Find buffers", })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep project", })
map("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command history", })

-- Files
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files", })
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Find projects", })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files", })

-- Search
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Search keymaps", })
map("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location list", })
map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix list", })
map("n", "<leader>sb", function() Snacks.picker.grep_buffers() end, { desc = "Search open buffers", })
map("n", "<leader>sD", function() Snacks.picker.diagnostics() end, { desc = "Workspace diagnostics", })
map("n", "<leader>sd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer diagnostics", })

-- Diagnostics
map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Line diagnostics popup", })
map("n", "<leader>d", function() vim.diagnostic.open_float() end, { desc = "Line diagnostics popup", })

-- LSP
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Go to definition", })
map("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Go to declaration", })
map("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Go to implementation", })
map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References", nowait = true, })
map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "Document symbols", })
map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Workspace symbols", })
map("n", "<leader>rf", function() Snacks.rename.rename_file() end, { desc = "Rename file", })

-- Git
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit", })
map("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git diff", })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git log file", })

-- Terminal
map({ "n", "t" }, "<C-`>", function() Snacks.terminal() end, { desc = "Toggle terminal", })
map({ "n", "t" }, "<C-~>", function() Snacks.terminal() end, { desc = "Toggle terminal", })

-- Agent Terminal (Ctrl+Shift+? / Ctrl+? / Ctrl+Shift+/ / Ctrl+/)
for _, key in ipairs({ "<C-?>", "<C-S-?>", "<C-S-/>", "<C-/>", "<C-_>" }) do
  map({ "n", "t" }, key, toggle_agent_terminal, { desc = "Toggle Agent Terminal" })
end

-- Notifications
map("n", "<leader>nd", function() Snacks.notifier.hide() end, { desc = "Dismiss notifications", })
map("n", "<leader>nh", function() Snacks.notifier.show_history() end, { desc = "Notification history", })
