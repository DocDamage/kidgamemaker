<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity, ToyboxAsset } from './lib/canvasState';

  export let entity: PlacedEntity;
  export let placed: PlacedEntity[] = [];
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: triggerTargets = placed.filter(
    (item) => item.type === 'gate' || item.type === 'locked_door' || item.type === 'portal'
  );

  function saveRoom() {
    dispatch('saveRoom');
  }

  function targetLabel(target: PlacedEntity) {
    const assetName = findAsset(target.asset_id)?.name ?? target.asset_id;
    return `${target.type.toUpperCase()}: ${assetName} (${target.instance_id.slice(0, 8)}...)`;
  }
</script>

<div class="option-group">
  <span class="option-label-text">Link Target Gate:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.target_id}
    on:change={saveRoom}
  >
    <option value="">❌ None</option>
    {#each triggerTargets as target}
      <option value={target.instance_id}>{targetLabel(target)}</option>
    {/each}
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
