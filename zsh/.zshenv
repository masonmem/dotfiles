# ~/bin needs to be on PATH BEFORE .zshrc runs — p10k's instant-prompt
# cache spawns gitstatus which may need binaries from there (e.g. mkfifo
# on hosts whose system busybox lacks it). 00-path.zsh re-adds it later
# but by then the instant-prompt cache has already failed.
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Cargo env (only on hosts where rustup has been installed)
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
