<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isHazard = entity.type === 'hazard';
  $: isWindZone = entity.type === 'wind_zone';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isHazard}
  <div class="option-group">
    <div class="option-label">
      <span>Spike/Cactus Damage:</span>
      <span>{entity.modifiers.damage_value ?? 15} HP</span>
    </div>
    <input
      type="range"
      min="5"
      max="75"
      step="5"
      class="option-slider"
      bind:value={entity.modifiers.damage_value}
      on:change={saveRoom}
    />
  </div>
{:else if isWindZone}
  <div class="option-group">
    <span class="option-label-text">Wind Direction:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.wind_direction}
      on:change={saveRoom}
    >
      <option value="right">➡️ Blow Right</option>
      <option value="left">⬅️ Blow Left</option>
      <option value="up">⬆️ Blow Up</option>
      <option value="down">⬇️ Blow Down</option>
    </select>
  </div>
  <div class="option-group">
    <span class="option-label-text">Wind Strength:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.wind_force}
      on:change={saveRoom}
    >
      <option value={150.0}>🍃 Gentle Breeze</option>
      <option value={300.0}>💨 Windy Gust</option>
      <option value={500.0}>🌪️ Hurricane Push</option>
    </select>
  </div>
{/if}

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
