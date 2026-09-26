#!/usr/bin/env bash
# Integration test for install.sh + bin/dotfiles-sync in a throwaway $HOME
# with a throwaway "origin". Offline: brew, pipx and hostname are shims and
# bootstrap-shell gets an empty manifest. Needs git and GNU stow.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fails=0
pass() { printf '  ok   %s\n' "$*"; }
fail() { printf '  FAIL %s\n' "$*"; fails=$((fails + 1)); }
check() { local desc="$1"; shift; if "$@"; then pass "$desc"; else fail "$desc"; fi; }
is_link() { [[ -L "$HOME/$1" && -e "$HOME/$1" ]]; }
absent()  { [[ ! -e "$HOME/$1" && ! -L "$HOME/$1" ]]; }
links()   { (cd "$HOME" && find . -path ./dotfiles -prune -o -type l -print | sed 's|^\./||' | sort); }

# ── fixtures ────────────────────────────────────────────────────────────────
# Snapshot the working tree (tracked + untracked, minus ignored) as the origin.
mkdir -p "$WORK/snap"
(cd "$REPO" && git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' f; do
  [[ -e "$f" || -L "$f" ]] && printf '%s\0' "$f"
done | xargs -0 tar cf -) | tar xf - -C "$WORK/snap"
git -C "$WORK/snap" init -q -b main
git -C "$WORK/snap" add -A
git -C "$WORK/snap" -c user.name=t -c user.email=t@t commit -qm snapshot
git clone -q --bare "$WORK/snap" "$WORK/origin.git"

SHIMS="$WORK/shims"; mkdir -p "$SHIMS"
cat > "$SHIMS/brew" <<'EOF'
#!/bin/sh
echo "brew $*" >> "$SHIM_LOG"
EOF
cat > "$SHIMS/pipx" <<'EOF'
#!/bin/sh
case "$1" in
  list) echo "py_natpmp 1.3.2" ;;         # already installed (non-canonical spelling)
  *) echo "pipx $*" >> "$SHIM_LOG" ;;
esac
EOF
printf '#!/bin/sh\necho Solaris\n' > "$SHIMS/hostname"
printf '#!/bin/sh\necho Solaris\n' > "$SHIMS/scutil"   # macOS: dotfiles-sync asks scutil
chmod +x "$SHIMS"/*
: > "$WORK/empty-manifest"

# The current PATH minus stow, for the built-in linker.
NOSTOW="$WORK/nostow"; mkdir -p "$NOSTOW"
IFS=: read -r -a path_dirs <<<"$PATH"
for d in "${path_dirs[@]}"; do
  for f in "$d"/*; do
    [[ -x "$f" && ! -d "$f" ]] || continue
    n="${f##*/}"
    [[ "$n" == stow || -e "$NOSTOW/$n" ]] || ln -s "$f" "$NOSTOW/$n"
  done
done

new_home() {   # fresh $HOME with a clone of origin at ~/dotfiles
  export HOME="$WORK/home-$1"
  rm -rf "$HOME"; mkdir -p "$HOME"
  git clone -q "$WORK/origin.git" "$HOME/dotfiles"
  git -C "$HOME/dotfiles" config user.name t
  git -C "$HOME/dotfiles" config user.email t@t
  export SHIM_LOG="$HOME/shim.log"; : > "$SHIM_LOG"
  export XDG_CONFIG_HOME="$HOME/.config"
  unset DOTFILES
}
export SHELL_CLONES_MANIFEST="$WORK/empty-manifest"
BASE_PATH="$SHIMS:$PATH"
NOSTOW_PATH="$SHIMS:$NOSTOW"
run_sync() { "$HOME/dotfiles/bin/dotfiles-sync" > "$HOME/sync.out" 2>&1; }

