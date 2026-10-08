vim.pack.add({
  {
    src = "https://github.com/Saghen/blink.cmp",
    version = "v1",
  },
  {
    src = "https://github.com/rafamadriz/friendly-snippets",
  },
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",

    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },

    ["<Tab>"] = {
      "select_next",
      "snippet_forward",
      "fallback",
    },

    ["<S-Tab>"] = {
      "select_prev",
      "snippet_backward",
      "fallback",
    },
  },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },

    menu = {
      border = "rounded",
      draw = {
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "source_name" },
        },
      },
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
      window = {
        border = "rounded",
      },
    },

    ghost_text = {
      enabled = true,
    },
  },

  signature = {
    enabled = true,
    window = {
      border = "rounded",
    },
  },

  snippets = {
    preset = "default",
  },

  sources = {
    default = {
      "lsp",
      "path",
      "snippets",
      "buffer",
    },
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
})
