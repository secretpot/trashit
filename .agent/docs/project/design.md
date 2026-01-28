# Design Document

## Architecture
`trashit` is implemented as a high-performance Rust CLI tool, designed to provide stable and predictable safe deletion services.

### Core Components
1. **CLI Interaction Layer (`clap`)**: Supports multiple path inputs, allowing AI assistants to process multiple files in a single command.
2. **Multi-Level Deletion Logic**:
    - Integrates the `trash` crate to invoke native operating system APIs.
    - Custom `.trash` fallback logic ensures safety even in environments without a system trash (e.g., certain CI environments or Docker containers).
3. **Data Traceability**:
    - Automatically detects the project root directory (via `.git` or `.agent` markers).
    - Path Structure: `[root]/.trash/[filename]/[filename]_[timestamp]`.
    - Facilitates precise recovery of specific versions of deleted files, even in fallback mode.

### Safety Strategy
- **Atomic Attempts**: Prioritizes moving files. If moving across file systems, it performs a "copy-then-delete" operation to ensure at least one copy of the data exists at all times.
- **Lossless Operations**: Preserves original file metadata whenever possible.
