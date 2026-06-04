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
    <span>Score Value:</span>
    <span>{entity.modifiers.score_value ?? 10}</span>
  </div>
  <input
    type="range"
    min="0"
    max="500"
    step="10"
    class="option-slider"
    bind:value={entity.modifiers.score_value}
    on:change={saveRoom}
  />
</div>

<div class="option-group">
  <div class="option-label">
    <span>Healing Power:</span>
    <span>{entity.modifiers.heal_value ?? 0}</span>
  </div>
  <input
    type="range"
    min="0"
    max="100"
    step="5"
    class="option-slider"
    bind:value={entity.modifiers.heal_value}
    on:change={saveRoom}
  />
</div>

<div class="option-group">
  <span class="option-label-text">Give Hero Special Power:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.powerup_type}
    on:change={saveRoom}
  >
    <option value="">❌ None</option>
    <option value="speed">🧪 Speed Boost Potion</option>
    <option value="shield">🛡️ Shield Bubble</option>
    <option value="double_jump">👟 Double Jump Shoes</option>
    <option value="charge_jump">🌱 Charge Spring</option>
    <option value="glider">🪂 Glider Cape</option>
    <option value="jetpack">🚀 Jetpack Thruster</option>
    <option value="giant">🍄 Giant Growth Potion</option>
    <option value="gravity">🔮 Gravity Inversion Potion</option>
  </select>
</div>

{#if entity.modifiers.powerup_type === 'charge_jump' || entity.asset_id === 'charge_spring'}
  <div class="option-group">
    <span class="option-label-text">Charge Speed:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.charge_jump_speed}
      on:change={saveRoom}
    >
      <option value="fast">⚡ Fast</option>
      <option value="normal">🌱 Normal</option>
      <option value="slow">🐢 Slow</option>
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
