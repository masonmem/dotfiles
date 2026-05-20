# ── Ollama (local LLM runtime) ──────────────────────────────────────────────
# Tuning for Apple Silicon Macs with 16–32 GB unified memory.
# Persistent equivalents (read by the Ollama.app and `brew services` ollama
# alike) live in launchctl — set them once with:
#
#   launchctl setenv OLLAMA_FLASH_ATTENTION 1
#   launchctl setenv OLLAMA_KV_CACHE_TYPE q8_0
#   launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
#   launchctl setenv OLLAMA_KEEP_ALIVE 30m
#   launchctl setenv OLLAMA_MAX_LOADED_MODELS 1
#   launchctl setenv OLLAMA_NUM_PARALLEL 1
#
# The shell exports below make those same values visible to ad-hoc
# `ollama serve` invocations launched from a terminal.

export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_CONTEXT_LENGTH=32768
export OLLAMA_KEEP_ALIVE=30m
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1
