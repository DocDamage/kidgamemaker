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
  import { muteGameIframe, setGlobalGameLevel, setGlobalGameMuted, liveUpdateGameIframe } from './lib/playbackControls';
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
    buildSurpriseWorld,
    randomRoomAdjective,
    randomRoomNoun,
    remixPlacedRoom,
    type ThemeName
  } from './lib/themeRooms';
  import { invoke } from '@tauri-apps/api/core';
  import qrcode from './lib/qrcode.min.js';
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
  let scrapbookOpen = false;

  let activeCelebration: { name: string; emoji: string } | null = null;
  let confettiParticles: Array<{ x: number; y: number; color: string; speedX: number; speedY: number; size: number; angle: number; spin: number }> = [];

  const STICKER_DETAILS: Record<string, { name: string; emoji: string }> = {
    jungle_explorer: { name: 'Jungle Explorer', emoji: '🌴' },
    lava_runner: { name: 'Lava Runner', emoji: '🌋' },
    monster_masher: { name: 'Monster Masher', emoji: '👾' },
    coop_champ: { name: 'Co-Op Champ', emoji: '👥' },
    temporal_master: { name: 'Temporal Master', emoji: '⏳' },
    sound_designer: { name: 'Sound Designer', emoji: '🎹' },
    world_architect: { name: 'World Architect', emoji: '🎲' }
  };

  function unlockAchievement(id: string) {
    let scrapbook: string[] = [];
    try {
      const stored = localStorage.getItem('scrapbook_stickers');
      if (stored) scrapbook = JSON.parse(stored);
    } catch (_) {}
    if (!scrapbook.includes(id)) {
      scrapbook.push(id);
      try {
        localStorage.setItem('scrapbook_stickers', JSON.stringify(scrapbook));
      } catch (_) {}
      triggerStickerCelebration(id);
    }
  }

  function triggerStickerCelebration(id: string) {
    const details = STICKER_DETAILS[id];
    if (details) {
      activeCelebration = details;
      playUiSound('chime');
      createConfettiBurst();
      setTimeout(() => {
        activeCelebration = null;
      }, 3500);
    }
  }

  function createConfettiBurst() {
    const colors = ['#f43f5e', '#a855f7', '#3b82f6', '#10b981', '#fbbf24', '#f97316'];
    const particles = [];
    for (let i = 0; i < 80; i++) {
      particles.push({
        x: window.innerWidth / 2,
        y: window.innerHeight / 2 - 100,
        color: colors[Math.floor(Math.random() * colors.length)],
        speedX: (Math.random() - 0.5) * 15,
        speedY: (Math.random() - 0.7) * 20 - 5,
        size: Math.random() * 8 + 6,
        angle: Math.random() * 360,
        spin: (Math.random() - 0.5) * 10
      });
    }
    confettiParticles = particles;
    animateConfetti();
  }

  let animationFrameId: number;
  function animateConfetti() {
    if (confettiParticles.length === 0) return;
    confettiParticles = confettiParticles.map(p => {
      return {
        ...p,
        x: p.x + p.speedX,
        y: p.y + p.speedY,
        speedY: p.speedY + 0.4,
        speedX: p.speedX * 0.98,
        angle: p.angle + p.spin
      };
    }).filter(p => p.y < window.innerHeight && p.x > 0 && p.x < window.innerWidth);

    if (confettiParticles.length > 0) {
      animationFrameId = requestAnimationFrame(animateConfetti);
    }
  }

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

  function saveBeatSequence(detail: { sequence: number[][]; instruments: string[] }) {
    worldSettings.custom_bgm_sequence = detail.sequence;
    worldSettings.custom_bgm_instruments = detail.instruments;
    worldSettings.theme = 'custom';
    saveCurrentRoom();
    playUiSound('chime');
    beatComposerOpen = false;
    unlockAchievement('sound_designer');
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

  // --- Daily Discovery & Weekly Challenges ---
  let unlockedStamps: string[] = [];
  try {
    const stored = localStorage.getItem('toybox_unlocked_stamps');
    if (stored) unlockedStamps = JSON.parse(stored);
  } catch (_) {}

  let weeklyChallengeCompleted = localStorage.getItem('weekly_challenge_completed') === 'true';

  let sessionStampsCount = 0;
  let lastPlacedLength = 0;
  let creationDurationSeconds = 0;

  // Track daily progress reactively
  $: {
    const fireCount = placed.filter(e => e.asset_id === 'chemistry_fire').length;
    const iceCount = placed.filter(e => e.asset_id === 'chemistry_ice').length;
    const starCount = placed.filter(e => e.asset_id === 'star_piece').length;

    if (fireCount >= 3 && !unlockedStamps.includes('effects_fire')) {
      unlockStamp('effects_fire', 'Fire Effect 🔥');
    }
    if (iceCount >= 3 && !unlockedStamps.includes('effects_snow')) {
      unlockStamp('effects_snow', 'Snow Flurry ❄️');
    }
    if (starCount >= 3 && !unlockedStamps.includes('effects_sparkles')) {
      unlockStamp('effects_sparkles', 'Magic Sparkles ✨');
    }

    const hasSword = placed.some(e => e.asset_id === 'weapon_sword');
    const hasCactus = placed.some(e => e.asset_id === 'cactus_hazard');
    const hasJelly = placed.some(e => e.asset_id === 'jelly_trampoline');

    if (hasSword && hasCactus && hasJelly && !weeklyChallengeCompleted) {
      weeklyChallengeCompleted = true;
      localStorage.setItem('weekly_challenge_completed', 'true');
      playUiSound('chime');
      alert("🏆 Weekly Challenge Completed!\nAmazing job using the Sword, Cactus, and Bouncy Jelly in your design! You are a master creator!");
    }

    // Achievements/Stickers updates
    const enemyCount = placed.filter(e => e.category === 'enemies').length;
    if (enemyCount >= 3) {
      unlockAchievement('monster_masher');
    }

    const playerCount = placed.filter(e => e.category === 'heroes' && e.type === 'player').length;
    if (playerCount >= 2) {
      unlockAchievement('coop_champ');
    }

    if (worldSettings.theme === 'jungle') {
      unlockAchievement('jungle_explorer');
    } else if (worldSettings.theme === 'volcano') {
      unlockAchievement('lava_runner');
    }

    // Session placed stamps count
    if (placed.length > lastPlacedLength) {
      sessionStampsCount += (placed.length - lastPlacedLength);
    }
    lastPlacedLength = placed.length;
  }

  function unlockStamp(id: string, name: string) {
    unlockedStamps = [...unlockedStamps, id];
    localStorage.setItem('toybox_unlocked_stamps', JSON.stringify(unlockedStamps));
    playUiSound('chime');
    alert(`🎉 Daily Discovery Unlocked!\nYou created using your toys and unlocked: ${name}!`);
  }


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

  onMount(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data && event.data.type === 'unlock_sticker') {
        unlockAchievement(event.data.id);
      }
    };
    window.addEventListener('message', handleMessage);

    (async () => {
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
    })();

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

    // Creation duration timer & time limit checker
    const timerId = setInterval(() => {
      creationDurationSeconds += 1;
      const limitMins = Number(localStorage.getItem('parent_screen_time_limit') || '30');
      if (creationDurationSeconds === limitMins * 60) {
        alert(`⏰ Screen Time Alert: You have been creating for ${limitMins} minutes! Time to take a little break!`);
      }
    }, 1000);

    // Return cleanup so intervals are cancelled on unmount / hot-reload
    return () => {
      clearInterval(saveId);
      clearInterval(refreshId);
      clearInterval(timerId);
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

      // Live hot-update WebGL play session
      if (playModalOpen) {
        const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
        payload.world_settings = {
          ...payload.world_settings,
          difficulty: difficultyMode,
          calm_mode: calmMode
        };
        liveUpdateGameIframe(JSON.stringify(payload));
      }
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

  let shareModalOpen = false;
  let shareUrl = '';
  let qrSvgString = '';

  async function shareGame() {
    const peerBlockingEnabled = localStorage.getItem('parent_peer_blocking') === 'true';
    if (peerBlockingEnabled) {
      alert("🔏 Sharing is blocked by Parent controls! Unblock it in the Parents settings panel.");
      return;
    }

    status = 'Saving and packaging Toybox...';
    try {
      await saveCurrentRoom();
      const ktoyPath = await invoke<string>('package_game_project');
      status = `Packaged successfully to ${ktoyPath}. Starting share server...`;

      await invoke('start_share_server');
      const localIp = await invoke<string>('get_local_ip');
      shareUrl = `http://${localIp}:8099/download`;

      const qr = qrcode(4, 'L');
      qr.addData(shareUrl);
      qr.make();
      qrSvgString = qr.createSvgTag(6, 12);
      shareModalOpen = true;

      status = 'Sharing active! QR code generated.';
      playUiSound('chime');
    } catch (err) {
      console.error(err);
      status = `Packaging or sharing failed: ${String(err)}`;
      alert(`Sharing failed: ${err}`);
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
    status = '🎲 Generating connected 4x4 Spelunky-style Metroidvania world...';
    try {
      const generatedRooms = buildSurpriseWorld(findAsset, difficultyMode, calmMode);
      for (const r of generatedRooms) {
        const payload = toRoomPayload(r.placed, r.worldSettings, 'demo_project', r.roomId);
        payload.world_settings.difficulty = r.worldSettings.difficulty ?? 'normal';
        payload.world_settings.calm_mode = r.worldSettings.calm_mode ?? false;
        payload.world_settings.grid_x = r.worldSettings.grid_x;
        payload.world_settings.grid_y = r.worldSettings.grid_y;
        await saveRoomPayload(r.roomId, payload);
      }
      
      await loadRoomList();
      const firstRoom = generatedRooms[0];
      await loadSelectedRoom(firstRoom.roomId);

      status = `🎲 Generated 4x4 Metroidvania world! Start playing in ${firstRoom.roomId}!`;
      playUiSound('chime');
      unlockAchievement('world_architect');
    } catch (err) {
      console.error(err);
      status = `Failed to generate surprise world: ${String(err)}`;
    }
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
    on:openScrapbook={() => scrapbookOpen = true}
  />

  {#if parentsPanelOpen}
    <ParentsPanel
      {rooms}
      {activeRoomId}
      {activeAsset}
      {difficultyMode}
      {calmMode}
      {worldSettings}
      placedCount={placed.length}
      {sessionStampsCount}
      {creationDurationSeconds}
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
      on:healthStyleChange={(event) => { worldSettings.health_style = event.detail; saveCurrentRoom(); }}
    />
  {/if}

  {#if showMapView}
    <RoomMapView
      {rooms}
      {activeRoomId}
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
      {unlockedStamps}
      on:select={(event) => selectAsset(event.detail)}
    />

    <!-- Floating Quests Widget -->
    <div class="quests-floating-widget">
      <h3>🎯 Daily & Weekly Quests</h3>
      
      <div class="quest-section">
        <h4>🌟 Daily Stamp Discoveries</h4>
        <div class="quest-item" class:completed={unlockedStamps.includes('effects_fire')}>
          <span class="quest-status">{unlockedStamps.includes('effects_fire') ? '✅' : '🔥'}</span>
          <div class="quest-details">
            <span class="quest-title">Fire Effect</span>
            <span class="quest-desc">Place 3 Fire Torches ({placed.filter(e => e.asset_id === 'chemistry_fire').length}/3)</span>
          </div>
        </div>

        <div class="quest-item" class:completed={unlockedStamps.includes('effects_snow')}>
          <span class="quest-status">{unlockedStamps.includes('effects_snow') ? '✅' : '❄️'}</span>
          <div class="quest-details">
            <span class="quest-title">Snow Effect</span>
            <span class="quest-desc">Place 3 Ice Crystals ({placed.filter(e => e.asset_id === 'chemistry_ice').length}/3)</span>
          </div>
        </div>

        <div class="quest-item" class:completed={unlockedStamps.includes('effects_sparkles')}>
          <span class="quest-status">{unlockedStamps.includes('effects_sparkles') ? '✅' : '✨'}</span>
          <div class="quest-details">
            <span class="quest-title">Magic Sparkles</span>
            <span class="quest-desc">Place 3 Star Pieces ({placed.filter(e => e.asset_id === 'star_piece').length}/3)</span>
          </div>
        </div>
      </div>

      <div class="quest-section">
        <h4>🏆 Weekly Design Challenge</h4>
        <div class="quest-item" class:completed={weeklyChallengeCompleted}>
          <span class="quest-status">{weeklyChallengeCompleted ? '✅' : '⚔️'}</span>
          <div class="quest-details font-bold">
            <span class="quest-title">Course Constructor Challenge</span>
            <span class="quest-desc">Use <strong>Sword</strong>, <strong>Cactus</strong>, and <strong>Bouncy Jelly</strong> to build a course!</span>
            <div class="check-row">
              <span class:check-ok={placed.some(e => e.asset_id === 'weapon_sword')}>Sword</span>
              <span class:check-ok={placed.some(e => e.asset_id === 'cactus_hazard')}>Cactus</span>
              <span class:check-ok={placed.some(e => e.asset_id === 'jelly_trampoline')}>Jelly</span>
            </div>
          </div>
        </div>
      </div>
    </div>

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
    {scrapbookOpen}
    {inventory}
    {isMuted}
    bind:favorites
    {rooms}
    {activeRoomId}
    {getThumbnail}
    {editingAssetId}
    {editingCategory}
    {themeDraft}
    {unlockedStamps}
    customBgmSequence={worldSettings.custom_bgm_sequence}
    customBgmInstruments={worldSettings.custom_bgm_instruments}
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
    on:closeScrapbook={() => scrapbookOpen = false}
  />

  {#if shareModalOpen}
    <div class="share-modal-backdrop" on:click={() => shareModalOpen = false}>
      <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
      <div class="share-modal-box" on:click|stopPropagation>
        <h2>📲 Share Your Game!</h2>
        <p>Friends on the same Wi-Fi can scan this QR code or click the link to play your level!</p>
        
        <div class="qr-container">
          {@html qrSvgString}
        </div>
        
        <div class="share-url-box">
          <span class="url-label">Wi-Fi Link:</span>
          <a href={shareUrl} class="url-value" target="_blank">{shareUrl}</a>
        </div>

        <p class="share-warning-hint font-bold">⚠️ Keep this window open while your friends download the game!</p>

        <button class="close-share-btn" on:click={() => shareModalOpen = false}>Close</button>
      </div>
    </div>
  {/if}

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

  {#if activeCelebration}
    <div class="celebration-overlay">
      <div class="celebration-card">
        <span class="celebration-stars">✨⭐✨</span>
        <h2>STICKER EARNED!</h2>
        <div class="celebration-emoji-glow">
          <span class="celebration-emoji">{activeCelebration.emoji}</span>
        </div>
        <h3>{activeCelebration.name}</h3>
        <p>Added to your Sticker Scrapbook!</p>
      </div>
    </div>
  {/if}

  {#if confettiParticles.length > 0}
    <div class="confetti-container">
      {#each confettiParticles as p}
        <div class="confetti-piece" style="
          left: {p.x}px;
          top: {p.y}px;
          background-color: {p.color};
          width: {p.size}px;
          height: {p.size * 1.5}px;
          transform: rotate({p.angle}deg);
        "></div>
      {/each}
    </div>
  {/if}
</main>

<style>
  .app-shell {
    height: 100vh;
    display: grid;
    grid-template-rows: auto auto 1fr auto;
  }

  .quests-floating-widget {
    position: fixed;
    bottom: 50px;
    right: 20px;
    width: 320px;
    background: rgba(15, 23, 42, 0.85);
    backdrop-filter: blur(12px);
    border: 3px solid rgba(251, 191, 36, 0.4);
    border-radius: 20px;
    padding: 16px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    z-index: 50;
    color: white;
  }

  .quests-floating-widget h3 {
    margin: 0 0 12px 0;
    font-size: 1.1rem;
    color: #fbbf24;
    text-align: center;
    border-bottom: 2px solid rgba(255, 255, 255, 0.1);
    padding-bottom: 6px;
  }

  .quest-section {
    margin-bottom: 12px;
  }

  .quest-section h4 {
    margin: 0 0 6px 0;
    font-size: 0.8rem;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .quest-item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    background: rgba(30, 41, 59, 0.5);
    border-radius: 10px;
    padding: 8px 10px;
    margin-bottom: 6px;
    border: 1px solid transparent;
    transition: all 0.2s;
  }

  .quest-item.completed {
    background: rgba(16, 185, 129, 0.15);
    border-color: rgba(16, 185, 129, 0.4);
  }

  .quest-status {
    font-size: 1.2rem;
  }

  .quest-details {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .quest-title {
    font-weight: bold;
    font-size: 0.85rem;
  }

  .quest-desc {
    font-size: 0.75rem;
    color: #94a3b8;
  }

  .check-row {
    display: flex;
    gap: 8px;
    margin-top: 4px;
  }

  .check-row span {
    font-size: 0.65rem;
    background: #374151;
    color: #9ca3af;
    padding: 2px 6px;
    border-radius: 4px;
  }

  .check-row span.check-ok {
    background: #059669;
    color: white;
    font-weight: bold;
  }

  /* Share Modal styles */
  .share-modal-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.85);
    backdrop-filter: blur(8px);
    display: grid;
    place-items: center;
    z-index: 100;
  }

  .share-modal-box {
    background: #1e293b;
    border: 6px solid #a855f7;
    border-radius: 32px;
    padding: 32px;
    width: min(480px, 90vw);
    text-align: center;
    box-shadow: 0 25px 50px rgba(0,0,0,0.5);
    color: white;
  }

  .share-modal-box h2 {
    color: #a855f7;
    margin-top: 0;
  }

  .qr-container {
    background: white;
    padding: 16px;
    border-radius: 20px;
    display: inline-block;
    margin: 20px 0;
    box-shadow: 0 4px 10px rgba(0,0,0,0.3);
  }

  .qr-container :global(svg) {
    display: block;
  }

  .share-url-box {
    background: #0f172a;
    border: 2px solid #374151;
    border-radius: 12px;
    padding: 10px 14px;
    display: flex;
    flex-direction: column;
    gap: 4px;
    margin-bottom: 16px;
  }

  .url-label {
    font-size: 0.75rem;
    color: #94a3b8;
  }

  .url-value {
    color: #38bdf8;
    font-family: monospace;
    font-size: 1rem;
    word-break: break-all;
    text-decoration: none;
    font-weight: bold;
  }

  .url-value:hover {
    text-decoration: underline;
  }

  .share-warning-hint {
    font-size: 0.75rem;
    color: #fca5a5;
    margin-bottom: 20px;
  }

  .close-share-btn {
    background: #a855f7;
    color: white;
    border: none;
    border-radius: 16px;
    padding: 10px 28px;
    font-weight: bold;
    font-size: 1.1rem;
    cursor: pointer;
    box-shadow: 0 4px 0 #7e22ce;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .close-share-btn:active {
    transform: translateY(4px);
    box-shadow: none;
  }

  /* Sticker unlock celebrations */
  .celebration-overlay {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.6);
    display: grid;
    place-items: center;
    z-index: 998;
    pointer-events: none;
    animation: fade-in 0.3s ease-out;
  }

  .celebration-card {
    background: #2a1f3d;
    border: 6px solid #fbbf24;
    border-radius: 30px;
    padding: 30px;
    text-align: center;
    box-shadow: 0 20px 50px rgba(0,0,0,0.6);
    color: white;
    max-width: 320px;
    animation: bounce-in 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  .celebration-stars {
    font-size: 2rem;
    display: block;
    margin-bottom: 8px;
  }

  .celebration-card h2 {
    margin: 0;
    font-size: 1.5rem;
    color: #f43f5e;
    font-weight: 900;
  }

  .celebration-emoji-glow {
    position: relative;
    width: 100px;
    height: 100px;
    background: white;
    border-radius: 50%;
    display: grid;
    place-items: center;
    margin: 16px auto;
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.8);
  }

  .celebration-emoji {
    font-size: 4rem;
    line-height: 1;
  }

  .celebration-card h3 {
    margin: 8px 0 0 0;
    font-size: 1.4rem;
    color: #fbbf24;
    font-weight: 800;
  }

  .celebration-card p {
    margin: 6px 0 0 0;
    font-size: 0.9rem;
    color: #cbd5e1;
  }

  .confetti-container {
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: 999;
    overflow: hidden;
  }

  .confetti-piece {
    position: absolute;
    border-radius: 2px;
  }

  @keyframes fade-in {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  @keyframes bounce-in {
    0% { transform: scale(0.3); opacity: 0; }
    50% { transform: scale(1.1); }
    70% { transform: scale(0.9); }
    100% { transform: scale(1); opacity: 1; }
  }
</style>
