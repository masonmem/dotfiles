# AI Playground — Local Ollama + Agentic CLIs

A hands-on tour of `copilotp`, `aider`, `opencode`, and `goose` against your
local Ollama models. Work through it top-to-bottom; each section is independent
so feel free to skip around.

> **Setup tip:** open a fresh shell first (`exec zsh`) so the latest `copilotp`
> env vars are loaded. In another pane, run `watch -n2 'ollama ps'` to see
> which model is loaded, GPU%, and context size in real time.
>
> **Sample resources** for these exercises live in `playground/sample-project`,
> `playground/sample-files`, and `playground/sample-logs`. Copy them anywhere
> you like to play; the originals stay untouched in the repo.

---

## 0. Sanity checks (~30 seconds)

```sh
ollama list                                 # see installed models
ollama ps                                   # should be empty until first request
launchctl getenv OLLAMA_CONTEXT_LENGTH      # → 32768
launchctl getenv OLLAMA_KV_CACHE_TYPE       # → q8_0
launchctl getenv OLLAMA_FLASH_ATTENTION     # → 1
curl -s http://localhost:11434/api/tags | jq '.models[].name'
```

Quick generation, no agent:

```sh
ollama run qwen3:8b "Say hi in exactly 5 words. /no_think"
```

Watch `ollama ps` — first request loads the model (~5–10 s), then `100% GPU`
at your 32 K context window.

---

## 1. `copilotp` — private GitHub Copilot CLI

The marquee tool. Same UX as cloud `copilot`, but inference is local.

### 1a. One-shot, no tools (warm-up)

```sh
copilotp -p "In one sentence, what does the file ~/.zshrc do?"
```

The very first `copilotp` call after a fresh shell warms the model + KV cache —
expect 60–90 s. Subsequent calls in the same session are much faster.

### 1b. Read-only directory exploration (file tool)

```sh
SCRATCH=$(mktemp -d) && cp -R ~/dotfiles/ollama/playground/sample-files/* "$SCRATCH/"
cd "$SCRATCH"
copilotp -p "List every file in the current directory and group them by likely category (docs, images, finance, other). Don't move or modify anything."
```

What to check:
- Does it call the read/list tool instead of hallucinating?
- Does the grouping make sense?

### 1c. Bash tool with approval (the killer feature)

```sh
cd "$SCRATCH"   # same scratch dir from 1b
copilotp -p "Create subfolders 'docs', 'images', 'finance' and move the existing files into the right one. Ask before each destructive command."
```

Approve each `mv` interactively. This is the offline equivalent of letting
Claude reorganize a directory — fully local, no data leaves the machine.

### 1d. Stretch test: code edit + grep

```sh
PROJ=$(mktemp -d) && cp -R ~/dotfiles/ollama/playground/sample-project/* "$PROJ/"
cd "$PROJ"
copilotp -p "Add docstrings and type hints to every function in app.py. Show me the diff before writing."
```

This is where qwen3:8b will start to feel its size — instruction following on
multi-step edits is good but not Claude-good. If it stumbles, try:

```sh
COPILOT_MODEL=qwen2.5-coder:7b copilotp -p "..."     # cleaner tool calls
COPILOT_MODEL=qwen3:14b        copilotp -p "..."     # smarter, slower (~15 tok/s)
```

### 1e. Allow specific tools without prompting

```sh
copilotp --allow-tool='shell(ls:*)' --allow-tool='shell(rg:*)' \
  -p "Find every TODO comment in ~/.config/zsh and summarize them."
```

### 1f. Online-but-local mode

```sh
COPILOT_PRIVATE_ONLINE=1 copilotp
```

Keeps GitHub plumbing alive (`/pr`, `/delegate`, GitHub MCP) but still routes
inference to Ollama. Useful if you want local privacy for *thinking* but still
need to interact with GitHub.

---

## 2. `aider` — diff-based pair programmer

No tool-calling required → works on **any** Ollama model, including ones that
botch tool JSON. Great fallback for refactors.

### 2a. Configure once

```sh
cp ~/dotfiles/ollama/playground/aider.conf.yml ~/.aider.conf.yml
export OLLAMA_API_BASE=http://localhost:11434
```

(Add the export to `~/dotfiles/ollama/.config/zsh/15-ollama.zsh` if you decide
you like aider; for now keep it ad-hoc.)

### 2b. Drive it

```sh
PROJ=$(mktemp -d) && cp -R ~/dotfiles/ollama/playground/sample-project/* "$PROJ/"
cd "$PROJ" && git init -q && git add -A && git commit -q -m "initial"
aider app.py
```

Inside aider:

```
> Add a `div(a, b)` function that raises ValueError on b==0. Include a docstring.
> /diff
> /commit
> Now add a test file test_app.py covering all four functions.
> /run pytest -q
```

What to check:
- Does it produce a clean unified diff?
- Does `/run` pick up the failing output and self-correct?

### 2c. Larger context experiment

```sh
aider --model ollama_chat/qwen3:14b ~/.config/zsh/*.zsh
> Summarize what each file in this session does, in a markdown table.
```

