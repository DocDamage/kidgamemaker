<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;
  export let rooms: string[] = [];
  export let activeRoomId = '';

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isKey = entity.type === 'key_collectible';
  $: isLockedDoor = entity.type === 'locked_door';
  $: isPortal = entity.category === 'portals' || entity.type === 'portal';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isKey}
  <div class="option-group">
    <span class="option-label-text">Key Color:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.key_color}
      on:change={saveRoom}
    >
      <option value="gold">🟡 Gold Key</option>
      <option value="red">🔴 Red Key</option>
      <option value="blue">🔵 Blue Key</option>
    </select>
  </div>
{:else if isLockedDoor}
  <div class="option-group">
    <span class="option-label-text">Required Key Color:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.key_color}
      on:change={saveRoom}
    >
      <option value="gold">🟡 Gold Key</option>
      <option value="red">🔴 Red Key</option>
      <option value="blue">🔵 Blue Key</option>
    </select>
  </div>
  <div class="option-group">
    <span class="option-label-text">Select Link Room (Optional portal exit):</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.target_room}
      on:change={saveRoom}
    >
      <option value="">(No Teleport, Just Unlocks)</option>
      {#each rooms as room}
        <option value={room}>{room === activeRoomId ? `${room} (This Room)` : room}</option>
      {/each}
    </select>
  </div>
{:else if isPortal}
  <div class="option-group">
    <span class="option-label-text">Select Link Room:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.target_room}
      on:change={saveRoom}
    >
      {#each rooms as room}
        <option value={room}>{room === activeRoomId ? `${room} (This Room)` : room}</option>
      {/each}
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
