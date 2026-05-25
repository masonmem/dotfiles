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
ollama pull granite4.1:8b     # 5.3 GB — default for agentic CLI (Copilot CLI/opencode)
ollama pull gemma4:e4b        # 9.6 GB — chat/code-writing, multimodal, 256K ctx
ollama pull qwen2.5-coder:7b  # fallback if a session misbehaves
ollama pull qwen3:8b          # pure-chat option (no tools)

# (24 GB+ Macs can also pull qwen3:14b, qwen3:8b-q8_0, granite3.3:8b)
```

## Daily use

| Command | Behavior |
|---|---|
| `copilot` | Unchanged — GitHub Copilot **cloud** session (Claude/GPT-*) |
| `copilotc` | Explicit alias for the cloud session; useful in scripts |
| `copilotp` | **Private** session via local Ollama; sets `COPILOT_PROVIDER_*` and `COPILOT_OFFLINE=true`. Default model: `granite4.1:8b` (cleanest agentic tool calls). Also passes `--effort none` and excludes cloud-only / sub-agent tools (`task`, `sql`, `skill`, `report_intent`, `fetch_copilot_cli_documentation`, `read_agent`, `list_agents`) which routinely confuse small local models. |
| `COPILOT_MODEL=gemma4:e4b-tools copilotp` | Same, but using a different local model |
| `COPILOT_PRIVATE_ONLINE=1 copilotp` | Local inference but **keep** GitHub plumbing (`/pr`, `/delegate`, GitHub MCP) |

### Model picks for `copilotp` (16 GB Mac)

| Model | Why pick it |
|---|---|
| `granite4.1:8b` (**current default**) | IBM Apache-2.0, ~5 GB. In a May 2026 head-to-head Copilot CLI bench against `gemma4:e4b-tools` and `qwen3.5:4b`, only granite made clean tool calls (`glob`, `view`) without inventing tool names. Trained against OpenAI-style tool schemas. |
| `gemma4:e4b-tools` | Custom Modelfile variant (`modelfiles/gemma4-e4b-tools.Modelfile`) of `gemma4:e4b` with temperature lowered to 0.2 to reduce tool-name confabulation. Stock `gemma4:e4b` ships at temperature=1.0 which causes it to invent tool names like `google_search` / `view_directory`. Apache-2.0, multimodal, native 256K context, ~27 tok/s warm. Great for chat / code-writing; less reliable than granite in multi-step agent loops. |
| `gemma4:e4b` | Untuned base. Use for one-shot chat where you want maximum creativity. |
| `qwen2.5-coder:7b` (older default) | Stable, ~25 tok/s. Note: emits function calls as JSON inside `content` rather than the OpenAI `tool_calls` field. |
| `qwen3:8b` | Better reasoning/chat, but `<think>` blocks corrupt tool calls over Ollama's OpenAI-compatible endpoint — prefer for non-tool chat |
| `qwen3.5:4b` | Newer Qwen with tools+thinking+vision, tiny (~3.4 GB). In the bench it emitted XML-style `<search_files>` tags that ollama's tool-parser can't extract — wrong agent harness. Useful for chat. |
| `qwen3:14b` | Higher quality, ~15–22 tok/s (cap context at 8K to fit) |
| `granite3.3:8b` | Superseded by 4.1; kept for comparison |
| `gemma4:26b` (removed) | Pulled and removed because 18 GB resident size forces partial-GPU split on 16 GB Macs and warm gens stall. |

### Tool calling reality check (May 2026, ollama 0.24, Copilot CLI 1.0.51)

Verified end-to-end through Copilot CLI's BYOK path with the same agentic
prompt and full 10-tool catalog (after the `copilotp` exclusions). Captured
via a localhost proxy logging real request bodies:

| Model | Real tool calls? | Notes |
|---|---|---|
| `granite4.1:8b` | ✅ clean | Called `glob`, then `view "."`. Only "failure" was choosing to `view "/"` which Copilot CLI's path policy blocked — model behavior was correct, the call was real. |
| `gemma4:e4b-tools` | ⚠️ unreliable | Even with temp=0.2 and an anti-confabulation instruction in `~/.copilot/copilot-instructions.md`, still invents tool names (`google_search`, `view_file_list_`, `google_cloud-ai_list_files`) about a third of the time. Fine for chat, not for agent loops. |
| `gemma4:e4b` (stock) | ❌ broken | Stock temperature=1.0 → invents a different fake tool name almost every turn. |
| `qwen3.5:4b` | ❌ wrong harness | Emits XML-style `<search_files>` tags instead of OpenAI `tool_calls`; ollama's parser drops the call. |
| `qwen2.5-coder:7b` | ⚠️ wrong field | Emits the call as JSON in `content`. Copilot CLI tolerates this; downstream clients expecting `tool_calls` will miss it. |

**Takeaway:** Copilot CLI was designed for frontier models that don't
confabulate. The 4-8B class is genuinely hit-and-miss at agentic tool
loops; `granite4.1:8b` is the most reliable local option we found.

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

Copilot CLI's BYOK path talks to the OpenAI-compatible endpoint
(`/v1/chat/completions`) and does not expose a `think` toggle, so for
guaranteed no-think behavior inside `copilotp` agent loops with qwen3,
you'd need to drop to `qwen2.5-coder:7b` (no thinking mode at all).

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
