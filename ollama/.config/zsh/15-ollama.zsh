# ── Ollama (local LLM runtime) ──────────────────────────────────────────────
# Tuning for Apple Silicon Macs with 16–32 GB unified memory.
# On solaris the persistent values are set by the com.user.ollama LaunchAgent
# (~/dotfiles/ollama/launchagents/com.user.ollama.plist), which runs the
# official standalone ollama build — NOT `brew services` (the brew formula
# bottle is broken; see that plist's header and the launchagents README).
#
# The shell exports below make those same values visible to ad-hoc
# `ollama serve` invocations launched from a terminal.

export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_CONTEXT_LENGTH=32768
export OLLAMA_KEEP_ALIVE=30m
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1

# Consumed by aider (LiteLLM) and any other tool that auto-discovers Ollama.
export OLLAMA_API_BASE=http://localhost:11434
