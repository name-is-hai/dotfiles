vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "bashls",
    "yamlls",
    "ansiblels",
    "terraformls",
    "rust_analyzer",
    "dockerls",
    "docker_compose_language_service",
    "gh_actions_ls",
  },

  automatic_enable = true,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = {
          "vim",
          "Snacks",
        },
      },

      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local function map(keys, action, description)
      vim.keymap.set("n", keys, action, {
        buffer = event.buf,
        desc = description,
      })
    end

    local hover_window = {
      border = "rounded",
      winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
    }

    map("K", function() vim.lsp.buf.hover(hover_window) end, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
    source = true,
  },
})
