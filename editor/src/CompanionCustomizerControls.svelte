<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isPet = entity.type === 'pet';
  $: isPikmin = entity.type === 'companion_pikmin';
  $: isGhost = entity.type === 'companion_ghost';
  $: isPalico = entity.type === 'companion_palico';
  $: isRush = entity.type === 'companion_rush';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isPet}
  <div class="option-group">
    <span class="option-label-text">Magic Power 🔮:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.pet_power}
      on:change={saveRoom}
    >
      <option value="magnet">🧲 Coin Magnet (Pulls Coins)</option>
      <option value="light">💡 Lantern Fly (Lights Dark Rooms)</option>
      <option value="shield">🛡️ Shield Link (Protects Player)</option>
    </select>
  </div>
{:else if isPikmin}
  <div class="option-group">
    <span class="option-label-text">Pikmin Color 🌱:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.pikmin_color}
      on:change={saveRoom}
    >
      <option value="red">❤️ Red (Fireproof)</option>
      <option value="blue">💙 Blue (Swim/Water)</option>
      <option value="yellow">💛 Yellow (Electricproof)</option>
    </select>
  </div>
{:else if isGhost}
  <div class="option-group">
    <div class="option-label">
      <span>Life Drain Rate:</span>
      <span>{entity.modifiers.drain_rate ?? 10}</span>
    </div>
    <input
      type="range"
      min="5"
      max="30"
      step="5"
      class="option-slider"
      bind:value={entity.modifiers.drain_rate}
      on:change={saveRoom}
    />
  </div>
{:else if isPalico}
  <div class="option-group">
    <span class="option-label-text">Palico Armor Color 🐱:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.palico_color}
      on:change={saveRoom}
    >
      <option value="calico">🧡 Calico Orange</option>
      <option value="black">🖤 Shadow Black</option>
      <option value="pink">💖 Bubblegum Pink</option>
      <option value="green">💚 Forest Green</option>
    </select>
  </div>
{:else if isRush}
  <div class="option-group">
    <span class="option-label-text">Rush Dog Accent 🐶:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.rush_color}
      on:change={saveRoom}
    >
      <option value="red">❤️ Classic Red</option>
      <option value="blue">💙 Electric Blue</option>
      <option value="gold">💛 Cyber Gold</option>
    </select>
  </div>
{/if}

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .option-label,
  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-label {
    display: flex;
    justify-content: space-between;
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
