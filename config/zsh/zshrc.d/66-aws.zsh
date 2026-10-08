if command -v aws >/dev/null 2>&1 && command -v aws_completer >/dev/null 2>&1; then
  autoload -Uz bashcompinit
  bashcompinit

  complete -C "$(command -v aws_completer)" aws
  export AWS_CLI_AUTO_PROMPT=on-partial
fi
