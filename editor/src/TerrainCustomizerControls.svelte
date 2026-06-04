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

<div class="option-group flex-row">
  <span class="option-label-text">Is Moving Platform? 🚋</span>
  <input
    type="checkbox"
    class="option-toggle"
    bind:checked={entity.modifiers.is_moving_platform}
    on:change={saveRoom}
  />
</div>

<div class="option-group flex-row">
  <span class="option-label-text">Secret Passage? 🕵️‍♂️</span>
  <input
    type="checkbox"
    class="option-toggle"
    bind:checked={entity.modifiers.is_illusion}
    on:change={saveRoom}
  />
</div>

{#if entity.modifiers.is_moving_platform}
  <div class="option-group">
    <span class="option-label-text">Movement Axis:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.move_axis}
      on:change={saveRoom}
    >
      <option value="horizontal">↔️ Horizontal</option>
      <option value="vertical">↕️ Vertical</option>
    </select>
  </div>

  <div class="option-group">
    <div class="option-label">
      <span>Move Speed:</span>
      <span>{entity.modifiers.move_speed ?? 100}</span>
    </div>
    <input
      type="range"
      min="20"
      max="200"
      step="10"
      class="option-slider"
      bind:value={entity.modifiers.move_speed}
      on:change={saveRoom}
    />
  </div>

  <div class="option-group">
    <div class="option-label">
      <span>Travel Distance:</span>
      <span>{entity.modifiers.move_travel ?? 128}px</span>
    </div>
    <input
      type="range"
      min="32"
      max="512"
      step="16"
      class="option-slider"
      bind:value={entity.modifiers.move_travel}
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

  .option-group.flex-row {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 16px;
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

  .option-toggle {
    width: 24px;
    height: 24px;
    accent-color: #fbbf24;
    cursor: pointer;
  }
</style>
