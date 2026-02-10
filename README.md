# Terminal IDE with Claude Integration

A batteries-included terminal development environment that launches with a single `dev` command. Built with Neovim, tmux, Ghostty, and optimized for working with Claude Code.

## What You Get

```
┌──────────────────────┬─────────────────────────┐
│                      │                         │
│                      │   Neovim (editor +      │
│   Claude Code        │   file tree on right)   │
│   (left half)        │                         │
│                      │                         │
│                      ├─────────────────────────┤
│                      │   Terminal (small)      │
└──────────────────────┴─────────────────────────┘
```

**One command: `dev`** → Full IDE workspace with:
- **Neovim** with file tree, fuzzy finder, LSP, git integration
- **Claude Code** in a dedicated pane, always visible
- **Terminal** for commands
- **Seamless navigation** — Ctrl+h/j/k/l moves between all panes
- **Ghostty terminal** — GPU-accelerated, fast, beautiful

## Features

### Neovim
- **File tree** (neo-tree): `Space e` to toggle, auto-refreshes on file changes
- **Fuzzy finder** (telescope): `Space ff` for files, `Space fg` for grep
- **Autocomplete** (nvim-cmp): Tab/Shift-Tab to navigate, Enter to confirm
- **LSP support**: TypeScript, Python, Lua — type hints, go-to-definition, hover docs, diagnostics
- **Comment toggling**: `gcc` to toggle line comment, `gc` in visual mode
- **Surround**: `ys`/`ds`/`cs` to add/delete/change surrounding quotes, brackets, etc.
- **Auto pairs**: Brackets, quotes, parens auto-close
- **Markdown preview**: `Space mp` opens live preview in browser
- **Git integration**: View diffs, stage hunks, lazygit TUI with `Space gg`
- **Theme**: Catppuccin Mocha (matches Ghostty)
- **Which-key**: Press `Space` to see all available commands
- **Built-in manual**: `Space ?` shows keybinding cheat sheet

### tmux
- **Prefix**: `Ctrl+a` (easier than default `Ctrl+b`)
- **vim-tmux-navigator**: Ctrl+h/j/k/l works across neovim AND tmux panes
- **Session switching**: `Ctrl+a c` to jump between projects
- **Clipboard integration**: System clipboard works in all panes
- **Easy splits**: `Ctrl+a |` for vertical, `Ctrl+a -` for horizontal

### Ghostty
- **GPU-accelerated** rendering
- **System clipboard** integration (Cmd+C/V works)
- **Catppuccin theme** matches neovim
- **JetBrains Mono Nerd Font** for icons

## Installation

### Fresh Mac Setup

