#!/bin/bash
# jp4boot installer
# Usage: curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash

set -e

REPO="https://github.com/jiripisa/jp4boot.git"
INSTALL_DIR="$HOME/.jp4boot"
BIN_DIR="/usr/local/bin"

# --- Install or update ---
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating jp4boot..."
    cd "$INSTALL_DIR"
    git pull -q origin main
    ACTION="updated"
else
    echo "Installing jp4boot..."
    git clone -q "$REPO" "$INSTALL_DIR"
    ACTION="installed"
fi

# Ensure bin directory exists
if [ ! -d "$BIN_DIR" ]; then
    sudo mkdir -p "$BIN_DIR"
fi

# Create symlink
sudo ln -sf "$INSTALL_DIR/jp4boot" "$BIN_DIR/jp4boot"

# Verify it's in PATH
if ! command -v jp4boot &> /dev/null; then
    echo ""
    echo "jp4boot was $ACTION but is not in your PATH."
    echo "Add /usr/local/bin to your PATH:"
    echo ""
    echo "  echo 'export PATH=\"/usr/local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
    echo ""
    exit 0
fi

VERSION=$(cd "$INSTALL_DIR" && git log -1 --format="%h" 2>/dev/null || echo "unknown")

cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  jp4boot — successfully $ACTION ($VERSION)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Bootstrap macOS SwiftUI apps from the command line.
  Swift 6.0 / SwiftUI / macOS 15+ / Swift Package Manager

  Quick start:

    jp4boot MyApp
    cd MyApp
    ./run.sh

  Options:

    jp4boot MyApp --bundle-id com.mycompany
    jp4boot MyApp --bundle-id com.mycompany --notary-profile my-notary

  You can also set defaults via environment variables
  (add to your ~/.zshrc):

    export JP4BOOT_BUNDLE_ID="com.mycompany"
    export JP4BOOT_NOTARY_PROFILE="my-notary"

  Build commands (inside a project):

    ./run.sh                Debug — run in terminal (logs visible)
    ./run.sh release        Release — open as .app

    ./build.sh              Debug build
    ./build.sh release      Release build
    ./build.sh dist         Release + sign + notarize + DMG
    ./build.sh clean        Remove build artifacts

  Manage jp4boot:

    Update:     curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash
    Uninstall:  sudo rm $BIN_DIR/jp4boot && rm -rf $INSTALL_DIR

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
