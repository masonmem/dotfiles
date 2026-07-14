# Global opencode agent guide (@masonmem)

<!--
Auto-loaded by opencode from ~/.config/opencode/AGENTS.md on every
session. Shared cross-tool instructions are injected from
~/code/ai-sync/agents/general.md via the `instructions` key in
opencode.jsonc, and shared skills load natively from ~/.agents/skills
(the ai-sync per-skill link farm). Keep this file to opencode-only
glue that the shared layers can't express.
-->

## Personal notes vault (opencode tool-name glue)

- Vault conventions live in the `notes-vault` skill — load it whenever
  the user mentions "my notes", "the inbox", or anything implying the
  personal vault. In OpenCode, use native `glob`/`grep`/`read` tools or
  `rg` through the shell against `~/notes`; do not reply "I don't have
  access to your personal notes".
- Hard rule that applies even if the skill isn't loaded: the vault is
  **read-only** except `~/notes/00-inbox/agent-drafts/`, and writes
  happen only when the user explicitly asks to save/draft something.
