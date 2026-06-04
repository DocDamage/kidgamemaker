<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import CollectibleCustomizerControls from './CollectibleCustomizerControls.svelte';
  import CompanionCustomizerControls from './CompanionCustomizerControls.svelte';
  import ConveyorCustomizerControls from './ConveyorCustomizerControls.svelte';
  import CrumblingCloudCustomizerControls from './CrumblingCloudCustomizerControls.svelte';
  import EnemyCustomizerControls from './EnemyCustomizerControls.svelte';
  import HazardWindCustomizerControls from './HazardWindCustomizerControls.svelte';
  import HeroCustomizerControls from './HeroCustomizerControls.svelte';
  import InteractiveItemCustomizerControls from './InteractiveItemCustomizerControls.svelte';
  import KeyPortalCustomizerControls from './KeyPortalCustomizerControls.svelte';
  import MovementPadCustomizerControls from './MovementPadCustomizerControls.svelte';
  import ParticleCustomizerControls from './ParticleCustomizerControls.svelte';
  import SpeechSignCustomizerControls from './SpeechSignCustomizerControls.svelte';
  import TerrainCustomizerControls from './TerrainCustomizerControls.svelte';
  import TriggerCustomizerControls from './TriggerCustomizerControls.svelte';
  import WaterCustomizerControls from './WaterCustomizerControls.svelte';
  import ZonaiCustomizerControls from './ZonaiCustomizerControls.svelte';
  import LogicGateCustomizerControls from './LogicGateCustomizerControls.svelte';
  import type { PlacedEntity, ToyboxAsset } from './lib/canvasState';

  export let entity: PlacedEntity;
  export let rooms: string[] = [];
  export let activeRoomId: string;
  export let placed: PlacedEntity[];
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;

  const dispatch = createEventDispatcher<{
    close: void;
    deleteToy: string;
    saveRoom: void;
  }>();

  $: asset = findAsset(entity.asset_id);

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

<div class="customizer-panel">
  <header class="customizer-header">
    <h3>Customize Toy 🎛️</h3>
    <button class="close-customizer-btn" on:click={() => dispatch('close')}>✕</button>
  </header>

  <div class="customizer-body">
    <div class="toy-info">
      <span class="toy-icon">{asset?.visual ?? '🎮'}</span>
      <span class="toy-name">{asset?.name ?? entity.asset_id}</span>
    </div>

    <div class="option-group">
      <div class="option-label">
        <span>Toy Size:</span>
        <span>{entity.modifiers.scale_multiplier.toFixed(1)}x</span>
      </div>
      <input
        type="range"
        min="0.5"
        max="3.0"
        step="0.1"
        class="option-slider"
        bind:value={entity.modifiers.scale_multiplier}
        on:change={saveRoom}
      />
    </div>

    {#if entity.category === 'heroes' && entity.type === 'player'}
      <HeroCustomizerControls {entity} on:saveRoom={saveRoom} />
    {/if}

    {#if entity.category === 'terrain' || entity.type === 'terrain'}
      <TerrainCustomizerControls {entity} on:saveRoom={saveRoom} />
    {/if}

    {#if entity.category === 'enemies' || entity.type === 'enemy'}
      <EnemyCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.category === 'collectibles' || entity.type === 'collectible'}
      <CollectibleCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'key_collectible' || entity.type === 'locked_door' || entity.category === 'portals' || entity.type === 'portal'}
      <KeyPortalCustomizerControls
        {entity}
        {rooms}
        {activeRoomId}
        on:saveRoom={saveRoom}
      />
    {:else if entity.type === 'conveyor'}
      <ConveyorCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'mystery_box'}
      <div class="option-group">
        <span class="option-label-text">Weighted Rewards:</span>
        <span class="option-note">Spawns Coins, Health, Speed boost, Shields, or a surprise slime!</span>
      </div>
    {:else if entity.category === 'particles' || entity.type === 'particles'}
      <ParticleCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'trigger'}
      <TriggerCustomizerControls
        {entity}
        {placed}
        {findAsset}
        on:saveRoom={saveRoom}
      />
    {:else if entity.type === 'jelly'}
      <MovementPadCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'speed_pad'}
      <MovementPadCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'speech_sign'}
      <SpeechSignCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'water_block'}
      <WaterCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'pet'}
      <CompanionCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'crumbling_cloud'}
      <CrumblingCloudCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'hazard'}
      <HazardWindCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'wind_zone'}
      <HazardWindCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'target_practice'}
      <div class="option-group">
        <span class="option-label-text">Target Mode:</span>
        <span class="option-note">🎯 Hit this target with projectiles, stomps, or a hammer to trigger magic rules!</span>
      </div>
    {:else if entity.type === 'zonai_fan'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'zonai_rocket'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'zonai_balloon'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'zonai_spring'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'zonai_beam'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'zonai_battery'}
      <ZonaiCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'companion_pikmin'}
      <CompanionCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'companion_ghost'}
      <CompanionCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'companion_palico'}
      <CompanionCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'companion_rush'}
      <CompanionCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'shopkeeper'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'bbq_spit'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'crafting_bench'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'grapple_ring'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.asset_id === 'weapon_boomerang'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.asset_id === 'weapon_bomb'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.asset_id === 'focus_amulet'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'wall_run_surface' || entity.type === 'ceiling_run_surface'}
      <InteractiveItemCustomizerControls {entity} on:saveRoom={saveRoom} />
    {:else if entity.type === 'logic_and' || entity.type === 'logic_or' || entity.type === 'logic_not'}
      <LogicGateCustomizerControls
        {entity}
        {placed}
        {findAsset}
        on:saveRoom={saveRoom}
      />
    {/if}
  </div>

  <footer class="customizer-footer">
    <button class="customizer-delete-btn" on:click={() => dispatch('deleteToy', entity.instance_id)}>
      🗑️ Throw Away Toy
    </button>
  </footer>
</div>

<style>
  .customizer-panel {
    position: fixed;
    right: 24px;
    top: 100px;
    width: 320px;
    background: #1e293b;
    border: 4px solid #fbbf24;
    border-radius: 24px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    z-index: 100;
    color: white;
    overflow: hidden;
  }

  .customizer-header {
    background: #0f172a;
    padding: 12px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #334155;
  }

  .customizer-header h3 {
    margin: 0;
    color: #fbbf24;
    font-size: 1.1rem;
  }

  .close-customizer-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 50%;
    width: 28px;
    height: 28px;
    padding: 0;
    font-size: 1rem;
    box-shadow: none;
  }

  .customizer-body {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    max-height: 60vh;
    overflow-y: auto;
  }

  .toy-info {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px;
    background: rgba(255, 255, 255, 0.08);
    border-radius: 16px;
  }

  .toy-icon {
    font-size: 2rem;
  }

  .toy-name {
    font-weight: 900;
    font-size: 1rem;
  }

  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
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

  .option-note {
    font-size: 0.85rem;
    color: #94a3b8;
  }

  .customizer-footer {
    padding: 12px 16px;
    background: #0f172a;
    border-top: 2px solid #334155;
  }

  .customizer-delete-btn {
    width: 100%;
    background: #ef4444;
    color: white;
    box-shadow: 0 5px 0 #991b1b;
  }

  .customizer-delete-btn:active {
    box-shadow: 0 2px 0 #991b1b;
  }
</style>
