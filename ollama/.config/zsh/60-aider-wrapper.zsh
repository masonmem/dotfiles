# ── aider wrapper ─────────────────────────────────────────────────────────
#
# aider's YAML config doesn't expand env vars, so we can't put
# openai-api-key: ${AIDER_LITELLM_KEY} in .aider.conf.yml. Instead, wrap
# the binary in a function that sets OPENAI_API_KEY to aider's per-tool
# LiteLLM virtual key before exec. The user's shell-level OPENAI_API_KEY
# (which defaults to copilotp's key) is preserved everywhere else.
#
# Escape hatch: AIDER_USE_MASTER_KEY=1 → use the LiteLLM master key
# (useful if you accidentally revoke the aider virtual key).

aider() {
  local key="${AIDER_LITELLM_KEY:-}"
  if [[ -n "${AIDER_USE_MASTER_KEY:-}" && -r "$HOME/.copilot/secrets/litellm-master-key.txt" ]]; then
    key="$(<"$HOME/.copilot/secrets/litellm-master-key.txt")"
  fi
  if [[ -z "$key" ]]; then
    print -u2 "aider: no AIDER_LITELLM_KEY available — run 'litellm-keys pull' (or 'litellm-keys mint aider'; see ~/dotfiles/ollama/bin/litellm-keys)"
    return 1
  fi
  OPENAI_API_KEY="$key" command aider "$@"
}
