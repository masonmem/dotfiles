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
unset _dc_stamp
