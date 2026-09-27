# ollama (dotfiles package)

The local-LLM agent stack for **personal** machines: `stow ollama` there, never
on the work machine (unless your employer has cleared local-LLM tooling). The
agents themselves (aider, opencode, goose) are in
`Brewfile.d/personal.Brewfile`.

What it links into `$HOME`:

| File | Purpose |
|---|---|
| `.config/zsh/16-llm-gateway.zsh` | Sets `LITELLM_BASE_URL`; loads per-tool LiteLLM virtual keys into `<TOOL>_LITELLM_KEY` (file first, then macOS Keychain). |
| `.config/zsh/60-aider-wrapper.zsh`, `61-goose-wrapper.zsh` | `aider` / `goose` wrappers that pass the tool's key as `OPENAI_API_KEY` to that process only. |
| `.config/opencode/` | opencode config (reads its key via `{file:…}`) + opencode-only agent notes. |
| `.config/goose/config.yaml`, `.aider.conf.yml` | goose and aider configs. |
| `bin/litellm-keys` → `~/bin` | list / push / pull / mint / revoke per-tool virtual keys (file ↔ Keychain). |

What it does **not** link (see `.stow-local-ignore`):

- `bin/install-ollama.sh`, `launchagents/` — the Ollama server itself, used on
  **solaris** only; see [launchagents/README.md](launchagents/README.md).

## Where the models live

Ollama, the Modelfiles, and LiteLLM run on **solaris**; other Macs reach them
over the tailnet at `https://llm.hyperionx.dev/v1`. The model roster and naming
convention are in `homelab/docs/models.md`; the gateway / virtual-key plumbing
is in `homelab/docs/llm-clients.md`.

```sh
curl -sS https://llm.hyperionx.dev/v1/models \
  -H "Authorization: Bearer $(cat ~/.copilot/secrets/litellm-master-key.txt)" \
  | jq -r '.data[].id' | sort
```

## Daily use

| Command | Behavior |
|---|---|
| `opencode` | TUI agent on the gateway. Default model `auto`; switch with `/models`. |
| `aider` | Architect mode: `local/qwen3-14b-0x` plans, `local/qwen2.5-coder-7b-0x` edits (`.aider.conf.yml`). |
| `goose` | MCP-heavy agent. Default `local/granite4.1-8b-0x`; override with `GOOSE_MODEL=…`. |
| `litellm-keys list` · `pull` · `push` · `mint <tool> [--budget USD --duration 30d]` · `revoke <tool>` | Manage per-tool keys. On a new Mac: `litellm-keys pull`. |

## Tool calling on local models

Verified 2026-05-26 against the gateway (`ollama_chat/` prefix):

- **Agent loops:** `local/granite4.1-8b-0x` (default), `local/qwen3-14b-0x`,
  `local/qwen3-abliterated-8b-0x`, `local/gemma4-e4b-0x`.
- **Chat only (no tools capability):** `local/deepseek-r1-14b-0x`,
  `local/llama3.2-vision-11b-0x`, `local/dolphin3-8b-0x` — sending tools just
  makes them emit raw JSON.
- **Completion, not agent loops:** `local/qwen2.5-coder-7b-0x` — advertises
  tools but emits raw JSON.

`opencode.jsonc` encodes these as `tools: true/false`.
