import { invoke } from '@tauri-apps/api/core';
import {
  toRoomPayload,
  type AssetInventory,
  type PlacedEntity,
  type RoomPayload,
  type WorldSettings
} from './canvasState';

export type DifficultyMode = 'easy' | 'normal' | 'creative';

export type SavedRoomState = {
  entities?: PlacedEntity[];
  world_settings?: Partial<WorldSettings> & {
    difficulty?: DifficultyMode;
    calm_mode?: boolean;
  };
};

export function hasTauriHost(): boolean {
  return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

export async function loadAssetInventory(): Promise<AssetInventory> {
  return invoke<AssetInventory>('get_asset_inventory');
}

export async function loadLegacyGameState(): Promise<SavedRoomState | null> {
  return invoke<SavedRoomState>('load_game_state');
}

export async function listSavedRooms(fallbackRoomId: string): Promise<string[]> {
  if (!hasTauriHost()) return [fallbackRoomId];

  const rooms = await invoke<string[]>('list_rooms');
  return rooms.length > 0 ? rooms : [fallbackRoomId];
}

export async function loadSavedRoom(roomId: string): Promise<SavedRoomState> {
  return invoke<SavedRoomState>('load_room', { roomId });
}

export async function deleteSavedRoom(roomId: string): Promise<void> {
  await invoke('delete_room', { roomId });
}

export async function saveRoomPayload(roomId: string, payload: RoomPayload): Promise<string> {
  return invoke<string>('save_room', { roomId, jsonString: JSON.stringify(payload) });
}

export async function saveRoomCompressed(roomId: string, payload: RoomPayload): Promise<string> {
  return invoke<string>('save_room_compressed', { roomId, jsonString: JSON.stringify(payload) });
}

export async function cloudSyncRoom(roomId: string): Promise<string> {
  return invoke<string>('cloud_sync_room', { roomId });
}

export async function saveEditorRoom(options: {
  roomId: string;
  placed: PlacedEntity[];
  worldSettings: WorldSettings;
  difficultyMode: DifficultyMode;
  calmMode: boolean;
  projectId?: string;
}): Promise<string> {
  const payload = toRoomPayload(options.placed, options.worldSettings, options.projectId ?? 'demo_project', options.roomId);
  payload.world_settings = {
    ...payload.world_settings,
    difficulty: options.difficultyMode,
    calm_mode: options.calmMode
  };

  return saveRoomPayload(options.roomId, payload);
}

export function normalizeLoadedWorldSettings(savedSettings?: SavedRoomState['world_settings']): WorldSettings {
  return {
    time_of_day: savedSettings?.time_of_day ?? 'day',
    weather: savedSettings?.weather ?? 'clear',
    rising_hazard_type: savedSettings?.rising_hazard_type ?? '',
    rising_hazard_speed: savedSettings?.rising_hazard_speed ?? 20,
    camera_autoscroll: savedSettings?.camera_autoscroll ?? false,
    camera_autoscroll_direction: savedSettings?.camera_autoscroll_direction ?? 'right',
    camera_autoscroll_speed: savedSettings?.camera_autoscroll_speed ?? 40,
    victory_rules: savedSettings?.victory_rules ?? { win_condition: 'all_enemies', celebration: 'confetti' },
    loss_rules: savedSettings?.loss_rules ?? { lose_condition: 'health_0', action: 'game_over' },
    room_rules: savedSettings?.room_rules ?? [],
    level_balancer_enabled: savedSettings?.level_balancer_enabled ?? true,
    tutorial_whisperer_enabled: savedSettings?.tutorial_whisperer_enabled ?? true,
    theme: savedSettings?.theme,
    story_title: savedSettings?.story_title,
    story_intro_text: savedSettings?.story_intro_text,
    custom_bgm_sequence: savedSettings?.custom_bgm_sequence,
    custom_bgm_instruments: savedSettings?.custom_bgm_instruments,
    grid_x: savedSettings?.grid_x,
    grid_y: savedSettings?.grid_y,
    health_style: savedSettings?.health_style ?? 'hearts',
    age_mode: savedSettings?.age_mode,
    snap_size: savedSettings?.snap_size,
    game_speed_multiplier: savedSettings?.game_speed_multiplier
  };
}

export function getSavedDifficulty(savedSettings?: SavedRoomState['world_settings']): DifficultyMode {
  return savedSettings?.difficulty ?? 'normal';
}

export function getSavedCalmMode(savedSettings?: SavedRoomState['world_settings']): boolean {
  return savedSettings?.calm_mode ?? false;
}
