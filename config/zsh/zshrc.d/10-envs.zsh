set -a

for env_file in "$HOME"/.config/environment.d/*.conf(N); do
  [[ -r "$env_file" ]] && source "$env_file"
done

set +a
