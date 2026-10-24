-- Editor tools managed by Mason. Rerun scripts/bootstrap-nvim.sh after updates.
return {
  tools = {
    ["ansible-language-server"] = "26.6.0",
    ["bash-language-server"] = "5.8.1",
    biome = "2.5.15",
    ["docker-compose-language-service"] = "1.0.0",
    ["dockerfile-language-server"] = "0.15.0",
    ["gh-actions-language-server"] = "0.3.61",
    ["lua-language-server"] = "3.19.2",
    prettier = "3.9.10",
    ["rust-analyzer"] = "2026-10-19",
    stylua = "v2.6.0",
    terraform = "v1.17.0",
    ["terraform-ls"] = "v0.39.0",
    ["yaml-language-server"] = "2.0.0",
    yamlfmt = "v0.21.0",
  },
  parsers = {
    "bash", "dockerfile", "git_config", "git_rebase", "gitcommit",
    "json", "lua", "luadoc", "markdown", "markdown_inline", "query",
    "regex", "rust", "terraform", "vim", "vimdoc", "yaml",
  },
}
