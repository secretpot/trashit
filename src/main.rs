use anyhow::{Context, Result};
use chrono::Local;
use clap::Parser;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Parser)]
#[command(name = "trashit")]
#[command(about = "Safely delete files and directories", long_about = None)]
struct Cli {
    /// Paths to files or directories to delete
    #[arg(required = true)]
    paths: Vec<PathBuf>,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let mut exit_code = 0;

    for path in cli.paths {
        if let Err(e) = delete_item(&path) {
            eprintln!("Error deleting {:?}: {}", path, e);
            exit_code = 1;
        }
    }

    if exit_code != 0 {
        std::process::exit(exit_code);
    }

    Ok(())
}

fn delete_item(path: &Path) -> Result<()> {
    if !path.exists() {
        return Err(anyhow::anyhow!("Path does not exist: {:?}", path));
    }

    // 1. Try native trash
    match trash::delete(path) {
        Ok(_) => {
            println!("Moved {:?} to system trash", path);
            Ok(())
        }
        Err(e) => {
            eprintln!("Warning: Failed to use system trash: {}. Falling back to local .trash...", e);
            use_local_trash(path)
        }
    }
}

fn use_local_trash(path: &Path) -> Result<()> {
    let trash_dir = find_trash_dir();

    if !trash_dir.exists() {
        fs::create_dir_all(&trash_dir).context("Failed to create .trash directory")?;
        println!("Created local trash directory: {:?}", trash_dir);
    }

    let file_name = path
        .file_name()
        .context("Could not get file name")?
        .to_string_lossy();
    
    let trash_subdir = trash_dir.join(&*file_name);
    if !trash_subdir.exists() {
        fs::create_dir_all(&trash_subdir).context("Failed to create trash subdirectory")?;
    }

    let timestamp = Local::now().format("%Y%m%d_%H%M%S").to_string();
    let trash_path = trash_subdir.join(format!("{}_{}", file_name, timestamp));

    fs::rename(path, &trash_path)
        .or_else(|_| {
            // Fallback for cross-device rename
            copy_and_delete(path, &trash_path)
        })
        .with_context(|| format!("Failed to move {:?} to local trash at {:?}", path, trash_path))?;

    println!("Moved {:?} to local trash: {:?}", path, trash_path);
    Ok(())
}

fn find_trash_dir() -> PathBuf {
    // 1. Try to find project root (.git, .agent, or existing .trash)
    if let Some(root) = find_project_root() {
        return root.join(".trash");
    }

    // 2. Fallback to home directory
    if let Some(home) = home::home_dir() {
        return home.join(".trash");
    }

    // 3. Absolute last resort: current directory
    PathBuf::from(".trash")
}

fn find_project_root() -> Option<PathBuf> {
    let mut current = std::env::current_dir().ok()?;
    loop {
        // Look for common markers
        if current.join(".git").exists() || current.join(".agent").exists() || current.join(".trash").exists() {
            return Some(current);
        }
        if !current.pop() {
            break;
        }
    }
    None
}

fn copy_and_delete(from: &Path, to: &Path) -> Result<()> {
    if from.is_dir() {
        copy_dir_all(from, to)?;
        fs::remove_dir_all(from)?;
    } else {
        fs::copy(from, to)?;
        fs::remove_file(from)?;
    }
    Ok(())
}

fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}
