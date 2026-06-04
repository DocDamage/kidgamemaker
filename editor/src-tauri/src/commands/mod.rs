pub mod assets;
pub mod game;
pub mod rooms;
pub mod utils;

pub use self::assets::*;
pub use self::game::*;
pub use self::rooms::*;
pub use self::utils::locate_repo_root;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_export_game() -> Result<(), String> {
        let path_str = export_game("test_project_id_123".to_string())?;
        assert!(path_str.contains("test_project_id_123_export.zip"));

        let repo_root = locate_repo_root()?;
        let zip_path = repo_root
            .join("exports")
            .join("test_project_id_123_export.zip");
        assert!(zip_path.exists());

        let _ = std::fs::remove_file(&zip_path);
        Ok(())
    }
}
