-- ── Options ─────────────────────────────────────────────────────────────────
vim.opt.number         = true           -- show line numbers
vim.opt.relativenumber = true           -- relative numbers for easy jump (5j, 12k)
vim.opt.cursorline     = true           -- highlight current line
vim.opt.scrolloff      = 8             -- keep 8 lines above/below cursor
vim.opt.sidescrolloff  = 8
vim.opt.wrap           = false          -- no line wrapping

vim.opt.expandtab      = true           -- spaces not tabs
vim.opt.shiftwidth     = 2
vim.opt.tabstop        = 2
vim.opt.smartindent    = true

vim.opt.ignorecase     = true           -- case-insensitive search...
vim.opt.smartcase      = true           -- ...unless you type a capital

vim.opt.termguicolors  = true           -- true color
vim.opt.signcolumn     = "yes"          -- always show sign column (no layout jump)
vim.opt.splitbelow     = true           -- horizontal splits go below
vim.opt.splitright     = true           -- vertical splits go right
vim.opt.updatetime     = 250            -- faster CursorHold (used by many plugins)

vim.opt.clipboard      = "unnamedplus"  -- yank/paste uses system clipboard
vim.opt.mouse          = "a"            -- mouse in all modes

vim.opt.undofile       = true           -- persistent undo across sessions
vim.opt.swapfile       = false

-- ── Leader ───────────────────────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Keymaps ──────────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- File operations (familiar shortcuts on top of :w / :wq)
map("n", "<leader>w",  "<cmd>w<cr>",  { desc = "Save file" })
map("n", "<leader>q",  "<cmd>q<cr>",  { desc = "Quit" })
map("n", "<leader>Q",  "<cmd>qa!<cr>", { desc = "Quit all (no save)" })

-- Clear search highlight (replaces typing :noh)
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Window navigation with Ctrl+hjkl (same as tmux panes with vim mode)
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Better indenting in visual mode (stay in visual after indent)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selected lines up/down
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })

-- Comments: Neovim's built-in gcc (line) / gc{motion} / gc in visual mode.

-- File explorer (built-in netrw)
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })

-- ── Plugin manager: lazy.nvim ────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- ── Colorscheme (Catppuccin Macchiato — matches tmux, bat, fzf, lazygit) ───
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    config   = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },

  -- ── Syntax highlighting via Treesitter ────────────────────────────────────
  -- nvim-treesitter's `main` branch: needs Neovim 0.12+ and the tree-sitter
  -- CLI (Brewfile: tree-sitter-cli) to build parsers. Skipped on older Neovim
  -- (e.g. distro packages), which keeps regex highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy   = false,           -- the plugin does not support lazy-loading
    build  = ":TSUpdate",
    cond   = vim.fn.has("nvim-0.12") == 1,
    config = function()
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install({
          "bash", "go", "javascript", "json", "lua", "markdown",
          "python", "rust", "toml", "typescript", "vim", "vimdoc", "yaml",
        })
      end
      -- Highlighting is Neovim's own; start it for any filetype with a parser.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args) pcall(vim.treesitter.start, args.buf) end,
      })
    end,
  },

  -- ── Status line ───────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin-macchiato" } })
    end,
  },

  -- ── Fuzzy finder (requires ripgrep + fd — already installed) ─────────────
  {
    "nvim-telescope/telescope.nvim",
    version      = "*",       -- latest release tag, as upstream recommends
    dependencies = { "nvim-lua/plenary.nvim" },
    config       = function()
      require("telescope").setup({
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
          },
        },
      })
      local b = require("telescope.builtin")
      map("n", "<leader>ff", b.find_files,  { desc = "Find files" })
      map("n", "<leader>fg", b.live_grep,   { desc = "Live grep" })
      map("n", "<leader>fb", b.buffers,     { desc = "Find buffers" })
      map("n", "<leader>fr", b.oldfiles,    { desc = "Recent files" })
      map("n", "<leader>fh", b.help_tags,   { desc = "Help tags" })
    end,
  },

  -- ── Show available keybindings on <leader> pause ─────────────────────────
  {
    "folke/which-key.nvim",
    event  = "VeryLazy",
    config = function()
      require("which-key").setup({
        icons = { mappings = false },
      })
    end,
  },

  -- ── Auto-close brackets/quotes ───────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = true,
  },

})
