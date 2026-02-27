#!/bin/bash
# ============================================================
# Dotfiles Installer for Terminal IDE with Claude Integration
# ============================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info "Installing Terminal IDE dotfiles..."

# ── 1. Install Homebrew ────────────────────────────────────
if ! command -v brew &> /dev/null; then
    info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# ── 2. Install packages ────────────────────────────────────
info "Installing packages..."
PACKAGES=(
    neovim
    tmux
    ripgrep
    fd
    fzf
    lazygit
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        success "$pkg already installed"
    else
        info "Installing $pkg..."
        brew install "$pkg"
        success "$pkg installed"
    fi
done

# Install Ghostty (cask)
if brew list --cask ghostty &> /dev/null; then
    success "Ghostty already installed"
else
    info "Installing Ghostty terminal..."
    brew install --cask ghostty
    success "Ghostty installed"
fi

# Install JetBrains Mono Nerd Font (for Ghostty icons)
if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
    success "JetBrains Mono Nerd Font already installed"
else
    info "Installing JetBrains Mono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font
    success "Font installed"
fi

# ── 3. Create config directories ───────────────────────────
info "Creating config directories..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux
mkdir -p ~/.config/ghostty
mkdir -p ~/.local/bin

# ── 4. Symlink configs ─────────────────────────────────────
info "Symlinking configs..."

# Neovim
if [ -f ~/.config/nvim/init.lua ] && [ ! -L ~/.config/nvim/init.lua ]; then
    warn "Backing up existing ~/.config/nvim/init.lua to ~/.config/nvim/init.lua.backup"
    mv ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup
fi
ln -sf "$DOTFILES_DIR/nvim/init.lua" ~/.config/nvim/init.lua
success "Neovim config symlinked"

# tmux
if [ -f ~/.config/tmux/tmux.conf ] && [ ! -L ~/.config/tmux/tmux.conf ]; then
    warn "Backing up existing ~/.config/tmux/tmux.conf"
    mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.backup
fi
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.config/tmux/tmux.conf
success "tmux config symlinked"

# Ghostty
if [ -f ~/.config/ghostty/config ] && [ ! -L ~/.config/ghostty/config ]; then
    warn "Backing up existing ~/.config/ghostty/config"
    mv ~/.config/ghostty/config ~/.config/ghostty/config.backup
fi
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
success "Ghostty config symlinked"

# Launcher scripts
ln -sf "$DOTFILES_DIR/bin/dev" ~/.local/bin/dev
chmod +x ~/.local/bin/dev
success "dev launcher symlinked"

ln -sf "$DOTFILES_DIR/bin/tmux-sessionizer" ~/.local/bin/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
success "tmux-sessionizer symlinked"

# ── 5. Ensure ~/.local/bin is in PATH ──────────────────────
SHELL_RC="$HOME/.zshrc"
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
    info "Adding ~/.local/bin to PATH in $SHELL_RC"
    echo '' >> "$SHELL_RC"
    echo '# Added by dotfiles installer' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    success "PATH updated"
else
    success "~/.local/bin already in PATH"
fi

# ── 6. Install language servers (for LSP) ──────────────────
info "Installing language servers..."

# TypeScript/JavaScript
if ! command -v typescript-language-server &> /dev/null; then
    info "Installing typescript-language-server..."
    npm install -g typescript-language-server typescript
    success "typescript-language-server installed"
else
    success "typescript-language-server already installed"
fi

# Python
if ! command -v pyright &> /dev/null; then
    info "Installing pyright (Python LSP)..."
    npm install -g pyright
    success "pyright installed"
else
    success "pyright already installed"
fi

# Lua
if ! command -v lua-language-server &> /dev/null; then
    info "Installing lua-language-server..."
    brew install lua-language-server
    success "lua-language-server installed"
else
    success "lua-language-server already installed"
fi

# ── 7. Install clorch (Claude session dashboard) ─────────
info "Installing clorch..."

# Ensure pipx is available (for Python apps in isolated environments)
if ! command -v pipx &> /dev/null; then
    info "Installing pipx..."
    brew install pipx
    success "pipx installed"
fi

if command -v clorch &> /dev/null; then
    success "clorch already installed"
else
    pipx install git+https://github.com/androsovm/clorch.git
    success "clorch installed"
fi

info "Initializing clorch hooks..."
clorch init
success "clorch hooks initialized"

# ── 8. Bootstrap neovim plugins ────────────────────────────
info "Neovim will auto-install plugins on first launch (lazy.nvim)"
success "Plugins will be installed when you first run nvim"

# ── Done ───────────────────────────────────────────────────
echo ""
success "✨ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your shell: exec zsh"
echo "  2. Launch the IDE: dev"
echo "  3. In neovim, plugins will auto-install on first launch"
echo "  4. Set Ghostty as your default terminal in System Settings"
echo ""
echo "Keybindings cheat sheet: press Space ? in neovim"
echo "Full CLI help: dev --help"
