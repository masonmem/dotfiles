#!/bin/sh
# install-ollama.sh — install the official standalone Ollama build into
# ~/.local/ollama.
#
# WHY NOT HOMEBREW: the Homebrew `ollama` *formula* bottle is broken — it
# ships only the main binary with no `llama-server` runner, so every model
# load fails with "llama-server binary not found" (verified 0.30.7,
# 2026-06-11). The official ollama-darwin.tgz is the complete build:
# llama-server + libggml/libllama + bundled mlx_metal_v3/v4 MLX runners
# (self-contained — no brew mlx-c dependency).
#
# The runtime is managed by the com.user.ollama LaunchAgent (see
# ../launchagents/com.user.ollama.plist), NOT by `brew services`.
#
# Usage:
#   ollama/bin/install-ollama.sh [VERSION]
# e.g.
#   ollama/bin/install-ollama.sh 0.30.7
set -eu

VERSION="${1:-0.30.7}"
DEST="$HOME/.local/ollama"
URL="https://github.com/ollama/ollama/releases/download/v${VERSION}/ollama-darwin.tgz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> downloading ollama v${VERSION} (official standalone)"
curl -fsSL -o "$TMP/ollama-darwin.tgz" "$URL"

echo "==> extracting to $DEST"
mkdir -p "$DEST"
tar xzf "$TMP/ollama-darwin.tgz" -C "$DEST"
chmod +x "$DEST/ollama" "$DEST/llama-server" 2>/dev/null || true
# strip Gatekeeper quarantine so the launchd-spawned binary can exec the runner
xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

# keep `ollama` on PATH for interactive use (brew bin dir is already on PATH).
if [ -d /opt/homebrew/bin ]; then
  ln -sf "$DEST/ollama" /opt/homebrew/bin/ollama
fi

echo "==> installed: $("$DEST/ollama" --version 2>&1 | tail -1)"
echo "    runtime is managed by the com.user.ollama LaunchAgent."
