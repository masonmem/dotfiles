# Global opencode agent guide (@masonmem)

<!--
Auto-loaded by opencode from ~/.config/opencode/AGENTS.md on every
session, regardless of cwd. Keep terse — durable, non-project-specific
hints only. Project-specific instructions belong in a repo-root
AGENTS.md.
-->

## Personal notes vault

- `~/notes` is the user's Obsidian vault (Mason's personal notes,
  journal, inbox, projects). Same vault is mounted in Open WebUI as
  the `notes` tool server, so behaviour should be symmetric across
  surfaces.
- When the user mentions "my notes", "the inbox", "what did I write
  about X", or anything implying the personal vault, USE the `notes`
  MCP tools (`notes_search_files`, `notes_read_text_file`,
  `notes_list_directory`, etc.). Do NOT respond with "I don't have
  access to your personal notes" — you do.
- Latest-by-mtime: `notes_directory_tree` of `00-inbox/` and the dated
  subfolders is usually the right starting point; fall back to
  `notes_search_files` with a query when the user asks about topics.
- Treat the vault as **read-only by default**. Only write under
  `~/notes/00-inbox/agent-drafts/` (matches the OWUI airlock), and
  only when the user explicitly asks you to save / draft something.
