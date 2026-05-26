# ── goose wrapper — inject the per-tool LiteLLM key as OPENAI_API_KEY ──
#
# Goose's `openai` provider reads OPENAI_API_KEY from the env. We don't
# export OPENAI_API_KEY globally (that would trigger opencode's
# provider auto-detection — see 16-llm-gateway.zsh). Instead we wrap
# the goose CLI so the key is only set inside the goose process.
#
# Config: ~/.config/goose/config.yaml (stowed from
# dotfiles/ollama/.config/goose/config.yaml). Default model:
# cloud/sonnet-4.5-3x — override with GOOSE_MODEL=local/granite4.1-8b-0x.

goose() {
  local key="${GOOSE_LITELLM_KEY:-}"
  if [[ -z "$key" ]]; then
    print -u2 "goose: no GOOSE_LITELLM_KEY available — run 'litellm-keys mint goose'"
    return 1
  fi
  OPENAI_API_KEY="$key" command goose "$@"
}
