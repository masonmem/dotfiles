#!/usr/bin/env bash
# Install CLI tools in a devcontainer (Linux arm64/amd64).
# Idempotent — safe to run multiple times. Silent on subsequent runs.
# Tools are installed to /usr/local/bin.
# If TOOL_CACHE is set and writable, binaries are cached for fast reinstall.
# Each tool installs independently; failures don't block others.
set -uo pipefail

ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) ARCH_ALT="aarch64"; GOARCH="arm64"; ARCH_FZF="arm64" ;;
  x86_64)        ARCH_ALT="x86_64";  GOARCH="amd64"; ARCH_FZF="amd64" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

BIN="/usr/local/bin"
CACHE="${TOOL_CACHE:-/var/cache/devcontainer-tools}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$CACHE" 2>/dev/null || true

installed() { command -v "$1" &>/dev/null; }

# Install a binary: check cache first, otherwise download and cache
install_bin() {
  local name="$1" url="$2" extract_path="$3"
  if [[ -f "$CACHE/$name" ]]; then
    cp "$CACHE/$name" "$BIN/"
    return
  fi
  curl -sL "$url" | tar xz -C "$TMP"
  cp "$TMP/$extract_path" "$BIN/"
  cp "$BIN/$name" "$CACHE/" 2>/dev/null || true
}

# ── bat ──────────────────────────────────────────────────────────────────────
if ! installed bat; then
  BAT_VER=$(curl -sL "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin bat "https://github.com/sharkdp/bat/releases/download/v${BAT_VER}/bat-v${BAT_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" "bat-v${BAT_VER}-${ARCH_ALT}-unknown-linux-gnu/bat"
fi

# ── eza ──────────────────────────────────────────────────────────────────────
if ! installed eza; then
  EZA_VER=$(curl -sL "https://api.github.com/repos/eza-community/eza/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin eza "https://github.com/eza-community/eza/releases/download/v${EZA_VER}/eza_${ARCH_ALT}-unknown-linux-gnu.tar.gz" "eza"
fi

# ── fd ───────────────────────────────────────────────────────────────────────
if ! installed fd; then
  FD_VER=$(curl -sL "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin fd "https://github.com/sharkdp/fd/releases/download/v${FD_VER}/fd-v${FD_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" "fd-v${FD_VER}-${ARCH_ALT}-unknown-linux-gnu/fd"
fi

# ── ripgrep ──────────────────────────────────────────────────────────────────
if ! installed rg; then
  RG_VER=$(curl -sL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep tag_name | cut -d'"' -f4)
  install_bin rg "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/ripgrep-${RG_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" "ripgrep-${RG_VER}-${ARCH_ALT}-unknown-linux-gnu/rg"
fi

# ── fzf ──────────────────────────────────────────────────────────────────────
if ! installed fzf; then
  FZF_VER=$(curl -sL "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin fzf "https://github.com/junegunn/fzf/releases/download/v${FZF_VER}/fzf-${FZF_VER}-linux_${ARCH_FZF}.tar.gz" "fzf"
fi

# ── zoxide ───────────────────────────────────────────────────────────────────
if ! installed zoxide; then
  if [[ -f "$CACHE/zoxide" ]]; then
    cp "$CACHE/zoxide" "$BIN/"
  else
    curl -sLS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir "$BIN" &>/dev/null
    cp "$BIN/zoxide" "$CACHE/" 2>/dev/null || true
  fi
fi

# ── atuin ────────────────────────────────────────────────────────────────────
if ! installed atuin; then
  ATUIN_VER=$(curl -sL "https://api.github.com/repos/atuinsh/atuin/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  if [[ -f "$CACHE/atuin" ]]; then
    cp "$CACHE/atuin" "$BIN/"
  else
    curl -sL "https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VER}/atuin-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
    cp "$TMP/atuin" "$BIN/" 2>/dev/null || cp "$TMP/atuin-${ARCH_ALT}-unknown-linux-gnu/atuin" "$BIN/" 2>/dev/null || true
    cp "$BIN/atuin" "$CACHE/" 2>/dev/null || true
  fi
fi

# ── lazygit ──────────────────────────────────────────────────────────────────
if ! installed lazygit; then
  LG_VER=$(curl -sL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin lazygit "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_linux_${GOARCH}.tar.gz" "lazygit"
fi

# ── neovim ───────────────────────────────────────────────────────────────────
if ! installed nvim; then
  if [[ -d "$CACHE/nvim-linux-${GOARCH}" ]]; then
    cp -r "$CACHE/nvim-linux-${GOARCH}"/* /usr/local/
  else
    curl -sL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${GOARCH}.tar.gz" | tar xz -C "$TMP"
    cp -r "$TMP/nvim-linux-${GOARCH}"/* /usr/local/
    cp -r "$TMP/nvim-linux-${GOARCH}" "$CACHE/" 2>/dev/null || true
  fi
fi

# ── delta (git pager) ────────────────────────────────────────────────────────
if ! installed delta; then
  DELTA_VER=$(curl -sL "https://api.github.com/repos/dandavison/delta/releases/latest" | grep tag_name | cut -d'"' -f4)
  install_bin delta "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/delta-${DELTA_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" "delta-${DELTA_VER}-${ARCH_ALT}-unknown-linux-gnu/delta"
fi

# ── kubecolor ────────────────────────────────────────────────────────────────
if ! installed kubecolor; then
  KC_VER=$(curl -sL "https://api.github.com/repos/kubecolor/kubecolor/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  install_bin kubecolor "https://github.com/kubecolor/kubecolor/releases/download/v${KC_VER}/kubecolor_${KC_VER}_linux_${GOARCH}.tar.gz" "kubecolor"
fi

# ── tldr ─────────────────────────────────────────────────────────────────────
if ! installed tldr; then
  pip install --quiet --break-system-packages tldr 2>/dev/null || pip install --quiet tldr 2>/dev/null
fi

echo "✓ All devcontainer tools installed"
