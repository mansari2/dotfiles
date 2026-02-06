#!/bin/bash
# install.sh — set up terminal IDE on a fresh Mac
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
echo "Installing from: $DOTFILES"

# ── 1. Homebrew ────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 2. Brew packages ──────────────────────────────────────
echo "Installing packages..."
brew install neovim tmux ripgrep fd

# ── 3. Symlink configs ────────────────────────────────────
echo "Symlinking configs..."

mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux
mkdir -p ~/.local/bin

# Helper: symlink with backup
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up existing $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  $dst → $src"
}

link "$DOTFILES/nvim/init.lua"   ~/.config/nvim/init.lua
link "$DOTFILES/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
link "$DOTFILES/bin/dev"         ~/.local/bin/dev
link "$DOTFILES/bin/dev-keys"    ~/.local/bin/dev-keys

chmod +x ~/.local/bin/dev ~/.local/bin/dev-keys

# ── 4. tmux plugin manager (tpm) ──────────────────────────
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ── 5. Ensure ~/.local/bin is in PATH ─────────────────────
SHELL_RC=""
if [ -f ~/.zshrc ]; then
  SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
  SHELL_RC=~/.bashrc
fi

if [ -n "$SHELL_RC" ]; then
  if ! grep -q 'local/bin' "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo '# Added by dotfiles installer' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "  Added ~/.local/bin to PATH in $SHELL_RC"
  fi
fi

# ── 6. First-run neovim plugin install ────────────────────
echo "Installing neovim plugins (lazy.nvim will bootstrap)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo ""
echo "Done! Run 'dev' or 'dev ~/myproject' to start."
echo "Run 'dev-keys' for keybinding reference."
echo ""
echo "NOTE: You may need to restart your shell or run:"
echo "  source $SHELL_RC"
