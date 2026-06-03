<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke, convertFileSrc } from '@tauri-apps/api/core';
  import ToyboxModal from './ToyboxModal.svelte';
  import BookshelfModal from './BookshelfModal.svelte';
  import SpriteEditorModal from './SpriteEditorModal.svelte';
  import {
    eraseEntity,
    fallbackInventory,
    snapPosition,
    stampEntity,
    toRoomPayload,
    makeInstanceId,
    type AssetInventory,
    type PlacedEntity,
    type ToyboxAsset,
    type WorldSettings
  } from './lib/canvasState';

  let spriteEditorOpen = false;
  let editingAssetId = '';
  let editingCategory = 'decorations';

  // Kid friendly UI toggles
  let parentsPanelOpen = false;
  let themeSelectorOpen = false;
  let playModalOpen = false;
  let isGamePaused = false;
  let isMuted = false;
  let selectedPlacedEntity: PlacedEntity | null = null;


  function togglePauseGame() {
    const iframe = document.querySelector('.game-iframe') as HTMLIFrameElement;
    if (iframe && iframe.contentWindow) {
      isGamePaused = !isGamePaused;
      try {
        (iframe.contentWindow as any).godotPauseGame(isGamePaused);
        status = isGamePaused ? "Game Paused ⏸" : "Game Resumed ▶";
      } catch (e) {
        console.error("Failed to pause game:", e);
      }
    }
  }

  function restartGame() {
    const iframe = document.querySelector('.game-iframe') as HTMLIFrameElement;
    if (iframe && iframe.contentWindow) {
      isGamePaused = false;
      try {
        iframe.src = iframe.src;
        status = "Game Restarted 🔄";
        playUiSound('chime');
      } catch (e) {
        console.error("Failed to restart game:", e);
      }
    }
  }

  function closePlayModal() {
    playModalOpen = false;
    isGamePaused = false;
  }

  function toggleMute() {
    isMuted = !isMuted;
    (window as any).currentGameMuted = isMuted;

    const iframe = document.querySelector('.game-iframe') as HTMLIFrameElement;
    if (iframe && iframe.contentWindow) {
      try {
        (iframe.contentWindow as any).godotMuteGame(isMuted);
      } catch (e) {
        console.error("Failed to mute game inside iframe:", e);
      }
    }
    if (!isMuted) {
      playUiSound('pop');
    }
  }

  let audioCtx: AudioContext | null = null;
  function getAudioContext() {
    if (!audioCtx) {
      audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  function playUiSound(type: 'pop' | 'squeak' | 'chime') {
    if (isMuted) return;
    try {
      const ctx = getAudioContext();
      const now = ctx.currentTime;
      if (type === 'pop') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(150, now);
        osc.frequency.exponentialRampToValueAtTime(600, now + 0.1);
        gain.gain.setValueAtTime(0.12, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.1);
      } else if (type === 'squeak') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(800, now);
        osc.frequency.exponentialRampToValueAtTime(120, now + 0.15);
        gain.gain.setValueAtTime(0.15, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.15);
      } else if (type === 'chime') {
        const notes = [600, 900, 1200, 1500];
        notes.forEach((freq, idx) => {
          const time = now + idx * 0.04;
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, time);
          gain.gain.setValueAtTime(0.06, time);
          gain.gain.exponentialRampToValueAtTime(0.001, time + 0.1);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(time);
          osc.stop(time + 0.1);
        });
      }
    } catch (_) {}
  }

  function animateClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLElement;
    target.classList.remove('bounce-click');
    void target.offsetWidth; // trigger reflow
    target.classList.add('bounce-click');
  }

  function cycleTime() {
    const times: ('day' | 'morning' | 'sunset' | 'night')[] = ['day', 'morning', 'sunset', 'night'];
    const idx = times.indexOf(worldSettings.time_of_day);
    worldSettings.time_of_day = times[(idx + 1) % times.length];
    saveCurrentRoom();
    playUiSound('pop');
  }

  function cycleWeather() {
    const weathers: ('clear' | 'rain' | 'snow')[] = ['clear', 'rain', 'snow'];
    const idx = weathers.indexOf(worldSettings.weather);
    worldSettings.weather = weathers[(idx + 1) % weathers.length];
    saveCurrentRoom();
    playUiSound('pop');
  }

  function openCustomAssetCanvas() {
    editingAssetId = '';
    editingCategory = 'decorations';
    spriteEditorOpen = true;
  }

  function editActiveAsset() {
    if (activeAsset) {
      editingAssetId = activeAsset.id;
      editingCategory = activeAsset.category;
      spriteEditorOpen = true;
    }
  }

  function handleDrawingSaved(event: CustomEvent<string>) {
    status = `Magic Brush auto-saved toy: ${event.detail}`;
    refreshInventory();
  }


  let placed: PlacedEntity[] = [
    {
      instance_id: 'hero_001',
      asset_id: 'hero_knight',
      category: 'heroes',
      type: 'player',
      position: { x: 128, y: 216 },
      is_camera_target: true,
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'floor_001',
      asset_id: 'stone_floor',
      category: 'terrain',
      type: 'terrain',
      position: { x: 320, y: 392 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'enemy_001',
      asset_id: 'slime_patrol',
      category: 'enemies',
      type: 'enemy',
      position: { x: 520, y: 344 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    }
  ];

  let inventory: AssetInventory = fallbackInventory;
  let activeAsset: ToyboxAsset = fallbackInventory.terrain[0];
  let eraserMode = false;
  let toyboxOpen = false;
  let bookshelfOpen = false;
  let snapEnabled = true;
  let status = 'Ready';

  // World settings — drives time_of_day / weather in saved JSON
  let worldSettings: WorldSettings = { time_of_day: 'day', weather: 'clear' };

  // Multi-room state
  let rooms: string[] = ['test_chamber_01'];
  let activeRoomId = 'test_chamber_01';

  // Viewport Pan/Zoom state
  let zoom = 1.0;
  let offsetX = 100;
  let offsetY = 100;
  let isPanning = false;
  let panStart = { x: 0, y: 0 };
  
  // Drag-to-paint and hover guide state
  let isDrawing = false;
  let hoverPos = { x: 0, y: 0 };
  let isHovering = false;

  $: quickRibbon = Object.values(inventory).flat().slice(0, 8);

  // Level editor undo/redo history stack
  let levelHistory: PlacedEntity[][] = [];
  let levelHistoryIndex = -1;

  function saveLevelState() {
    if (levelHistoryIndex < levelHistory.length - 1) {
      levelHistory = levelHistory.slice(0, levelHistoryIndex + 1);
    }
    // Deep copy of placed entities
    levelHistory.push(placed.map(ent => ({
      ...ent,
      position: { ...ent.position },
      modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
    })));
    levelHistoryIndex = levelHistory.length - 1;
    if (levelHistory.length > 50) {
      levelHistory.shift();
      levelHistoryIndex--;
    }
  }

  function undoLevel() {
    if (levelHistoryIndex > 0) {
      levelHistoryIndex--;
      placed = levelHistory[levelHistoryIndex].map(ent => ({
        ...ent,
        position: { ...ent.position },
        modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
      }));
      saveCurrentRoom();
      playUiSound('squeak');
    }
  }

  function redoLevel() {
    if (levelHistoryIndex < levelHistory.length - 1) {
      levelHistoryIndex++;
      placed = levelHistory[levelHistoryIndex].map(ent => ({
        ...ent,
        position: { ...ent.position },
        modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
      }));
      saveCurrentRoom();
      playUiSound('pop');
    }
  }

  onMount(async () => {
    try {
      inventory = await invoke<AssetInventory>('get_asset_inventory');
      activeAsset = inventory.terrain?.[0] ?? Object.values(inventory).flat()[0] ?? activeAsset;
      status = 'Loaded toybox assets.';
    } catch (error) {
      status = `Using fallback toybox: ${error}`;
    }

    await loadRoomList();
    
    if (rooms.includes(activeRoomId)) {
      await loadSelectedRoom(activeRoomId);
    } else {
      try {
        const savedState = await invoke<any>('load_game_state');
        if (savedState && Array.isArray(savedState.entities)) {
          placed = savedState.entities;
          status += ' Restored saved game state.';
        }
      } catch (error) {
        status += ' No saved game state found, starting fresh.';
      }
      levelHistory = [placed.map(ent => ({
        ...ent,
        position: { ...ent.position },
        modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
      }))];
      levelHistoryIndex = 0;
    }

    // Auto-save every 60 seconds
    const saveId = setInterval(() => {
      if (placed.length > 0) saveCurrentRoom();
    }, 60_000);

    // Refresh Toybox inventory every 5 seconds (picks up inbox-ingested assets)
    const refreshId = setInterval(async () => {
      try {
        inventory = await invoke<AssetInventory>('get_asset_inventory');
      } catch { /* silent */ }
    }, 5_000);

    // Return cleanup so intervals are cancelled on unmount / hot-reload
    return () => {
      clearInterval(saveId);
      clearInterval(refreshId);
    };
  });

  async function loadRoomList() {
    try {
      rooms = await invoke<string[]>('list_rooms');
      if (rooms.length === 0) {
        rooms = [activeRoomId];
      }
    } catch (err) {
      console.error('Failed to list rooms:', err);
    }
  }

  function getCanvasCoords(clientX: number, clientY: number, rect: DOMRect) {
    const screenX = clientX - rect.left;
    const screenY = clientY - rect.top;
    return {
      x: (screenX - offsetX) / zoom,
      y: (screenY - offsetY) / zoom
    };
  }

  function getSnappedPosition(rawCoords: { x: number; y: number }, asset: ToyboxAsset): { x: number; y: number } {
    if (!snapEnabled) return rawCoords;

    const snapping = asset.snapping_type ?? (asset.category === 'terrain' ? 'edge_to_edge' : 'gravity_snap');

    if (snapping === 'edge_to_edge') {
      // Terrain edge-to-edge snapping to 32px grid
      return {
        x: Math.round(rawCoords.x / 32) * 32,
        y: Math.round(rawCoords.y / 32) * 32
      };
    } else if (snapping === 'gravity_snap') {
      // Gravity snap: snap X to 8px, snap Y to stand on top of terrain block below cursor
      const snapX = Math.round(rawCoords.x / 8) * 8;
      
      let stampHeight = 32;
      if (asset.category === 'heroes') stampHeight = 48;
      if (asset.frames && asset.frames[0]) {
        stampHeight = asset.frames[0].h;
      }

      // Scan placed terrain blocks to find the topmost terrain block below the cursor
      let bestTopY: number | null = null;
      for (const item of placed) {
        if (item.category === 'terrain') {
          // Default terrain width is 128 (64px half-width margin)
          const left = item.position.x - 64;
          const right = item.position.x + 64;
          
          if (snapX >= left && snapX <= right) {
            const topEdge = item.position.y - 16; // Terrain half-height margin
            // If the block top edge is below the cursor y position (with small buffer)
            if (topEdge >= rawCoords.y - 16) {
              if (bestTopY === null || topEdge < bestTopY) {
                bestTopY = topEdge;
              }
            }
          }
        }
      }

      if (bestTopY !== null) {
        return {
          x: snapX,
          y: bestTopY - stampHeight / 2
        };
      }

      // Fallback: grid snap if no terrain block is directly below
      return {
        x: snapX,
        y: Math.round(rawCoords.y / 8) * 8
      };
    }

    // Default 8px snap
    return {
      x: Math.round(rawCoords.x / 8) * 8,
      y: Math.round(rawCoords.y / 8) * 8
    };
  }

  function handleCanvasClick(event: MouseEvent) {
    selectedPlacedEntity = null;
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    if (eraserMode) {
      const hit = [...placed].reverse().find((item) => {
        const dx = item.position.x - position.x;
        const dy = item.position.y - position.y;
        return Math.sqrt(dx * dx + dy * dy) < 36 / zoom;
      });

      if (hit) {
        placed = eraseEntity(placed, hit.instance_id);
        playUiSound('squeak');
      }
      return;
    }

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < 4 && 
               Math.abs(ent.position.y - position.y) < 4
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
      playUiSound('pop');
    }
  }

  function paintStamp(event: MouseEvent) {
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    const spacingThreshold = activeAsset.category === 'terrain' ? 48 : 24;

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < spacingThreshold && 
               Math.abs(ent.position.y - position.y) < 8
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
      playUiSound('pop');
    }
  }

  function startDrawing(event: MouseEvent) {
    if (event.button === 0) {
      isDrawing = true;
      handleCanvasClick(event);
    }
  }

  function stopDrawing(event: MouseEvent) {
    if (event.button === 0) {
      isDrawing = false;
      saveLevelState();
      saveCurrentRoom();
    }
  }

  function handleWheel(event: WheelEvent) {
    event.preventDefault();
    const zoomFactor = 0.08;
    let newZoom = zoom;
    if (event.deltaY < 0) {
      newZoom += zoomFactor;
    } else {
      newZoom -= zoomFactor;
    }
    zoom = Math.max(0.5, Math.min(2.0, newZoom));
  }

  function handleMouseDown(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = true;
      panStart = { x: event.clientX - offsetX, y: event.clientY - offsetY };
      event.preventDefault();
    }
  }

  function handleMouseMove(event: MouseEvent) {
    if (isPanning) {
      offsetX = event.clientX - panStart.x;
      offsetY = event.clientY - panStart.y;
    } else {
      const target = event.currentTarget as HTMLDivElement;
      const rect = target.getBoundingClientRect();
      const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
      hoverPos = getSnappedPosition(rawCoords, activeAsset);
      isHovering = true;

      if (isDrawing && !eraserMode) {
        paintStamp(event);
      }
    }
  }

  function handleMouseUp(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = false;
    }
  }

  async function handlePortalPlacement(position: { x: number; y: number }, asset: ToyboxAsset) {
    let targetRoomId = '';
    do {
      targetRoomId = `room_${Math.random().toString(36).substring(2, 8)}`;
    } while (rooms.includes(targetRoomId));

    const thisPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;
    const targetPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;

    const newPortal: PlacedEntity = {
      instance_id: thisPortalId,
      asset_id: asset.id,
      category: asset.category,
      type: asset.type ?? asset.category,
      position,
      modifiers: {
        variant: 'default',
        scale_multiplier: 1.0,
        target_room: targetRoomId,
        target_portal: targetPortalId
      }
    };

    placed = [...placed, newPortal];
    saveLevelState();
    status = `Placed portal ${thisPortalId} linking to room ${targetRoomId}`;

    try {
      const returnPortal: PlacedEntity = {
        instance_id: targetPortalId,
        asset_id: asset.id,
        category: asset.category,
        type: asset.type ?? asset.category,
        position: { x: position.x, y: position.y },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0,
          target_room: activeRoomId,
          target_portal: thisPortalId
        }
      };

      const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
      const floorUnderPortal: PlacedEntity = {
        instance_id: `stone_floor_${Math.random().toString(36).substring(2, 8)}`,
        asset_id: terrainAsset.id,
        category: terrainAsset.category,
        type: terrainAsset.type ?? terrainAsset.category,
        position: { x: position.x, y: position.y + 48 },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0
        }
      };

      const targetPayload = {
        schema_version: 1,
        project_id: 'demo_project',
        room_id: targetRoomId,
        world_settings: {
          time_of_day: 'day',
          weather: 'clear'
        },
        entities: [returnPortal, floorUnderPortal]
      };

      const jsonString = JSON.stringify(targetPayload);
      await invoke('save_room', { roomId: targetRoomId, jsonString });
      await loadRoomList();
      status = `Placed portal linking to auto-created room ${targetRoomId}!`;
    } catch (err) {
      status = `Failed to auto-create target room: ${err}`;
    }
  }

  async function saveCurrentRoom() {
    status = `Saving room ${activeRoomId}...`;
    try {
      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      const jsonString = JSON.stringify(payload);
      status = await invoke<string>('save_room', { roomId: activeRoomId, jsonString });
      await loadRoomList();
      generateThumbnail(activeRoomId);
    } catch (error) {
      status = `Save failed: ${String(error)}`;
    }
  }

  async function deleteRoom(roomId: string) {
    if (!confirm(`Delete room "${roomId}"? This cannot be undone.`)) return;
    try {
      await invoke('delete_room', { roomId });
      await loadRoomList();
      if (activeRoomId === roomId) {
        activeRoomId = rooms[0] ?? 'test_chamber_01';
        placed = [];
        status = `Deleted room. Now editing: ${activeRoomId}`;
      } else {
        status = `Deleted room: ${roomId}`;
      }
    } catch (error) {
      // delete_room command may not exist yet — fallback gracefully
      status = `Could not delete room: ${String(error)}`;
    }
  }

  async function loadSelectedRoom(roomId: string) {
    status = `Loading room ${roomId}...`;
    try {
      const savedState = await invoke<any>('load_room', { roomId });
      if (savedState && Array.isArray(savedState.entities)) {
        placed = savedState.entities;
        activeRoomId = roomId;
        // Restore world settings from saved JSON
        if (savedState.world_settings) {
          worldSettings = {
            time_of_day: savedState.world_settings.time_of_day ?? 'day',
            weather: savedState.world_settings.weather ?? 'clear'
          };
        }
        status = `Loaded room: ${roomId}`;
        levelHistory = [placed.map(ent => ({
          ...ent,
          position: { ...ent.position },
          modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
        }))];
        levelHistoryIndex = 0;
      }
    } catch (error) {
      status = `Failed to load room ${roomId}: ${error}`;
    }
  }

  async function refreshInventory() {
    try {
      inventory = await invoke<AssetInventory>('get_asset_inventory');
      status = 'Toybox refreshed.';
    } catch (error) {
      status = `Refresh failed: ${error}`;
    }
  }

  // ── Thumbnail generation using a hidden <canvas> ──────────────────────────
  const CATEGORY_COLORS: Record<string, string> = {
    heroes: '#60a5fa',
    terrain: '#6b7280',
    enemies: '#f87171',
    collectibles: '#fbbf24',
    portals: '#a78bfa',
    decorations: '#34d399'
  };

  function generateThumbnail(roomId: string) {
    try {
      const canvas = document.createElement('canvas');
      canvas.width = 160;
      canvas.height = 90;
      const ctx = canvas.getContext('2d');
      if (!ctx) return;

      // Background
      ctx.fillStyle = worldSettings.time_of_day === 'night' ? '#0f172a'
        : worldSettings.time_of_day === 'sunset' ? '#7c2d12'
        : worldSettings.time_of_day === 'morning' ? '#164e63'
        : '#1e3a5f';
      ctx.fillRect(0, 0, 160, 90);

      if (placed.length === 0) {
        localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
        return;
      }

      // Compute world bounds from placed entities
      const xs = placed.map(e => e.position.x);
      const ys = placed.map(e => e.position.y);
      const minX = Math.min(...xs) - 32;
      const minY = Math.min(...ys) - 32;
      const rangeX = Math.max(...xs) - minX + 64;
      const rangeY = Math.max(...ys) - minY + 64;

      const scaleX = 160 / rangeX;
      const scaleY = 90 / rangeY;
      const scale = Math.min(scaleX, scaleY);

      for (const e of placed) {
        const px = (e.position.x - minX) * scale;
        const py = (e.position.y - minY) * scale;
        ctx.fillStyle = CATEGORY_COLORS[e.category] ?? '#94a3b8';
        if (e.category === 'terrain') {
          ctx.fillRect(px - 6, py - 2, 12, 4);
        } else {
          ctx.beginPath();
          ctx.arc(px, py, e.category === 'heroes' ? 5 : 3, 0, Math.PI * 2);
          ctx.fill();
        }
      }

      localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
    } catch { /* non-critical */ }
  }

  function getThumbnail(roomId: string): string | null {
    try { return localStorage.getItem(`thumb_${roomId}`); }
    catch { return null; }
  }

  function createNewRoom() {
    openThemeSelector();
  }

  function openThemeSelector() {
    themeSelectorOpen = true;
  }

  async function applyTheme(themeName: 'space' | 'candy' | 'jungle' | 'ice' | 'volcano') {
    themeSelectorOpen = false;
    const newId = `${themeName}_room_${Math.floor(Math.random() * 900 + 100)}`;
    activeRoomId = newId;

    if (themeName === 'space') {
      worldSettings = { time_of_day: 'night', weather: 'clear' };
    } else if (themeName === 'candy') {
      worldSettings = { time_of_day: 'sunset', weather: 'clear' };
    } else if (themeName === 'ice') {
      worldSettings = { time_of_day: 'morning', weather: 'snow' };
    } else if (themeName === 'volcano') {
      worldSettings = { time_of_day: 'sunset', weather: 'clear' };
    } else {
      worldSettings = { time_of_day: 'day', weather: 'rain' };
    }
    (worldSettings as any).theme = themeName;

    const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
    const heroAsset = findAsset('hero_knight') ?? { id: 'hero_knight', name: 'Hero Knight', category: 'heroes', type: 'player' };
    const rubyAsset = findAsset('gold_ruby') ?? { id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', type: 'collectible' };

    const newPlaced: PlacedEntity[] = [
      {
        instance_id: makeInstanceId(heroAsset.id),
        asset_id: heroAsset.id,
        category: heroAsset.category,
        type: heroAsset.type ?? heroAsset.category,
        position: { x: 128, y: 300 },
        is_camera_target: true,
        modifiers: { variant: 'default', scale_multiplier: 1.0 }
      },
      {
        instance_id: makeInstanceId(rubyAsset.id),
        asset_id: rubyAsset.id,
        category: rubyAsset.category,
        type: rubyAsset.type ?? rubyAsset.category,
        position: { x: 800, y: 330 },
        modifiers: { variant: 'default', scale_multiplier: 1.0 }
      }
    ];

    for (let i = 0; i < 7; i++) {
      newPlaced.push({
        instance_id: makeInstanceId(terrainAsset.id),
        asset_id: terrainAsset.id,
        category: terrainAsset.category,
        type: terrainAsset.type ?? terrainAsset.category,
        position: { x: 128 + i * 128, y: 392 },
        modifiers: { variant: 'default', scale_multiplier: 1.0 }
      });
    }

    placed = newPlaced;
    levelHistory = [placed.map(ent => ({
      ...ent,
      position: { ...ent.position },
      modifiers: ent.modifiers ? { ...ent.modifiers } : undefined
    }))];
    levelHistoryIndex = 0;

    status = `Created new ${themeName} room: ${newId}`;
    playUiSound('chime');

    await saveCurrentRoom();
  }

  async function play() {
    status = 'Saving room level...';
    try {
      await saveCurrentRoom();

      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      (window as any).currentGameLevel = JSON.stringify(payload);
      (window as any).currentGameMuted = isMuted;

      status = 'Preparing WebGL game...';
      try {
        await invoke('build_web_runner');
        playModalOpen = true;
        isGamePaused = false;
        status = 'Loaded embedded play mode!';
        playUiSound('chime');
      } catch (err) {
        console.log('WebGL player not built/available, falling back to native window:', err);
        status = 'Launching Godot runner window...';
        await launchNativeWindow();
      }
    } catch (error) {
      status = `Play failed: ${String(error)}`;
    }
  }

  async function launchNativeWindow() {
    try {
      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      status = await invoke<string>('compile_and_play', { roomPayload: payload });
      playUiSound('chime');
    } catch (error) {
      status = `Native play failed: ${String(error)}`;
    }
  }

  async function exportGame() {
    status = 'Saving and exporting...';
    try {
      await saveCurrentRoom();
      const payload = toRoomPayload(placed);
      status = await invoke<string>('export_game', { projectId: payload.project_id });
    } catch (error) {
      status = `Export failed: ${String(error)}`;
    }
  }

  function selectAsset(asset: ToyboxAsset) {
    activeAsset = asset;
    eraserMode = false;
    toyboxOpen = false;
  }

  function findAsset(assetId: string): ToyboxAsset | undefined {
    return Object.values(inventory).flat().find((asset) => asset.id === assetId);
  }

  function isEmoji(str: string | undefined): boolean {
    if (!str) return true;
    return !str.includes('.') && !str.includes('/') && !str.includes('\\');
  }

  function getAssetUrl(asset: ToyboxAsset): string {
    if (!asset.visual || isEmoji(asset.visual)) return '';
    if (!asset.sidecar_path) return asset.visual;
    const lastSlash = Math.max(asset.sidecar_path.lastIndexOf('/'), asset.sidecar_path.lastIndexOf('\\'));
    if (lastSlash === -1) return asset.visual;
    const dir = asset.sidecar_path.substring(0, lastSlash + 1);
    return convertFileSrc(dir + asset.visual);
  }
</script>

<main class="app-shell">
  <header class="topbar">
    <span class="logo">🧸 KidGameMaker</span>

    <!-- World cycle settings -->
    <div class="world-cycle-controls">
      <button class="cycle-btn time-btn" on:click={(e) => { animateClick(e); cycleTime(); }} title="Change Time of Day">
        {#if worldSettings.time_of_day === 'day'}☀️{:else if worldSettings.time_of_day === 'morning'}🌅{:else if worldSettings.time_of_day === 'sunset'}🌇{:else}🌙{/if}
      </button>
      <button class="cycle-btn weather-btn" on:click={(e) => { animateClick(e); cycleWeather(); }} title="Change Weather">
        {#if worldSettings.weather === 'clear'}🌤{:else if worldSettings.weather === 'rain'}🌧{:else}❄️{/if}
      </button>
      <button class="cycle-btn mute-btn" class:active={isMuted} on:click={(e) => { animateClick(e); toggleMute(); }} title="Toggle Sound">
        {isMuted ? "🔇" : "🔊"}
      </button>
    </div>

    <!-- Active Stamp -->
    <button class="stamp-select-btn" class:active={!eraserMode} on:click={(e) => { animateClick(e); eraserMode = false; }} style="display: flex; align-items: center; gap: 8px;">
      <span class="active-visual-container">
        {#if activeAsset.visual && !isEmoji(activeAsset.visual)}
          {#if activeAsset.is_spritesheet && activeAsset.frames && activeAsset.frames[0]}
            <img
              src={getAssetUrl(activeAsset)}
              alt={activeAsset.name}
              style="
                width: {activeAsset.frames[0].w}px;
                height: {activeAsset.frames[0].h}px;
                object-fit: none;
                object-position: -{activeAsset.frames[0].x}px -{activeAsset.frames[0].y}px;
                transform: scale({Math.min(1.5, 24 / Math.max(activeAsset.frames[0].w, activeAsset.frames[0].h))});
                transform-origin: center;
                display: block;
              "
            />
          {:else}
            <img
              src={getAssetUrl(activeAsset)}
              alt={activeAsset.name}
              style="max-width: 24px; max-height: 24px; object-fit: contain; display: block;"
            />
          {/if}
        {:else}
          <span>{activeAsset.visual ?? '🎮'}</span>
        {/if}
      </span>
      <span class="btn-text">{activeAsset.name}</span>
    </button>
    
    {#if activeAsset}
      <button class="edit-toy-btn" on:click={(e) => { animateClick(e); editActiveAsset(); }} title="Paint/Edit this toy">🎨 Edit</button>
    {/if}

    <button class="eraser-btn-top" class:active={eraserMode} on:click={(e) => { animateClick(e); eraserMode = !eraserMode; }} title="Eraser">🧽 Eraser</button>
    <button class="snap-btn-top" class:active={snapEnabled} on:click={(e) => { animateClick(e); snapEnabled = !snapEnabled; }} title="Snap to Grid">🧲 Snap</button>
    <button class="undo-btn-top" disabled={levelHistoryIndex <= 0} on:click={(e) => { animateClick(e); undoLevel(); }} title="Undo last action">↺ Undo</button>
    <button class="redo-btn-top" disabled={levelHistoryIndex >= levelHistory.length - 1} on:click={(e) => { animateClick(e); redoLevel(); }} title="Redo action">↻ Redo</button>
    <button class="toybox-btn-top" on:click={(e) => { animateClick(e); toyboxOpen = true; }} title="Toybox">🧰 Toybox</button>
    <button class="draw-toy-btn-top" on:click={(e) => { animateClick(e); openCustomAssetCanvas(); }} title="Draw Toy">🎨 Draw</button>

    <!-- Play Button (Big, green) -->
    <button id="btn-play" class="play-btn-top" on:click={(e) => { animateClick(e); play(); }} title="Play!">▶ PLAY</button>

    <!-- Parents panel toggle -->
    <button class="parents-toggle-btn" class:active={parentsPanelOpen} on:click={(e) => { animateClick(e); parentsPanelOpen = !parentsPanelOpen; }} title="Parents / Developers Settings">⚙️ Parents</button>
  </header>

  {#if parentsPanelOpen}
    <div class="parents-panel-container">
      <div class="parents-panel-header">
        <h3>⚙️ Parents & Developers Settings</h3>
      </div>
      <div class="parents-panel-body">
        <div class="panel-section">
          <h4>Room Manager</h4>
          <div class="panel-row">
            <button class="bookshelf-btn" on:click={(e) => { animateClick(e); bookshelfOpen = true; }}>📚 Browse Rooms</button>
            <select id="room-selector" value={activeRoomId} on:change={(e) => loadSelectedRoom(e.currentTarget.value)}>
              {#each rooms as room}
                <option value={room}>{room}</option>
              {/each}
            </select>
            <input id="room-name-input" type="text" bind:value={activeRoomId} placeholder="Room ID" title="Change Room Name" />
            <button id="btn-new-room" class="icon-btn" on:click={(e) => { animateClick(e); createNewRoom(); }} title="New Room">➕ New</button>
          </div>
        </div>

        <div class="panel-section">
          <h4>Actions</h4>
          <div class="panel-row">
            <button id="btn-save" class="save" on:click={(e) => { animateClick(e); saveCurrentRoom(); }}>💾 SAVE</button>
            <button id="btn-export" class="export" on:click={(e) => { animateClick(e); exportGame(); }} style="background: #10b981; color: white;">📦 EXPORT</button>
            <button id="btn-refresh-toybox" class="icon-btn refresh-btn" on:click={(e) => { animateClick(e); refreshInventory(); }} title="Refresh Toybox from disk">🔄 RELOAD</button>
          </div>
        </div>

        <div class="panel-section">
          <h4>Active Toy Specs</h4>
          <div class="panel-row spec-labels">
            <span><strong>ID:</strong> {activeAsset.id}</span>
            <span><strong>Category:</strong> {activeAsset.category}</span>
            <span><strong>Snap Type:</strong> {activeAsset.snapping_type || 'default'}</span>
          </div>
        </div>
      </div>
    </div>
  {/if}

  <section class="quick-ribbon" aria-label="Quick toybox ribbon">
    {#each quickRibbon as asset}
      <button
        class="ribbon-btn"
        class:active={activeAsset.id === asset.id && !eraserMode}
        on:click={(e) => { animateClick(e); selectAsset(asset); }}
        title={asset.name}
      >
        <span class="ribbon-visual-container">
          {#if asset.visual && !isEmoji(asset.visual)}
            {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
              <img
                src={getAssetUrl(asset)}
                alt={asset.name}
                style="
                  width: {asset.frames[0].w}px;
                  height: {asset.frames[0].h}px;
                  object-fit: none;
                  object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                  transform: scale({Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                  transform-origin: center;
                  display: block;
                "
              />
            {:else}
              <img
                src={getAssetUrl(asset)}
                alt={asset.name}
                style="max-width: 48px; max-height: 48px; object-fit: contain; display: block;"
              />
            {/if}
          {:else}
            <span>{asset.visual ?? '🎮'}</span>
          {/if}
        </span>
        <small>{asset.name}</small>
      </button>
    {/each}
  </section>

  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div 
    class="canvas" 
    on:mousedown={startDrawing}
    on:mousemove={handleMouseMove}
    on:mouseup={stopDrawing}
    on:mouseleave={() => { isHovering = false; isDrawing = false; }}
    on:wheel={handleWheel}
    on:contextmenu|preventDefault
    on:mousedown|stopPropagation={handleMouseDown}
    on:mouseup|stopPropagation={handleMouseUp}
    aria-label="Game canvas"
  >
    <div 
      class="canvas-inner" 
      style:transform={`translate(${offsetX}px, ${offsetY}px) scale(${zoom})`}
      style:transform-origin="0 0"
    >
      <div class="horizon"></div>
      {#each placed as item (item.instance_id)}
        {@const asset = findAsset(item.asset_id)}
        <button
          class="stamp {item.category}"
          style:left={`${item.position.x}px`}
          style:top={`${item.position.y}px`}
          title={`${item.asset_id} ${item.instance_id}${item.modifiers.target_room ? ` (Leads to ${item.modifiers.target_room})` : ''}`}
          on:click|stopPropagation={() => {
            if (eraserMode) {
              placed = eraseEntity(placed, item.instance_id);
              playUiSound('squeak');
            } else {
              selectedPlacedEntity = item;
              playUiSound('chime');
            }
          }}
          on:mousedown|stopPropagation
          style:border-radius={item.category === 'terrain' ? '14px' : '50%'}
          style:width={item.category === 'terrain' ? '160px' : '56px'}
          style:overflow="hidden"
        >
          <span class="stamp-visual-container">
            {#if asset && asset.visual && !isEmoji(asset.visual)}
              {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
                <img
                  src={getAssetUrl(asset)}
                  alt={asset.name}
                  style="
                    width: {asset.frames[0].w}px;
                    height: {asset.frames[0].h}px;
                    object-fit: none;
                    object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                    transform: scale({item.category === 'terrain' ? Math.min(2.0, 160 / asset.frames[0].w) : Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                    transform-origin: center;
                    display: block;
                  "
                />
              {:else}
                <img
                  src={getAssetUrl(asset)}
                  alt={asset.name}
                  style="max-width: {item.category === 'terrain' ? '150px' : '48px'}; max-height: 48px; object-fit: contain; display: block;"
                />
              {/if}
            {:else}
              <span>{asset?.visual ?? '🎮'}</span>
            {/if}
          </span>
        </button>
      {/each}

      {#if isHovering && !eraserMode}
        <div 
          class="hover-guide {activeAsset.category}"
          style:left={`${hoverPos.x}px`}
          style:top={`${hoverPos.y}px`}
          style:border-radius={activeAsset.category === 'terrain' ? '14px' : '50%'}
          style:width={activeAsset.category === 'terrain' ? '160px' : '56px'}
          style:overflow="hidden"
        >
          <span class="stamp-visual-container">
            {#if activeAsset.visual && !isEmoji(activeAsset.visual)}
              {#if activeAsset.is_spritesheet && activeAsset.frames && activeAsset.frames[0]}
                <img
                  src={getAssetUrl(activeAsset)}
                  alt={activeAsset.name}
                  style="
                    width: {activeAsset.frames[0].w}px;
                    height: {activeAsset.frames[0].h}px;
                    object-fit: none;
                    object-position: -{activeAsset.frames[0].x}px -{activeAsset.frames[0].y}px;
                    transform: scale({activeAsset.category === 'terrain' ? Math.min(2.0, 160 / activeAsset.frames[0].w) : Math.min(1.5, 48 / Math.max(activeAsset.frames[0].w, activeAsset.frames[0].h))});
                    transform-origin: center;
                    display: block;
                  "
                />
              {:else}
                <img
                  src={getAssetUrl(activeAsset)}
                  alt={activeAsset.name}
                  style="max-width: {activeAsset.category === 'terrain' ? '150px' : '48px'}; max-height: 48px; object-fit: contain; display: block;"
                />
              {/if}
            {:else}
              <span>{activeAsset.visual ?? '🎮'}</span>
            {/if}
          </span>
        </div>
      {/if}
    </div>
  </div>

  <footer>
    <code>{status}</code>
    <span>{placed.length} stamped objects | Zoom: {Math.round(zoom * 100)}%</span>
  </footer>

  <ToyboxModal
    isVisible={toyboxOpen}
    inventory={inventory}
    isMuted={isMuted}
    on:itemSelected={(event) => selectAsset(event.detail)}
    on:close={() => (toyboxOpen = false)}
  />

  <BookshelfModal
    isVisible={bookshelfOpen}
    {rooms}
    {activeRoomId}
    {getThumbnail}
    on:selectRoom={(e) => { loadSelectedRoom(e.detail); bookshelfOpen = false; }}
    on:newRoom={() => { createNewRoom(); bookshelfOpen = false; }}
    on:deleteRoom={(e) => deleteRoom(e.detail)}
    on:close={() => (bookshelfOpen = false)}
  />

  <SpriteEditorModal
    isVisible={spriteEditorOpen}
    targetAssetId={editingAssetId}
    category={editingCategory}
    isMuted={isMuted}
    on:close={() => (spriteEditorOpen = false)}
    on:saved={handleDrawingSaved}
  />

  {#if themeSelectorOpen}
    <div class="backdrop" role="button" tabindex="-1" on:click={() => (themeSelectorOpen = false)}>
      <div class="modal theme-modal" role="dialog" tabindex="0" on:click|stopPropagation>
        <h2>🌟 Choose a Theme! 🌟</h2>
        <div class="theme-cards">
          <button class="theme-card space" on:click={() => applyTheme('space')}>
            <span class="card-icon">🚀</span>
            <h3>Space Bouncy</h3>
            <p>Bounce on stars under dark glowing skies!</p>
          </button>
          <button class="theme-card candy" on:click={() => applyTheme('candy')}>
            <span class="card-icon">🍭</span>
            <h3>Candy Hills</h3>
            <p>Yummy sunset skies and sugary blocks!</p>
          </button>
          <button class="theme-card jungle" on:click={() => applyTheme('jungle')}>
            <span class="card-icon">🌴</span>
            <h3>Jungle Rain</h3>
            <p>Rainy green forests and wild vine jumps!</p>
          </button>
          <button class="theme-card ice" on:click={() => applyTheme('ice')}>
            <span class="card-icon">❄️</span>
            <h3>Winter Wonderland</h3>
            <p>Slide on snow under bright icy blue skies!</p>
          </button>
          <button class="theme-card volcano" on:click={() => applyTheme('volcano')}>
            <span class="card-icon">🌋</span>
            <h3>Volcano Run</h3>
            <p>Watch out for lava blocks and sunset skies!</p>
          </button>
        </div>
        <button class="close-btn" on:click={() => (themeSelectorOpen = false)}>✕ Close</button>
      </div>
    </div>
  {/if}

  {#if playModalOpen}
    <div class="backdrop" role="button" tabindex="-1" on:click={closePlayModal}>
      <div class="modal play-modal" role="dialog" tabindex="0" on:click|stopPropagation>
        <header class="play-header">
          <h2>🎮 Playing Game! 🎮</h2>
          <div class="play-controls-overlay">
            <button class="play-control-btn mute-btn-overlay" on:click={toggleMute} title="Toggle Sound" style="background: #374151; box-shadow: 0 5px 0 #1f2937;">
              {isMuted ? "🔇" : "🔊"}
            </button>
            <button class="play-control-btn pause-btn" on:click={togglePauseGame} title={isGamePaused ? "Resume" : "Pause"}>
              {isGamePaused ? "▶ Resume" : "⏸ Pause"}
            </button>
            <button class="play-control-btn restart-btn" on:click={restartGame} title="Restart level">
              🔄 Restart
            </button>
            <button class="play-control-btn stop-btn" on:click={closePlayModal} title="Exit game">
              🛑 Exit
            </button>
          </div>
        </header>
        <div class="game-container">
          <iframe src="/game/index.html" title="KidGameMaker Embedded Play View" class="game-iframe"></iframe>
        </div>
        <div class="play-options">
          <button class="window-btn" on:click={() => { closePlayModal(); launchNativeWindow(); }}>📺 Run in Large Window</button>
        </div>
      </div>
    </div>
  {/if}

  {#if selectedPlacedEntity}
    <div class="customizer-panel">
      <header class="customizer-header">
        <h3>Customize Toy 🎛️</h3>
        <button class="close-customizer-btn" on:click={() => selectedPlacedEntity = null}>✕</button>
      </header>

      <div class="customizer-body">
        <div class="toy-info">
          <span class="toy-icon">{findAsset(selectedPlacedEntity.asset_id)?.visual ?? '🎮'}</span>
          <span class="toy-name">{findAsset(selectedPlacedEntity.asset_id)?.name ?? selectedPlacedEntity.asset_id}</span>
        </div>

        <div class="option-group">
          <div class="option-label">
            <span>Toy Size:</span>
            <span>{selectedPlacedEntity.modifiers.scale_multiplier.toFixed(1)}x</span>
          </div>
          <input 
            type="range" 
            min="0.5" 
            max="3.0" 
            step="0.1" 
            class="option-slider" 
            bind:value={selectedPlacedEntity.modifiers.scale_multiplier} 
            on:change={saveCurrentRoom} 
          />
        </div>

        {#if selectedPlacedEntity.category === 'enemies' || selectedPlacedEntity.type === 'enemy'}
          <div class="option-group">
            <div class="option-label">
              <span>Monster Speed:</span>
              <span>{selectedPlacedEntity.modifiers.patrol_speed ?? 70}</span>
            </div>
            <input 
              type="range" 
              min="20" 
              max="300" 
              step="10" 
              class="option-slider" 
              bind:value={selectedPlacedEntity.modifiers.patrol_speed} 
              on:change={saveCurrentRoom} 
            />
          </div>

          <div class="option-group">
            <div class="option-label">
              <span>Damage:</span>
              <span>{selectedPlacedEntity.modifiers.damage_value ?? 10}</span>
            </div>
            <input 
              type="range" 
              min="0" 
              max="100" 
              step="5" 
              class="option-slider" 
              bind:value={selectedPlacedEntity.modifiers.damage_value} 
              on:change={saveCurrentRoom} 
            />
          </div>

          <div class="option-group">
            <span class="option-label-text">Monster AI Behavior:</span>
            <select 
              class="option-select" 
              bind:value={selectedPlacedEntity.modifiers.behavior_type} 
              on:change={saveCurrentRoom}
            >
              <option value="patrol">🚶 Walk back & forth</option>
              <option value="chase">🏃 Chase the player</option>
              <option value="jump">🦘 Hop & Jump around</option>
              <option value="fly">🦇 Fly like a bat</option>
            </select>
          </div>

          <div class="option-group flex-row">
            <span class="option-label-text">Is it a Boss? 👑</span>
            <input 
              type="checkbox" 
              class="option-toggle" 
              bind:checked={selectedPlacedEntity.modifiers.boss_mode} 
              on:change={() => {
                if (selectedPlacedEntity.modifiers.boss_mode) {
                  selectedPlacedEntity.modifiers.scale_multiplier = 1.8;
                } else {
                  selectedPlacedEntity.modifiers.scale_multiplier = 1.0;
                }
                saveCurrentRoom();
              }} 
            />
          </div>
        {:else if selectedPlacedEntity.category === 'collectibles' || selectedPlacedEntity.type === 'collectible'}
          <div class="option-group">
            <div class="option-label">
              <span>Score Value:</span>
              <span>{selectedPlacedEntity.modifiers.score_value ?? 10}</span>
            </div>
            <input 
              type="range" 
              min="0" 
              max="500" 
              step="10" 
              class="option-slider" 
              bind:value={selectedPlacedEntity.modifiers.score_value} 
              on:change={saveCurrentRoom} 
            />
          </div>

          <div class="option-group">
            <div class="option-label">
              <span>Healing Power:</span>
              <span>{selectedPlacedEntity.modifiers.heal_value ?? 0}</span>
            </div>
            <input 
              type="range" 
              min="0" 
              max="100" 
              step="5" 
              class="option-slider" 
              bind:value={selectedPlacedEntity.modifiers.heal_value} 
              on:change={saveCurrentRoom} 
            />
          </div>

          <div class="option-group">
            <span class="option-label-text">Give Hero Special Power:</span>
            <select 
              class="option-select" 
              bind:value={selectedPlacedEntity.modifiers.powerup_type} 
              on:change={saveCurrentRoom}
            >
              <option value="">❌ None</option>
              <option value="speed">🧪 Speed Boost Potion</option>
              <option value="shield">🛡️ Shield Bubble</option>
              <option value="double_jump">👟 Double Jump Shoes</option>
            </select>
          </div>
        {:else if selectedPlacedEntity.category === 'portals' || selectedPlacedEntity.type === 'portal'}
          <div class="option-group">
            <span class="option-label-text">Select Link Room:</span>
            <select 
              class="option-select" 
              bind:value={selectedPlacedEntity.modifiers.target_room} 
              on:change={saveCurrentRoom}
            >
              {#each rooms as r}
                <option value={r}>{r === activeRoomId ? `${r} (This Room)` : r}</option>
              {/each}
            </select>
          </div>
        {/if}
      </div>

      <footer class="customizer-footer">
        <button class="customizer-delete-btn" on:click={() => {
          placed = eraseEntity(placed, selectedPlacedEntity.instance_id);
          selectedPlacedEntity = null;
          playUiSound('squeak');
          saveCurrentRoom();
        }}>🗑️ Throw Away Toy</button>
      </footer>
    </div>
  {/if}
</main>

<style>
  .app-shell {
    height: 100vh;
    display: grid;
    grid-template-rows: auto auto 1fr auto;
  }

  .ribbon-visual-container,
  .stamp-visual-container {
    width: 100%;
    height: 100%;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .active-visual-container {
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .topbar,
  .quick-ribbon,
  footer {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px;
    background: #101827;
    border-bottom: 3px solid rgba(255, 255, 255, 0.08);
  }

  .topbar {
    flex-wrap: wrap;
  }

  .logo {
    font-size: 1.5rem;
    font-weight: 900;
    color: #ffd84d;
    margin-right: 12px;
  }

  .room-controls {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 10px;
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .room-controls select,
  .room-controls input {
    background: #1f2937;
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    padding: 4px 8px;
    font-weight: 800;
    font-size: 0.9rem;
  }

  .room-controls input {
    width: 130px;
  }

  .bookshelf-btn {
    background: linear-gradient(135deg, #f59e0b, #d97706);
    color: white;
  }

  .world-controls {
    display: flex;
    align-items: center;
    gap: 6px;
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 10px;
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .world-label {
    font-size: 1rem;
    line-height: 1;
  }

  .world-select {
    background: #1f2937;
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 10px;
    padding: 4px 8px;
    font-weight: 700;
    font-size: 0.85rem;
    cursor: pointer;
  }

  .save {
    background: #3b82f6;
    color: white;
  }

  button {
    border: 0;
    border-radius: 18px;
    padding: 12px 18px;
    font-weight: 900;
    cursor: pointer;
    background: #f3f5ff;
    color: #101827;
    box-shadow: 0 5px 0 rgba(0, 0, 0, 0.35);
  }

  button:active {
    transform: translateY(3px);
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.35);
  }

  button.active {
    outline: 4px solid #ffd84d;
  }

  .play {
    background: #55e36f;
    font-size: 1.2rem;
  }

  .icon-btn {
    padding: 6px 12px;
    border-radius: 12px;
  }

  .refresh-btn {
    background: #92400e;
    color: #fde68a;
    font-size: 1rem;
  }

  .refresh-btn:hover {
    background: #b45309;
  }


  .quick-ribbon {
    overflow-x: auto;
  }

  .quick-ribbon button {
    display: grid;
    place-items: center;
    min-width: 104px;
  }

  .quick-ribbon span {
    font-size: 2rem;
  }

  .canvas {
    position: relative;
    overflow: hidden;
    background: linear-gradient(#31466d, #1d2d45 55%, #1b2331 55%);
    cursor: grab;
  }

  .canvas:active {
    cursor: grabbing;
  }

  .canvas-inner {
    position: absolute;
    width: 5000px;
    height: 3000px;
    pointer-events: none;
    background:
      linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
    background-size: 32px 32px, 32px 32px;
  }

  .canvas-inner :global(*) {
    pointer-events: auto;
  }

  .horizon {
    position: absolute;
    left: 0;
    right: 0;
    top: 55%;
    height: 4px;
    background: rgba(255, 255, 255, 0.08);
  }

  .stamp {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    padding: 0;
    display: grid;
    place-items: center;
    font-size: 2rem;
    border-radius: 50%;
  }

  .stamp.terrain {
    width: 160px;
    border-radius: 14px;
  }

  .hover-guide {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    opacity: 0.5;
    border: 3px dashed #ffd84d;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 2rem;
    pointer-events: none;
  }

  .hover-guide.terrain {
    width: 160px;
    border-radius: 14px;
  }

  footer {
    justify-content: space-between;
    border-top: 3px solid rgba(255, 255, 255, 0.08);
    border-bottom: 0;
  }

  /* Kid UI custom styles */
  .world-cycle-controls {
    display: flex;
    gap: 8px;
  }

  .cycle-btn {
    font-size: 1.8rem;
    padding: 8px 14px;
    border-radius: 50%;
    background: #1e2937;
    border: 3px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.3);
    cursor: pointer;
    display: grid;
    place-items: center;
    transition: transform 0.1s, background-color 0.2s;
  }

  .cycle-btn:active {
    transform: translateY(2px);
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.3);
  }

  .stamp-select-btn {
    background: #1f2937;
    color: white;
    border: 3px solid #f59e0b;
    border-radius: 18px;
    padding: 6px 12px;
    font-weight: 800;
  }

  .edit-toy-btn {
    background: #eab308;
    color: #0f172a;
    box-shadow: 0 4px 0 #a16207;
  }

  .eraser-btn-top {
    background: #ef4444;
    color: white;
    box-shadow: 0 4px 0 #991b1b;
  }

  .snap-btn-top {
    background: #3b82f6;
    color: white;
    box-shadow: 0 4px 0 #1e40af;
  }

  .toybox-btn-top {
    background: #8b5cf6;
    color: white;
    box-shadow: 0 4px 0 #5b21b6;
  }

  .draw-toy-btn-top {
    background: #ec4899;
    color: white;
    box-shadow: 0 4px 0 #9d174d;
  }

  .play-btn-top {
    background: #22c55e;
    color: white;
    font-size: 1.3rem;
    padding: 10px 24px;
    box-shadow: 0 6px 0 #15803d;
  }

  .parents-toggle-btn {
    background: #4b5563;
    color: white;
    box-shadow: 0 4px 0 #1f2937;
  }

  /* Parents Settings Panel */
  .parents-panel-container {
    background: #0f172a;
    border-bottom: 4px solid #374151;
    padding: 16px 24px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    color: white;
  }

  .parents-panel-header h3 {
    margin: 0;
    font-size: 1.1rem;
    color: #fbbf24;
  }

  .parents-panel-body {
    display: flex;
    gap: 32px;
    flex-wrap: wrap;
  }

  .panel-section {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .panel-section h4 {
    margin: 0;
    font-size: 0.85rem;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .panel-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .panel-row select,
  .panel-row input {
    background: #1f2937;
    color: white;
    border: 1px solid #4b5563;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 0.9rem;
    font-weight: 700;
  }

  .panel-row input {
    width: 140px;
  }

  .spec-labels {
    font-family: monospace;
    font-size: 0.85rem;
    color: #cbd5e1;
    gap: 16px;
  }

  /* Modals overrides/customs */
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.85);
    backdrop-filter: blur(8px);
    display: grid;
    place-items: center;
    z-index: 100;
  }

  .modal {
    background: #1e293b;
    border: 6px solid #fbbf24;
    border-radius: 40px;
    padding: 32px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .close-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 4px 0 #b91c1c;
    transition: transform 0.1s, box-shadow 0.1s;
    align-self: center;
  }

  .close-btn:active {
    transform: translateY(4px);
    box-shadow: 0 0 0 #b91c1c;
  }

  /* Theme selector card designs */
  .theme-modal h2 {
    text-align: center;
    color: #fbbf24;
    font-size: 2.2rem;
    margin: 0;
  }

  .theme-cards {
    display: flex;
    gap: 20px;
    justify-content: center;
    padding: 10px 0;
  }

  .theme-card {
    border: 4px solid #374151;
    border-radius: 24px;
    padding: 24px;
    width: 220px;
    color: white;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3);
    transition: transform 0.2s, border-color 0.2s;
  }

  .theme-card:hover {
    transform: translateY(-8px) scale(1.03);
    border-color: #fbbf24;
  }

  .theme-card .card-icon {
    font-size: 4rem;
    margin-bottom: 12px;
  }

  .theme-card h3 {
    margin: 0 0 8px 0;
    font-size: 1.3rem;
  }

  .theme-card p {
    margin: 0;
    font-size: 0.85rem;
    color: #cbd5e1;
    line-height: 1.4;
  }

  .theme-card.space {
    background: linear-gradient(135deg, #1e1b4b, #311042);
  }

  .theme-card.candy {
    background: linear-gradient(135deg, #be185d, #db2777);
  }

  .theme-card.jungle {
    background: linear-gradient(135deg, #065f46, #047857);
  }

  /* Embedded Play Modal */
  .play-modal {
    width: min(850px, 90vw);
    max-height: 90vh;
  }

  .play-modal header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .play-modal h2 {
    margin: 0;
    font-size: 1.8rem;
    color: #22c55e;
  }

  .game-container {
    width: 100%;
    aspect-ratio: 16 / 9;
    background: black;
    border-radius: 20px;
    overflow: hidden;
    border: 4px solid #4b5563;
  }

  .game-iframe {
    width: 100%;
    height: 100%;
    border: 0;
  }

  .play-options {
    display: flex;
    justify-content: center;
    margin-top: 10px;
  }

  .window-btn {
    border: 0;
    border-radius: 18px;
    padding: 12px 24px;
    font-weight: 900;
    cursor: pointer;
    background: #3b82f6;
    color: white;
    box-shadow: 0 4px 0 #1d4ed8;
  }

  .window-btn:active {
    transform: translateY(2px);
    box-shadow: 0 1px 0 #1d4ed8;
  }

  /* Click Animation Class */
  :global(.bounce-click) {
    animation: bounce-pop 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  @keyframes bounce-pop {
    0% { transform: scale(1); }
    30% { transform: scale(1.15) rotate(-3deg); }
    50% { transform: scale(0.92) rotate(2deg); }
    80% { transform: scale(1.05) rotate(-1deg); }
    100% { transform: scale(1) rotate(0deg); }
  }

  /* Hover Animation for Ribbon buttons */
  .ribbon-btn {
    display: grid;
    place-items: center;
    min-width: 104px;
    transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  .ribbon-btn:hover {
    transform: translateY(-5px) scale(1.05);
  }

  .ribbon-btn:hover :global(span) {
    animation: wobble 0.5s ease-in-out infinite alternate;
  }

  @keyframes wobble {
    0% { transform: rotate(-5deg); }
    100% { transform: rotate(5deg); }
  }

  .undo-btn-top {
    background: #f87171;
    color: white;
    box-shadow: 0 5px 0 #b91c1c;
  }
  .undo-btn-top:active {
    transform: translateY(3px);
    box-shadow: 0 2px 0 #b91c1c;
  }
  .undo-btn-top:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .redo-btn-top {
    background: #60a5fa;
    color: white;
    box-shadow: 0 5px 0 #1d4ed8;
  }
  .redo-btn-top:active {
    transform: translateY(3px);
    box-shadow: 0 2px 0 #1d4ed8;
  }
  .redo-btn-top:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .theme-card.ice {
    background: linear-gradient(135deg, #0284c7, #38bdf8);
  }

  .theme-card.volcano {
    background: linear-gradient(135deg, #7c2d12, #ea580c);
  }

  .play-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
  }

  .play-controls-overlay {
    display: flex;
    gap: 12px;
  }

  .play-control-btn {
    border: 0;
    border-radius: 20px;
    padding: 10px 20px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    color: white;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .play-control-btn:active {
    transform: translateY(3px);
  }

  .play-control-btn.pause-btn {
    background: #eab308;
    box-shadow: 0 5px 0 #ca8a04;
  }
  .play-control-btn.pause-btn:active {
    box-shadow: 0 2px 0 #ca8a04;
  }

  .play-control-btn.restart-btn {
    background: #3b82f6;
    box-shadow: 0 5px 0 #1d4ed8;
  }
  .play-control-btn.restart-btn:active {
    box-shadow: 0 2px 0 #1d4ed8;
  }

  .play-control-btn.stop-btn {
    background: #ef4444;
    box-shadow: 0 5px 0 #b91c1c;
  }
  .play-control-btn.stop-btn:active {
    box-shadow: 0 2px 0 #b91c1c;
  }

  /* Customizer Inspector Panel styling */
  .customizer-panel {
    position: fixed;
    top: 96px;
    right: 24px;
    width: 320px;
    background: rgba(30, 41, 59, 0.95);
    backdrop-filter: blur(12px);
    border: 5px solid #fbbf24;
    border-radius: 28px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
    display: flex;
    flex-direction: column;
    z-index: 90;
    color: white;
    padding: 20px;
    gap: 16px;
    max-height: calc(100vh - 140px);
    overflow-y: auto;
  }

  .customizer-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .customizer-header h3 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 900;
    color: #fbbf24;
  }

  .close-customizer-btn {
    border: 0;
    background: transparent;
    color: #94a3b8;
    font-size: 1.5rem;
    font-weight: 900;
    cursor: pointer;
  }

  .toy-info {
    display: flex;
    align-items: center;
    gap: 12px;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 16px;
  }

  .toy-icon {
    font-size: 2rem;
  }

  .toy-name {
    font-weight: 900;
    font-size: 1.1rem;
  }

  .customizer-body {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .option-group.flex-row {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 16px;
  }

  .option-label {
    display: flex;
    justify-content: space-between;
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-slider {
    width: 100%;
    accent-color: #fbbf24;
    cursor: pointer;
  }

  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-select {
    width: 100%;
    background: #0f172a;
    color: white;
    font-weight: 800;
    padding: 10px;
    border-radius: 12px;
    border: 2px solid #334155;
    cursor: pointer;
  }

  .option-toggle {
    width: 24px;
    height: 24px;
    accent-color: #fbbf24;
    cursor: pointer;
  }

  .customizer-footer {
    margin-top: 8px;
  }

  .customizer-delete-btn {
    width: 100%;
    border: 0;
    background: #ef4444;
    color: white;
    font-weight: 900;
    padding: 14px;
    border-radius: 18px;
    cursor: pointer;
    box-shadow: 0 4px 0 #b91c1c;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .customizer-delete-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #b91c1c;
  }
</style>
