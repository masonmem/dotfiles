# ── LiteLLM gateway (solaris) — single OpenAI-compatible endpoint ──────────
#
# Routes opencode, aider, and anything else that honors OPENAI_BASE_URL +
# OPENAI_API_KEY through the LiteLLM proxy on solaris. LiteLLM gives one
# namespace for:
#   • local/*  — privately-hosted ollama models on solaris
#   • cloud/*  — BYOK Anthropic / OpenAI / Gemini routes (add provider key
#                in solaris Periphery [secrets] to enable)
#
# Auth model:
#   • Master key (~/.copilot/secrets/litellm-master-key.txt) is operator-only
#     and is NOT exported. Use it for admin/key minting only.
#   • Per-tool virtual keys (mint with /key/generate) live at
#     ~/.copilot/secrets/litellm-<tool>.txt. We export them as
#     <TOOL>_LITELLM_KEY so each tool's config can opt in explicitly.
#   • OPENAI_BASE_URL points at the gateway. OPENAI_API_KEY is set to the
#     copilotp key as a sane default for ad-hoc `curl` / OpenAI SDK use;
#     aider and opencode use their own virtual keys via their configs.
#
# Endpoint:
#   • llm.hyperionx.dev (Caddy → LiteLLM on solaris) — tailnet-only via
#     CGNAT DNS; gives TLS and edge revocation. For same-host (solaris)
#     usage swap to http://localhost:4000/v1.

export LITELLM_BASE_URL="https://llm.hyperionx.dev/v1"

_load_litellm_key() {
  local tool="$1" var="$2" file="$HOME/.copilot/secrets/litellm-$1.txt"
  [[ -r "$file" ]] && export "$var=$(<"$file")"
}

_load_litellm_key copilotp COPILOTP_LITELLM_KEY
_load_litellm_key opencode OPENCODE_LITELLM_KEY
_load_litellm_key aider    AIDER_LITELLM_KEY

unfunction _load_litellm_key

# OpenAI-compatible env for ad-hoc tooling (uses copilotp key as default).
if [[ -n "${COPILOTP_LITELLM_KEY:-}" ]]; then
  export OPENAI_BASE_URL="$LITELLM_BASE_URL"
  export OPENAI_API_BASE="$OPENAI_BASE_URL"
  export OPENAI_API_KEY="$COPILOTP_LITELLM_KEY"
fi
