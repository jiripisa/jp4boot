#!/bin/bash
# jp4boot installer
# Usage: curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash

set -e

REPO="https://github.com/jiripisa/jp4boot.git"
INSTALL_DIR="$HOME/.jp4boot"
BIN_DIR="/usr/local/bin"

echo "Installing jp4boot..."

# Clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull -q origin main
else
    echo "Downloading..."
    git clone -q "$REPO" "$INSTALL_DIR"
fi

# Ensure bin directory exists
if [ ! -d "$BIN_DIR" ]; then
    echo "Creating $BIN_DIR (requires sudo)..."
    sudo mkdir -p "$BIN_DIR"
fi

# Create symlink
echo "Linking jp4boot to $BIN_DIR..."
sudo ln -sf "$INSTALL_DIR/jp4boot" "$BIN_DIR/jp4boot"

# Verify
if command -v jp4boot &> /dev/null; then
    echo ""
    echo "jp4boot installed successfully!"
    echo ""
    echo "  Usage: jp4boot MyApp"
    echo "  Update: curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash"
    echo "  Uninstall: sudo rm $BIN_DIR/jp4boot && rm -rf $INSTALL_DIR"
else
    echo ""
    echo "jp4boot installed to $BIN_DIR/jp4boot"
    echo "If 'jp4boot' is not found, add $BIN_DIR to your PATH:"
    echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi
