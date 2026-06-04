<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

<div class="option-group">
  <div class="option-label">
    <span>Crumble Delay:</span>
    <span>{entity.modifiers.crumble_delay ?? 0.5}s</span>
  </div>
  <input
    type="range"
    min="0.1"
    max="2.0"
    step="0.1"
    class="option-slider"
    bind:value={entity.modifiers.crumble_delay}
    on:change={saveRoom}
  />
</div>

<div class="option-group">
  <div class="option-label">
    <span>Respawn Time:</span>
    <span>{entity.modifiers.respawn_time ?? 3.0}s</span>
  </div>
  <input
    type="range"
    min="1.0"
    max="10.0"
    step="0.5"
    class="option-slider"
    bind:value={entity.modifiers.respawn_time}
    on:change={saveRoom}
  />
</div>

<style>
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
</style>
