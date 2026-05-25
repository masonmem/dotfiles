# ollama (dotfiles package)

Opt-in zsh configuration for a local LLM workflow on macOS:

- Ollama tuning env vars for Apple Silicon (`15-ollama.zsh`)
- LiteLLM gateway env: loads per-tool virtual keys into env vars; sets
  `OPENAI_BASE_URL`/`OPENAI_API_KEY` for ad-hoc OpenAI-SDK use
  (`16-llm-gateway.zsh`)
- `aider` wrapper that injects `OPENAI_API_KEY=$AIDER_LITELLM_KEY`
  per-call (aider's YAML doesn't expand env vars) (`60-aider-wrapper.zsh`)
- `litellm-keys` CLI: list / push / pull / mint / revoke per-tool LiteLLM
  virtual keys; bridges file cache and macOS Keychain
  (`bin/litellm-keys`)

> **Retired (May 2026):** the `copilotp` zsh function (wrapper around
> GitHub Copilot CLI for local-model inference) is gone. Small local
> models never produced reliable tool calls in the Copilot CLI harness.
> Use `opencode` for local-LLM work; the stock `copilot` CLI is for the
> GitHub-hosted cloud models.

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
ollama pull granite4.1:8b     # 5.3 GB — default for agentic CLI (Copilot CLI/opencode)
ollama pull gemma4:e4b        # 9.6 GB — chat/code-writing, multimodal, 256K ctx
ollama pull qwen2.5-coder:7b  # fallback if a session misbehaves
ollama pull qwen3:8b          # pure-chat option (no tools)

