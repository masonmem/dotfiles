# Tool integrations

# fzf — sets Ctrl-T (file picker) and Alt-C (dir picker)
# Note: fzf also sets Ctrl-R, but atuin (loaded below) overrides it
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} 2>/dev/null | head -100'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"
fi

# atuin — enhanced history search; takes over Ctrl-R
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# zoxide — smart cd replacement (--cmd cd makes `cd` use zoxide transparently)
# `cd -` and normal path navigation work as expected; `zi` opens interactive picker
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
