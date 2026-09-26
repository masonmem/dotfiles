# Aliases. Every alias for an optional tool is guarded, so a host without the
# tool (QNAP, minimal Linux, a container) keeps the real command instead of a
# broken alias. Personal-only aliases live in the `personal` package.

# --- Editors ---
if (( $+commands[nvim] )); then
  alias vi='nvim'
  alias vim='nvim'
fi

# --- Modern CLI replacements ---
(( $+commands[bat] )) && alias cat='bat --paging=auto'

if [[ -n "${DEVCONTAINER:-}" || -n "${REMOTE_CONTAINERS:-}" || -e /.dockerenv ]]; then
  # A host-built or cached eza can be incompatible with the container's
  # libc/CPU and has segfaulted `ls`. Keep native ls; eza stays callable.
  unalias ls ll la lt 2>/dev/null
  alias ll='command ls -alh'
  alias la='command ls -Ah'
elif (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -la --git --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --icons --group-directories-first'
fi

# --- Kubernetes ---
(( $+commands[kubecolor] )) && alias kubectl='kubecolor'
(( $+commands[kubectl] )) && alias k='kubectl'

# --- Python ---
(( $+commands[pip3] )) && alias pip='pip3'

# --- Claude Code ---
# Only the interactive `cc` is remapped; Makefiles and scripts still get the
# C compiler.
(( $+commands[claude] )) && alias cc='claude'

# --- Git ---
(( $+commands[lazygit] )) && alias lg='lazygit'
