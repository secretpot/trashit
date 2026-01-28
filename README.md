# trashit

**trashit** is a professional safe file deletion tool designed for AI assistants and human developers. It provides a recoverable alternative to the destructive `rm` / `del` command by moving files to the system trash or a local `.trash` directory.

[English](#english) | [中文](#中文)

---

<a name="english"></a>
## English

### Core Features
- **Safety First**: Prevents accidental permanent data loss.
- **Multi-Level Fallback**: Automatically falls back to a local `.trash` directory if the system trash (Windows, macOS, Linux) is unavailable.
- **Traceable**: Files in `.trash` are timestamped and organized in subdirectories matching their original names.
- **Cross-Platform**: Support for macOS, Linux, and Windows with native binaries.

### Usage
Use the absolute path to the binary appropriate for your operating system (e.g., `.agent/skills/trashit/bin/trashit`).

#### Safe Deletion
```bash
trashit <file_or_directory_path>
```

#### Multiple Items
```bash
trashit path1 path2 path3
```

---

<a name="中文"></a>
## 中文

### 核心功能
- **安全第一**：防止意外的永久性数据丢失。
- **多级回退**：当系统回收站（Windows, macOS, Linux）不可用时，自动降级到本地 `.trash` 目录。
- **可追溯**：`.trash` 中的文件带有时间戳，并按原始名称分类存储。
- **跨平台支持**：为 macOS, Linux 和 Windows 提供原生二进制支持。

### 使用方法
请根据您的操作系统使用对应的二进制文件绝对路径（例如：`.agent/skills/trashit/bin/trashit`）。

#### 安全删除
```bash
trashit <文件或目录路径>
```

#### 批量删除
```bash
trashit 路径1 路径2 路径3
```

---

## Installation / 编译安装
Build requirements: Rust toolchain.

**Recommended (with packaging / 推荐使用脚本自动化打包):**
- macOS/Linux: `bash scripts/build.sh`
- Windows: `scripts\build.bat` (Coming soon / 敬请期待)

**Manual (Binary only / 仅编译二进制文件):**
```bash
cargo build --release
```
Packaged results will be in the `dist/` directory.