run_suite() {   # <label> <PATH>
  local label="$1"; export PATH="$2"
  echo "── $label"

  new_home "$label-none"
  if run_sync; then fail "sync without a package list should fail"; else
    check "no package list → clear error" grep -q "install.sh" "$HOME/sync.out"; fi

  new_home "$label-work"
  echo "pre-existing" > "$HOME/.zprofile"
  "$HOME/dotfiles/install.sh" work > "$HOME/install.out" 2>&1 || { fail "install.sh work"; cat "$HOME/install.out"; }
  check "work: shared zsh config linked"           is_link .zshrc
  check "work: modular zsh file linked"            is_link .config/zsh/10-env.zsh
  check "work: git config linked"                  is_link .gitconfig
  check "work: existing file moved aside"          grep -qx "pre-existing" "$HOME/.zprofile.pre-dotfiles"
  check "work: .zprofile now linked"               is_link .zprofile
  check "work: NO personal zsh"                    absent .config/zsh/50-personal.zsh
  check "work: NO ollama config"                   absent .aider.conf.yml
  check "work: gitconfig.local from template"      test -f "$HOME/.gitconfig.local"
  check "work: ssh config is private"              test "$(stat -c %a "$HOME/.ssh/config" 2>/dev/null || stat -f %Lp "$HOME/.ssh/config")" = 600
  check "work: shared Brewfile only"               test "$(grep -c 'bundle' "$SHIM_LOG")" = 2   # Brewfile + solaris host file
  check "work: host Brewfile from hostname"        grep -q "Brewfile.d/solaris.Brewfile" "$SHIM_LOG"
  check "work: no personal Brewfile"               bash -c "! grep -q 'personal/Brewfile\|ollama/Brewfile' '$SHIM_LOG'"
  check "work: no pipx installs"                   bash -c "! grep -q '^pipx' '$SHIM_LOG'"
  check "work: reports unselected packages"        grep -q "not enabled on this host: .*personal" "$HOME/install.out"

  new_home "$label-personal"
  "$HOME/dotfiles/install.sh" personal > "$HOME/install.out" 2>&1 || { fail "install.sh personal"; cat "$HOME/install.out"; }
  check "personal: personal zsh linked"            is_link .config/zsh/50-personal.zsh
  check "personal: ollama config linked"           is_link .aider.conf.yml
  check "personal: litellm-keys in ~/bin"          is_link bin/litellm-keys
  for f in Brewfile pipx-tools.txt README.md .stow-local-ignore launchagents bin/install-ollama.sh; do
    check "personal: package metadata '$f' not in \$HOME" absent "$f"
  done
  check "personal: brew order shared→packages→host" \
    test "$(grep -o 'file=[^ ]*' "$SHIM_LOG" | sed "s|file=$HOME/dotfiles/||" | tr '\n' ' ')" = \
         "Brewfile personal/Brewfile ollama/Brewfile Brewfile.d/solaris.Brewfile "
  check "personal: pipx installs missing tools"    grep -q "pipx install unifi-mcp-server" "$SHIM_LOG"
  check "personal: pipx uses pinned git spec"      grep -q "pipx install git+https://github.com/rgarcia/ynab-mcp-server@" "$SHIM_LOG"
  check "personal: pipx skips installed (PEP 503)" bash -c "! grep -q 'py-natpmp' '$SHIM_LOG'"
  links > "$WORK/links-$label"

  # A file deleted upstream disappears here too.
  git clone -q "$WORK/origin.git" "$WORK/push-$label"
  git -C "$WORK/push-$label" rm -q zsh/.config/zsh/70-nvm.zsh
  git -C "$WORK/push-$label" -c user.name=t -c user.email=t@t commit -qm "drop nvm"
  git -C "$WORK/push-$label" push -q origin HEAD:main
  run_sync || { fail "sync after upstream delete"; cat "$HOME/sync.out"; }
  check "pull: fast-forwarded"                     grep -q "pulling 1 new commit" "$HOME/sync.out"
  check "pull: deleted file's link removed"        absent .config/zsh/70-nvm.zsh
  git -C "$WORK/origin.git" update-ref refs/heads/main "$(git -C "$WORK/snap" rev-parse HEAD)"

  # Legacy links from the old ollama layout are cleaned up.
  mkdir -p "$HOME/launchagents"
  ln -s ../dotfiles/ollama/launchagents/README.md "$HOME/launchagents/README.md"
  ln -s ../dotfiles/ollama/bin/install-ollama.sh "$HOME/bin/install-ollama.sh"
  run_sync || true
  check "legacy: ~/launchagents removed"           absent launchagents
  check "legacy: ~/bin/install-ollama.sh removed"  absent bin/install-ollama.sh

  # Uncommitted edits: no pull, but everything else still converges.
  echo "# local edit" >> "$HOME/dotfiles/zsh/.config/zsh/10-env.zsh"
  rm "$HOME/.zshrc"
  run_sync || { fail "sync with dirty tree"; cat "$HOME/sync.out"; }
  check "dirty: pull skipped with a warning"       grep -q "uncommitted changes" "$HOME/sync.out"
  check "dirty: links still converge"              is_link .zshrc

  # A real file in the way is reported, not clobbered.
  rm "$HOME/.tmux.conf"; echo mine > "$HOME/.tmux.conf"
  if run_sync; then fail "conflict should fail the sync"; else pass "conflict: sync reports failure"; fi
  check "conflict: user file untouched"            grep -qx mine "$HOME/.tmux.conf"

  # So is a symlink of your own that points elsewhere.
  rm "$HOME/.tmux.conf"; echo theirs > "$WORK/elsewhere-$label"; ln -s "$WORK/elsewhere-$label" "$HOME/.tmux.conf"
  if run_sync; then fail "foreign symlink should fail the sync"; else pass "foreign symlink: sync reports failure"; fi
  check "foreign symlink: left pointing elsewhere" test "$(readlink "$HOME/.tmux.conf")" = "$WORK/elsewhere-$label"
}

run_suite stow   "$BASE_PATH"
run_suite nostow "$NOSTOW_PATH"

echo "── parity"
if diff "$WORK/links-stow" "$WORK/links-nostow" > "$WORK/links.diff"; then
  pass "built-in linker creates exactly the links stow does"
else
  fail "linker parity:"; cat "$WORK/links.diff"
fi

if (( fails )); then echo "dotfiles-sync: $fails check(s) failed"; exit 1; fi
echo "dotfiles-sync: all checks passed"
