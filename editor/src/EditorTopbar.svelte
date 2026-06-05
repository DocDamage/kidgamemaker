<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { getInventoryAssetUrl, isEmojiVisual } from './lib/assetInventory';
  import type { ToyboxAsset, WorldSettings } from './lib/canvasState';

  export let worldSettings: WorldSettings;
  export let activeAsset: ToyboxAsset;
  export let isMuted = false;
  export let showMapView = false;
  export let showRulesEditor = false;
  export let eraserMode = false;
  export let snapEnabled = true;
  export let canUndo = false;
  export let canRedo = false;
  export let parentsPanelOpen = false;
  export let magicWandOpen = false;
  export let gridSize = 32;

  const dispatch = createEventDispatcher<{
    cycleTime: void;
    cycleWeather: void;
    toggleMute: void;
    openBeatComposer: void;
    toggleMapView: void;
    toggleRulesEditor: void;
    toggleMagicWand: void;
    selectStamp: void;
    editActiveAsset: void;
    toggleEraser: void;
    toggleSnap: void;
    setGridSize: number;
    undo: void;
    redo: void;
    openToybox: void;
    drawToy: void;
    surprise: void;
    openLevelBuilder: void;
    remix: void;
    play: void;
    toggleParents: void;
    openScrapbook: void;
  }>();

  function animateClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLElement;
    target.classList.remove('bounce-click');
    void target.offsetWidth;
    target.classList.add('bounce-click');
  }

  function clickDispatch(event: MouseEvent, eventName: keyof typeof dispatchEvents) {
    animateClick(event);
    dispatchEvents[eventName]();
  }

  const dispatchEvents = {
    cycleTime: () => dispatch('cycleTime'),
    cycleWeather: () => dispatch('cycleWeather'),
    toggleMute: () => dispatch('toggleMute'),
    openBeatComposer: () => dispatch('openBeatComposer'),
    toggleMapView: () => dispatch('toggleMapView'),
    toggleRulesEditor: () => dispatch('toggleRulesEditor'),
    toggleMagicWand: () => dispatch('toggleMagicWand'),
    selectStamp: () => dispatch('selectStamp'),
    editActiveAsset: () => dispatch('editActiveAsset'),
    toggleEraser: () => dispatch('toggleEraser'),
    toggleSnap: () => dispatch('toggleSnap'),
    undo: () => dispatch('undo'),
    redo: () => dispatch('redo'),
    openToybox: () => dispatch('openToybox'),
    drawToy: () => dispatch('drawToy'),
    surprise: () => dispatch('surprise'),
    openLevelBuilder: () => dispatch('openLevelBuilder'),
    remix: () => dispatch('remix'),
    play: () => dispatch('play'),
    toggleParents: () => dispatch('toggleParents'),
    openScrapbook: () => dispatch('openScrapbook')
  };
</script>

