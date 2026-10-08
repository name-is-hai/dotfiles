# Personal dotfiles

Personal settings from this machine, including Ghostty, Neovim, Zsh/Starship, Git, Fcitx5-Unikey, Tmux, Zed, COSMIC, autostart, and environment configuration.

The editable `config/` tree holds the directly portable files. `archive/cosmkit-config-full.tar.gz` is a complete 427-file snapshot of the original Cosmkit configuration, including the full COSMIC state tree and Fcitx cache.

## Install configuration

```bash
./install.sh
```

Existing files are left alone. Use `./install.sh --force` to replace them after a timestamped backup.

## Developer tools with Mise

Install [Mise](https://mise.jdx.dev/) through your distribution or its official installer, then run:

```bash
mise install
```

Mise manages developer tools such as Node, Python, Rust, Go, UV, Just, and Usage. Use the distribution package manager for system packages, GUI applications, drivers, and desktop services.
