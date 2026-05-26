# ── LiteLLM gateway (solaris) — single OpenAI-compatible endpoint ──────────
#
# Loads per-tool LiteLLM virtual keys into <TOOL>_LITELLM_KEY env vars so
# opencode / aider / etc. can authenticate without each having its own
# bespoke secret-loading code.
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

_litellm_load_key opencode OPENCODE_LITELLM_KEY
_litellm_load_key aider    AIDER_LITELLM_KEY
_litellm_load_key goose    GOOSE_LITELLM_KEY

unfunction _litellm_load_key

# Deliberately NOT exporting OPENAI_API_KEY globally:
#   opencode auto-detects providers from env vars and would silently
#   light up its built-in "OpenAI" catalog (gpt-4o, gpt-5, …) on top of
#   the LiteLLM provider configured in opencode.jsonc — polluting the
#   model picker with models we don't host. opencode reads the gateway
#   key from $OPENCODE_LITELLM_KEY via the `{env:…}` placeholder in its
#   config; aider uses its own shell wrapper (60-aider-wrapper.zsh).
#
# For ad-hoc curl / scripts, set explicitly per-invocation, e.g.:
#   OPENAI_BASE_URL=$LITELLM_BASE_URL OPENAI_API_KEY=$OPENCODE_LITELLM_KEY \
#       curl "$LITELLM_BASE_URL/models" -H "Authorization: Bearer $OPENAI_API_KEY"
