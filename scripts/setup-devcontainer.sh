#!/usr/bin/env bash
set -euo pipefail

# Standalone: copy this file into a project's .devcontainer directory.
DOTFILES_REPO=${DOTFILES_REPO:-${DOTFILES:-https://github.com/name-is-hai/dotfiles.git}}
DOTFILES_BRANCH=${DOTFILES_BRANCH:-main}
DOTFILES_HOME=${DOTFILES_HOME:-"$HOME/.local/share/dotfiles"}

log_info() { printf '[INFO] %s\n' "$*"; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' \
    'Usage: setup-devcontainer.sh [--update] [--link-only] [CONFIG ...]' \
    'Defaults: nvim mise zsh tmux git' \
    'Available: fcitx5 ghostty git mise nvim tmux zed zsh' \
    'Clones dotfiles, links configs, and installs tools and selected plugins.' \
    '--link-only skips tool installation and project trust.' \
    '--update fast-forwards an existing clean checkout on DOTFILES_BRANCH.' \
    'Configure DOTFILES_REPO, DOTFILES_BRANCH, and DOTFILES_HOME as needed.' \
    'DOTFILES_PROJECT_DIR selects the project (default: current directory).'
}

update=0
link_only=0
project_dir=${DOTFILES_PROJECT_DIR:-$PWD}
configs=()
for arg in "$@"; do
  case $arg in
    -h|--help) usage; exit 0 ;;
    --update) update=1 ;;
    --link-only) link_only=1 ;;
    fcitx5|ghostty|git|mise|nvim|tmux|zed|zsh) configs+=("$arg") ;;
    *) die "Unknown config or option: $arg (use --help)" ;;
  esac
done
if (( ${#configs[@]} == 0 )); then
  configs=(nvim mise zsh tmux git)
fi
if (( ! link_only )); then
  [[ -d $project_dir ]] || die "Project directory does not exist: $project_dir"
  # All runtime versions come from the repository's Mise config.
  if [[ " ${configs[*]} " != *' mise '* ]]; then
    configs+=(mise)
  fi
fi

command -v git >/dev/null 2>&1 || die 'Install git in the container image first.'

new_clone=0
if [[ ! -e $DOTFILES_HOME && ! -L $DOTFILES_HOME ]]; then
  log_info "Cloning dotfiles into $DOTFILES_HOME"
  mkdir -p -- "$(dirname -- "$DOTFILES_HOME")"
  git clone --branch "$DOTFILES_BRANCH" --filter=blob:none --sparse \
    -- "$DOTFILES_REPO" "$DOTFILES_HOME"
  new_clone=1
else
  # Do not mistake a directory inside a parent repository for a dotfiles clone.
  [[ -d $DOTFILES_HOME/.git || -f $DOTFILES_HOME/.git ]] ||
    die "$DOTFILES_HOME exists but is not a Git checkout; choose another DOTFILES_HOME."
  git -C "$DOTFILES_HOME" rev-parse --is-inside-work-tree >/dev/null ||
    die "Invalid Git checkout: $DOTFILES_HOME"
  log_info "Reusing $DOTFILES_HOME"
fi

DOTFILES_HOME=$(cd -- "$DOTFILES_HOME" && pwd -P)
if (( update && ! new_clone )); then
  current_branch=$(git -C "$DOTFILES_HOME" symbolic-ref --quiet --short HEAD) ||
    die 'Checkout has a detached HEAD; switch branches manually before updating.'
  [[ $current_branch == "$DOTFILES_BRANCH" ]] ||
    die "Checkout is on $current_branch; expected $DOTFILES_BRANCH. Switch branches manually."
  [[ -z $(git -C "$DOTFILES_HOME" status --porcelain) ]] ||
    die 'Checkout has local changes. Commit or stash them before using --update.'
  log_info "Updating $DOTFILES_BRANCH with a fast-forward merge"
  git -C "$DOTFILES_HOME" fetch origin "$DOTFILES_BRANCH"
  git -C "$DOTFILES_HOME" merge --ff-only FETCH_HEAD
fi

paths=(scripts)
for config in "${configs[@]}"; do
  paths+=("config/$config")
done
if (( new_clone )); then
  # Cone mode includes root files such as install.sh automatically.
  git -C "$DOTFILES_HOME" sparse-checkout set --cone "${paths[@]}"
elif [[ $(git -C "$DOTFILES_HOME" config --bool core.sparseCheckout || true) == true ]]; then
  [[ $(git -C "$DOTFILES_HOME" config --bool core.sparseCheckoutCone || true) == true ]] ||
    die 'Existing sparse checkout uses non-cone patterns; expand it manually before running setup.'
  # Expand existing sparse selections so previously linked configs stay present.
  git -C "$DOTFILES_HOME" sparse-checkout add "${paths[@]}"
fi

# Check the entire selection before replacing any container configuration.
[[ -f $DOTFILES_HOME/install.sh ]] || die "Missing $DOTFILES_HOME/install.sh"
if (( ! link_only )); then
  [[ -f $DOTFILES_HOME/scripts/bootstrap-devcontainer.sh ]] ||
    die 'Runtime bootstrap is missing. Update the checkout or use --link-only.'
fi
for config in "${configs[@]}"; do
  [[ -d $DOTFILES_HOME/config/$config && -f $DOTFILES_HOME/scripts/install-$config.sh ]] ||
    die "Missing installer for $config. Commit and push the config installers, then update the checkout."
done

for config in "${configs[@]}"; do
  log_info "Linking $config"
  bash "$DOTFILES_HOME/scripts/install-$config.sh" --force
done

if (( link_only )); then
  log_info 'Devcontainer configs linked.'
else
  bash "$DOTFILES_HOME/scripts/bootstrap-devcontainer.sh" "$project_dir" "${configs[@]}"
  log_info 'Devcontainer setup complete. Your tools and selected plugins are ready.'
fi
