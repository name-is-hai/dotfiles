# Personal dotfiles

Personal settings from this machine, including Ghostty, Neovim, Zsh/Starship, Git, Fcitx5-Unikey, Tmux, Zed, COSMIC, autostart, and environment configuration.

The editable `config/` tree holds the directly portable files. `archive/cosmkit-config-full.tar.gz` is a complete 427-file snapshot of the original Cosmkit configuration, including the full COSMIC state tree and Fcitx cache.

## Install configuration

```bash
./install.sh
```

Existing files are left alone. Use `./install.sh --force` to replace them after a timestamped backup.

Each configuration also has its own installer in `scripts/`:

```bash
./scripts/install-ghostty.sh
./scripts/install-nvim.sh
./scripts/install-zsh.sh --force
```

Available installers: `fcitx5`, `ghostty`, `git`, `mise`, `nvim`, `tmux`, `zed`,
and `zsh`. All accept `--force` and `--help`. They only link config files;
applications, dependencies, and plugins are installed separately.

Each installer links `${XDG_CONFIG_HOME:-$HOME/.config}/NAME` directly to
`config/NAME` in **this checkout**. Editing either path changes the same files,
so there are no separate copies to sync. Keep this repository in place after
installation, and use Git to sync it between machines. The Zsh installer also
links `~/.zshrc` to this repository's entry point. Existing files/directories
and links to other checkouts are preserved unless `--force` is supplied.

Install or repair Neovim's complete toolchain with:

```bash
./scripts/bootstrap-nvim.sh
```

See [Neovim setup](config/nvim/README.md) for prerequisites and existing-config backups.

## Devcontainers without local dotfiles

Copy `scripts/setup-devcontainer.sh` into your project's
`.devcontainer/setup-dotfiles.sh` and commit that copy with the project. It is
standalone and clones the dotfiles repository inside the container when needed.
Add this to the existing `devcontainer.json` setup commands:

```jsonc
"postCreateCommand": {
  "dotfiles": "bash .devcontainer/setup-dotfiles.sh nvim mise zsh tmux git"
}
```

Run it as the container's development user, with Git installed in the image.
The config names select what gets linked; omitting them uses the five above.
Overrides: `DOTFILES_REPO` (defaults to `https://github.com/name-is-hai/dotfiles.git`),
`DOTFILES_BRANCH` (`main`), and `DOTFILES_HOME` (`~/.local/share/dotfiles`).
The old `DOTFILES` repository URL variable is also accepted.

Fresh clones use sparse checkout for the selected configs and `scripts/`, with
root files such as `install.sh` included. Existing clones are reused; sparse
selections are expanded without removing earlier configs. Full clones stay full.
Conflicting container configs are backed up before linking, and repeated setup
keeps correct symlinks. To fetch changes later, run:

```bash
bash .devcontainer/setup-dotfiles.sh --update nvim mise zsh tmux git
```

Updates require a clean checkout on the requested branch and only fast-forward;
local edits are preserved. Config edits through the links update the container's
dotfiles clone. Commit and push them to sync with other machines. Applications,
Neovim tools, Mise tool installation, and TPM setup remain separate steps.
Commit and push the installers in this repository before using remote clones.

## Developer tools with Mise

Install [Mise](https://mise.jdx.dev/) through your distribution or its official installer, then run:

```bash
mise install
```

Mise manages developer tools such as Node, Python, Rust, Go, UV, Just, and Usage. Use the distribution package manager for system packages, GUI applications, drivers, and desktop services.
