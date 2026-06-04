mod commands;
mod inbox;
mod slicer;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    if let Ok(repo_root) = commands::locate_repo_root() {
        inbox::start_inbox_watcher(repo_root);
    }

    if let Err(error) = tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            commands::compile_and_play,
            commands::get_asset_inventory,
            commands::save_game_state,
            commands::load_game_state,
            commands::get_project_paths,
            commands::launch_runner,
            commands::save_room,
            commands::load_room,
            commands::list_rooms,
            commands::delete_room,
            commands::export_game,
            commands::save_child_sprite,
            commands::load_child_sprite,
            commands::save_custom_audio,
            commands::package_game_project,
            commands::build_web_runner,
            commands::get_local_ip,
            commands::start_share_server
        ])
        .run(tauri::generate_context!())
    {
        eprintln!("error while running KidGameMaker Tauri application: {error}");
    }
}
