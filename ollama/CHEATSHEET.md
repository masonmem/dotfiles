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

## Streaming smoke test (bypasses copilot entirely)

```sh
curl -N http://localhost:11434/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3:8b","stream":true,
       "messages":[{"role":"user","content":"Say hi /no_think"}]}'
```
Tokens stream → ollama is healthy; problem is on the copilot side.

## Token-throughput benchmark

```sh
ollama run qwen3:8b --verbose "Write a 200-word story about a cat. /no_think"
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
COPILOT_MODEL=qwen2.5-coder:7b copilotp                # cleaner tool calls
COPILOT_MODEL=qwen3:14b      copilotp                  # smarter, slower
COPILOT_MODEL=granite3.3:8b  copilotp                  # 128K context
```

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

| Model         | Prefill | Output  | Cold start | Notes |
|---------------|---------|---------|------------|-------|
| qwen3:8b      | ~75 t/s | ~35 t/s | ~90 s      | Default; needs `/no_think` |
| qwen2.5-coder:7b | ~90 t/s | ~45 t/s | ~60 s | Cleanest tool calls |
| qwen3:14b     | ~30 t/s | ~17 t/s | ~150 s     | Lower ctx; close to RAM ceiling |
| granite3.3:8b | ~70 t/s | ~32 t/s | ~80 s      | Best for very long context |

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
ollama stop qwen3:8b
```

## Where things live

| Path | What |
|---|---|
| `~/dotfiles/ollama/` | This stow package |
| `~/.config/zsh/15-ollama.zsh` | OLLAMA_* shell exports (symlink) |
| `~/.config/zsh/50-copilot-local.zsh` | `copilotp()` function (symlink) |
| `~/.copilot/copilot-instructions.md` | `/no_think` guardrail (machine-local) |
| `/opt/homebrew/var/log/ollama.log` | Server log |
| `~/.ollama/models/` | Model blobs (~33 GB current) |
