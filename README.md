# jp4boot

A CLI tool for bootstrapping macOS SwiftUI apps with a standardized project structure, build scripts, and distribution pipeline — all without Xcode.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash
```

This clones the repo to `~/.jp4boot/` and creates a symlink in `/usr/local/bin/` (requires sudo).

## Uninstall

```bash
sudo rm /usr/local/bin/jp4boot && rm -rf ~/.jp4boot
```

## Update

```bash
curl -fsSL https://raw.githubusercontent.com/jiripisa/jp4boot/main/install.sh | bash
```

Same command as install — it detects existing installation and pulls the latest version.

## Usage

```bash
jp4boot AppName [options]
```

Creates a new macOS SwiftUI project in `./AppName/` with everything ready to build and run from the command line.

### Options

| Option | Description | Default |
|---|---|---|
| `--bundle-id PREFIX` | Bundle ID prefix (result: `PREFIX.appname`) | `com.example` |
| `--notary-profile NAME` | Keychain profile name for notarization | `notary` |

### Examples

```bash
# Basic — creates ./MyApp/ with bundle ID com.example.myapp
jp4boot MyApp

# Custom bundle ID
jp4boot MyApp --bundle-id com.mycompany

# With notarization profile
jp4boot MyApp --bundle-id io.mydomain --notary-profile my-notary
```

## What you get

```
MyApp/
├── Package.swift              Swift 6.0, macOS 15+
├── build.sh                   Build, sign, notarize, create DMG
├── run.sh                     Auto-build and run
├── CLAUDE.md                  Conventions for Claude Code
├── Sources/MyApp/
│   ├── App/MyAppApp.swift     @main entry point
│   ├── Models/
│   ├── Services/
│   └── Views/
│       ├── ContentView.swift
│       ├── Components/
│       └── Theme/
├── Resources/
│   ├── Info.plist
│   └── MyApp.entitlements
└── Tests/MyAppTests/
```

The project is initialized as a git repo with the first commit already made.

## Build & Run commands

### run.sh

| Command | Description |
|---|---|
| `./run.sh` | Debug build + run in terminal (log output visible, Ctrl+C to quit) |
| `./run.sh release` | Release build + open as .app |

### build.sh

| Command | Description |
|---|---|
| `./build.sh` | Debug build (default) |
| `./build.sh release` | Optimized release build + app bundle |
| `./build.sh dist` | Release build + code sign + notarize + DMG |
| `./build.sh clean` | Remove all build artifacts |

Both `run.sh` and `build.sh` auto-detect source changes and rebuild only when needed.

## Distribution (build.sh dist)

The `dist` mode handles the full distribution pipeline:

1. **Release build** via Swift Package Manager
2. **App bundle** creation with Info.plist, PkgInfo, and icon
3. **Icon generation** from `Resources/AppIcon.png` (1024x1024) to .icns
4. **Code signing** with Developer ID (auto-detected from Keychain)
5. **DMG creation** with Applications symlink for drag-and-drop install
6. **Notarization** via `notarytool` with the configured keychain profile
7. **Stapling** the notarization ticket to the DMG

If no Developer ID is found in Keychain, signing and notarization are skipped gracefully.

### Setting up notarization

Before using `./build.sh dist`, store your Apple ID credentials in a keychain profile:

```bash
xcrun notarytool store-credentials "my-notary" \
    --apple-id "your@email.com" \
    --team-id "XXXXXXXXXX" \
    --password "app-specific-password"
```

Then pass the profile name when creating the project:

```bash
jp4boot MyApp --notary-profile my-notary
```

Or override it at build time:

```bash
NOTARY_PROFILE=my-notary ./build.sh dist
```

## Tech stack

- **Swift 6.0** with strict concurrency
- **SwiftUI** (macOS 15+ / Sequoia)
- **Swift Package Manager** — no Xcode required
- **Observable** macro (not ObservableObject)

## Requirements

- macOS 15+ (Sequoia)
- Swift 6.0+ (`swift --version` to check)
- Xcode Command Line Tools (`xcode-select --install`)
- For distribution: Apple Developer ID certificate in Keychain
