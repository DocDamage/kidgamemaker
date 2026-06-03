<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import ToyboxModal from './ToyboxModal.svelte';
  import {
    eraseEntity,
    fallbackInventory,
    snapPosition,
    stampEntity,
    toRoomPayload,
    type AssetInventory,
    type PlacedEntity,
    type ToyboxAsset
  } from './lib/canvasState';

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
  let snapEnabled = true;
  let status = 'Ready';

  $: quickRibbon = Object.values(inventory).flat().slice(0, 8);

  onMount(async () => {
    try {
      inventory = await invoke<AssetInventory>('get_asset_inventory');
      activeAsset = inventory.terrain?.[0] ?? Object.values(inventory).flat()[0] ?? activeAsset;
      status = 'Loaded toybox assets.';
    } catch (error) {
      status = `Using fallback toybox: ${error}`;
    }

    try {
      const savedState = await invoke<any>('load_game_state');
      if (savedState && Array.isArray(savedState.entities)) {
        placed = savedState.entities;
        status += ' Restored saved game state.';
      }
    } catch (error) {
      status += ' No saved game state found, starting fresh.';
    }
  });

  function handleCanvasClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const position = snapPosition(
      {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top
      },
      8,
      snapEnabled
    );

    if (eraserMode) {
      const hit = [...placed].reverse().find((item) => {
        const dx = item.position.x - position.x;
        const dy = item.position.y - position.y;
        return Math.sqrt(dx * dx + dy * dy) < 36;
      });

      if (hit) placed = eraseEntity(placed, hit.instance_id);
      return;
    }

    placed = stampEntity(placed, activeAsset, position);
  }

  async function save() {
    status = 'Saving game state...';
    try {
      const payload = toRoomPayload(placed);
      const jsonString = JSON.stringify(payload);
      status = await invoke<string>('save_game_state', { jsonString });
    } catch (error) {
      status = `Save failed: ${String(error)}`;
    }
  }

  async function play() {
    status = 'Writing game_state.json and launching...';
    try {
      const payload = toRoomPayload(placed);
      status = await invoke<string>('compile_and_play', { roomPayload: payload });
    } catch (error) {
      status = `Play failed: ${String(error)}`;
    }
  }

  function selectAsset(asset: ToyboxAsset) {
    activeAsset = asset;
    eraserMode = false;
    toyboxOpen = false;
  }

  function iconFor(item: PlacedEntity): string {
    return quickRibbon.find((asset) => asset.id === item.asset_id)?.visual ?? '🎮';
  }
</script>

<main class="app-shell">
  <header class="topbar">
    <span class="logo">🧸 KidGameMaker</span>
    <button class="play" on:click={play}>▶ PLAY</button>
    <button class="save" on:click={save}>💾 SAVE</button>
    <button class:active={!eraserMode} on:click={() => (eraserMode = false)}>
      Stamp: {activeAsset.visual ?? '🎮'} {activeAsset.name}
    </button>
    <button class:active={eraserMode} on:click={() => (eraserMode = !eraserMode)}>🧽 Eraser</button>
    <button class:active={snapEnabled} on:click={() => (snapEnabled = !snapEnabled)}>🧲 Snap</button>
    <button on:click={() => (toyboxOpen = true)}>🧰 Toybox</button>
  </header>

  <section class="quick-ribbon" aria-label="Quick toybox ribbon">
    {#each quickRibbon as asset}
      <button
        class:active={activeAsset.id === asset.id && !eraserMode}
        on:click={() => selectAsset(asset)}
        title={asset.name}
      >
        <span>{asset.visual ?? '🎮'}</span>
        <small>{asset.name}</small>
      </button>
    {/each}
  </section>

  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <section class="canvas" on:click={handleCanvasClick} aria-label="Game canvas">
    <div class="horizon"></div>
    {#each placed as item (item.instance_id)}
      <button
        class="stamp {item.category}"
        style:left={`${item.position.x}px`}
        style:top={`${item.position.y}px`}
        title={`${item.asset_id} ${item.instance_id}`}
        on:click|stopPropagation={() => {
          if (eraserMode) placed = eraseEntity(placed, item.instance_id);
        }}
      >
        {iconFor(item)}
      </button>
    {/each}
  </section>

  <footer>
    <code>{status}</code>
    <span>{placed.length} stamped objects</span>
  </footer>

  <ToyboxModal
    isVisible={toyboxOpen}
    inventory={inventory}
    on:itemSelected={(event) => selectAsset(event.detail)}
    on:close={() => (toyboxOpen = false)}
  />
</main>

<style>
  .app-shell {
    height: 100vh;
    display: grid;
    grid-template-rows: auto auto 1fr auto;
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
    background:
      linear-gradient(rgba(255, 255, 255, 0.06) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
      linear-gradient(#31466d, #1d2d45 55%, #1b2331 55%);
    background-size: 32px 32px, 32px 32px, 100% 100%;
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

  footer {
    justify-content: space-between;
    border-top: 3px solid rgba(255, 255, 255, 0.08);
    border-bottom: 0;
  }
</style>
