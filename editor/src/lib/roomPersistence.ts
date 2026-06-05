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
    difficulty?: string;
    calm_mode?: boolean;
  };
};

export function hasTauriHost(): boolean {
  return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

export async function loadAssetInventory(): Promise<AssetInventory> {
  if (!hasTauriHost()) {
    const response = await fetch('/engine-asset-inventory');
    if (!response.ok) {
      throw new Error(`Browser inventory request failed: ${response.status}`);
    }
    return response.json() as Promise<AssetInventory>;
  }
  return invoke<AssetInventory>('get_asset_inventory');
}

export async function loadLegacyGameState(): Promise<SavedRoomState | null> {
  if (!hasTauriHost()) {
    return loadBrowserRoom('test_chamber_01');
  }
  return invoke<SavedRoomState>('load_game_state');
}

export async function listSavedRooms(fallbackRoomId: string): Promise<string[]> {
  if (!hasTauriHost()) {
    const rooms = listBrowserRooms();
    return rooms.length > 0 ? rooms : [fallbackRoomId];
  }

  const rooms = await invoke<string[]>('list_rooms');
  return rooms.length > 0 ? rooms : [fallbackRoomId];
}

export async function loadSavedRoom(roomId: string): Promise<SavedRoomState> {
  if (!hasTauriHost()) {
    return loadBrowserRoom(roomId) ?? { entities: [], world_settings: {} };
  }
  return invoke<SavedRoomState>('load_room', { roomId });
}

export async function deleteSavedRoom(roomId: string): Promise<void> {
  if (!hasTauriHost()) {
    try {
      localStorage.removeItem(browserRoomKey(roomId));
      localStorage.setItem('kidgamemaker_browser_rooms', JSON.stringify(listBrowserRooms().filter((id) => id !== roomId)));
    } catch (_) {}
    return;
  }
  await invoke('delete_room', { roomId });
}

export async function saveRoomPayload(roomId: string, payload: RoomPayload): Promise<string> {
  if (!hasTauriHost()) {
    saveBrowserRoom(roomId, payload);
    return `Saved ${roomId} in browser preview.`;
  }
  return invoke<string>('save_room', { roomId, jsonString: JSON.stringify(payload) });
}

export async function saveRoomCompressed(roomId: string, payload: RoomPayload): Promise<string> {
  if (!hasTauriHost()) {
    saveBrowserRoom(roomId, payload);
    return `Saved ${roomId} in browser preview.`;
  }
  return invoke<string>('save_room_compressed', { roomId, jsonString: JSON.stringify(payload) });
}

export async function cloudSyncRoom(roomId: string): Promise<string> {
  if (!hasTauriHost()) {
    return `Browser preview room ${roomId} is local only.`;
  }
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
  const difficulty = savedSettings?.difficulty;
  return difficulty === 'easy' || difficulty === 'creative' || difficulty === 'normal'
    ? difficulty
    : 'normal';
}

export function getSavedCalmMode(savedSettings?: SavedRoomState['world_settings']): boolean {
  return savedSettings?.calm_mode ?? false;
}

function browserRoomKey(roomId: string): string {
  return `kidgamemaker_browser_room_${roomId}`;
}

function listBrowserRooms(): string[] {
  try {
    const stored = localStorage.getItem('kidgamemaker_browser_rooms');
    if (!stored) return [];
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) ? parsed.filter((item): item is string => typeof item === 'string') : [];
  } catch (_) {
    return [];
  }
}

function saveBrowserRoom(roomId: string, payload: RoomPayload): void {
  const state: SavedRoomState = {
    entities: payload.entities,
    world_settings: payload.world_settings
  };
  localStorage.setItem(browserRoomKey(roomId), JSON.stringify(state));
  const rooms = listBrowserRooms();
  if (!rooms.includes(roomId)) {
    localStorage.setItem('kidgamemaker_browser_rooms', JSON.stringify([...rooms, roomId]));
  }
}

function loadBrowserRoom(roomId: string): SavedRoomState | null {
  try {
    const stored = localStorage.getItem(browserRoomKey(roomId));
    return stored ? JSON.parse(stored) as SavedRoomState : null;
  } catch (_) {
    return null;
  }
}
