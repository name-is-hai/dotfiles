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
  install_file "$source" "$HOME/.config/$relative"
done < <(find "$repo_root/config" -type f -print0 | sort -z)

while IFS= read -r -d '' source; do
  relative=${source#"$repo_root/home"/}
  install_file "$source" "$HOME/$relative"
done < <(find "$repo_root/home" -type f -print0 | sort -z)

printf '%s\n' 'Dotfiles installed. Run `mise install` in this repository for developer tools.'
