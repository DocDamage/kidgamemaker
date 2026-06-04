import { invoke } from '@tauri-apps/api/core';
import { toRoomPayload, type PlacedEntity, type WorldSettings } from './canvasState';
import { setGlobalGameLevel, setGlobalGameMuted } from './playbackControls';

export async function runWebGLPlay(
  placed: PlacedEntity[],
  worldSettings: WorldSettings,
  activeRoomId: string,
  isMuted: boolean,
  saveCurrentRoom: () => Promise<void>,
  playUiSound: (type: 'pop' | 'squeak' | 'chime') => void
): Promise<{ success: boolean; modalOpen?: boolean; status: string }> {
  try {
    await saveCurrentRoom();

    const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
    setGlobalGameLevel(JSON.stringify(payload));
    setGlobalGameMuted(isMuted);

    try {
      await invoke('build_web_runner');
      playUiSound('chime');
      return { success: true, modalOpen: true, status: 'Loaded embedded play mode!' };
    } catch (err) {
      console.log('WebGL player not built/available, falling back to native window:', err);
      const nativeStatus = await runNativePlay(placed, worldSettings, activeRoomId, playUiSound);
      return { success: true, modalOpen: false, status: nativeStatus };
    }
  } catch (error) {
    return { success: false, status: `Play failed: ${String(error)}` };
  }
}

export async function runNativePlay(
  placed: PlacedEntity[],
  worldSettings: WorldSettings,
  activeRoomId: string,
  playUiSound: (type: 'pop' | 'squeak' | 'chime') => void
): Promise<string> {
  try {
    const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
    const status = await invoke<string>('compile_and_play', { roomPayload: payload });
    playUiSound('chime');
    return status;
  } catch (error) {
    return `Native play failed: ${String(error)}`;
  }
}

export async function runExportGame(
  placed: PlacedEntity[],
  saveCurrentRoom: () => Promise<void>
): Promise<string> {
  try {
    await saveCurrentRoom();
    const payload = toRoomPayload(placed);
    const status = await invoke<string>('export_game', { projectId: payload.project_id });
    return status;
  } catch (error) {
    return `Export failed: ${String(error)}`;
  }
}

export async function runShareGame(
  saveCurrentRoom: () => Promise<void>,
  playUiSound: (type: 'pop' | 'squeak' | 'chime') => void
): Promise<string> {
  try {
    await saveCurrentRoom();
    const path = await invoke<string>('package_game_project');
    playUiSound('chime');
    return `Toybox packaged successfully! Saved to: ${path}`;
  } catch (error) {
    return `Packaging failed: ${String(error)}`;
  }
}
