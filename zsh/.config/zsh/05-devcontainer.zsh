# Devcontainer bootstrap — auto-install CLI tools on first shell open.
# Only runs when DEVCONTAINER=1 and the stamp file is missing.
# Tools are cached in a named volume for fast reinstalls.
[[ -z "${DEVCONTAINER}" ]] && return

_dc_stamp="/usr/local/share/.devcontainer-tools-installed"
if [[ ! -f "$_dc_stamp" ]] && [[ -x "/opt/dotfiles-scripts/devcontainer-tools.sh" ]]; then
  echo "⏳ Installing shell tools (first run)..."
  TOOL_CACHE="/var/cache/devcontainer-tools" /opt/dotfiles-scripts/devcontainer-tools.sh &>/dev/null && touch "$_dc_stamp"
  echo "✓ Done"
fi

# Apply only the portable/work-safe ai-sync layer when the same personal repo
# has been cloned into this container. Never assume or install home-only skills.
_ai_sync="$HOME/code/ai-sync"
_ai_stamp="$HOME/.local/share/ai-sync/.container-installed"
if [[ -x "$_ai_sync/install.sh" && ! -f "$_ai_stamp" ]]; then
  echo "⏳ Installing portable AI configuration..."
  mkdir -p "${_ai_stamp:h}"
  "$_ai_sync/install.sh" --work --container && touch "$_ai_stamp"
  echo "✓ Done"
fi

if [[ -x "/opt/dotfiles-scripts/configure-vscode-ai" ]]; then
  /opt/dotfiles-scripts/configure-vscode-ai --container &>/dev/null || true
fi
unset _dc_stamp _ai_sync _ai_stamp
