# ollama (dotfiles package)

Opt-in zsh configuration for a local LLM workflow on macOS:

- Ollama tuning env vars for Apple Silicon (`15-ollama.zsh`)
- `copilotp` zsh function: GitHub Copilot CLI wrapper that routes inference
  through Ollama (BYOK) and runs in `COPILOT_OFFLINE=true` mode by default
  (`50-copilot-local.zsh`)

This package is **not** stowed automatically by the bootstrap. Personal
machines opt in explicitly:

```bash
stow --no-folding ollama
```

Do **not** stow this on work machines unless you've cleared local-LLM
use with your employer.

## What you also need on the machine

```bash
brew install ollama
brew services start ollama

# Persistent runtime tuning. `launchctl setenv` only writes the LIVE launchd
# session — it does NOT survive reboot. Install the bundled LaunchAgent so
# the vars are re-set automatically at every login, then restart ollama so
# its inherited env picks them up.
ln -sf ~/dotfiles/ollama/launchagents/com.user.ollama-env.plist \
       ~/Library/LaunchAgents/com.user.ollama-env.plist
launchctl load -w ~/Library/LaunchAgents/com.user.ollama-env.plist
brew services restart ollama

# Verify (all six should be set):
for v in OLLAMA_FLASH_ATTENTION OLLAMA_KV_CACHE_TYPE OLLAMA_CONTEXT_LENGTH \
         OLLAMA_KEEP_ALIVE OLLAMA_MAX_LOADED_MODELS OLLAMA_NUM_PARALLEL; do
  printf "%-30s = %s\n" "$v" "$(launchctl getenv "$v")"
done

# Models for 16 GB Macs
ollama pull qwen3:8b
ollama pull qwen2.5-coder:7b

# (24 GB+ Macs can also pull qwen3:14b, qwen3:8b-q8_0, granite3.3:8b)
```

## Daily use

| Command | Behavior |
|---|---|
| `copilot` | Unchanged — GitHub Copilot **cloud** session (Claude/GPT-*) |
| `copilotc` | Explicit alias for the cloud session; useful in scripts |
| `copilotp` | **Private** session via local Ollama; sets `COPILOT_PROVIDER_*` and `COPILOT_OFFLINE=true` |
| `COPILOT_MODEL=qwen2.5-coder:7b copilotp` | Same, but with a different local model |
| `COPILOT_PRIVATE_ONLINE=1 copilotp` | Local inference but **keep** GitHub plumbing (`/pr`, `/delegate`, GitHub MCP) |

### Model picks for `copilotp` (16 GB Mac)

| Model | Why pick it |
|---|---|
| `qwen3:8b` (default) | Best all-rounder for agentic coding + reasoning |
| `qwen2.5-coder:7b` | Most reliable tool-calling, no thinking-mode caveats |
| `qwen3:14b` | Better quality, ~15–22 tok/s (cap context at 8K to fit) |
| `qwen3:8b-q8_0` | Higher-quality 8B, slower than Q4 |
| `granite3.3:8b` | IBM Apache-2.0, 128K context, strong FIM |

### /no_think guardrail

Copilot CLI loads `~/.copilot/copilot-instructions.md`. A `/no_think` directive
there suppresses Qwen3's `<think>` blocks (which can pollute tool-call JSON).
Keep that file machine-local — it's harmless for cloud sessions too.

## Companion alternatives (not stowed; install via Homebrew)

```bash
brew install aider                       # diff-based pair programming (no tool calling required)
brew install anomalyco/tap/opencode      # Claude-Code-style TUI agent
brew install block-goose-cli             # MCP-heavy general agent
```

## Unstow

```bash
stow -D ollama
```
