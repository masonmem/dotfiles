#!/usr/bin/env bash
# Install the shell's CLI tools inside a Linux dev container (x86_64/arm64)
# from upstream release binaries into /usr/local. Run by 05-devcontainer.zsh
# on first shell; idempotent. Each tool installs independently — one failure
# doesn't block the rest — and the exit status is non-zero if any failed.
#
# If TOOL_CACHE (default /var/cache/devcontainer-tools) is writable, e.g. a
# named volume, binaries are cached there for fast reinstalls.
set -uo pipefail

case "$(uname -m)" in
  aarch64|arm64) ARCH=aarch64 GOARCH=arm64 LGARCH=arm64  NVARCH=arm64  RG_TARGET=aarch64-unknown-linux-gnu ;;
  x86_64)        ARCH=x86_64  GOARCH=amd64 LGARCH=x86_64 NVARCH=x86_64 RG_TARGET=x86_64-unknown-linux-musl ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

BIN=/usr/local/bin
CACHE="${TOOL_CACHE:-/var/cache/devcontainer-tools}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$CACHE" 2>/dev/null || true
FAILED=()

installed() { command -v "$1" >/dev/null 2>&1; }

# latest <owner/repo> — newest release tag (e.g. v1.2.3), read from the
# /releases/latest redirect: no GitHub API call, so no API rate limit.
latest() {
  local url
  url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest") || return 1
  [[ "$url" == */tag/* ]] && printf '%s' "${url##*/}"
}

# install_bin <name> <tarball url> <path of the binary inside the tarball>
install_bin() {
  local name="$1" url="$2" member="$3"
  if [[ ! -f "$CACHE/$name" ]]; then
    curl -fsSL "$url" | tar xz -C "$TMP" || return 1
    install -m 755 "$TMP/$member" "$CACHE/$name" 2>/dev/null \
      || { install -m 755 "$TMP/$member" "$BIN/$name"; return; }
  fi
  install -m 755 "$CACHE/$name" "$BIN/$name"
}

# tool <command> <install function> — run the installer unless present.
tool() {
  installed "$1" && return 0
  "$2" || { FAILED+=("$1"); echo "✗ $1 failed to install" >&2; }
}

get_bat() {
  local v; v=$(latest sharkdp/bat) || return 1
  install_bin bat "https://github.com/sharkdp/bat/releases/download/$v/bat-$v-$ARCH-unknown-linux-gnu.tar.gz" "bat-$v-$ARCH-unknown-linux-gnu/bat"
}
get_eza() {
  install_bin eza "https://github.com/eza-community/eza/releases/latest/download/eza_$ARCH-unknown-linux-gnu.tar.gz" eza
}
get_fd() {
  local v; v=$(latest sharkdp/fd) || return 1
  install_bin fd "https://github.com/sharkdp/fd/releases/download/$v/fd-$v-$ARCH-unknown-linux-gnu.tar.gz" "fd-$v-$ARCH-unknown-linux-gnu/fd"
}
get_rg() {   # ripgrep tags have no "v"; x86_64 ships musl only
  local v; v=$(latest BurntSushi/ripgrep) || return 1
  install_bin rg "https://github.com/BurntSushi/ripgrep/releases/download/$v/ripgrep-$v-$RG_TARGET.tar.gz" "ripgrep-$v-$RG_TARGET/rg"
}
get_fzf() {
  local v; v=$(latest junegunn/fzf) || return 1
  install_bin fzf "https://github.com/junegunn/fzf/releases/download/$v/fzf-${v#v}-linux_$GOARCH.tar.gz" fzf
}
get_zoxide() {
  local v; v=$(latest ajeetdsouza/zoxide) || return 1
  install_bin zoxide "https://github.com/ajeetdsouza/zoxide/releases/download/$v/zoxide-${v#v}-$ARCH-unknown-linux-musl.tar.gz" zoxide
}
get_atuin() {
  install_bin atuin "https://github.com/atuinsh/atuin/releases/latest/download/atuin-$ARCH-unknown-linux-gnu.tar.gz" "atuin-$ARCH-unknown-linux-gnu/atuin"
}
get_lazygit() {
  local v; v=$(latest jesseduffield/lazygit) || return 1
  install_bin lazygit "https://github.com/jesseduffield/lazygit/releases/download/$v/lazygit_${v#v}_linux_$LGARCH.tar.gz" lazygit
}
get_delta() {   # delta tags have no "v"
  local v; v=$(latest dandavison/delta) || return 1
  install_bin delta "https://github.com/dandavison/delta/releases/download/$v/delta-$v-$ARCH-unknown-linux-gnu.tar.gz" "delta-$v-$ARCH-unknown-linux-gnu/delta"
}
get_kubecolor() {
  local v; v=$(latest kubecolor/kubecolor) || return 1
  install_bin kubecolor "https://github.com/kubecolor/kubecolor/releases/download/$v/kubecolor_${v#v}_linux_$GOARCH.tar.gz" kubecolor
}
get_tldr() {    # tealdeer, same client as the Macs; a bare binary, not a tarball
  if [[ ! -f "$CACHE/tldr" ]]; then
    curl -fsSL -o "$TMP/tldr" "https://github.com/tealdeer-rs/tealdeer/releases/latest/download/tealdeer-linux-$ARCH-musl" || return 1
    install -m 755 "$TMP/tldr" "$CACHE/tldr" 2>/dev/null || { install -m 755 "$TMP/tldr" "$BIN/tldr"; return; }
  fi
  install -m 755 "$CACHE/tldr" "$BIN/tldr"
}
get_nvim() {    # a whole tree (bin/ lib/ share/), not a single binary
  local dir="nvim-linux-$NVARCH"
  if [[ ! -d "$CACHE/$dir" ]]; then
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$dir.tar.gz" | tar xz -C "$TMP" || return 1
    cp -r "$TMP/$dir" "$CACHE/" 2>/dev/null || { cp -r "$TMP/$dir"/* /usr/local/; return; }
  fi
  cp -r "$CACHE/$dir"/* /usr/local/
}

tool bat       get_bat
tool eza       get_eza
tool fd        get_fd
tool rg        get_rg
tool fzf       get_fzf
tool zoxide    get_zoxide
tool atuin     get_atuin
tool lazygit   get_lazygit
tool nvim      get_nvim
tool delta     get_delta
tool kubecolor get_kubecolor
tool tldr      get_tldr

if (( ${#FAILED[@]} )); then
  echo "✗ failed: ${FAILED[*]}" >&2
  exit 1
fi
echo "✓ All devcontainer tools installed"
