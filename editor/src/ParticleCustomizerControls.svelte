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
  <span class="option-label-text">Effect Theme:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.particle_theme}
    on:change={saveRoom}
  >
    <option value="default">✨ Default</option>
    <option value="rainbow">🌈 Rainbow Spark</option>
    <option value="neon">⚡ Electric Neon</option>
    <option value="frost">❄️ Frost Chill</option>
    <option value="shadow">💀 Shadow Curse</option>
  </select>
</div>

<div class="option-group">
  <span class="option-label-text">Flow Speed:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.particle_intensity}
    on:change={saveRoom}
  >
    <option value="calm">🌸 Calm</option>
    <option value="normal">💧 Normal</option>
    <option value="wild">🌪️ Wild</option>
  </select>
</div>

<div class="option-group">
  <span class="option-label-text">Wind Direction:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.particle_direction}
    on:change={saveRoom}
  >
    <option value="up">⬆️ Blow Up</option>
    <option value="down">⬇️ Blow Down</option>
    <option value="left">⬅️ Blow Left</option>
    <option value="right">➡️ Blow Right</option>
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
