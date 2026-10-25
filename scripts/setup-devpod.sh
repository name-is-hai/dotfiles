#!/usr/bin/env bash
set -euo pipefail

# Fedora/COSMIC host setup. Run before creating containers, not inside one.
log_info() { printf '[INFO] %s\n' "$*"; }
log_ok() { printf '[OK] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }

agent_only=0
update_cli=0
for arg in "$@"; do
  case $arg in
    --ssh-agent-only) agent_only=1 ;;
    --update-cli) update_cli=1 ;;
    -h|--help)
      printf '%s\n' \
        'Usage: setup-devpod.sh [--ssh-agent-only] [--update-cli]' \
        'Set up GCR SSH agent and DevPod with the Podman-backed docker provider.' \
        '--ssh-agent-only configures GCR without installing/configuring DevPod.' \
        '--update-cli replaces an existing DevPod CLI in ~/.local/bin.' \
        'DEVPOD_VERSION selects a download release tag (default: latest).'
      exit 0
      ;;
    *) die "Unknown option: $arg (use --help)" ;;
  esac
done

download_dir=""
cleanup() {
  if [[ -n $download_dir ]]; then
    rm -f -- "$download_dir/devpod"
    rmdir -- "$download_dir"
  fi
}
trap cleanup EXIT

install_devpod_cli() {
  if command -v devpod >/dev/null 2>&1 && (( ! update_cli )); then
    log_ok 'Using the existing DevPod CLI (use --update-cli to replace it).'
    return
  fi

  require_cmd curl
  local arch release_url
  case $(uname -m) in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) die "Unsupported architecture: $(uname -m)" ;;
  esac
  if [[ ${DEVPOD_VERSION:-latest} == latest ]]; then
    release_url=https://github.com/loft-sh/devpod/releases/latest/download
  else
    release_url="https://github.com/loft-sh/devpod/releases/download/$DEVPOD_VERSION"
  fi

  log_info "Installing DevPod CLI for Linux $arch..."
  download_dir=$(mktemp -d)
  curl --fail --show-error --location --retry 3 \
    --output "$download_dir/devpod" "$release_url/devpod-linux-$arch"
  chmod +x "$download_dir/devpod"
  "$download_dir/devpod" version
  install -d "$HOME/.local/bin"
  install -m 0755 "$download_dir/devpod" "$HOME/.local/bin/devpod"
  log_ok 'DevPod CLI installed in ~/.local/bin.'
}

setup_devpod_podman_provider() {
  local providers provider_registered
  providers=$(devpod provider list --output json)
  provider_registered=$(python3 -c \
    'import json, sys; print("yes" if "docker" in json.load(sys.stdin) else "no")' <<< "$providers")
  if [[ $provider_registered == no ]]; then
    log_info 'Adding the docker provider with Podman...'
    devpod provider add docker --option DOCKER_PATH=podman
  else
    log_info 'Updating the docker provider to use Podman...'
    devpod provider set-options docker --option DOCKER_PATH=podman
  fi
  log_ok 'DevPod docker provider configured to use Podman.'
}

setup_gcr_ssh_agent() {
  local units unit runtime_dir config_home path status
  log_info 'Setting up GCR SSH agent...'
  rpm -q gcr >/dev/null 2>&1 || die 'gcr is not installed. Install it with: sudo dnf install gcr'
  systemctl --user daemon-reload
  units=$(systemctl --user list-unit-files --no-legend --no-pager)
  if ! awk '$1 == "gcr-ssh-agent.socket" { found = 1 } END { exit !found }' <<< "$units"; then
    die 'gcr-ssh-agent.socket was not found. Restart your login session after installing GCR, then rerun.'
  fi

  # Start the replacement before stopping the old agent and its activating socket.
  systemctl --user enable --now gcr-ssh-agent.socket
  runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  [[ -S $runtime_dir/gcr/ssh ]] || die "GCR socket was not created at $runtime_dir/gcr/ssh"
  export SSH_AUTH_SOCK="$runtime_dir/gcr/ssh"

  for unit in ssh-agent.socket ssh-agent.service; do
    if awk -v unit="$unit" '$1 == unit { found = 1 } END { exit !found }' <<< "$units"; then
      log_info "Disabling $unit..."
      systemctl --user disable --now "$unit"
    fi
  done

  # Refresh the manager even when the socket was already active before this run.
  systemctl --user set-environment "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
  if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd SSH_AUTH_SOCK
  fi
  log_ok "GCR SSH agent socket: $SSH_AUTH_SOCK"

  log_info 'Current SSH_AUTH_SOCK definitions:'
  config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
  local definitions=()
  for path in "$HOME/.profile" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zshrc" \
    "$config_home/zsh/zshrc.d" "$config_home/environment.d"; do
    [[ ! -e $path ]] || definitions+=("$path")
  done
  if (( ${#definitions[@]} )); then
    if grep -Rn -- 'SSH_AUTH_SOCK' "${definitions[@]}"; then
      log_warn 'Check the definitions above for overrides pointing at an old agent.'
    else
      status=$?
      [[ $status == 1 ]] || log_warn 'Some shell/environment definitions could not be read.'
    fi
  fi
}

[[ $(uname -s) == Linux ]] || die 'This setup script is for a Fedora/COSMIC Linux host.'
for command in rpm systemctl awk grep; do
  require_cmd "$command"
done
if (( ! agent_only )); then
  for command in podman python3 install; do
    require_cmd "$command"
  done
fi

export PATH="$HOME/.local/bin:$PATH"
setup_gcr_ssh_agent
if (( ! agent_only )); then
  install_devpod_cli
  setup_devpod_podman_provider
fi

log_ok 'Host setup finished.'
log_warn 'Log out and back into COSMIC, then restart DevPod so GUI apps inherit SSH_AUTH_SOCK.'
printf '%s\n' \
  'To use the agent immediately in this terminal:' \
  "  export SSH_AUTH_SOCK=\"$SSH_AUTH_SOCK\"" \
  'Checks:' \
  '  echo "$SSH_AUTH_SOCK"' \
  '  systemctl --user status gcr-ssh-agent.socket' \
  '  ssh-add -l' \
  '  ssh-add ~/.ssh/id_ed25519' \
  '  ssh -T git@github.com'
