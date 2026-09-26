# Per-host shell config. NOT tracked. To use on a host:
#
#   cp ~/dotfiles/templates/zsh-host.zsh ~/.config/zsh/90-$(hostname -s).zsh
#
# ~/.zshrc sources ~/.config/zsh/*.zsh in name order, so 90-* runs last and
# can override earlier aliases and variables. Settings that must exist BEFORE
# oh-my-zsh / powerlevel10k load (ZSH_THEME, POWERLEVEL9K_*) belong in
# ~/.zshrc.early.local instead.

# ── Example: solaris (always-on Mac mini) ───────────────────────────────────
# # Land in tmux over SSH, so a dropped connection doesn't kill long sessions.
# if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then
#   tmux attach -t default || tmux new -s default
# fi
# # Reach the LiteLLM gateway locally instead of through the proxy.
# export LITELLM_BASE_URL="http://localhost:4000/v1"

# ── Example: work laptop ────────────────────────────────────────────────────
# alias kw='kubectl --context=work-prod'
# alias ks='kubectl --context=work-staging'
# export DEXEC_FALLBACKS="my-project-devenv devenv"

# ── Example: hyperion (QNAP) ────────────────────────────────────────────────
# alias g=git gs='git status' d=docker dc='docker compose'
# alias dcontainers='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"'
