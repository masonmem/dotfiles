# Playground resources

Static sample inputs and provider configs used by `../PLAYGROUND.md`. Nothing
here is symlinked or stowed — the playground exercises `cp` these into
`mktemp -d` scratch dirs so your experiments don't dirty the repo.

| Path | Used by |
|---|---|
| `sample-project/`         | aider, opencode, copilotp code-edit exercises |
| `sample-files/`           | directory-organization exercises (copilotp, goose) |
| `sample-logs/sample.log`  | head-to-head benchmark (§5) — contains 5 ERROR lines |
| `aider.conf.yml`          | aider config pointing at `ollama_chat/qwen2.5-coder:7b` |
| `opencode.config.json`    | opencode provider block for the local Ollama OpenAI-compatible endpoint |

To reset any of the scratch directories you've created, they live under
`/var/folders/.../tmp.*` and self-clean on reboot.
