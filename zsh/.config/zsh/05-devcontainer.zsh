# Devcontainer bootstrap — auto-install CLI tools on first shell open.
# Only runs when DEVCONTAINER=1 and the stamp file is missing.
[[ -z "${DEVCONTAINER}" ]] && return

_dc_stamp="/usr/local/share/.devcontainer-tools-installed"
if [[ ! -f "$_dc_stamp" ]] && [[ -x "/opt/dotfiles-scripts/devcontainer-tools.sh" ]]; then
  echo "⏳ Installing shell tools (first run only)..."
  /opt/dotfiles-scripts/devcontainer-tools.sh && touch "$_dc_stamp"
fi
unset _dc_stamp
