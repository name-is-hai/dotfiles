#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( $# > 1 )) || [[ ${1:-} != "" && ${1:-} != --force ]]; then
  printf '%s\n' 'Usage: scripts/bootstrap-nvim.sh [--force]' >&2
  exit 1
fi
for tool in mise git cc curl tar unzip; do
  command -v "$tool" >/dev/null || {
    printf 'Missing prerequisite: %s. See config/nvim/README.md.\n' "$tool" >&2
    exit 1
  }
done

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
for name in nvim mise; do
  destination="$config_home/$name"
  if [[ -e $destination || -L $destination ]] &&
    [[ $(readlink -f -- "$destination") != "$repo_root/config/$name" ]] &&
    [[ ${1:-} != --force ]]; then
    printf '%s exists separately. Use --force to back it up and link this repository.\n' "$destination" >&2
    exit 1
  fi
done
for name in nvim mise; do
  "$repo_root/install.sh" --only "$name" "$@"
done

export MISE_GLOBAL_CONFIG_FILE="$repo_root/config/mise/config.toml"
cd "$repo_root"
mise trust "$MISE_GLOBAL_CONFIG_FILE"
mise install neovim node tree-sitter rust fd
export DOTFILES_NVIM_CONFIG="$repo_root/config/nvim"
mise exec neovim node tree-sitter rust fd -- nvim --headless -u NONE -l "$repo_root/scripts/bootstrap-nvim.lua"
printf '\n%s\n' 'Neovim bootstrap complete. Open a new shell, then run nvim.'
