# Project Overview

`trashit` is a safe file deletion tool designed specifically for AI assistants. Its primary purpose is to replace dangerous permanent deletion operations with a recoverable process, providing a safety net for autonomous file system interactions.

## Core Features
- **Safety First**: Prevents the use of `rm`, protecting against accidental data loss caused by AI agents.
- **Multi-Level Fallback**: Prioritizes system-native trash (Windows, macOS, Linux) and automatically falls back to a local `.trash` directory if the native API is unavailable.
- **Collision Avoidance**: Uses timestamped naming for local backups to ensure that files with the same name are never overwritten.
- **Cross-Platform Support**: Written in Rust for high performance and a consistent experience across different operating systems.
