# ollama (dotfiles package)

Opt-in zsh configuration for using the LiteLLM gateway on solaris from
this Mac:

- Local Ollama tuning env vars for Apple Silicon (`15-ollama.zsh`) — the
  Modelfile-baked sampler/`num_ctx` lives **server-side** on solaris
  (in `homelab/solaris/ollama/modelfiles/`); these env vars matter only
  if you also `brew install ollama` on this Mac.
- LiteLLM gateway env: loads per-tool virtual keys into env vars; sets
  `OPENAI_BASE_URL`/`OPENAI_API_KEY` for ad-hoc OpenAI-SDK use
  (`16-llm-gateway.zsh`).
- `aider` and `goose` wrappers that inject `OPENAI_API_KEY=$<TOOL>_LITELLM_KEY`
  per call (their YAML doesn't expand env vars).
- `litellm-keys` CLI: list / push / pull / mint / revoke per-tool LiteLLM
  virtual keys; bridges file cache and macOS Keychain (`bin/litellm-keys`).

This package is **not** stowed automatically. Personal machines opt in:

```bash
stow --no-folding ollama
```

Do **not** stow this on work machines unless you've cleared local-LLM
use with your employer.

## Where the models actually live

The Ollama daemon + every `local/*-0x` Modelfile + LiteLLM run on
**solaris** (Mac Mini). This Mac talks to them over the tailnet via
`https://llm.hyperionx.dev/v1`. You don't need Ollama installed locally
unless you want a fallback when solaris is unreachable.

To see what's exposed:

```sh
curl -sS https://llm.hyperionx.dev/v1/models \
  -H "Authorization: Bearer $(cat ~/.copilot/secrets/litellm-master-key.txt)" \
  | jq -r '.data[].id' | sort
```

See `homelab/docs/models.md` for the model roster, naming convention
(`<scope>/<short>-<version>-<Nx>`), cost tiers, and the `auto` / `smart`
routed aliases.

## Daily use

| Command | Behavior |
|---|---|
| `opencode` | TUI agent against the LiteLLM gateway. `Ctrl-M` switches model. Default: `auto` (local granite, escalates to cloud only on context overflow). |
| `aider` | Diff-driven editor. Shell wrapper injects `OPENAI_API_KEY` per call. Default: `openai/local/gemma4-e4b-0x`. |
| `goose` | MCP-heavy interactive agent. Shell wrapper injects `OPENAI_API_KEY=$GOOSE_LITELLM_KEY`. Default: `local/granite4.1-8b-0x`. Config: `~/.config/goose/config.yaml` (stowed). |
| `litellm-keys list` / `mint <tool> [--budget USD --duration 30d]` / `revoke <tool>` / `push` / `pull` | Manage per-tool LiteLLM virtual keys (file ↔ Keychain). |

See `homelab/docs/llm-clients.md` for how the gateway, virtual keys,
and BYOK plumbing fit together end-to-end.

## Tool calling on local models — the short version

Verified 2026-05-26 against the gateway with `ollama_chat/` prefix:

- **Use for agentic loops:** `local/granite4.1-8b-0x` (default),
  `local/qwen3-14b-0x` (reasoning + tools), `local/qwen3-abliterated-8b-0x`,
  `local/gemma4-e4b-0x` (multimodal + 256K ctx).
- **Chat only (no tools):** `local/deepseek-r1-14b-0x`,
  `local/llama3.2-vision-11b-0x`, `local/dolphin3-8b-0x` —
  these lack the `tools` capability per `ollama show`; sending tools
  embeds the schema as prompt text and the model emits raw JSON.
- **Code completion, not agent loops:** `local/qwen2.5-coder-7b-0x` —
  advertises `tools` but its template emits raw JSON even at native
  `/api/chat`. Marked `tools:false` in `opencode.jsonc` for safety.

`opencode.jsonc` encodes these flags; the homelab-helper skill
(rule 16) gates `tools:true` on `ollama show` capability before
toggling.

## Companion alternatives (configs stowed; install binaries via Homebrew)

```bash
brew install aider                       # diff-based pair programming
brew install opencode                    # Claude-Code-style TUI agent
brew install block-goose-cli             # MCP-heavy general agent
```

After binaries are installed, `stow --no-folding ollama` from
`~/dotfiles` (re-)creates symlinks for the opencode, aider, and goose
configs.

## Unstow

```bash
stow -D ollama
```
