# launchagents/

User-scope `launchd` plists that survive reboot/logout. Symlink them into
`~/Library/LaunchAgents/` so the dotfile remains the source of truth.

## `com.user.ollama.plist` — Ollama runtime (solaris)

Self-contained agent that runs the **official standalone Ollama build**
(installed by `../bin/install-ollama.sh` into `~/.local/ollama`) directly as
`ollama serve`. It sets all tuning env, gates startup on the external models
SSD (`/Volumes/Helio`), and KeepAlive-restarts on crash.

### Why not Homebrew / `brew services`?

The Homebrew `ollama` **formula** bottle is broken: it ships only the main
binary with **no `llama-server` runner**, so every model load fails with
`llama-server binary not found` (verified on 0.30.7, 2026-06-11). The official
`ollama-darwin.tgz` is the complete build (llama-server + libggml/libllama +
bundled `mlx_metal_v3`/`v4` MLX runners, no brew `mlx-c` dependency). So we
install the standalone binary and manage it with this one LaunchAgent instead
of `brew services` + separate env/host pokers.

### Install

```sh
# 1. install the runtime (re-run to upgrade; pass a version to pin)
~/dotfiles/ollama/bin/install-ollama.sh 0.30.7

# 2. wire up the service
ln -sf ~/dotfiles/ollama/launchagents/com.user.ollama.plist \
       ~/Library/LaunchAgents/com.user.ollama.plist
launchctl unload ~/Library/LaunchAgents/com.user.ollama.plist 2>/dev/null
launchctl load -w ~/Library/LaunchAgents/com.user.ollama.plist
```

### Verify

```sh
launchctl print gui/$(id -u)/com.user.ollama | grep state   # → running
curl -s http://localhost:11434/api/tags | jq '.models | length'
```

### Force restart (e.g. after SSD remount)

```sh
launchctl kickstart -k gui/$(id -u)/com.user.ollama
```

### Uninstall

```sh
launchctl bootout gui/$(id -u)/com.user.ollama
rm ~/Library/LaunchAgents/com.user.ollama.plist
```
