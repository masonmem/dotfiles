# Ollama + copilotp Cheatsheet

Quick reference for debugging and operating the local Ollama setup.
Tail with `cat ~/dotfiles/ollama/CHEATSHEET.md` or `bat` it.

---

## Status at a glance

```sh
ollama ps                          # loaded model, GPU%, ctx, eviction TTL
ollama list                        # all installed models + sizes
launchctl getenv OLLAMA_CONTEXT_LENGTH    # confirm runtime config
brew services list | grep ollama          # service state
```

## Is my copilotp request actually running?

```sh
# 1-liner triage
ollama ps && lsof -nP -iTCP:11434 -sTCP:ESTABLISHED 2>/dev/null
```
- **ESTABLISHED** connection → request in flight, just wait.
- Empty → copilot isn't talking to ollama (check env vars).

## Live log tail (run in a second pane)

```sh
tail -f /opt/homebrew/var/log/ollama.log
# Look for "POST /v1/chat/completions" with timing
```

## Watch model + memory in real time

```sh
watch -n2 'ollama ps; echo; vm_stat | head -5'
```

## Memory pressure check

```sh
vm_stat | awk '/Pages free/||/Pages active/||/swapouts/'
# "Pages free" near 0 + growing swapouts = thrash
top -l 1 -o mem -n 10 -stats command,mem,cpu       # what's eating RAM
```

## Who is eating RAM? (top 15 by RSS)

```sh
ps -axm -o pid,ppid,rss,%cpu,comm \
  | sort -k3 -nr | head -15 \
  | awk '{printf "%-7s ppid=%-6s %7.1f MB  %4s%%cpu  %s\n",$1,$2,$3/1024,$4,$5}'
```

## Stuck VS Code `rg` reaper

VS Code extensions (Tailwind IntelliSense, TS/JS language features) sometimes
leave ripgrep processes running for hours. Each is small (~5 MB), but a
swarm of them holds FDs and adds up.

```sh
# See them and how long they've been running
ps -ax -o pid,ppid,etime,command \
  | awk 'NR==1 || /@vscode\/ripgrep\/bin\/rg/'

# Kill the lot (VS Code respawns fresh ones if it actually needs them)
pgrep -fl '@vscode/ripgrep/bin/rg' | awk '{print $1}' | xargs kill 2>/dev/null

# If a plain kill doesn't take:
pgrep -fl '@vscode/ripgrep/bin/rg' | awk '{print $1}' | xargs kill -9
```

Prevent the swarm in the first place — add to VS Code `settings.json`:
```json
{
  "search.followSymlinks": false,
  "search.useGlobalIgnoreFiles": true
}
```

## Streaming smoke test (bypasses copilot entirely)

```sh
curl -N http://localhost:11434/api/chat \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3:8b","stream":true,"think":false,
       "messages":[{"role":"user","content":"Say hi"}]}'
```
Tokens stream → ollama is healthy; problem is on the copilot side.

## Token-throughput benchmark

```sh
ollama run qwen3:8b --verbose --think=false "Write a 200-word story about a cat."
# Reports: eval rate (output tok/s), prompt eval rate (prefill tok/s)
```

---

## Kick the tires

```sh
ollama stop qwen3:8b               # unload to free RAM
ollama run qwen3:8b ""             # warm up (no prompt)
brew services restart ollama       # full server restart
```

## Switch model for one call

```sh
COPILOT_MODEL=gemma4:e4b-tools copilotp                # tuned gemma4 (chat/code, less reliable tool use)
COPILOT_MODEL=gemma4:e4b       copilotp                # stock gemma4 (creative chat)
COPILOT_MODEL=qwen2.5-coder:7b copilotp                # older default; no thinking mode
COPILOT_MODEL=qwen3:8b         copilotp                # pure chat / reasoning (no tools)
COPILOT_MODEL=qwen3:14b        copilotp                # smarter, slower
COPILOT_MODEL=granite3.3:8b    copilotp                # 128K context (older granite)
```
Default is `granite4.1:8b` — most reliable real `tool_calls` in agent loops on this 16 GB Mac (bench results in README). `copilotp` also passes `--effort none` and excludes cloud-only / sub-agent tools that confuse small local models.

## Override token budgets one-off

```sh
COPILOT_PROVIDER_MAX_PROMPT_TOKENS=30720 \
COPILOT_PROVIDER_MAX_OUTPUT_TOKENS=2048 \
  copilotp -p "..."
```
Constraint: PROMPT + OUTPUT ≤ `OLLAMA_CONTEXT_LENGTH` (32768 here).

## Online-but-local mode

```sh
COPILOT_PRIVATE_ONLINE=1 copilotp   # local inference + GitHub plumbing kept
```

## Cloud session (unchanged)

```sh
copilot          # GitHub Copilot cloud (Claude/GPT-*)
copilotc         # same; explicit alias for scripts
```

