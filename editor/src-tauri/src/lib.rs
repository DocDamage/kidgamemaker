mod commands;
mod inbox;
mod slicer;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    if let Ok(repo_root) = commands::locate_repo_root() {
        inbox::start_inbox_watcher(repo_root);
    }

    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            commands::compile_and_play,
            commands::get_asset_inventory,
            commands::save_game_state,
            commands::load_game_state,
            commands::get_project_paths,
            commands::launch_runner,
            commands::save_room,
            commands::load_room,
            commands::list_rooms
        ])
        .run(tauri::generate_context!())
        .expect("error while running KidGameMaker Tauri application");
}
