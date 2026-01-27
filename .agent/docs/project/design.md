# Design Document

## Architecture
The `trashit` skill is implemented as a Rust CLI tool.

### Components
1. **CLI Layer (`clap`)**: Handles argument parsing for multiple file paths.
2. **Deletion Logic**:
    - Uses the `trash` crate for native integration.
    - Implements a custom fallback to a `.trash` directory within the project root.
3. **Build System**:
    - `scripts/build.sh` (Unix) and `scripts/build.bat` (Windows) for cross-compilation.
    - Assets management (SKILL.md) during the distribution phase.

### Fallback Strategy
1. Try Native API.
2. If failure, find project root (containing `.git` or `.agent`).
3. Move to `[root]/.trash/[filename]/[filename]_[timestamp]`.
4. Handle cross-device moves via copy-and-delete.
