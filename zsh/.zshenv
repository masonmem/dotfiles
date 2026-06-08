# ~/bin needs to be on PATH BEFORE .zshrc runs — p10k's instant-prompt
# cache spawns gitstatus which may need binaries from there (e.g. mkfifo
# on hosts whose system busybox lacks it). 00-path.zsh re-adds it later
# but by then the instant-prompt cache has already failed.
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Entware (QNAP / OpenWrt-style hosts) needs to be on PATH for
# non-interactive zsh too (e.g. `ssh hyperion nvim ...`, scripts), not
# only via 00-path.zsh which is .zshrc-only. Guarded so Mac hosts skip.
for _d in /opt/bin /opt/sbin /opt/usr/bin /opt/usr/sbin; do
  [[ -d "$_d" ]] && export PATH="$_d:$PATH"
done
unset _d

# Container Station docker on QNAP — same rationale as Entware above.
[[ -d /share/CACHEDEV3_DATA/.qpkg/container-station/bin ]] \
  && export PATH="/share/CACHEDEV3_DATA/.qpkg/container-station/bin:$PATH"

# Cargo env (only on hosts where rustup has been installed)
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Silence zoxide's chpwd-hook ordering warning. It fires whenever zoxide
# runs after another plugin (p10k/gitstatus) has registered its own
# chpwd hooks — the doctor wants zoxide initialized last, but reordering
# is brittle because plugin load order drifts. This is the documented
# opt-out; the warning is benign.
export _ZO_DOCTOR=0
