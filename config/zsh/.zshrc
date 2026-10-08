# Generic modular zsh loader.
# Works even when ~/.zshrc is a symlink to any dotfiles repo.

_zshrc_path="${(%):-%N}"

# Resolve symlink if ~/.zshrc points to another file.
while [[ -L "$_zshrc_path" ]]; do
  _zshrc_dir="$(cd -P "$(dirname "$_zshrc_path")" >/dev/null 2>&1 && pwd)"
  _zshrc_path="$(readlink "$_zshrc_path")"

  [[ "$_zshrc_path" != /* ]] && _zshrc_path="$_zshrc_dir/$_zshrc_path"
done

_zshrc_dir="$(cd -P "$(dirname "$_zshrc_path")" >/dev/null 2>&1 && pwd)"

export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$_zshrc_dir}"

if [[ -d "$ZSH_CONFIG_DIR/zshrc.d" ]]; then
  for file in "$ZSH_CONFIG_DIR"/zshrc.d/*.zsh(N); do
    [[ -r "$file" ]] && source "$file"
  done
fi

unset _zshrc_path
unset _zshrc_dir
