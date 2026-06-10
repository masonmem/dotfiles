# Export the GitHub PAT consumed by the `github` Claude Code / Copilot MCP
# server, whose .mcp.json sets `Authorization: Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}`.
# The token is machine-local and lives out of git in
#   ~/.ai-config/secrets/github-mcp-pat.txt   (chmod 600)
# Create it with a fine-grained PAT (see that server's docs for scopes).
_gh_mcp_pat_file="${AI_CONFIG:-$HOME/.ai-config}/secrets/github-mcp-pat.txt"
if [[ -r "$_gh_mcp_pat_file" ]]; then
  export GITHUB_PERSONAL_ACCESS_TOKEN="$(<"$_gh_mcp_pat_file")"
fi
unset _gh_mcp_pat_file
