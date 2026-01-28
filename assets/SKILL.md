---
name: trashit
description: Safely delete files and directories by moving them to trash/recycle bin instead of permanent deletion. Works across macOS, Linux, and Windows with automatic fallback mechanisms.
---

# Safe File Deletion Skill
This skill provides a safe, recoverable file deletion mechanism. Instead of permanently deleting files, it moves them to the system trash/recycle bin or a local `.trash` directory within the project root.

## When to Use
**CRITICAL**: Use this skill whenever you or the user wants to delete any file or directory, especially when:
- Agent proactively needs to delete files/directories
- User requests file deletion
- Cleaning up temporary files
- Any operation that would normally use `rm` or `del`

## How It Works
The skill implements a robust fallback strategy:

1. **Native Trash**: Uses the system's native API to move items to the Recycle Bin (Windows), Trash (macOS), or Freedesktop Trash (Linux).
2. **Project Fallback**: If native trash fails or is unavailable, it creates a `.trash` directory in the project root (detected by `.git` or `.agent`). 
3. **Collision Handling**: Files in `.trash` are stored in subdirectories matching their original names and suffixed with a timestamp (`filename_YYYYMMDD_HHMMSS`) to prevent overwriting.

## Usage Instructions
### Before Deleting Files
Always use `trashit` instead of `rm` or `del`. Use the absolute path to the binary appropriate for your operating system (e.g., `.agent/skills/trashit/bin/trashit`).

```
<path_to_trashit> file.txt
<path_to_trashit> directory/
```

### Example Workflow
```
# Delete a single file
<path_to_trashit> old_file.txt

# Delete a directory
<path_to_trashit> old_directory/

# Delete multiple items
<path_to_trashit> file1.txt file2.txt file3.txt
```

## Recovery Instructions
- **System Trash**: Check your OS's Recycle Bin or Trash folder.
- **Local Fallback**: Check the `.trash/` directory in the project root. Files are organized by their original names.

## Technical Details
- **Architecture Support**: Binaries are provided for macOS (amd64/arm64), Linux (amd64/arm64), and Windows (amd64).
- **Safety**: Preserves metadata and handles cross-device moves by falling back to copy-and-delete if necessary.
