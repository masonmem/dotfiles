# Completions
# Most tool completions are auto-provided by Homebrew's site-functions —
# see the fpath setup in ~/.zshrc (before oh-my-zsh).

# kubectl (from Docker Desktop, not Homebrew — cached to file)
# To regenerate: rm ~/.config/zsh/completions/_kubectl && exec zsh
if command -v kubectl >/dev/null 2>&1; then
  if [[ ! -f "$HOME/.config/zsh/completions/_kubectl" ]]; then
    kubectl completion zsh > "$HOME/.config/zsh/completions/_kubectl" 2>/dev/null
  fi
  # kubecolor wraps kubectl — reuse kubectl's completions
  compdef kubecolor=kubectl 2>/dev/null
fi

# iTerm2 shell integration (track cwd, history, SSH)
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"
