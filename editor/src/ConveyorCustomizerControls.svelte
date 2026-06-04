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
  <span class="option-label-text">Belt Direction:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.conveyor_direction}
    on:change={saveRoom}
  >
    <option value={1.0}>⏩ Move Right</option>
    <option value={-1.0}>⏪ Move Left</option>
  </select>
</div>

<div class="option-group">
  <span class="option-label-text">Belt Speed:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.conveyor_speed}
    on:change={saveRoom}
  >
    <option value={80.0}>🐌 Slow</option>
    <option value={140.0}>🏃 Fast</option>
    <option value={220.0}>⚡ Super Fast</option>
  </select>
</div>

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
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
</style>
