#!/bin/bash
# Bootstrap a new macOS SwiftUI app from template
# Usage: bootstrap.sh AppName
#        Creates ~/Claude/AppName/AppName/ with complete project structure

set -e

# --- Validate input ---
if [ -z "$1" ]; then
    echo "Usage: $0 AppName"
    echo "Creates ~/Claude/AppName/AppName/ with complete project structure"
    exit 1
fi

APP_NAME="$1"
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
BUNDLE_ID="io.jp4.${APP_NAME_LOWER}"
YEAR=$(date +%Y)

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates"
TARGET_ROOT="$HOME/Claude/$APP_NAME"
TARGET_DIR="$TARGET_ROOT/$APP_NAME"

if [ -d "$TARGET_DIR" ]; then
    echo "ERROR: $TARGET_DIR already exists."
    exit 1
fi

echo "Creating $APP_NAME at $TARGET_DIR..."

# --- Create directory structure ---
mkdir -p "$TARGET_DIR/Sources/$APP_NAME/App"
mkdir -p "$TARGET_DIR/Sources/$APP_NAME/Models"
mkdir -p "$TARGET_DIR/Sources/$APP_NAME/Services"
mkdir -p "$TARGET_DIR/Sources/$APP_NAME/Views/Components"
mkdir -p "$TARGET_DIR/Sources/$APP_NAME/Views/Theme"
mkdir -p "$TARGET_DIR/Resources"
mkdir -p "$TARGET_DIR/Tests/${APP_NAME}Tests"

# --- Helper: copy template with placeholder replacement ---
apply_template() {
    local src="$1"
    local dst="$2"
    sed -e "s/__APP_NAME__/$APP_NAME/g" \
        -e "s/__BUNDLE_ID__/$BUNDLE_ID/g" \
        -e "s/__YEAR__/$YEAR/g" \
        "$src" > "$dst"
}

# --- Copy and transform templates ---
apply_template "$TEMPLATE_DIR/Package.swift.template"     "$TARGET_DIR/Package.swift"
apply_template "$TEMPLATE_DIR/build.sh.template"          "$TARGET_DIR/build.sh"
apply_template "$TEMPLATE_DIR/run.sh.template"            "$TARGET_DIR/run.sh"
apply_template "$TEMPLATE_DIR/CLAUDE.md.template"         "$TARGET_DIR/CLAUDE.md"
apply_template "$TEMPLATE_DIR/Info.plist.template"        "$TARGET_DIR/Resources/Info.plist"
apply_template "$TEMPLATE_DIR/Entitlements.template"      "$TARGET_DIR/Resources/$APP_NAME.entitlements"
apply_template "$TEMPLATE_DIR/gitignore.template"         "$TARGET_DIR/.gitignore"
apply_template "$TEMPLATE_DIR/AppApp.swift.template"      "$TARGET_DIR/Sources/$APP_NAME/App/${APP_NAME}App.swift"
apply_template "$TEMPLATE_DIR/ContentView.swift.template" "$TARGET_DIR/Sources/$APP_NAME/Views/ContentView.swift"
apply_template "$TEMPLATE_DIR/Tests.swift.template"       "$TARGET_DIR/Tests/${APP_NAME}Tests/${APP_NAME}Tests.swift"

# Make scripts executable
chmod +x "$TARGET_DIR/build.sh"
chmod +x "$TARGET_DIR/run.sh"

# --- Init git repo ---
cd "$TARGET_DIR"
git init -q
git add -A
git commit -q -m "Initial project structure from template"

echo ""
echo "Done! Created $APP_NAME at $TARGET_DIR"
echo ""
echo "  cd $TARGET_DIR"
echo "  ./build.sh build-only   # Build for development"
echo "  ./run.sh                # Build and run"
echo "  ./build.sh              # Full build + sign + notarize + DMG"
