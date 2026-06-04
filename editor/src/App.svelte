<script lang="ts">
  import { onMount } from 'svelte';
  import {
    runWebGLPlay,
    runNativePlay,
    runExportGame,
    runShareGame
  } from './lib/editorLauncher';
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
    getAgeModeDefaults,
    toRoomPayload,
    type AgeMode,
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

  function applyAgeModeChange(patch: Partial<WorldSettings>) {
    worldSettings = { ...worldSettings, ...patch };
    if (patch.difficulty !== undefined) {
      const dm = patch.difficulty as DifficultyMode;
      if (difficultyModes.includes(dm)) difficultyMode = dm;
    }
    if (patch.calm_mode !== undefined) {
      calmMode = patch.calm_mode;
    }
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

  // Multi-room state
  let rooms: string[] = ['test_chamber_01'];
  let activeRoomId = 'test_chamber_01';

  // Viewport Zoom state
  let zoom = 1.0;

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
    const res = await runWebGLPlay(placed, worldSettings, activeRoomId, isMuted, saveCurrentRoom, playUiSound);
    if (res.modalOpen !== undefined) playModalOpen = res.modalOpen;
    status = res.status;
  }

  async function launchNativeWindow() {
    status = await runNativePlay(placed, worldSettings, activeRoomId, playUiSound);
  }

  async function exportGame() {
    status = 'Saving and exporting...';
    status = await runExportGame(placed, saveCurrentRoom);
  }

  async function shareGame() {
    status = 'Saving and packaging Toybox...';
    status = await runShareGame(saveCurrentRoom, playUiSound);
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
      {worldSettings}
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
      on:ageModeChange={(event) => applyAgeModeChange(event.detail)}
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
      bind:placed
      {activeAsset}
      {eraserMode}
      bind:zoom
      {snapEnabled}
      {rooms}
      {activeRoomId}
      {findAsset}
      on:change={() => { saveLevelState(); saveCurrentRoom(); }}
      on:selectEntity={(event) => {
        if (event.detail) {
          selectEntity(event.detail);
        } else {
          selectedPlacedEntity = null;
        }
      }}
      on:playSound={(event) => playUiSound(event.detail)}
      on:status={(event) => status = event.detail}
      on:portalCreated={() => loadRoomList()}
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
