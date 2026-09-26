#!/usr/bin/env bash
# End-to-end: link zsh/p10k/git/personal into a throwaway $HOME, install the
# pinned shell framework with bootstrap-shell (needs network), then start
# real shells and require a clean startup. Needs git, stow and zsh.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
export HOME; HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT
unset ZSH ZDOTDIR XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME AI_CONFIG

fails=0
pass() { printf '  ok   %s\n' "$*"; }
fail() { printf '  FAIL %s\n' "$*"; fails=$((fails + 1)); }

ln -s "$REPO" "$HOME/dotfiles"
mkdir -p "$HOME/bin"
stow --no-folding -d "$REPO" -t "$HOME" zsh p10k git personal
"$REPO/bin/bootstrap-shell" > "$HOME/bootstrap.out" 2>&1 || { cat "$HOME/bootstrap.out"; exit 1; }

# Interactive shell: no errors at all, twice (the second run uses the caches).
for run in first second; do
  out="$(TERM=xterm-256color zsh -i -c 'print -r -- READY' 2> "$HOME/err")" || true
  if [[ "$out" == *READY* && ! -s "$HOME/err" ]]; then
    pass "interactive startup is clean ($run run)"
  else
    fail "interactive startup ($run run):"; sed 's/^/       /' "$HOME/err"
  fi
done

# Every modular file was sourced (spot-check functions/aliases they define).
defined="$(TERM=xterm-256color zsh -i -c 'whence -w copilot nvm; alias cc lg 2>/dev/null; print -r -- $EDITOR' 2>/dev/null)"
if [[ "$defined" == *"copilot: function"* && "$defined" == *"nvm: function"* ]]; then
  pass "modular config sourced"
else
  fail "modular config not sourced: $defined"
fi
if [[ "$(zsh -i -c 'print -r -- $COPILOT_OTEL_ENABLED' 2>/dev/null)" == true ]]; then
  pass "personal package config sourced"
else
  fail "personal package config not sourced"
fi

# PATH: ours first, in every kind of shell; no duplicates.
for mode in "-c" "-l -c" "-i -c"; do
  # shellcheck disable=SC2086
  first="$(zsh $mode 'print -r -- ${path[1]} ${path[2]}' 2>/dev/null | tail -1)"
  if [[ "$first" == "$HOME/bin $HOME/dotfiles/bin" ]]; then
    pass "zsh $mode: PATH starts with ~/bin ~/dotfiles/bin"
  else
    fail "zsh $mode: PATH starts with: $first"
  fi
done
dupes="$(zsh -l -c 'print -rl -- $path' | sort | uniq -d)"
if [[ -z "$dupes" ]]; then pass "PATH has no duplicates"; else fail "duplicate PATH entries: $dupes"; fi
command_path="$(zsh -c 'command -v dotfiles-sync')"
if [[ "$command_path" == "$HOME/dotfiles/bin/dotfiles-sync" ]]; then
  pass "non-interactive shells find dotfiles-sync"
else
  fail "dotfiles-sync resolves to: $command_path"
fi

# Re-running bootstrap-shell is a no-op.
"$REPO/bin/bootstrap-shell" > "$HOME/bootstrap2.out" 2>&1
if [[ "$(grep -c 'at pin' "$HOME/bootstrap2.out")" == 4 ]]; then pass "bootstrap-shell is idempotent"; else
  fail "bootstrap-shell second run:"; cat "$HOME/bootstrap2.out"; fi

if (( fails )); then echo "shell startup: $fails check(s) failed"; exit 1; fi
echo "shell startup: all checks passed"
