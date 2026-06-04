use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn locate_repo_root() -> Result<PathBuf, String> {
    let current = std::env::current_dir()
        .map_err(|err| format!("Could not read current directory: {err}"))?;

    for candidate in current.ancestors() {
        if candidate.join("engine").exists() && candidate.join("editor").exists() {
            return Ok(candidate.to_path_buf());
        }
    }

    current
        .parent()
        .map(Path::to_path_buf)
        .ok_or_else(|| "Could not locate repository root.".to_string())
}

pub fn locate_godot_runner(engine_dir: &Path) -> Option<PathBuf> {
    let candidates = if cfg!(target_os = "windows") {
        vec![
            engine_dir.join("Runner.exe"),
            engine_dir.join("godot_runner.exe"),
            engine_dir
                .join("exports")
                .join("windows")
                .join("Runner.exe"),
        ]
    } else if cfg!(target_os = "macos") {
        vec![
            engine_dir
                .join("Runner.app")
                .join("Contents")
                .join("MacOS")
                .join("Runner"),
            engine_dir.join("godot_runner"),
        ]
    } else {
        vec![
            engine_dir.join("Runner.x86_64"),
            engine_dir.join("godot_runner.x86_64"),
            engine_dir.join("godot_runner"),
        ]
    };

    candidates
        .into_iter()
        .find(|path| path.exists())
        .or_else(|| {
            if Command::new("godot").arg("--version").output().is_ok() {
                Some(PathBuf::from("godot"))
            } else {
                None
            }
        })
}

pub fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> std::io::Result<()> {
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

pub fn zip_dir_to_file(source_dir: &Path, zip_path: &Path) -> Result<(), String> {
    let out_file = fs::File::create(zip_path)
        .map_err(|err| format!("Cannot create zip file '{}': {err}", zip_path.display()))?;
    let out_buf = io::BufWriter::new(out_file);
    let mut zip_writer = zip::ZipWriter::new(out_buf);
    let options =
        zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Deflated);

    let mut stack: Vec<PathBuf> = vec![source_dir.to_path_buf()];
    while let Some(dir) = stack.pop() {
        for entry in fs::read_dir(&dir)
            .map_err(|err| format!("Cannot read dir '{}': {err}", dir.display()))?
        {
            let entry = entry.map_err(|err| err.to_string())?;
            let path = entry.path();
            // Relative path inside the ZIP (strip the source_dir prefix)
            let relative = path
                .strip_prefix(source_dir)
                .map_err(|_| format!("Path prefix error for '{}'", path.display()))?;
            let zip_name = relative.to_string_lossy().replace('\\', "/");

            if path.is_dir() {
                zip_writer
                    .add_directory(&zip_name, options)
                    .map_err(|err| format!("Failed to add dir '{zip_name}': {err}"))?;
                stack.push(path);
            } else {
                zip_writer
                    .start_file(&zip_name, options)
                    .map_err(|err| format!("Failed to start zip entry '{zip_name}': {err}"))?;
                let mut file = fs::File::open(&path)
                    .map_err(|err| format!("Cannot read file '{}': {err}", path.display()))?;
                io::copy(&mut file, &mut zip_writer)
                    .map_err(|err| format!("Failed to write '{zip_name}' into zip: {err}"))?;
            }
        }
    }

    zip_writer
        .finish()
        .map_err(|err| format!("Failed to finalize zip: {err}"))?;
    Ok(())
}
