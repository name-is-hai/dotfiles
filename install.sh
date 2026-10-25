#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
usage() {
  printf '%s\n' \
    'Usage: install.sh [--force] [--only CONFIG_NAME]' \
    'Link configurations to this dotfiles repository.' \
    'Existing configurations are kept unless --force is used to back them up.' \
    'For one configuration: ./scripts/install-CONFIG_NAME.sh [--force]'
}

force=0
only=""
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
while (( $# )); do
  case $1 in
    -h|--help) usage; exit 0 ;;
    --force) force=1; shift ;;
    --only)
      [[ $# -ge 2 && -d $repo_root/config/$2 && $2 != */* && $2 != . && $2 != .. ]] || {
        usage >&2
        exit 1
      }
      only=$2
      shift 2
      ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
done

link_path() {
  local source=$1 destination=$2 backup backup_base suffix=0

  if [[ -L $destination ]] && [[ $(readlink -f -- "$destination") == $(readlink -f -- "$source") ]]; then
    printf 'Linked %s\n' "$destination"
    return
  fi

  if [[ -e $destination || -L $destination ]]; then
    if (( ! force )); then
      printf 'Keeping existing %s (run with --force to replace it with a symlink)\n' "$destination"
      return
    fi
    backup_base="$destination.backup-$(date +%Y%m%d-%H%M%S)"
    backup=$backup_base
    while [[ -e $backup || -L $backup ]]; do
      suffix=$((suffix + 1))
      backup="$backup_base-$suffix"
    done
    mv -- "$destination" "$backup"
    printf 'Backed up %s to %s\n' "$destination" "$backup"
  fi

  install -d "$(dirname "$destination")"
  ln -s "$source" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source"
}

# Each configuration is a directory symlink. This keeps edits from either
# ~/.config/<name> or the repository immediately synchronized and avoids a
# partial copy drifting from its source.
while IFS= read -r -d '' source; do
  name=$(basename "$source")
  [[ -z $only || $name == "$only" ]] || continue
  link_path "$source" "$config_home/$name"
done < <(find "$repo_root/config" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

# Zsh reads this one entry point from $HOME. Its sibling zshrc.d directory is
# available through the ~/.config/zsh link above.
if [[ -z $only || $only == zsh ]]; then
  link_path "$repo_root/config/zsh/.zshrc" "$HOME/.zshrc"
fi

if [[ -z $only && -d $repo_root/home ]]; then
  while IFS= read -r -d '' source; do
    relative=${source#"$repo_root/home"/}
    link_path "$source" "$HOME/$relative"
  done < <(find "$repo_root/home" -type f -print0 | sort -z)
fi

printf '%s\n' 'Configuration links installed.'
