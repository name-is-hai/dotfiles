# File system
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lha --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --long --icons --git'
  alias lta='lt -a'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

if command -v btop >/dev/null 2>&1; then
  alias top='btop'
fi

if command -v eza >/dev/null 2>&1; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi


# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