# (24 GB+ Macs can also pull qwen3:14b, qwen3:8b-q8_0, granite3.3:8b)
```

## Daily use

| Command | Behavior |
|---|---|
| `opencode` | TUI agent against LiteLLM gateway. `Ctrl-M` switches model. Default: `local/granite4.1-8b`. |
| `aider` | Diff-driven editor. Shell wrapper injects `OPENAI_API_KEY` per-call. Default: `openai/local/gemma4-e4b`. |
| `litellm-keys list` / `mint <tool>` / `revoke <tool>` / `push` / `pull` | Manage per-tool LiteLLM virtual keys (file ↔ Keychain). |

See `homelab/docs/llm-clients.md` for how the gateway, virtual keys,
and BYOK Anthropic plumbing fit together.

### Model picks (16 GB Mac)

These notes are about the **models** themselves; choose them in
opencode's picker (`Ctrl-M`) or aider's `--model openai/local/<name>`.

| Model | Why pick it |
|---|---|
| `granite4.1:8b` (default for agentic work) | IBM Apache-2.0, ~5 GB. In a May 2026 head-to-head bench against `gemma4:e4b-tools` and `qwen3.5:4b`, only granite made clean tool calls without inventing tool names. Trained against OpenAI-style tool schemas. |
| `gemma4:e4b-tools` | Custom Modelfile variant (`modelfiles/gemma4-e4b-tools.Modelfile`) of `gemma4:e4b` with temperature lowered to 0.2 to reduce tool-name confabulation. Stock `gemma4:e4b` ships at temperature=1.0 which causes it to invent tool names like `google_search` / `view_directory`. Apache-2.0, multimodal, native 256K context, ~27 tok/s warm. Great for chat / code-writing; less reliable than granite in multi-step agent loops. |
| `gemma4:e4b` | Untuned base. Use for one-shot chat where you want maximum creativity. |
| `qwen2.5-coder:7b` | Stable, ~25 tok/s. Note: emits function calls as JSON inside `content` rather than the OpenAI `tool_calls` field. |
| `qwen3:8b` | Better reasoning/chat, but `<think>` blocks corrupt tool calls over Ollama's OpenAI-compatible endpoint — prefer for non-tool chat. |
| `qwen3.5:4b` | Newer Qwen with tools+thinking+vision, tiny (~3.4 GB). Emits XML-style `<search_files>` tags that ollama's tool-parser can't extract — useful for chat. |
| `qwen3:14b` | Higher quality, ~15–22 tok/s (cap context at 8K to fit). |
| `granite3.3:8b` | Superseded by 4.1; kept for comparison. |
| `gemma4:26b` (removed) | 18 GB resident forces partial-GPU split on 16 GB Macs; warm gens stall. |

### Tool calling reality check (May 2026, ollama 0.24)

Verified end-to-end against agentic prompts with a full tool catalog,
via a localhost proxy logging real request bodies:

| Model | Real tool calls? | Notes |
|---|---|---|
| `granite4.1:8b` | ✅ clean | Called `glob`, then `view "."`. |
| `gemma4:e4b-tools` | ⚠️ unreliable | Even with temp=0.2 still invents tool names about a third of the time. Fine for chat, not agent loops. |
| `gemma4:e4b` (stock) | ❌ broken | temperature=1.0 → invents a different fake tool name almost every turn. |
| `qwen3.5:4b` | ❌ wrong harness | Emits XML-style `<search_files>` tags instead of OpenAI `tool_calls`. |
| `qwen2.5-coder:7b` | ⚠️ wrong field | Emits the call as JSON in `content`; tolerant clients work, strict ones don't. |

**Takeaway:** the 4–8B class is genuinely hit-and-miss at agentic tool
loops. `granite4.1:8b` is the most reliable local option for opencode
agent work; reach for `cloud/sonnet-4.5` when the task is non-trivial.

### Suppressing Qwen3 thinking

Qwen3 has a `<think>` mode that can pollute tool-call JSON during agent
loops. The Qwen `/no_think` in-prompt soft switch is **not reliable** via
Ollama — the model often treats it as ordinary prompt text and reasons
about what the string means before answering. Use Ollama-native controls:

```bash
ollama run qwen3:8b --think=false "Say hi in 5 words"   # one-shot CLI
# Interactive: type  /set nothink  before your prompt
# API: pass  "think": false  as a TOP-LEVEL field on /api/chat or
#      /api/generate (not inside "options")
```

`--hidethinking` is **not** the same: the model still reasons internally,
the trace is just suppressed in output (saves clutter, not latency).

LiteLLM's gateway talks to ollama's OpenAI-compatible endpoint
(`/v1/chat/completions`) and does not expose a `think` toggle. For
guaranteed no-think behavior with qwen3 through opencode/aider, drop
to `qwen2.5-coder:7b` (no thinking mode at all).

**Gemma 4 is different:** the `/v1/chat/completions` endpoint *does*
honor `reasoning_effort: "none"` for `gemma4:*`. Thinking output also
arrives in a dedicated `reasoning` field on streaming deltas (not mixed
into `content`), so even with thinking on, tool-call JSON stays clean.
That makes `gemma4:e4b` a genuine "thinking + tools + no leakage" option
that qwen3 cannot match on this endpoint.

## Companion alternatives (configs stowed; install binaries via Homebrew)

```bash
brew install aider                       # diff-based pair programming (config: ~/.aider.conf.yml, stowed)
brew install opencode                    # Claude-Code-style TUI agent  (config: ~/.config/opencode/opencode.jsonc, stowed)
brew install block-goose-cli             # MCP-heavy general agent      (run `goose configure`; not stowed)
```

After binaries are installed, run `stow --no-folding ollama` from
`~/dotfiles` to (re-)create symlinks for the opencode and aider configs.
opencode defaults to `granite4.1:8b` (the agent-loop winner); aider stays
on `gemma4:e4b-tools` because aider is diff-driven and gemma4's chat /
code-writing quality is what matters there.

For `goose`, run `goose configure` once and pick:
- Provider: **Ollama** (or "OpenAI compatible" → `http://localhost:11434/v1`)
- Model: `granite4.1:8b`
- API key: anything (e.g. `ollama`)

## Unstow

```bash
stow -D ollama
```
