# Interactive environment. (PATH and XDG dirs live in ~/.zshenv.)

# Editor: nvim when present, so `git commit` still works on hosts without it.
if (( $+commands[nvim] )); then
  export EDITOR="nvim"
elif (( $+commands[vim] )); then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"

export BAT_THEME="Catppuccin Macchiato"   # bat, fzf previews, and delta
export LESS="-R --use-color"
export NVM_DIR="$HOME/.nvm"               # nvm itself is lazy-loaded in 70-nvm.zsh
