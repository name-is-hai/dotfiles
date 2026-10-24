# Neovim setup

Neovim 0.12+ with native `vim.pack`, Meowsoot, Snacks, Blink completion,
Mason language servers, Treesitter, and Conform formatting.

## Install or repair

Install Mise and system prerequisites first. On Fedora:

```bash
sudo dnf install mise git gcc curl tar unzip
```

From the dotfiles repository root:

```bash
./scripts/bootstrap-nvim.sh
```

The bootstrap links only Neovim and Mise, installs the pinned Neovim, Node/npm,
tree-sitter CLI, Rust/rustfmt, and fd versions, restores locked plugins, and
installs every configured language server, formatter, and parser. It waits for
downloads and compilation and returns a nonzero exit code on failure. Rerunning
it skips tools already at the configured versions and updates outdated parsers.
Network access is required.

If either configuration directory exists separately from this repository, use
`./scripts/bootstrap-nvim.sh --force` to back it up before replacing it with a
symlink. Configuration paths respect `XDG_CONFIG_HOME`.

Open a new shell after installation. The Zsh dotfiles activate Mise automatically.
For another shell, configure `mise activate`, or launch with:

```bash
mise exec neovim node tree-sitter rust fd -- nvim
```

Normal Neovim startup does not start Mason or parser installations. Plugins are
pinned in `nvim-pack-lock.json`; editor tool versions and parser selections are
in `lua/dependencies.lua`; runtime versions are in `config/mise/config.toml`.
Rerun the bootstrap after changing dependencies or updating plugins.

## Troubleshooting

- Missing npm: run the bootstrap, then reopen Neovim from a shell with Mise active.
- Inspect tool installations using `:Mason`, `:MasonLog`, and `:ConformInfo`.
- Use `:checkhealth` for editor and plugin diagnostics.
- `:TSInstallConfigured` installs missing parsers interactively; wait for it to
  finish before closing Neovim.
- Image previews require ImageMagick and a compatible terminal. They are disabled
  when no converter is available. A Nerd Font is recommended for icons.

Terraform projects still need their own `terraform init` to install project
modules/providers; the editor bootstrap does not initialize infrastructure.
