@echo off
setlocal enabledelayedexpansion

set APP_NAME=trashit
set ASSETS_DIR=assets
set DIST_DIR=dist

:: Detect platform (Simplified for Windows)
set OS=windows
set ARCH=amd64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set ARCH=arm64

set CURRENT_PLATFORM=%OS%_%ARCH%

if "%1"=="--all" (
    echo Building for all platforms...
    call :build macos_amd64 x86_64-apple-darwin
    call :build macos_arm64 aarch64-apple-darwin
    call :build linux_amd64 x86_64-unknown-linux-musl
    call :build linux_arm64 aarch64-unknown-linux-musl
    call :build windows_amd64 x86_64-pc-windows-msvc
) else if "%1"=="" (
    echo No target specified, defaulting to current platform: %CURRENT_PLATFORM%
    call :build %CURRENT_PLATFORM% x86_64-pc-windows-msvc
) else (
    :: Basic mapping for specific target input
    if "%1"=="macos_amd64" ( call :build macos_amd64 x86_64-apple-darwin )
    if "%1"=="macos_arm64" ( call :build macos_arm64 aarch64-apple-darwin )
    if "%1"=="linux_amd64" ( call :build linux_amd64 x86_64-unknown-linux-musl )
    if "%1"=="linux_arm64" ( call :build linux_arm64 aarch64-unknown-linux-musl )
    if "%1"=="windows_amd64" ( call :build windows_amd64 x86_64-pc-windows-msvc )
)

goto :eof

:build
set TARGET_KEY=%1
set RUST_TARGET=%2

echo Building for %TARGET_KEY% (%RUST_TARGET%)...

:: Check/Install target
rustup target add %RUST_TARGET%

:: Build
cargo build --release --target %RUST_TARGET%

:: Prepare dist
set TARGET_DIST=%DIST_DIR%\%TARGET_KEY%\%APP_NAME%
mkdir "%TARGET_DIST%\bin" 2>nul

:: Copy binary
set BIN_NAME=%APP_NAME%
if "%TARGET_KEY:~0,7%"=="windows" set BIN_NAME=%APP_NAME%.exe
copy "target\%RUST_TARGET%\release\%BIN_NAME%" "%TARGET_DIST%\bin\" >nul

:: Copy SKILL.md
copy "%ASSETS_DIR%\SKILL.md" "%TARGET_DIST%\" >nul

echo Done: %TARGET_DIST%
goto :eof