You'll feel the 14B speed drop here — that's the tradeoff.

---

## 3. `opencode` — Claude-Code-style TUI

Full agentic TUI with built-in tools. The closest "vibes" match to Claude Code.

### 3a. Point it at Ollama

```sh
mkdir -p ~/.config/opencode
cp ~/dotfiles/ollama/playground/opencode.config.json ~/.config/opencode/config.json
```

### 3b. Run it

```sh
PROJ=$(mktemp -d) && cp -R ~/dotfiles/ollama/playground/sample-project/* "$PROJ/"
cd "$PROJ"
opencode
```

Try these inside the TUI:

```
Read app.py and propose three improvements without making changes.
Now apply only improvement #2.
Run `python -c "import app; print(app.add(2,3))"` and report the output.
/switch model ollama/qwen2.5-coder:7b
Write a small CLI in cli.py that exposes add/sub/mul/div as subcommands.
```

What to check:
- Tool-call panel — do calls succeed without JSON errors?
- Try `/help` to see all built-in slash commands.

---

## 4. `goose` — MCP-heavy general agent (Block)

Different design philosophy: heavy use of MCP servers (filesystem, shell,
memory, web). Worth a spin to compare to Copilot CLI's tool model.

### 4a. First-time configure

```sh
goose configure
```

At the prompts:
- Provider: **Ollama** (or "OpenAI compatible" → `http://localhost:11434/v1`)
- Model: `qwen3:8b`
- API key: anything (`ollama`)

### 4b. Try a session

```sh
SCRATCH=$(mktemp -d) && cp -R ~/dotfiles/ollama/playground/sample-files/* "$SCRATCH/"
cd "$SCRATCH"
goose session
```

Sample prompts:

```
Show me the file tree under . (use the shell tool).
Read TODO.txt and propose 3 next steps.
Remember that my preferred local model is qwen3:8b.
/exit
```

Then start a new session and ask: *"What did I tell you to remember?"* — tests
goose's memory MCP.

### 4c. One-shot mode

```sh
goose run -t "Count lines of code in ~/.config/zsh, grouped by file."
```

---

## 5. Head-to-head benchmark

Run the same prompt through each tool and compare outputs / speed / correctness.

```sh
BENCH=$(mktemp -d) && cp ~/dotfiles/ollama/playground/sample-logs/sample.log "$BENCH/"
cd "$BENCH"
```

The prompt (paste the **same** wording into each tool):

> "Read sample.log and tell me how many ERROR lines there are, the earliest
> timestamp, and the latest timestamp. Show the shell commands you used."

Score on:

| Tool | Correct ERROR count? | Used real shell calls? | Wall-clock time | Notes |
|---|---|---|---|---|
| `copilotp` (qwen3:8b)         |  |  |  |  |
| `copilotp` (qwen2.5-coder:7b) |  |  |  |  |
| `aider` + `/run`              |  |  |  |  |
| `opencode`                    |  |  |  |  |
| `goose`                       |  |  |  |  |

(The expected ERROR count for the supplied `sample.log` is **5**.)

---

## 6. Limits & stress tests

### 6a. Long context

```sh
copilotp -p "$(cat ~/AI-REPORT.md)\n\nSummarize the above in 5 bullet points."
```

If you push past ~24 K tokens you'll trip `MAX_PROMPT_TOKENS=24576` — override
for a one-off:

```sh
COPILOT_PROVIDER_MAX_PROMPT_TOKENS=30720 \
COPILOT_PROVIDER_MAX_OUTPUT_TOKENS=2048 \
  copilotp -p "..."
```
(Output dropped to 2K to keep prompt+output ≤ 32 K.)

### 6b. Tool-call reliability

qwen3 has a `<think>` mode that can corrupt tool-call JSON. Compare:

```sh
COPILOT_MODEL=qwen3:8b          copilotp -p "List the 5 largest files in ~/Downloads using du."
COPILOT_MODEL=qwen2.5-coder:7b  copilotp -p "List the 5 largest files in ~/Downloads using du."
```

`qwen2.5-coder:7b` has no thinking mode → consistently cleaner tool calls.
`qwen3:8b` is fine *because* of the `/no_think` line in
`~/.copilot/copilot-instructions.md`.

### 6c. Memory ceiling (live!)

```sh
ollama run qwen3:14b "Hello"     # in one pane
# in another:
watch -n2 'vm_stat | head -5; echo; ollama ps'
```

Watch swap — `qwen3:14b` is the absolute ceiling for your 16 GB box.

---

## 7. Cleanup

Each section above uses `mktemp -d` directories, so cleanup is automatic on
reboot. If you want them gone now:

```sh
find /var/folders -maxdepth 5 -type d -user "$USER" -name 'tmp.*' -mmin -120 2>/dev/null
# inspect, then `rm -rf` the ones from this session
```

Optional clean-out:
```sh
rm -f  ~/.aider.conf.yml                # if you don't want aider's defaults
rm -rf ~/.config/opencode/config.json   # opencode's ollama provider config
```

When you're done playing, both `copilot` (cloud) and `copilotp` (local) keep
working independently. Have fun.
