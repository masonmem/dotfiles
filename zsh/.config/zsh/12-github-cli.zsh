# GitHub CLI authentication from the machine-local fine-grained PAT kept in
# ai-sync's secrets directory (personal hosts only — absent on work machines,
# where this is a no-op). GH_TOKEN takes precedence over `gh auth login`.
_gh_cli_pat_file="${AI_CONFIG:-$HOME/code/ai-sync}/secrets/github-mcp-pat.txt"
if [[ -z "${GH_TOKEN:-}" && -r "$_gh_cli_pat_file" ]]; then
  export GH_TOKEN="$(<"$_gh_cli_pat_file")"
fi
unset _gh_cli_pat_file
