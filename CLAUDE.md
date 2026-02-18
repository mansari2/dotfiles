# Terminal IDE Dotfiles — Claude Code Guide

## Project Overview

This repo is a **single-command terminal IDE** (`dev`) that combines Neovim, tmux, and Claude Code into one workspace. Running `dev` creates a tmux session with three panes: Claude Code (left), Neovim with file tree (right-top), and a terminal (right-bottom). Python-focused.

## File Structure

```
.dotfiles/
├── bin/
│   ├── dev                  # Main launcher script (creates tmux session)
│   ├── dev-keys             # Keybinding cheat sheet (printed to terminal)
│   └── tmux-sessionizer     # fzf-based tmux session switcher
├── nvim/
│   └── init.lua             # Single-file Neovim config (lazy.nvim + all plugins)
├── tmux/
│   └── tmux.conf            # tmux config (prefix=Ctrl+a, vim-tmux-navigator)
├── ghostty/
│   └── config               # Ghostty terminal config (catppuccin mocha theme)
├── install.sh               # Automated setup: brew, symlinks, LSP servers
└── README.md                # User-facing documentation
```

## How `dev` Works

The `bin/dev` script:
1. Creates a tmux session named after the directory
2. Left pane (50%): runs `claude` (or `claude --dangerously-skip-permissions` with `-y`)
3. Right-top pane (50% width, 75% height): runs `nvim '+Neotree reveal position=right'`
4. Right-bottom pane (25% height): plain shell
5. Focuses the Neovim pane and attaches

Usage: `dev [directory] [-n name] [-y] [-l]`

## Neovim Architecture

**Single-file config** at `nvim/init.lua` using lazy.nvim. Structure:
1. Leader key + core settings
2. lazy.nvim bootstrap
3. Plugin definitions with configs (all lazy-loaded where possible)
4. Python settings (PEP 8)
5. LSP configuration — uses native `vim.lsp.config`/`vim.lsp.enable` (nvim 0.11+)
6. Custom keymaps and manual

### Installed Plugins (13 total, lean)

| Plugin | Purpose | Load trigger |
|--------|---------|-------------|
| catppuccin | Theme (mocha) | Startup (priority) |
| neo-tree.nvim | File tree (right side) | `<leader>e` / `:Neotree` |
| telescope.nvim | Fuzzy finder (files, grep, git) | `<leader>f*` keys |
| nvim-treesitter | Syntax parser installer | BufReadPre |
| which-key.nvim | Keybinding hints | VeryLazy |
| gitsigns.nvim | Git gutter signs + blame | BufReadPre |
| lualine.nvim | Status line | Startup |
| bufferline.nvim | Tab bar for open buffers | Startup |
| vim-tmux-navigator | Ctrl+h/j/k/l across tmux+nvim | Startup |
| nvim-cmp | Autocomplete (LSP, snippets, buffer) | InsertEnter |
| nvim-autopairs | Auto-close brackets/quotes | InsertEnter |
| nvim-surround | Surround text operations | VeryLazy |
| codeium.vim | AI inline code completion | InsertEnter |
| markdown-preview.nvim | Live markdown preview | .md files only |

**Removed plugins** (native in Neovim 0.11+):
- Comment.nvim → native `gc`/`gcc`
- nvim-lspconfig → native `vim.lsp.config()`/`vim.lsp.enable()`
- indent-blankline.nvim → caused rendering artifacts in tmux

### LSP Servers

- `pyright` — Python (type checking, completions, auto-import)
- `ruff` — Python (fast linting + formatting, replaces black/isort/flake8)
- `lua_ls` — Lua (for editing this config)

### Python Features

- **Auto-format on save** via ruff LSP
- **Auto-import** via `Space ca` (code action)
- **PEP 8** indentation (4 spaces) auto-applied to .py files
- **Virtualenv auto-detection** — pyright finds `.venv/`, `venv/`, or `$VIRTUAL_ENV` per project
- **Type hints** toggle with `Space ch`

### Key Bindings (Space = leader)

**Files:** `<leader>e` toggle tree, `<leader>E` reveal in tree, `<leader>ff` find files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fr` recent files, `<leader>fs` symbols
**Buffers:** `<S-h>` prev buffer, `<S-l>` next buffer, `<leader>x` close buffer
**Git:** `<leader>gg` lazygit, `<leader>gs/gc/gb` git status/commits/branches, `<leader>h*` hunk actions
**LSP:** `gd` definition, `gr` references, `K` hover, `<leader>ca` code action, `<leader>rn` rename, `<leader>cf` format
**AI:** `Ctrl+y` accept Codeium, `Alt+]`/`Alt+[` cycle suggestions, `Ctrl+e` dismiss
**Edit:** `Ctrl+s` save, `<leader>w` save, `<leader>q` quit, `gcc` comment (native), `V J/K` move lines

## Making Changes

### Neovim Config
- Edit `nvim/init.lua` directly — changes apply on next nvim launch
- Add new plugins inside the `require("lazy").setup({...})` block
- **Always lazy-load** — use `event`, `cmd`, `keys`, or `ft` triggers
- Keep it as a single file — don't split into lua modules
- Use native Neovim features over plugins when possible (0.11+ has LSP, commenting, treesitter built-in)

### Tmux Config
- Edit `tmux/tmux.conf` — reload with `Ctrl+a :source ~/.config/tmux/tmux.conf`
- Prefix is `Ctrl+a`
- Terminal type must be `tmux-256color` with `Tc` overrides for proper rendering

### Theme Consistency
All tools use **Catppuccin Mocha**:
- Neovim: catppuccin plugin
- tmux: manual color codes (`#1e1e2e`, `#89b4fa`, etc.)
- Ghostty: `theme = catppuccin-mocha`

### Updating Manuals
When adding/changing keybindings, update BOTH:
1. The `<leader>?` manual in `nvim/init.lua` (the `lines` table)
2. The `bin/dev-keys` script (box-drawing format)

## Dependencies

Installed via `install.sh` (Homebrew):
- neovim (0.11+), tmux, ripgrep, fd, fzf, lazygit, ruff
- Ghostty (cask), JetBrains Mono Nerd Font (cask)
- pyright (npm), lua-language-server (brew)
