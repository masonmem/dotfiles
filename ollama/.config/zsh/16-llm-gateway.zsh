# ── LiteLLM gateway (solaris) — single OpenAI-compatible endpoint ──────────
#
# Loads per-tool LiteLLM virtual keys into <TOOL>_LITELLM_KEY env vars so
# copilotp / opencode / aider / etc. can authenticate without each having
# its own bespoke secret-loading code.
#
# Two-tier lookup, file first then Keychain:
#   1. ~/.copilot/secrets/litellm-<tool>.txt  (chmod 600, gitignored)
#   2. macOS Keychain generic password, service name "litellm-<tool>"
#
# Keychain is the sync mechanism across machines (iCloud Keychain /
# Passwords app). The file is just a per-machine cache so we don't shell
# out to `security` on every shell start. Use `litellm-keys` to move
# between them (see ~/dotfiles/ollama/bin/litellm-keys).
#
# Master key is operator-only — used to mint/list/delete virtual keys and
# log into the admin UI. NEVER exported to client tools.

export LITELLM_BASE_URL="https://llm.hyperionx.dev/v1"

_litellm_load_key() {
  local tool="$1" var="$2"
  local file="$HOME/.copilot/secrets/litellm-$tool.txt"
  local val=""
  if [[ -r "$file" ]]; then
    val="$(<"$file")"
  else
    val="$(security find-generic-password -s "litellm-$tool" -w 2>/dev/null)"
  fi
  [[ -n "$val" ]] && export "$var=$val"
}

_litellm_load_key copilotp COPILOTP_LITELLM_KEY
_litellm_load_key opencode OPENCODE_LITELLM_KEY
_litellm_load_key aider    AIDER_LITELLM_KEY

unfunction _litellm_load_key

# OpenAI-compatible env for ad-hoc tooling. Default to copilotp's key —
# it's the broadest-use one. aider has its own wrapper that overrides.
if [[ -n "${COPILOTP_LITELLM_KEY:-}" ]]; then
  export OPENAI_BASE_URL="$LITELLM_BASE_URL"
  export OPENAI_API_BASE="$OPENAI_BASE_URL"
  export OPENAI_API_KEY="$COPILOTP_LITELLM_KEY"
fi
