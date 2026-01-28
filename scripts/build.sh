#!/bin/bash
set -e

APP_NAME="trashit"
ASSETS_DIR="assets"
DIST_DIR="dist"
SCRIPTS_DIR="scripts"

# Support targets
TARGET_KEYS=("macos_amd64" "macos_arm64" "linux_amd64" "linux_arm64" "windows_amd64")

get_rust_target() {
    case "$1" in
        macos_amd64) echo "x86_64-apple-darwin" ;;
        macos_arm64) echo "aarch64-apple-darwin" ;;
        linux_amd64) echo "x86_64-unknown-linux-musl" ;;
        linux_arm64) echo "aarch64-unknown-linux-musl" ;;
        windows_amd64) echo "x86_64-pc-windows-gnu" ;;
        *) echo "" ;;
    esac
}

# Detect current platform
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$OS" in
        darwin) OS="macos" ;;
        linux) OS="linux" ;;
        msys*|mingw*|cygwin*) OS="windows" ;;
    esac
    
    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
    esac
    
    echo "${OS}_${ARCH}"
}

build_target() {
    local TARGET_KEY=$1
    local RUST_TARGET=$(get_rust_target "$TARGET_KEY")
    
    if [ -z "$RUST_TARGET" ]; then
        echo "Error: Unsupported platform $TARGET_KEY"
        exit 1
    fi
    
    echo "Building for $TARGET_KEY ($RUST_TARGET)..."
    
    # Set linkers for cross-compilation on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        case "$RUST_TARGET" in
            x86_64-unknown-linux-musl)
                export CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER="x86_64-linux-musl-gcc"
                ;;
            aarch64-unknown-linux-musl)
                export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER="aarch64-linux-musl-gcc"
                ;;
            x86_64-pc-windows-gnu)
                export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER="x86_64-w64-mingw32-gcc"
                ;;
        esac
    fi
    
    # Check if target is installed
    if ! rustup target list | grep -q "$RUST_TARGET (installed)"; then
        echo "Installing target $RUST_TARGET..."
        rustup target add "$RUST_TARGET"
    fi
    
    # Build
    cargo build --release --target "$RUST_TARGET"
    
    # Prepare dist
    local TARGET_DIST="$DIST_DIR/$TARGET_KEY/$APP_NAME"
    rm -rf "$TARGET_DIST"
    mkdir -p "$TARGET_DIST/bin"
    
    # Copy binary
    local BIN_NAME=$APP_NAME
    if [[ "$RUST_TARGET" == *windows* ]]; then
        BIN_NAME="${APP_NAME}.exe"
    fi
    cp "target/$RUST_TARGET/release/$BIN_NAME" "$TARGET_DIST/bin/"
    
    # Copy SKILL.md
    cp "$ASSETS_DIR/SKILL.md" "$TARGET_DIST/"
    
    echo "Done: $TARGET_DIST"
}

# Main
mkdir -p "$DIST_DIR"

if [ "$1" == "--all" ]; then
    for T in "${TARGET_KEYS[@]}"; do
        build_target "$T"
    done
elif [ -n "$1" ]; then
    build_target "$1"
else
    CURRENT=$(detect_platform)
    echo "No target specified, defaulting to current platform: $CURRENT"
    build_target "$CURRENT"
fi
