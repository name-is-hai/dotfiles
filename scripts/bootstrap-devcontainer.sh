#!/usr/bin/env bash
set -euo pipefail

# Called by setup-devcontainer.sh after configurations have been linked.
repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
project_dir=${1:?Project directory is required}
shift
configs=("$@")
selected() { [[ " ${configs[*]} " == *" $1 "* ]]; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

# System packages belong in the image; user tools and plugins belong to its user.
for tool in git curl tar unzip cc make python3; do
  command -v "$tool" >/dev/null || die "Missing image prerequisite: $tool"
done
if selected zsh; then
  command -v zsh >/dev/null || die 'Install zsh in the container image.'
fi
for dir in "${XDG_CACHE_HOME:-$HOME/.cache}" \
  "${XDG_STATE_HOME:-$HOME/.local/state}/mise" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/mise"; do
  mkdir -p "$dir" || die "Cannot create $dir. Fix its ownership in the container image."
  [[ -w $dir ]] || die "$dir is not writable. Fix its ownership in the container image."
done

export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null; then
  (
    installer=$(mktemp)
    trap 'rm -f -- "$installer"' EXIT
    curl -fsSL https://mise.run -o "$installer"
    MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer"
  )
fi
command -v mise >/dev/null || die 'Mise installation did not produce a usable executable.'
export MISE_GLOBAL_CONFIG_FILE="$repo_root/config/mise/config.toml"
mise trust "$MISE_GLOBAL_CONFIG_FILE"
cd "$project_dir"
# Full setup explicitly opts into running this project's tool configuration.
for config in mise.toml .mise.toml mise.local.toml .mise.local.toml; do
  [[ ! -f $config ]] || mise trust "$PWD/$config"
done
# Install selected config dependencies and project tools, not host-only extras.
tools=()
if selected nvim; then
  tools+=(neovim node tree-sitter rust fd ripgrep github:jesseduffield/lazygit)
fi
if selected zsh; then
  tools+=(starship fzf zoxide bat eza ripgrep)
fi
if selected tmux; then
  tools+=(tmux)
fi
if selected git; then
  tools+=(gh)
fi
project_tools_json=$(mise ls --local --json)
project_tool_names=$(python3 -c 'import json, sys; print("\n".join(json.load(sys.stdin)))' <<< "$project_tools_json")
if [[ -n $project_tool_names ]]; then
  mapfile -t project_tools <<< "$project_tool_names"
  tools+=("${project_tools[@]}")
fi
if (( ${#tools[@]} )); then
  mise install "${tools[@]}"
fi
mise_environment=$(mise env --shell bash)
eval "$mise_environment"
unset mise_environment

if selected nvim; then
  bash "$repo_root/scripts/bootstrap-nvim.sh"
fi
if selected zsh; then
  printf '[INFO] Preparing Zsh plugins...\n'
  zsh -ic '(( ${+functions[zinit]} )) && [[ -r "$ZINIT_HOME/zinit.zsh" ]] && command -v starship >/dev/null'
fi
if selected tmux; then
  (
    config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
    plugins="$config_home/tmux/plugins"
    tpm="$plugins/tpm"
    if [[ ! -f $tpm/tpm ]]; then
      mkdir -p "$plugins"
      git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
    fi
    # An isolated server avoids changing or killing existing user sessions.
    server="dotfiles-setup-$$"
    trap 'tmux -L "$server" kill-server >/dev/null 2>&1 || true' EXIT
    tmux -L "$server" -f "$config_home/tmux/tmux.conf" new-session -d -s bootstrap 'sleep 600'
    tmux -L "$server" set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugins/"
    tmux_address=$(tmux -L "$server" display-message -p '#{socket_path},#{pid},0')
    export TMUX="$tmux_address"
    bash "$tpm/bin/install_plugins"
  )
fi
