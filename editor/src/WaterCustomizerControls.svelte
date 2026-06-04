<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: buoyancyPercent = Math.round((entity.modifiers.water_buoyancy ?? 0.5) * 100);

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

<div class="option-group">
  <span class="option-label-text">Water Flavor:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.water_flavor}
    on:change={saveRoom}
  >
    <option value="normal">🌊 Blue Water (Swimmable)</option>
    <option value="toxic">🧪 Toxic Sludge (Hurts Slowly)</option>
    <option value="lava">🔥 Boiling Lava (Hurts Fast!)</option>
  </select>
</div>

<div class="option-group">
  <div class="option-label">
    <span>Water Floatiness (Buoyancy):</span>
    <span>{buoyancyPercent}%</span>
  </div>
  <input
    type="range"
    min="0.1"
    max="0.9"
    step="0.05"
    class="option-slider"
    bind:value={entity.modifiers.water_buoyancy}
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

  .option-slider {
    width: 100%;
    accent-color: #fbbf24;
    cursor: pointer;
  }
</style>
