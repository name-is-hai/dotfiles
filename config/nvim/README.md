# My Neovim Config

A modular Neovim setup using neovim native.

## Features
- **Theme**: Catppuccin
- **Language Support**: LSP, Treesitter, Blink.cmp (completion)
- **Formatting**: `conform.nvim` (Biome for web, CSharpier for .NET)
- **Debugging**: `nvim-dap`

## Structure
- `init.lua`: Main entry point.
- `lua`: Core settings and keymaps.
- `plugins`: Plugin configurations.

## Installation
Clone into `~/.config/nvim`:
```bash
git clone <repo_url> ~/.config/nvim
```
Plugins will install automatically on first launch.
