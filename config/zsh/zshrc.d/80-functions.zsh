# Functions

mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Fuzzy cd using fd + fzf
cdf() {
  local dir

  if command -v fd >/dev/null 2>&1; then
    dir="$(fd --type d --hidden --exclude .git . | fzf)"
  else
    dir="$(find . -type d -not -path '*/.git/*' | fzf)"
  fi

  [[ -n "$dir" ]] && cd "$dir"
}

# Search files with rg + fzf + bat preview
ff() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    return 1
  fi

  if command -v fd >/dev/null 2>&1; then
    fd --type f --hidden --exclude .git |
      fzf --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || cat {}'
  else
    find . -type f -not -path '*/.git/*' |
      fzf --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || cat {}'
  fi
}

# Search text with ripgrep + fzf + bat preview
frg() {
  local query="${1:-}"

  if ! command -v rg >/dev/null 2>&1; then
    echo "rg not found"
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    return 1
  fi

  local selected
  selected="$(
    rg --color=always --line-number --column --no-heading --hidden --glob '!.git' "$query" |
      fzf \
        --ansi \
        --delimiter ':' \
        --preview-window 'right,60%,border-left' \
        --preview '
          file={1}
          line={2}

          start=$((line - 10))
          end=$((line + 20))

          [ "$start" -lt 1 ] && start=1

          bat \
            --style=numbers \
            --color=always \
            --highlight-line "$line" \
            --line-range "$start:$end" \
            "$file" 2>/dev/null
        '
  )"

  [[ -z "$selected" ]] && return

  local file line
  file="$(echo "$selected" | cut -d: -f1)"
  line="$(echo "$selected" | cut -d: -f2)"

  "${EDITOR:-nvim}" "+$line" "$file"
}

