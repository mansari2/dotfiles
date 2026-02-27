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

echo ""
echo "✓ Clorch themed with catppuccin mocha"
echo "  Changes: brighter colors, improved jump logic, YOLO/telemetry visibility"
echo "  Open clorch to verify: Ctrl+a b (in tmux) or run 'clorch'"
