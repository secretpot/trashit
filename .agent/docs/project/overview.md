# Project Overview

`trashit` is a safe file deletion skill that moves files to the trash instead of permanently deleting them. It is now implemented in Rust for improved performance and better cross-platform support.

## Core Features
- Native trash support for Windows, macOS, and Linux.
- Local `.trash` fallback in the project root if native trash is unavailable.
- Collision avoidance using timestamped filenames.
- Multi-platform build system producing optimized binaries.
