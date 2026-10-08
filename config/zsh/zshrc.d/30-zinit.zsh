ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# Prompt
zinit snippet OMZP::starship

# General plugins
zinit snippet OMZP::git
zinit light djui/alias-tips
zinit light hlissner/zsh-autopair

# Completion definitions must be available before compinit
zinit light zsh-users/zsh-completions

# Must be after compinit
zinit light Aloxaf/fzf-tab

# History
zinit light zsh-users/zsh-history-substring-search
zinit load zdharma-continuum/history-search-multi-word

# UI plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
