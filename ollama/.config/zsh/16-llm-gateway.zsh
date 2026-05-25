# ── LiteLLM gateway (solaris) — single OpenAI-compatible endpoint ──────────
#
# Routes opencode, aider, and anything else that honors OPENAI_BASE_URL +
# OPENAI_API_KEY through the LiteLLM proxy on solaris. LiteLLM gives one
# namespace for:
#   • local/*  — privately-hosted ollama models (qwen3:14b, granite4.1, …)
#   • cloud/*  — BYOK Anthropic / OpenAI / Gemini routes
#
# copilotp is intentionally NOT routed here (it talks straight to Ollama at
# localhost:11434 for the lowest-latency private path). Tools that DO want
# both local and cloud under one config point at this gateway.
#
# Auth: the master key is operator-only and lives at
# ~/.copilot/secrets/litellm-master-key.txt. Per-tool virtual keys (with
# spend caps) will replace it as the rollout matures — track in MASON_TODO.
#
# Endpoint choice:
#   • llm.hyperionx.dev (Caddy → LiteLLM on solaris) — works anywhere on
#     tailnet, gets TLS, easy to revoke at the edge.
#   • For same-host (solaris) usage swap to http://localhost:4000/v1.

if [[ -r "$HOME/.copilot/secrets/litellm-master-key.txt" ]]; then
  export OPENAI_BASE_URL="https://llm.hyperionx.dev/v1"
  export OPENAI_API_KEY="$(<"$HOME/.copilot/secrets/litellm-master-key.txt")"
  # Some tools (openai-python <1.x, langchain) read the older name too:
  export OPENAI_API_BASE="$OPENAI_BASE_URL"
fi
