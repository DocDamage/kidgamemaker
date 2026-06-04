<script lang="ts">
  import { onDestroy, onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import CanvasWorkspace from './CanvasWorkspace.svelte';
  import EditorModals from './EditorModals.svelte';
  import ParentsPanel from './ParentsPanel.svelte';
  import EditorStatusBar from './EditorStatusBar.svelte';
  import RoomMapView from './RoomMapView.svelte';
  import RulesEditorView from './RulesEditorView.svelte';
  import SelectedEntityCustomizer from './SelectedEntityCustomizer.svelte';
  import ToyRibbon from './ToyRibbon.svelte';
  import {
    favoriteInventoryItems,
    findInventoryAsset,
    firstInventoryAsset,
    quickInventoryItems
  } from './lib/assetInventory';
  import {
    calculateLevelLengthLabel,
    generateRoomThumbnail,
    getCanvasCoords as toCanvasCoords,
    getSnappedPosition as snapCanvasPosition,
    getStoredThumbnail
  } from './lib/canvasView';
  import { playUiSound as playEditorUiSound } from './lib/editorAudio';
  import {
    createLevelHistory,
    pushLevelHistory,
    restoreLevelHistory,
    type LevelHistoryState
  } from './lib/editorHistory';
  import {
    DIFFICULTY_MODES,
    createDefaultPlacedEntities,
    createDefaultThemeDraft,
    createDefaultWorldSettings
  } from './lib/editorDefaults';
  import { ensurePlacedEntityDefaults } from './lib/entityDefaults';
  import { muteGameIframe, setGlobalGameLevel, setGlobalGameMuted } from './lib/playbackControls';
  import { addRoomRule, deleteRoomRule } from './lib/roomRules';
  import {
    deleteSavedRoom,
    getSavedCalmMode,
    getSavedDifficulty,
    hasTauriHost,
    listSavedRooms,
    loadAssetInventory,
    loadLegacyGameState,
    loadSavedRoom,
    normalizeLoadedWorldSettings,
    saveEditorRoom,
    saveRoomPayload,
    type DifficultyMode
  } from './lib/roomPersistence';
  import {
    buildNamedThemeRoomId,
    buildThemeRoomId,
    buildThemeStarterEntities,
    buildThemeWorldSettings,
    buildSurpriseRoom,
    randomRoomAdjective,
    randomRoomNoun,
    remixPlacedRoom,
    type ThemeName
  } from './lib/themeRooms';
  import {
    eraseEntity,
    fallbackInventory,
    snapPosition,
    stampEntity,
    toRoomPayload,
    type AssetInventory,
    type PlacedEntity,
    type ToyboxAsset,
    type WorldSettings
  } from './lib/canvasState';
  import EditorTopbar from './EditorTopbar.svelte';

  let spriteEditorOpen = false;
  let editingAssetId = '';
  let editingCategory = 'decorations';

  // Kid friendly UI toggles
  let parentsPanelOpen = false;
  let themeSelectorOpen = false;
  let playModalOpen = false;
  let isMuted = false;
  let selectedPlacedEntity: PlacedEntity | null = null;

  let showMapView = false;
  let showRulesEditor = false;

  function toggleMapView() {
    showMapView = !showMapView;
    if (showMapView) {
      showRulesEditor = false;
      selectedPlacedEntity = null;
    }
    playUiSound('pop');
  }

  function toggleRulesEditor() {
    showRulesEditor = !showRulesEditor;
    if (showRulesEditor) {
      showMapView = false;
      selectedPlacedEntity = null;
    }
    playUiSound('pop');
  }

  let beatComposerOpen = false;

  function selectEntity(item: PlacedEntity) {
    ensurePlacedEntityDefaults(item);
    selectedPlacedEntity = item;
    playUiSound('chime');
  }

  function openBeatComposer() {
    beatComposerOpen = true;
    playUiSound('chime');
  }

  function saveBeatSequence(sequence: number[][]) {
    worldSettings.custom_bgm_sequence = sequence;
    worldSettings.theme = 'custom';
    saveCurrentRoom();
    playUiSound('chime');
    beatComposerOpen = false;
  }

  onDestroy(() => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      longPressTimer = null;
    }
  });

  function addNewRule() {
    worldSettings.room_rules = addRoomRule(worldSettings.room_rules);
    saveCurrentRoom();
    playUiSound('pop');
  }

  function deleteRule(idx: number) {
    worldSettings.room_rules = deleteRoomRule(worldSettings.room_rules, idx);
    saveCurrentRoom();
    playUiSound('squeak');
  }

  function toggleMute() {
    isMuted = !isMuted;
    setGlobalGameMuted(isMuted);

    const result = muteGameIframe(isMuted);
    if (!result.ok && result.error !== 'Game iframe is not available.') {
      console.error("Failed to mute game inside iframe:", result.error);
    }
    if (!isMuted) {
      playUiSound('pop');
    }
  }

  function playUiSound(type: 'pop' | 'squeak' | 'chime') {
    if (isMuted) return;
    playEditorUiSound(type);
  }

  function deleteSelectedEntity(instanceId: string) {
    placed = eraseEntity(placed, instanceId);
    selectedPlacedEntity = null;
    playUiSound('squeak');
    saveCurrentRoom();
  }

  function setDifficultyMode(value: string) {
    if (!isDifficultyMode(value)) return;
    difficultyMode = value;
    saveCurrentRoom();
  }

  function setCalmMode(value: boolean) {
    calmMode = value;
    saveCurrentRoom();
  }

  function isDifficultyMode(value: string): value is DifficultyMode {
    return difficultyModes.some((mode) => mode === value);
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


  let placed: PlacedEntity[] = createDefaultPlacedEntities();

  let inventory: AssetInventory = fallbackInventory;
  let activeAsset: ToyboxAsset = fallbackInventory.terrain[0];
  let eraserMode = false;
  let favorites: string[] = [];
  let toyboxOpen = false;
  let bookshelfOpen = false;
  let snapEnabled = true;

  let status = 'Ready';

  let worldSettings: WorldSettings = createDefaultWorldSettings();

  // --- Feature: Difficulty Modes & Calm Mode ---
  let difficultyMode: DifficultyMode = 'normal';
  let calmMode = false;
  const difficultyModes: DifficultyMode[] = DIFFICULTY_MODES;

  // --- Feature: Kid-friendly Room Naming ---
  let themeDraft = createDefaultThemeDraft();

  // --- Feature: Drag-to-Reposition ---
  let draggingEntity: PlacedEntity | null = null;
  let dragOffset = { x: 0, y: 0 };
  let longPressTimer: ReturnType<typeof setTimeout> | null = null;
  let longPressTriggered = false;

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

  $: quickRibbon = quickInventoryItems(inventory);
  $: favoritesItems = favoriteInventoryItems(inventory, favorites);
  $: if (favorites) {
    try {
      localStorage.setItem('toybox_favorites', JSON.stringify(favorites));
    } catch (_) {}
  }

  $: levelLengthLabel = calculateLevelLengthLabel(placed);


  // Level editor undo/redo history stack
  let levelHistoryState: LevelHistoryState = { history: [], index: -1 };
  $: levelHistory = levelHistoryState.history;
  $: levelHistoryIndex = levelHistoryState.index;

  function saveLevelState() {
    levelHistoryState = pushLevelHistory(levelHistoryState, placed);
  }

  function undoLevel() {
    const restored = restoreLevelHistory(levelHistoryState, 'undo');
    if (!restored) return;
    levelHistoryState = restored.state;
    placed = restored.placed;
    saveCurrentRoom();
    playUiSound('squeak');
  }

  function redoLevel() {
    const restored = restoreLevelHistory(levelHistoryState, 'redo');
    if (!restored) return;
    levelHistoryState = restored.state;
    placed = restored.placed;
    saveCurrentRoom();
    playUiSound('pop');
  }

  onMount(async () => {
    try {
      const stored = localStorage.getItem('toybox_favorites');
      if (stored) {
        favorites = JSON.parse(stored);
      }
    } catch (_) {}

    if (hasTauriHost()) {
      try {
        inventory = await loadAssetInventory();
        activeAsset = firstInventoryAsset(inventory) ?? activeAsset;
        status = 'Loaded toybox assets.';

      } catch (error) {
        status = `Using fallback toybox: ${error}`;
      }
    } else {
      inventory = fallbackInventory;
      activeAsset = inventory.terrain?.[0] ?? activeAsset;
      status = 'Browser preview mode: using fallback toybox.';
    }

    await loadRoomList();
    
    if (rooms.includes(activeRoomId)) {
      await loadSelectedRoom(activeRoomId);
    } else {
      try {
        const savedState = await loadLegacyGameState();
        if (savedState && Array.isArray(savedState.entities)) {
          placed = savedState.entities;
          status += ' Restored saved game state.';
        }
      } catch (error) {
        status += ' No saved game state found, starting fresh.';
      }
      levelHistoryState = createLevelHistory(placed);
    }

    // Auto-save every 60 seconds
    const saveId = setInterval(() => {
      if (placed.length > 0) saveCurrentRoom();
    }, 60_000);

    // Refresh Toybox inventory every 5 seconds (picks up inbox-ingested assets)
    const refreshId = setInterval(async () => {
      if (!hasTauriHost()) return;
      try {
        inventory = await loadAssetInventory();
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
      rooms = await listSavedRooms(activeRoomId);
    } catch (err) {
      console.error('Failed to list rooms:', err);
    }
  }

  function getCanvasCoords(clientX: number, clientY: number, rect: DOMRect) {
    return toCanvasCoords(clientX, clientY, rect, offsetX, offsetY, zoom);
  }

  function getSnappedPosition(rawCoords: { x: number; y: number }, asset: ToyboxAsset): { x: number; y: number } {
    return snapCanvasPosition(rawCoords, asset, placed, snapEnabled);
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
    } else if (event.button === 0) {
      handleStampLongPressEnd();
    }
  }

  function handleCanvasLeave() {
    isHovering = false;
    isDrawing = false;
    handleStampLongPressEnd();
  }

  function handlePlacedStampClick(item: PlacedEntity) {
    if (longPressTriggered) {
      longPressTriggered = false;
      return;
    }

    if (eraserMode) {
      placed = eraseEntity(placed, item.instance_id);
      playUiSound('squeak');
    } else {
      selectEntity(item);
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

      const targetPayload = toRoomPayload(
        [returnPortal, floorUnderPortal],
        createDefaultWorldSettings(),
        'demo_project',
        targetRoomId
      );

      await saveRoomPayload(targetRoomId, targetPayload);
      await loadRoomList();
      status = `Placed portal linking to auto-created room ${targetRoomId}!`;
    } catch (err) {
      status = `Failed to auto-create target room: ${err}`;
    }
  }

  async function saveCurrentRoom() {
    if (!hasTauriHost()) {
      status = `Browser preview mode: ${activeRoomId} is not persisted.`;
      return;
    }

    status = `Saving room ${activeRoomId}...`;
    try {
      status = await saveEditorRoom({
        roomId: activeRoomId,
        placed,
        worldSettings,
        difficultyMode,
        calmMode
      });
      await loadRoomList();
      generateThumbnail(activeRoomId);
    } catch (error) {
      status = `Save failed: ${String(error)}`;
    }
  }

  async function deleteRoom(roomId: string) {
    if (!confirm(`Delete room "${roomId}"? This cannot be undone.`)) return;
    try {
      await deleteSavedRoom(roomId);
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
    if (!hasTauriHost()) {
      activeRoomId = roomId;
      status = `Browser preview mode: ${roomId} is not loaded from disk.`;
      return;
    }

    status = `Loading room ${roomId}...`;
    try {
      const savedState = await loadSavedRoom(roomId);
      if (savedState && Array.isArray(savedState.entities)) {
        placed = savedState.entities;
        activeRoomId = roomId;
        worldSettings = normalizeLoadedWorldSettings(savedState.world_settings);
        difficultyMode = getSavedDifficulty(savedState.world_settings);
        calmMode = getSavedCalmMode(savedState.world_settings);
        status = `Loaded room: ${roomId}`;
        levelHistoryState = createLevelHistory(placed);
      }
    } catch (error) {
      status = `Failed to load room ${roomId}: ${error}`;
    }
  }

  async function refreshInventory() {
    try {
      inventory = await loadAssetInventory();
      status = 'Toybox refreshed.';
    } catch (error) {
      status = `Refresh failed: ${error}`;
    }
  }

  function generateThumbnail(roomId: string) {
    generateRoomThumbnail(roomId, placed, worldSettings);
  }

  function getThumbnail(roomId: string): string | null {
    return getStoredThumbnail(roomId);
  }

  function createNewRoom() {
    themeDraft = {
      theme: 'space',
      adjective: randomRoomAdjective(),
      noun: randomRoomNoun('space')
    };
    openThemeSelector();
  }

  function openThemeSelector() {
    themeSelectorOpen = true;
  }

  async function applyNameAndTheme(theme: ThemeName, adjective: string, noun: string) {
    const customId = buildNamedThemeRoomId(theme, adjective, noun);
    await applyTheme(theme, customId);
  }

  async function applyTheme(themeName: ThemeName, customRoomId?: string) {
    themeSelectorOpen = false;
    const newId = customRoomId || buildThemeRoomId(themeName);
    activeRoomId = newId;

    worldSettings = buildThemeWorldSettings(themeName);
    placed = buildThemeStarterEntities(findAsset);
    levelHistoryState = createLevelHistory(placed);

    status = `Created new ${themeName} room: ${newId}`;
    playUiSound('chime');

    await saveCurrentRoom();
  }

  async function play() {
    status = 'Saving room level...';
    try {
      await saveCurrentRoom();

      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      setGlobalGameLevel(JSON.stringify(payload));
      setGlobalGameMuted(isMuted);

      status = 'Preparing WebGL game...';
      try {
        await invoke('build_web_runner');
        playModalOpen = true;
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

  async function shareGame() {
    status = 'Saving and packaging Toybox...';
    try {
      await saveCurrentRoom();
      const path = await invoke<string>('package_game_project');
      status = `Toybox packaged successfully! Saved to: ${path}`;
      playUiSound('chime');
    } catch (error) {
      status = `Packaging failed: ${String(error)}`;
    }
  }

  function selectAsset(asset: ToyboxAsset) {
    activeAsset = asset;
    eraserMode = false;
    toyboxOpen = false;
  }

  function findAsset(assetId: string): ToyboxAsset | undefined {
    return findInventoryAsset(inventory, assetId);
  }

  // ── Feature: 🎲 Surprise Me! Level Generator ──────────────────────────────
  async function surpriseMe() {
    const generated = buildSurpriseRoom(findAsset, difficultyMode, calmMode);
    activeRoomId = generated.roomId;
    worldSettings = generated.worldSettings;
    placed = generated.placed;
    levelHistoryState = createLevelHistory(placed);

    status = `🎲 Surprise! Created ${generated.theme} adventure with ${generated.platformCount} platforms!`;
    playUiSound('chime');
    await saveCurrentRoom();
  }

  async function remixCurrentRoom() {
    if (placed.length === 0) return;
    const remixed = remixPlacedRoom(placed, worldSettings);
    placed = remixed.placed;
    worldSettings = remixed.worldSettings;

    saveLevelState();
    await saveCurrentRoom();
    status = "🔀 Remixed! Room items shuffled and weather cycled!";
    playUiSound('chime');
  }

  // ── Feature: Drag-to-Reposition (long-press to grab a stamp) ──────────────
  function handleStampLongPressStart(event: MouseEvent, item: PlacedEntity) {
    if (eraserMode) return;
    longPressTriggered = false;
    longPressTimer = setTimeout(() => {
      longPressTriggered = true;
      draggingEntity = item;
      const canvasEl = event.currentTarget as HTMLElement;
      const canvasRect = canvasEl.closest('.canvas')?.getBoundingClientRect();
      if (canvasRect) {
        dragOffset = {
          x: item.position.x - ((event.clientX - canvasRect.left - offsetX) / zoom),
          y: item.position.y - ((event.clientY - canvasRect.top - offsetY) / zoom)
        };
      }
      playUiSound('pop');
    }, 400); // 400ms long press
  }

  function handleStampLongPressEnd() {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      longPressTimer = null;
    }
    if (draggingEntity) {
      draggingEntity = null;
      saveLevelState();
      saveCurrentRoom();
      playUiSound('chime');
    }
  }

  function handleDragMove(event: MouseEvent) {
    if (!draggingEntity) return;
    const canvasEl = (event.currentTarget as HTMLElement);
    const canvasRect = canvasEl.getBoundingClientRect();
    const rawX = (event.clientX - canvasRect.left - offsetX) / zoom + dragOffset.x;
    const rawY = (event.clientY - canvasRect.top - offsetY) / zoom + dragOffset.y;

    // Snap position
    if (snapEnabled) {
      draggingEntity.position.x = Math.round(rawX / 8) * 8;
      draggingEntity.position.y = Math.round(rawY / 8) * 8;
    } else {
      draggingEntity.position.x = rawX;
      draggingEntity.position.y = rawY;
    }
    placed = [...placed]; // trigger reactivity
  }
</script>

<main class="app-shell">
  <EditorTopbar
    {worldSettings}
    {activeAsset}
    {isMuted}
    {showMapView}
    {showRulesEditor}
    {eraserMode}
    {snapEnabled}
    canUndo={levelHistoryIndex > 0}
    canRedo={levelHistoryIndex < levelHistory.length - 1}
    {parentsPanelOpen}
    on:cycleTime={cycleTime}
    on:cycleWeather={cycleWeather}
    on:toggleMute={toggleMute}
    on:openBeatComposer={openBeatComposer}
    on:toggleMapView={toggleMapView}
    on:toggleRulesEditor={toggleRulesEditor}
    on:selectStamp={() => eraserMode = false}
    on:editActiveAsset={editActiveAsset}
    on:toggleEraser={() => eraserMode = !eraserMode}
    on:toggleSnap={() => snapEnabled = !snapEnabled}
    on:undo={undoLevel}
    on:redo={redoLevel}
    on:openToybox={() => toyboxOpen = true}
    on:drawToy={openCustomAssetCanvas}
    on:surprise={surpriseMe}
    on:remix={remixCurrentRoom}
    on:play={play}
    on:toggleParents={() => parentsPanelOpen = !parentsPanelOpen}
  />

  {#if parentsPanelOpen}
    <ParentsPanel
      {rooms}
      {activeRoomId}
      {activeAsset}
      {difficultyMode}
      {calmMode}
      on:browseRooms={() => bookshelfOpen = true}
      on:activeRoomIdChange={(event) => activeRoomId = event.detail}
      on:loadRoom={(event) => loadSelectedRoom(event.detail)}
      on:createNewRoom={createNewRoom}
      on:saveRoom={saveCurrentRoom}
      on:exportGame={exportGame}
      on:shareGame={shareGame}
      on:refreshInventory={refreshInventory}
      on:difficultyChange={(event) => setDifficultyMode(event.detail)}
      on:calmModeChange={(event) => setCalmMode(event.detail)}
    />
  {/if}

  {#if showMapView}
    <RoomMapView
      {rooms}
      {activeRoomId}
      {placed}
      on:loadRoom={(event) => loadSelectedRoom(event.detail)}
      on:saveRoom={saveCurrentRoom}
    />
  {:else if showRulesEditor}
    <RulesEditorView
      {worldSettings}
      {placed}
      {findAsset}
      on:addRule={addNewRule}
      on:deleteRule={(event) => deleteRule(event.detail)}
      on:saveRoom={saveCurrentRoom}
    />
  {:else}
    <ToyRibbon
      favorites={favoritesItems}
      quickItems={quickRibbon}
      {activeAsset}
      {eraserMode}
      on:select={(event) => selectAsset(event.detail)}
    />

    <CanvasWorkspace
      {worldSettings}
      {placed}
      {activeAsset}
      {eraserMode}
      {offsetX}
      {offsetY}
      {zoom}
      {isHovering}
      {hoverPos}
      {draggingEntity}
      {findAsset}
      {startDrawing}
      {stopDrawing}
      {handleMouseMove}
      {handleDragMove}
      {handleWheel}
      {handleMouseDown}
      {handleMouseUp}
      {handleCanvasLeave}
      {handleStampLongPressStart}
      {handleStampLongPressEnd}
      {handlePlacedStampClick}
    />
  {/if}

  <EditorStatusBar
    {status}
    {levelLengthLabel}
    objectCount={placed.length}
    {zoom}
  />

  <EditorModals
    {toyboxOpen}
    {bookshelfOpen}
    {spriteEditorOpen}
    {themeSelectorOpen}
    {beatComposerOpen}
    {playModalOpen}
    {inventory}
    {isMuted}
    bind:favorites
    {rooms}
    {activeRoomId}
    {getThumbnail}
    {editingAssetId}
    {editingCategory}
    {themeDraft}
    customBgmSequence={worldSettings.custom_bgm_sequence}
    on:selectToyboxItem={(event) => selectAsset(event.detail)}
    on:closeToybox={() => toyboxOpen = false}
    on:selectRoom={(event) => { loadSelectedRoom(event.detail); bookshelfOpen = false; }}
    on:newRoom={() => { createNewRoom(); bookshelfOpen = false; }}
    on:deleteRoom={(event) => deleteRoom(event.detail)}
    on:closeBookshelf={() => bookshelfOpen = false}
    on:closeSpriteEditor={() => spriteEditorOpen = false}
    on:drawingSaved={handleDrawingSaved}
    on:createThemeRoom={(event) => applyNameAndTheme(event.detail.theme, event.detail.adjective, event.detail.noun)}
    on:closeThemeSelector={() => themeSelectorOpen = false}
    on:previewBeat={() => playUiSound('pop')}
    on:saveBeat={(event) => saveBeatSequence(event.detail)}
    on:closeBeatComposer={() => beatComposerOpen = false}
    on:closePlayModal={() => playModalOpen = false}
    on:playStatus={(event) => status = event.detail}
    on:toggleMute={toggleMute}
    on:restartSound={() => playUiSound('chime')}
    on:launchWindow={() => { playModalOpen = false; launchNativeWindow(); }}
  />

  {#if selectedPlacedEntity}
    <SelectedEntityCustomizer
      entity={selectedPlacedEntity}
      {rooms}
      {activeRoomId}
      {placed}
      {findAsset}
      on:close={() => selectedPlacedEntity = null}
      on:deleteToy={(event) => deleteSelectedEntity(event.detail)}
      on:saveRoom={saveCurrentRoom}
    />
  {/if}
</main>

<style>
  .app-shell {
    height: 100vh;
    display: grid;
    grid-template-rows: auto auto 1fr auto;
  }

</style>
