# GitHub CLI authentication. The fine-grained PAT is machine-local and shared
# through ai-sync's secrets surface; GH_TOKEN is preferred by `gh` and avoids
# loading a duplicate GitHub MCP server just for API access.
_gh_cli_pat_file="${AI_CONFIG:-$HOME/.ai-config}/secrets/github-mcp-pat.txt"
if [[ -z "${GH_TOKEN:-}" && -r "$_gh_cli_pat_file" ]]; then
  export GH_TOKEN="$(<"$_gh_cli_pat_file")"
fi
unset _gh_cli_pat_file
