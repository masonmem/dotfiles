# ── copilotp — private GitHub Copilot CLI session backed by local Ollama ────
#
# Two commands are provided:
#   • copilot   — unchanged, hits GitHub Copilot cloud (Claude/GPT-*)
#   • copilotp  — wraps copilot with BYOK env vars + COPILOT_OFFLINE=true so
#                 inference runs entirely against Ollama on this machine.
#
# Usage:
#   copilotp                         # private interactive session, qwen3:8b
#   copilotp -p "..." --allow-tool='shell(ls:*)'
#   COPILOT_MODEL=qwen2.5-coder:7b copilotp
#   COPILOT_PRIVATE_ONLINE=1 copilotp    # local inference, keep GitHub plumbing
#
# Notes:
#   • COPILOT_OFFLINE=true requires COPILOT_PROVIDER_BASE_URL to be set;
#     it disables GitHub auth, telemetry, web tools, and the GitHub MCP server.
#   • Ollama is OpenAI-compatible at /v1/chat/completions, so wire-api stays
#     on the default "completions" (not "responses").
#   • API key is required by the SDK but unused by Ollama — any string works.
#   • Token budgets: prompt + output must fit within OLLAMA_CONTEXT_LENGTH
#     (32768). We give the agent 24K prompt headroom (tool results stack up)
#     and an 8K output cap, which is plenty for code generation.

copilotp() {
  local model="${COPILOT_MODEL:-qwen3:8b}"
  local offline="true"
  [[ -n "${COPILOT_PRIVATE_ONLINE:-}" ]] && offline="false"

  COPILOT_PROVIDER_BASE_URL="http://localhost:11434/v1" \
  COPILOT_PROVIDER_TYPE="openai" \
  COPILOT_PROVIDER_API_KEY="ollama" \
  COPILOT_PROVIDER_WIRE_API="completions" \
  COPILOT_MODEL="$model" \
  COPILOT_PROVIDER_MAX_PROMPT_TOKENS="${COPILOT_PROVIDER_MAX_PROMPT_TOKENS:-24576}" \
  COPILOT_PROVIDER_MAX_OUTPUT_TOKENS="${COPILOT_PROVIDER_MAX_OUTPUT_TOKENS:-8192}" \
  COPILOT_OFFLINE="$offline" \
    command copilot "$@"
}

# Explicit cloud alias, for clarity in scripts.
alias copilotc='command copilot'