<header class="topbar">
  <span class="logo">🧸 KidGameMaker</span>

  <div class="world-cycle-controls">
    <button class="cycle-btn time-btn" on:click={(event) => clickDispatch(event, 'cycleTime')} title="Change Time of Day">
      {#if worldSettings.time_of_day === 'day'}☀️{:else if worldSettings.time_of_day === 'morning'}🌅{:else if worldSettings.time_of_day === 'sunset'}🌇{:else}🌙{/if}
    </button>
    <button class="cycle-btn weather-btn" on:click={(event) => clickDispatch(event, 'cycleWeather')} title="Change Weather">
      {#if worldSettings.weather === 'clear'}🌤{:else if worldSettings.weather === 'rain'}🌧{:else}❄️{/if}
    </button>
    <button class="cycle-btn mute-btn" class:active={isMuted} on:click={(event) => clickDispatch(event, 'toggleMute')} title="Toggle Sound">
      {isMuted ? '🔇' : '🔊'}
    </button>
    <button class="cycle-btn composer-btn" on:click={(event) => clickDispatch(event, 'openBeatComposer')} title="🎹 Compose Beat Loop">
      🎹
    </button>
    <button class="cycle-btn map-btn" class:active={showMapView} on:click={(event) => clickDispatch(event, 'toggleMapView')} title="🗺️ World Map Connector">
      🗺️
    </button>
    <button class="cycle-btn rules-btn" class:active={showRulesEditor} on:click={(event) => clickDispatch(event, 'toggleRulesEditor')} title="✨ Magic Rules Engine">
      ✨
    </button>
    <button class="cycle-btn magic-wand-btn" class:active={magicWandOpen} on:click={(event) => clickDispatch(event, 'toggleMagicWand')} title="🪄 Magic Wand Console">
      🪄
    </button>
  </div>

  <button class="stamp-select-btn" class:active={!eraserMode} on:click={(event) => clickDispatch(event, 'selectStamp')}>
    <span class="active-visual-container">
      {#if activeAsset.visual && !isEmojiVisual(activeAsset.visual)}
        {#if activeAsset.is_spritesheet && activeAsset.frames && activeAsset.frames[0]}
          <img
            src={getInventoryAssetUrl(activeAsset)}
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
            src={getInventoryAssetUrl(activeAsset)}
            alt={activeAsset.name}
          />
        {/if}
      {:else}
        <span>{activeAsset.visual ?? '🎮'}</span>
      {/if}
    </span>
    <span class="btn-text">{activeAsset.name}</span>
  </button>

  <button class="edit-toy-btn" on:click={(event) => clickDispatch(event, 'editActiveAsset')} title="Paint/Edit this toy">🎨 Edit</button>
  <button class="eraser-btn-top" class:active={eraserMode} on:click={(event) => clickDispatch(event, 'toggleEraser')} title="Eraser">🧽 Eraser</button>
  <button class="snap-btn-top" class:active={snapEnabled} on:click={(event) => clickDispatch(event, 'toggleSnap')} title="Snap to Grid">🧲 Snap</button>
  <label class="grid-size-control" title="Grid size">
    <span>Grid</span>
    <input
      type="number"
      min="1"
      max="128"
      step="1"
      value={gridSize}
      on:change={(event) => dispatch('setGridSize', Number((event.currentTarget as HTMLInputElement).value))}
    />
  </label>
  <button class="undo-btn-top" disabled={!canUndo} on:click={(event) => clickDispatch(event, 'undo')} title="Undo last action">↺ Undo</button>
  <button class="redo-btn-top" disabled={!canRedo} on:click={(event) => clickDispatch(event, 'redo')} title="Redo action">↻ Redo</button>
  <button class="toybox-btn-top" on:click={(event) => clickDispatch(event, 'openToybox')} title="Toybox">🧰 Toybox</button>
  <button class="draw-toy-btn-top" on:click={(event) => clickDispatch(event, 'drawToy')} title="Draw Toy">🎨 Draw</button>
  <button class="surprise-btn-top" on:click={(event) => clickDispatch(event, 'surprise')} title="Generate a random level!">🎲 Surprise Me!</button>
  <button class="level-builder-btn-top" on:click={(event) => clickDispatch(event, 'openLevelBuilder')} title="Compile a seed-based level!">🧬 Level Builder</button>
  <button class="remix-btn-top" on:click={(event) => clickDispatch(event, 'remix')} title="Shuffles the items in the room!">🔀 Remix!</button>
  <button class="scrapbook-btn-top" on:click={(event) => clickDispatch(event, 'openScrapbook')} title="🏆 Achievement Sticker Scrapbook">🏆 Scrapbook</button>
  <button id="btn-play" class="play-btn-top" on:click={(event) => clickDispatch(event, 'play')} title="Play!">▶ PLAY</button>
  <button class="parents-toggle-btn" class:active={parentsPanelOpen} on:click={(event) => clickDispatch(event, 'toggleParents')} title="Parents / Developers Settings">⚙️ Parents</button>
</header>

<style>
  .topbar {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px;
    background: #101827;
    border-bottom: 3px solid rgba(255, 255, 255, 0.08);
    flex-wrap: wrap;
  }

  .logo {
    font-size: 1.5rem;
    font-weight: 900;
    color: #ffd84d;
    margin-right: 12px;
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

  button:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

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
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .active-visual-container {
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .active-visual-container img {
    max-width: 24px;
    max-height: 24px;
    object-fit: contain;
    display: block;
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

  .grid-size-control {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #0f172a;
    color: #e2e8f0;
    border: 2px solid #334155;
    border-radius: 12px;
    padding: 7px 10px;
    font-weight: 900;
  }

  .grid-size-control input {
    width: 58px;
    background: #1e293b;
    color: #f8fafc;
    border: 1px solid #64748b;
    border-radius: 8px;
    padding: 5px 7px;
    font-weight: 900;
  }

  .undo-btn-top {
    background: #f87171;
    color: white;
    box-shadow: 0 5px 0 #b91c1c;
  }

  .redo-btn-top {
    background: #60a5fa;
    color: white;
    box-shadow: 0 5px 0 #1d4ed8;
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

  .scrapbook-btn-top {
    background: #f43f5e;
    color: white;
    box-shadow: 0 4px 0 #be123c;
  }

  .parents-toggle-btn {
    background: #4b5563;
    color: white;
    box-shadow: 0 4px 0 #1f2937;
  }

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
</style>
