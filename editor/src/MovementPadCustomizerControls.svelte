<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isJelly = entity.type === 'jelly';
  $: isSpeedPad = entity.type === 'speed_pad';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isJelly}
  <div class="option-group">
    <span class="option-label-text">Bounce Power 🚀:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.bounce_force}
      on:change={saveRoom}
    >
      <option value={350}>🌸 Soft Spring (Low)</option>
      <option value={500}>🦘 Kangaroo Hop (Medium)</option>
      <option value={750}>🚀 Sky Launch (High)</option>
      <option value={1000}>🌌 Orbit Rocket (Super)</option>
    </select>
  </div>
{:else if isSpeedPad}
  <div class="option-group">
    <span class="option-label-text">Boost Direction:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.boost_direction}
      on:change={saveRoom}
    >
      <option value={1}>➡️ Boost Right</option>
      <option value={-1}>⬅️ Boost Left</option>
    </select>
  </div>
  <div class="option-group">
    <span class="option-label-text">Boost Speed:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.boost_force}
      on:change={saveRoom}
    >
      <option value={300}>🏃 Jog Speed</option>
      <option value={550}>⚡ Turbo Zoom</option>
      <option value={800}>🔥 Hyper Drive</option>
    </select>
  </div>
{/if}

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
