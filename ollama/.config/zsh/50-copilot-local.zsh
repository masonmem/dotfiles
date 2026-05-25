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

# Default model: granite4.1:8b
#   - Picked May 2026 after head-to-head bench with gemma4:e4b-tools and
#     qwen3.5:4b on Copilot CLI's agentic loop ("list files and describe"
#     against the real 10-tool catalog after exclusions):
#       granite4.1:8b   → 3 clean tool calls (glob, view, view), no confab
#       gemma4:e4b-tools → 0 tool calls, just shrugged
#       qwen3.5:4b      → emitted XML <search_files> tags (wrong harness),
#                          ollama tool-parser couldn't extract a call
#   - granite4.1 (IBM, Apache-2.0) is "tools"-tagged on ollama.com and is
#     trained against OpenAI-style tool schemas, so it actually uses tools
#     from the provided catalog instead of inventing google_search,
#     view_file_list_, etc. ~5 GB; comfortably fits with headroom on 16 GB.
#   - Use gemma4:e4b-tools for chat/code-writing tasks where you want
#     better prose/explanations and don't need clean agentic loops.
#
# Excluded tools (--excluded-tools):
#   Cloud-only or routinely confusing for small local models:
#     task, read_agent, list_agents  — sub-agent spawning (would re-invoke
#       the local model recursively; useless on small models)
#     skill                           — built-in Copilot skills (cloud)
#     sql                             — session SQLite; eats context with
#                                       little benefit at this model size
#     fetch_copilot_cli_documentation — cloud doc fetch
#     report_intent                   — UI-only signaling
#
# Fallbacks if granite misbehaves on a session:
#   COPILOT_MODEL=gemma4:e4b-tools  copilotp   # chattier; flaky on tools
#   COPILOT_MODEL=qwen2.5-coder:7b  copilotp   # old default
#   COPILOT_MODEL=qwen3:8b          copilotp   # pure chat
copilotp() {
  local model="${COPILOT_MODEL:-granite4.1:8b}"
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
    command copilot \
      --effort none \
      --excluded-tools=task,read_agent,list_agents,skill,sql,fetch_copilot_cli_documentation,report_intent \
      "$@"
}

# Explicit cloud alias, for clarity in scripts.
alias copilotc='command copilot'
