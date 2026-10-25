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

For a Fedora/COSMIC host using DevPod and Podman, configure the host first:

```bash
./scripts/setup-devpod.sh
```

This requires `gcr`, Podman, Python 3, and a running systemd user session. It
enables GCR's SSH agent socket, disables the previous `ssh-agent` service/socket,
refreshes the user-manager/D-Bus agent environment, and reports existing shell
overrides. It reuses an installed DevPod CLI or downloads one into `~/.local/bin`
without sudo, then configures the docker provider with `DOCKER_PATH=podman`.
Use `--ssh-agent-only` for the GCR fix alone, or `--update-cli` to download a new
CLI. `DEVPOD_VERSION` can select a release tag instead of `latest`.

Log out and back into COSMIC and restart DevPod afterward. For the current
terminal, use the `export SSH_AUTH_SOCK=...` command printed by the script.
Add your SSH key with `ssh-add` if needed. Run this on the host; the container
setup below keeps using the agent socket forwarded into the container.

Copy `scripts/setup-devcontainer.sh` into your project's
`.devcontainer/setup-dotfiles.sh` and commit that copy with the project. It is
standalone and clones the dotfiles repository inside the container when needed.
Add this to the existing `devcontainer.json` setup commands:

```jsonc
"postCreateCommand": "bash .devcontainer/setup-dotfiles.sh nvim mise zsh tmux git"
```

Run it as the container's development user. The image must supply Git, curl,
tar, unzip, a C compiler, make, Python 3, and Zsh when selected. The bootstrap installs
Mise if missing, trusts this checkout and the current project's Mise configs,
and installs the selected configs' dependencies plus project tools. Host-only
extras such as AI CLIs are skipped unless the project requests them.
It also completes the Neovim bootstrap,
warms Zsh plugins, and installs TPM/plugins when those configs are selected.
It waits for setup to finish and propagates failures instead of hiding them.
Mise is included automatically as a dependency of full setup.

The config names select what gets linked; omitting them uses the five above.
Overrides: `DOTFILES_REPO` (defaults to `https://github.com/name-is-hai/dotfiles.git`),
`DOTFILES_BRANCH` (`main`), and `DOTFILES_HOME` (`~/.local/share/dotfiles`).
The old `DOTFILES` repository URL variable is also accepted. `DOTFILES_PROJECT_DIR`
defaults to the working directory; set it when launching from outside the project.
Use `--link-only` to skip runtime installation and project trust:

```bash
bash .devcontainer/setup-dotfiles.sh --link-only nvim tmux
```

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
dotfiles clone. Commit and push them to sync with other machines. TPM downloads
are ignored by Git. GUI application installation stays outside container setup.
Commit and push the installers in this repository before using remote clones.

When downloading the setup script during creation, combine download and execution
in one command with `&&`; object entries in `postCreateCommand` run in parallel.
Include `zsh` if replacing an image's existing `~/.zshrc`.

If an image runs shell setup as root, ensure the development user owns its cache
and Mise state/tools before the final `USER dev`, for example:

```dockerfile
RUN install -d -o dev -g dev /home/dev/.cache /home/dev/.local/state /home/dev/.local/share/mise \
    && chown -R dev:dev /home/dev/.cache /home/dev/.local/state /home/dev/.local/share/mise
USER dev
```

Full setup handles Mise trust and tool installation; remove duplicate
`mise trust` / `mise install` commands and legacy Cosmkit postinstall calls from
your project lifecycle command. Use full setup only for projects you trust.

## Developer tools with Mise

Install [Mise](https://mise.jdx.dev/) through your distribution or its official installer, then run:

```bash
mise install
```

Mise manages developer tools such as Node, Python, Rust, Go, UV, Just, and Usage. Use the distribution package manager for system packages, GUI applications, drivers, and desktop services.