```bash
git clone https://github.com/mansari2/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will:
1. Install Homebrew (if missing)
2. Install neovim, tmux, ripgrep, fd, fzf, lazygit, Ghostty
3. Install JetBrains Mono Nerd Font
4. Symlink all configs to `~/.config/`
5. Install language servers (TypeScript, Python, Lua)
6. Ensure `~/.local/bin` is in PATH

After installation:
```bash
exec zsh                  # Restart shell
dev                       # Launch the IDE
```

### Updating Configs

Since configs are symlinked, just edit the files in `~/.dotfiles/` and changes apply immediately:
```bash
cd ~/.dotfiles
nvim nvim/init.lua        # Edit neovim config
nvim tmux/tmux.conf       # Edit tmux config
nvim ghostty/config       # Edit Ghostty config
```

## Usage

### Launch the IDE

```bash
dev                       # Opens IDE in current directory
dev ~/myproject           # Opens IDE in ~/myproject
dev ~/myproject -n work   # Custom session name
dev ~/myproject -y        # Skip Claude permissions prompts
dev ~/myproject -y -n work  # Both flags
dev -l                    # List all active sessions
dev --help                # Show help with all keybindings
```

Sessions live as long as tmux is running. Use `dev` to reattach to an existing session or create a new one.

### Quick Start

1. **Open Ghostty** and run `dev`
2. **File tree**: `Space e` to toggle
3. **Find files**: `Space ff` (fuzzy find by name)
4. **Search code**: `Space fg` (live grep)
5. **Edit a file**: Navigate in tree, press Enter
6. **Save**: `Ctrl+s`
7. **Ask Claude**: `Ctrl+h` to jump to Claude pane, `Ctrl+l` to go back
8. **Git**: `Space gg` opens lazygit (full git TUI)
9. **Detach**: `Ctrl+a d` (reattach later with `dev`)
10. **Refresh file tree**: `Space r`

### Essential Keybindings

#### Pane Navigation (tmux + neovim)
- `Ctrl+h/j/k/l` — Move between panes (left/down/up/right)
- `Ctrl+a d` — Detach from tmux (session keeps running)
- `Ctrl+a z` — Toggle pane fullscreen
- `Ctrl+a |` — Vertical split
- `Ctrl+a -` — Horizontal split

#### Session Switching (jump between projects)
- `Ctrl+a c` — **Switch sessions** (shows list, use arrow keys + Enter)
- `Ctrl+a C` — **Create new dev session** (prompts for path)
- `Ctrl+a S` — Fuzzy find sessions (requires fzf)
- `dev -l` — List all sessions (from shell)
- `dev ~/path` — Create/attach to session for that directory

#### File Tree (neo-tree)
- `Space e` — Toggle file tree
- `Space E` — Reveal current file in tree
- `Space r` — Manually refresh file tree
- `Enter` — Open file
- `a` — Create file (add `/` at end for folder)
- `d` — Delete
- `r` — Rename
- `H` — Toggle hidden files

#### Find (telescope)
- `Space ff` — Find files by name
- `Space fg` — Search file contents (grep)
- `Space fb` — Switch between open buffers
- `Space gs` — Git status (modified files)
- `Space gc` — Git commit log
- `Space gb` — Git branches

#### Git
- `Space gg` — Open lazygit (full git TUI)
- `Space hb` — Toggle line blame
- `Space hp` — Preview hunk diff
- `Space hs` — Stage hunk
- `Space hr` — Reset hunk (discard changes)
- `]h / [h` — Next / prev git hunk

#### Editing
- `i` — Insert mode (start typing)
- `Esc` — Normal mode
- `Ctrl+s` — Save file
- `Space x` — Close buffer (not neovim)
- `Space q` — Quit neovim
- `u / Ctrl+r` — Undo / redo
- `V then J/K` — Move lines up/down
- `Ctrl+d / Ctrl+u` — Half-page scroll
- `gcc` — Toggle line comment
- `gc` (visual) — Toggle comment on selection
- `Tab / Shift-Tab` — Navigate autocomplete menu
- `ys<motion><char>` — Surround with char (e.g. `ysiw"`)
- `ds<char>` — Delete surrounding char
- `cs<old><new>` — Change surrounding char

#### LSP / Code Intelligence
- `gd` — Go to definition
- `gD` — Go to declaration
- `gi` — Go to implementation
- `gr` — Find references
- `K` — Hover documentation
- `Space ca` — Code action
- `Space rn` — Rename symbol
- `Space d` — Show diagnostic details
- `[d / ]d` — Prev / next diagnostic
- `Space ih` — Toggle inlay type hints

#### Markdown
- `Space mp` — Toggle markdown preview (opens in browser)

#### Help
- `Space ?` — Open keybinding cheat sheet
- `dev --help` — CLI help with all keybindings
- `:help <topic>` — Neovim help (e.g., `:help telescope`)

## Customization

### Add a Plugin

Edit `~/.dotfiles/nvim/init.lua`:

```lua
require("lazy").setup({
  -- ... existing plugins ...

  -- New plugin
  {
    "someone/plugin-name",
    config = function()
      require("plugin-name").setup({})
    end,
  },
})
```

Restart neovim — lazy.nvim auto-installs new plugins.

### Change Theme

Edit `~/.dotfiles/nvim/init.lua` and replace `catppuccin` with another theme:
```lua
{ "folke/tokyonight.nvim", priority = 1000, config = function()
  vim.cmd.colorscheme("tokyonight")
end },
```

Update Ghostty theme in `~/.dotfiles/ghostty/config`:
```
theme = tokyonight
```

### Adjust Layout

Edit `~/.dotfiles/bin/dev` to change pane sizes. Current layout: Claude 50%, Neovim + terminal 50%.

## Troubleshooting

### File tree not refreshing
- `Space r` manually refreshes
- Auto-refresh is enabled with `use_libuv_file_watcher = true`

### Clipboard not working in tmux
- Ensure Ghostty is installed (has better clipboard support)
- tmux config includes `set -g set-clipboard on` and OSC 52 support
- In tmux copy mode (`Ctrl+a [`), press `v` to select, `y` to copy to system clipboard

### LSP not working
- Install language servers: `npm install -g typescript-language-server pyright`
- Or: `brew install lua-language-server`
- Check `:LspInfo` in neovim

### Kill a session
- From any terminal: `tmux kill-session -t sessionname`
- Kill all: `tmux kill-server`

### Neovim plugins not loading
- Run `:Lazy` in neovim to see plugin status
- `:Lazy sync` to update all plugins

## Uninstall

```bash
rm ~/.config/nvim/init.lua
rm ~/.config/tmux/tmux.conf
rm ~/.config/ghostty/config
rm ~/.local/bin/dev
rm ~/.local/bin/tmux-sessionizer
rm -rf ~/.dotfiles
```

## Credits

Built with:
- [Neovim](https://neovim.io/) + [lazy.nvim](https://github.com/folke/lazy.nvim)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [tmux](https://github.com/tmux/tmux) + [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Ghostty](https://ghostty.org/)
- [Claude Code](https://claude.ai/claude-code)
