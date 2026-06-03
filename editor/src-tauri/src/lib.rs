mod commands;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            commands::compile_and_play,
            commands::get_asset_inventory,
            commands::save_game_state,
            commands::load_game_state,
            commands::get_project_paths,
            commands::launch_runner
        ])
        .run(tauri::generate_context!())
        .expect("error while running KidGameMaker Tauri application");
}
