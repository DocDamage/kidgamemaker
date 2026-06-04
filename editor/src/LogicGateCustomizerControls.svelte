<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity, ToyboxAsset } from './lib/canvasState';

  export let entity: PlacedEntity;
  export let placed: PlacedEntity[] = [];
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  // Find all possible triggers that can be inputs: trigger (button, lever, pressure plate), target practice, or another logic gate
  $: possibleInputs = placed.filter(
    (item) =>
      item.instance_id !== entity.instance_id &&
      (item.type === 'trigger' ||
       item.type === 'target_practice' ||
       item.type === 'logic_and' ||
       item.type === 'logic_or' ||
       item.type === 'logic_not')
  );

  $: selectedInputs = entity.modifiers.logic_inputs || [];

  function toggleInput(instanceId: string) {
    let inputs = [...selectedInputs];
    const idx = inputs.indexOf(instanceId);
    if (idx >= 0) {
      inputs.splice(idx, 1);
    } else {
      inputs.push(instanceId);
    }
    entity.modifiers.logic_inputs = inputs;
    dispatch('saveRoom');
  }

  function getLabel(item: PlacedEntity) {
    const assetName = findAsset(item.asset_id)?.name ?? item.asset_id;
    return `${assetName} (${item.instance_id.slice(0, 5)})`;
  }
</script>

<div class="option-group">
  <span class="option-label-text">Select Input Signals 🎛️:</span>
  <span class="option-note">Choose which buttons, levers, or targets feed into this gate.</span>
  <div class="inputs-list">
    {#each possibleInputs as input}
      {@const isSelected = selectedInputs.includes(input.instance_id)}
      <button
        type="button"
        class="input-option-btn"
        class:active-option={isSelected}
        on:click={() => toggleInput(input.instance_id)}
      >
        <span class="checkbox-box">{isSelected ? '✅' : '⬜'}</span>
        <span class="label-text">{getLabel(input)}</span>
      </button>
    {:else}
      <span class="option-note empty-note">No triggers found in this room. Place some buttons or levers first!</span>
    {/each}
  </div>
</div>

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-top: 8px;
  }

  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-note {
    font-size: 0.85rem;
    color: #94a3b8;
    margin-bottom: 6px;
  }

  .empty-note {
    font-style: italic;
  }

  .inputs-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
    max-height: 200px;
    overflow-y: auto;
    background: #0f172a;
    padding: 8px;
    border-radius: 12px;
    border: 2px solid #334155;
  }

  .input-option-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    background: transparent;
    border: 0;
    color: #94a3b8;
    padding: 6px 8px;
    text-align: left;
    font-size: 0.85rem;
    cursor: pointer;
    border-radius: 6px;
    box-shadow: none;
  }

  .input-option-btn:hover {
    background: rgba(255, 255, 255, 0.05);
    color: white;
  }

  .input-option-btn.active-option {
    color: #fbbf24;
    background: rgba(251, 191, 36, 0.1);
  }

  .checkbox-box {
    font-size: 1rem;
  }

  .label-text {
    font-weight: bold;
  }
</style>