---

## Model maintenance

```sh
ollama pull qwen3:8b               # install / refresh
ollama rm <model>                  # delete (if CLI hangs, use API below)
# Reliable delete:
curl -X DELETE http://localhost:11434/api/delete -d '{"name":"<model>"}'
du -sh ~/.ollama/models            # disk usage
```

## Tuning knobs (set via `launchctl setenv`, then restart service)

> **Important:** `launchctl setenv` only writes the **live** launchd session.
> The vars evaporate on reboot/logout. The repo ships a LaunchAgent
> (`~/dotfiles/ollama/launchagents/com.user.ollama-env.plist`) that
> re-applies all six at login. Install once:
> ```sh
> ln -sf ~/dotfiles/ollama/launchagents/com.user.ollama-env.plist \
>        ~/Library/LaunchAgents/com.user.ollama-env.plist
> launchctl load -w ~/Library/LaunchAgents/com.user.ollama-env.plist
> brew services restart ollama
> ```
> After that, `launchctl getenv OLLAMA_*` returns values across reboots.

| Var | Current | Notes |
|---|---|---|
| `OLLAMA_CONTEXT_LENGTH` | 32768 | Max usable ctx; lower for 14B model |
| `OLLAMA_KV_CACHE_TYPE`  | q8_0  | Halves KV memory at ~no quality loss |
| `OLLAMA_FLASH_ATTENTION`| 1     | Required for KV quantization |
| `OLLAMA_KEEP_ALIVE`     | 30m   | How long a model stays loaded after idle |
| `OLLAMA_MAX_LOADED_MODELS` | 1  | Keep low on 16 GB |
| `OLLAMA_NUM_PARALLEL`   | 1     | One request at a time (lower latency) |

```sh
launchctl setenv OLLAMA_KEEP_ALIVE 1h && brew services restart ollama
```

---

## Performance expectations (M1 Pro 16 GB)

Measured on this machine, ollama 0.24, KV cache q8_0, ctx 32768.

| Model         | Prefill | Output  | Cold start | Notes |
|---------------|---------|---------|------------|-------|
| qwen2.5-coder:7b | ~160 t/s | ~25 t/s | ~8 s | Older default. **Note:** emits function calls inside `content`, not the OpenAI `tool_calls` field. |
| granite4.1:8b | ~110 t/s | ~28 t/s | ~10 s | **Current default.** Cleanest agentic tool calls in the May 2026 bench — only model that didn't invent fake tool names. IBM Apache-2.0, ~5 GB. |
| gemma4:e4b(-tools) | ~120 t/s | ~27 t/s | ~9 s | Best for chat/code-writing. Even the temp=0.2 variant invents tool names ~⅓ of the time in agent loops. Multimodal, 256K ctx. |
| qwen3.5:4b | ~140 t/s | ~30 t/s | ~7 s | Tiny, fast. Emits `<search_files>` XML instead of OpenAI `tool_calls` — wrong harness for Copilot CLI. |
| qwen3:8b      | ~75 t/s | ~35 t/s | ~90 s      | Better chat; `<think>` blocks corrupt tool JSON on OpenAI-compatible endpoint. |
| qwen3:14b     | ~30 t/s | ~17 t/s | ~150 s     | Lower ctx; close to RAM ceiling |
| granite3.3:8b | ~70 t/s | ~32 t/s | ~80 s      | Superseded by 4.1 |
| gemma4:26b    | (removed) | — | — | 18 GB resident forced a 39/61 CPU/GPU split with multi-minute warm gens. |

First `copilotp` call after `exec zsh` is the slowest — system prompt
(~12K tokens) must be prefilled. Subsequent calls in the same session
reuse the KV cache and feel snappy.

---

## Emergency: copilotp is wedged

```sh
# 1. Kill the copilot client (won't crash ollama)
pgrep -fl 'copilot$' && pkill -fl 'copilot$'

# 2. If ollama is the problem, restart it:
brew services restart ollama

# 3. Nuclear option — unload the model:
ollama stop gemma4:e4b
```

## Where things live

| Path | What |
|---|---|
| `~/dotfiles/ollama/` | This stow package |
| `~/.config/zsh/15-ollama.zsh` | OLLAMA_* shell exports (symlink) |
| `~/.config/zsh/50-copilot-local.zsh` | `copilotp()` function (symlink) |
| `~/.config/opencode/opencode.jsonc` | opencode → Ollama provider config (symlink) |
| `~/.aider.conf.yml` | aider default model config (symlink) |
| `~/dotfiles/ollama/modelfiles/` | Optional Modelfiles (e.g. qwen3:8b-nothink) |
| `~/.copilot/copilot-instructions.md` | Global user-level Copilot CLI guidance |
| `/opt/homebrew/var/log/ollama.log` | Server log |
| `~/.ollama/models/` | Model blobs (~33 GB current) |
