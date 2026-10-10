# History control
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# User-installed programs such as mise live here. Put it before the system
# path so their managed shims and activation are available in every terminal.
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

setopt appendhistory

