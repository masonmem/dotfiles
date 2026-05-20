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

# Persistent runtime tuning (read by both the .app and brew services):
launchctl setenv OLLAMA_FLASH_ATTENTION 1
launchctl setenv OLLAMA_KV_CACHE_TYPE q8_0
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
launchctl setenv OLLAMA_KEEP_ALIVE 30m
launchctl setenv OLLAMA_MAX_LOADED_MODELS 1
launchctl setenv OLLAMA_NUM_PARALLEL 1

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
