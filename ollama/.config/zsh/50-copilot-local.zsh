# ── copilotp — private GitHub Copilot CLI session backed by local LLMs ──────
#
# Two commands:
#   • copilot   — unchanged, hits GitHub Copilot cloud (Claude/GPT-*)
#   • copilotp  — wraps copilot with BYOK env vars + COPILOT_OFFLINE=true so
#                 inference runs against our LiteLLM gateway (solaris ollama).
#
# Wiring (default): routes through https://llm.hyperionx.dev/v1 using a
# per-tool LiteLLM virtual key at ~/.copilot/secrets/litellm-copilotp.txt.
# That gateway forwards to ollama on solaris. Requires Tailscale; the
# *.hyperionx.dev domain resolves to the tailnet CGNAT addr.
#
# Escape hatch (works ONLY when running on solaris itself, where ollama is
# bound to localhost:11434):
#   COPILOT_DIRECT=1 copilotp
#
# Usage:
#   copilotp                                          # default, granite4.1
#   copilotp -p "..." --allow-tool='shell(ls:*)'
#   COPILOT_MODEL=local/qwen2.5-coder-7b copilotp
#   COPILOT_PRIVATE_ONLINE=1 copilotp                 # keep GitHub plumbing on
#
# Excluded tools (cloud-only / unhelpful for small local models):
#   task, read_agent, list_agents — sub-agent spawning would recurse the
#     small model into itself
#   skill, fetch_copilot_cli_documentation — cloud features
#   sql — eats context for little benefit at this scale
#   report_intent — UI-only signal
#
# Model names follow LiteLLM's `local/*` namespace (see
# homelab/solaris/litellm/config.yaml). Fallbacks: local/gemma4-e4b,
# local/qwen2.5-coder-7b, local/qwen3-8b.
copilotp() {
  local model="${COPILOT_MODEL:-local/granite4.1-8b}"
  local offline="true"
  [[ -n "${COPILOT_PRIVATE_ONLINE:-}" ]] && offline="false"

  local base_url api_key
  if [[ -n "${COPILOT_DIRECT:-}" ]]; then
    base_url="http://localhost:11434/v1"
    api_key="ollama"
    # Strip the local/ prefix that LiteLLM uses; ollama wants the raw name.
    model="${model#local/}"
    # Translate hyphen-style names back to ollama's colon-tag style.
    case "$model" in
      granite4.1-8b)        model="granite4.1:8b" ;;
      gemma4-e4b)           model="gemma4:e4b" ;;
      qwen2.5-coder-7b)     model="qwen2.5-coder:7b" ;;
      qwen3-8b)             model="qwen3:8b" ;;
      qwen3-14b)            model="qwen3:14b" ;;
    esac
  else
    base_url="${COPILOT_LITELLM_BASE_URL:-https://llm.hyperionx.dev/v1}"
    local key_file="${COPILOT_LITELLM_KEY_FILE:-$HOME/.copilot/secrets/litellm-copilotp.txt}"
    if [[ ! -r "$key_file" ]]; then
      print -u2 "copilotp: missing LiteLLM virtual key at $key_file"
      print -u2 "  Mint one with: curl -X POST $base_url/key/generate -H 'Authorization: Bearer \$LITELLM_MASTER_KEY' \\"
      print -u2 "                  -H 'Content-Type: application/json' -d '{\"models\":[\"local/*\",\"cloud/*\"],\"key_alias\":\"copilotp\"}'"
      return 1
    fi
    api_key="$(<"$key_file")"
  fi

  COPILOT_PROVIDER_BASE_URL="$base_url" \
  COPILOT_PROVIDER_TYPE="openai" \
  COPILOT_PROVIDER_API_KEY="$api_key" \
  COPILOT_PROVIDER_WIRE_API="completions" \
  COPILOT_MODEL="$model" \
  COPILOT_PROVIDER_MAX_PROMPT_TOKENS="${COPILOT_PROVIDER_MAX_PROMPT_TOKENS:-24576}" \
  COPILOT_PROVIDER_MAX_OUTPUT_TOKENS="${COPILOT_PROVIDER_MAX_OUTPUT_TOKENS:-8192}" \
  COPILOT_OFFLINE="$offline" \
    command copilot \
      --effort none \
      --excluded-tools=task,read_agent,list_agents,skill,sql,fetch_copilot_cli_documentation,report_intent \
      "$@"
}

# Explicit cloud alias, for clarity in scripts.
alias copilotc='command copilot'
