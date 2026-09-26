# How-to guides

Task-focused recipes. Each ends with how the change reaches your other machines.

| Task | Guide |
|---|---|
| Make a change and get it onto every machine | [Everyday workflow](daily-workflow.md) |
| Install a new CLI tool or app, on every Mac, personal ones, or one host | [Add a tool](add-a-tool.md) |
| Track a new config file, or change, rename or delete one | [Add or change a config file](add-or-change-config.md) |
| Add an alias, function, env var or key binding | [Add shell config](add-shell-config.md) |
| Group a new tool's config (and software) as an opt-in unit | [Add a package](add-a-package.md) |
| Set up a new machine name, host-only software, or per-host tweaks | [Add a machine](add-a-machine.md) |
| Separate work git identity; keep personal things off the work Mac | [Keep work and personal apart](work-machine.md) |
| Stop using a tool, package or file | [Remove things](remove-things.md) |
| Upgrade oh-my-zsh / powerlevel10k / zsh plugins | [Update the shell framework](update-shell-framework.md) |

!!! abstract "The one rule"
    Every change goes: **edit → `tests/run` → commit → push → `sync-all`
    elsewhere.** The guides only differ in *which file* you edit.
