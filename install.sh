#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
force=0
[[ ${1:-} == "--force" ]] && force=1

link_path() {
  local source=$1 destination=$2 backup

  if [[ -L $destination ]] && [[ $(readlink -f -- "$destination") == $(readlink -f -- "$source") ]]; then
    printf 'Linked %s\n' "$destination"
    return
  fi

  if [[ -e $destination || -L $destination ]]; then
    if (( ! force )); then
      printf 'Keeping existing %s (run with --force to replace it with a symlink)\n' "$destination"
      return
    fi
    backup="$destination.backup-$(date +%Y%m%d-%H%M%S)"
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
  link_path "$source" "$HOME/.config/$name"
done < <(find "$repo_root/config" -mindepth 1 -maxdepth 1 -print0 | sort -z)

# Zsh reads this one entry point from $HOME. Its sibling zshrc.d directory is
# available through the ~/.config/zsh link above.
link_path "$repo_root/config/zsh/.zshrc" "$HOME/.zshrc"

if [[ -d $repo_root/home ]]; then
  while IFS= read -r -d '' source; do
    relative=${source#"$repo_root/home"/}
    link_path "$source" "$HOME/$relative"
  done < <(find "$repo_root/home" -type f -print0 | sort -z)
fi

printf '%s\n' 'Dotfiles installed. Run `mise install` in this repository for developer tools.'
