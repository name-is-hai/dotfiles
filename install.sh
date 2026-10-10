#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
force=0
[[ ${1:-} == "--force" ]] && force=1

install_file() {
  local source=$1 destination=$2 backup
  if [[ -e $destination || -L $destination ]]; then
    if (( ! force )); then
      printf 'Keeping existing %s\n' "$destination"
      return
    fi
    backup="$destination.backup-$(date +%Y%m%d-%H%M%S)"
    cp -a -- "$destination" "$backup"
  fi
  install -d "$(dirname "$destination")"
  install -m 0644 "$source" "$destination"
  printf 'Installed %s\n' "$destination"
}

while IFS= read -r -d '' source; do
  relative=${source#"$repo_root/config"/}
  # Zsh reads its interactive configuration from $HOME, unlike programs
  # that follow XDG_CONFIG_HOME. Keep the source grouped with shell config,
  # but install it where Zsh actually loads it.
  if [[ $relative == "zsh/.zshrc" ]]; then
    install_file "$source" "$HOME/.zshrc"
    continue
  fi
  install_file "$source" "$HOME/.config/$relative"
done < <(find "$repo_root/config" -type f -print0 | sort -z)

if [[ -d $repo_root/home ]]; then
  while IFS= read -r -d '' source; do
    relative=${source#"$repo_root/home"/}
    install_file "$source" "$HOME/$relative"
  done < <(find "$repo_root/home" -type f -print0 | sort -z)
fi

printf '%s\n' 'Dotfiles installed. Run `mise install` in this repository for developer tools.'
