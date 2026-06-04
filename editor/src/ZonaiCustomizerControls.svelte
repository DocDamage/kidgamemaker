<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isFan = entity.type === 'zonai_fan';
  $: isRocket = entity.type === 'zonai_rocket';
  $: isBalloon = entity.type === 'zonai_balloon';
  $: isSpring = entity.type === 'zonai_spring';
  $: isBeam = entity.type === 'zonai_beam';
  $: isBattery = entity.type === 'zonai_battery';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isFan}
  <div class="option-group">
    <span class="option-label-text">Blow Direction:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.zonai_direction}
      on:change={saveRoom}
    >
      <option value="right">➡️ Right</option>
      <option value="left">⬅️ Left</option>
      <option value="up">⬆️ Up</option>
      <option value="down">⬇️ Down</option>
    </select>
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Wind Force:</span>
      <span>{entity.modifiers.wind_force ?? 400}</span>
    </div>
    <input
      type="range"
      min="100"
      max="800"
      step="50"
      class="option-slider"
      bind:value={entity.modifiers.wind_force}
      on:change={saveRoom}
    />
  </div>
{:else if isRocket}
  <div class="option-group">
    <span class="option-label-text">Thrust Direction:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.zonai_direction}
      on:change={saveRoom}
    >
      <option value="up">⬆️ Up</option>
      <option value="right">➡️ Right</option>
      <option value="left">⬅️ Left</option>
      <option value="down">⬇️ Down</option>
    </select>
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Thrust Force:</span>
      <span>{entity.modifiers.thrust_force ?? 800}</span>
    </div>
    <input
      type="range"
      min="300"
      max="1500"
      step="50"
      class="option-slider"
      bind:value={entity.modifiers.thrust_force}
      on:change={saveRoom}
    />
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Blast Duration (seconds):</span>
      <span>{entity.modifiers.duration ?? 2.5}s</span>
    </div>
    <input
      type="range"
      min="0.5"
      max="5.0"
      step="0.5"
      class="option-slider"
      bind:value={entity.modifiers.duration}
      on:change={saveRoom}
    />
  </div>
{:else if isBalloon}
  <div class="option-group">
    <div class="option-label">
      <span>Lift Power:</span>
      <span>{entity.modifiers.lift_force ?? 250}</span>
    </div>
    <input
      type="range"
      min="50"
      max="500"
      step="25"
      class="option-slider"
      bind:value={entity.modifiers.lift_force}
      on:change={saveRoom}
    />
  </div>
{:else if isSpring}
  <div class="option-group">
    <div class="option-label">
      <span>Spring Force:</span>
      <span>{entity.modifiers.spring_force ?? 600}</span>
    </div>
    <input
      type="range"
      min="200"
      max="1200"
      step="50"
      class="option-slider"
      bind:value={entity.modifiers.spring_force}
      on:change={saveRoom}
    />
  </div>
{:else if isBeam}
  <div class="option-group">
    <span class="option-label-text">Laser Direction:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.zonai_direction}
      on:change={saveRoom}
    >
      <option value="right">➡️ Right</option>
      <option value="left">⬅️ Left</option>
      <option value="up">⬆️ Up</option>
      <option value="down">⬇️ Down</option>
    </select>
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Laser Damage:</span>
      <span>{entity.modifiers.damage ?? 15}</span>
    </div>
    <input
      type="range"
      min="5"
      max="50"
      step="5"
      class="option-slider"
      bind:value={entity.modifiers.damage}
      on:change={saveRoom}
    />
  </div>
{:else if isBattery}
  <div class="option-group">
    <div class="option-label">
      <span>Battery Energy:</span>
      <span>{entity.modifiers.battery_capacity ?? 100}</span>
    </div>
    <input
      type="range"
      min="50"
      max="500"
      step="25"
      class="option-slider"
      bind:value={entity.modifiers.battery_capacity}
      on:change={saveRoom}
    />
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
