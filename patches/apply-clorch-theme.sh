#!/bin/bash
# Apply catppuccin mocha theme + jump improvements to clorch
# Run this after installing/upgrading clorch via pipx

set -e

CLORCH_DIR=$(python3 -c "import clorch; import os; print(os.path.dirname(clorch.__file__))" 2>/dev/null)

if [ -z "$CLORCH_DIR" ]; then
    echo "Error: clorch not found. Install it first: pipx install git+https://github.com/androsovm/clorch.git"
    exit 1
fi

PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_FILE="$PATCH_DIR/clorch-catppuccin.patch"

if [ ! -f "$PATCH_FILE" ]; then
    echo "Error: Patch file not found at $PATCH_FILE"
    exit 1
fi

echo "Applying catppuccin mocha theme to clorch at $CLORCH_DIR..."

# Apply patch using the clorch package dir as the target
# The patch has paths like clorch/constants.py so we apply from the parent dir
cd "$(dirname "$CLORCH_DIR")"
patch -p0 --forward < "$PATCH_FILE" || true

# Also patch notify_handler.sh to use terminal-notifier instead of osascript
HOOK_FILE="$HOME/.local/share/clorch/hooks/notify_handler.sh"
if [[ -f "$HOOK_FILE" ]] && ! grep -q "terminal-notifier" "$HOOK_FILE"; then
    echo "Patching notify_handler.sh to use terminal-notifier..."
    sed -i '' 's|^osascript -e "display notification.*|# Send macOS notification — use terminal-notifier so clicking opens iTerm\nTN="/opt/homebrew/bin/terminal-notifier"\nif [[ -x "$TN" ]]; then\n    "$TN" \\\\\n        -title "Clorch — $PROJECT_NAME" \\\\\n        -message "$DISPLAY_MSG" \\\\\n        -sound "Ping" \\\\\n        -activate "com.googlecode.iterm2" \\\\\n        -group "clorch-$SESSION_ID" \\\\\n        2>/dev/null || true\nelse\n    osascript -e "display notification \\"$(_escape_applescript "$DISPLAY_MSG")\\" with title \\"Clorch\\" subtitle \\"$(_escape_applescript "$PROJECT_NAME")\\"" 2>/dev/null || true\nfi|' "$HOOK_FILE"
    echo "✓ notify_handler.sh patched"
fi

echo ""
echo "✓ Clorch themed with catppuccin mocha"
echo "  Changes: brighter colors, improved jump logic, notifications open iTerm"
echo "  Open clorch to verify: Ctrl+a b (in tmux) or run 'clorch'"
