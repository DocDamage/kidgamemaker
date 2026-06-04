<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  const PRESET_MESSAGES = [
    'Watch out! 🌋',
    'Collect all the gems! 💎',
    'Double Jump to reach the top! 👟',
    'Almost there! Find the portal! 🏁',
    'Hello adventurer! 🧙‍♂️'
  ];

  function saveRoom() {
    dispatch('saveRoom');
  }

  function applyPreset(event: Event) {
    entity.modifiers.speech_text = (event.currentTarget as HTMLSelectElement).value;
    saveRoom();
  }
</script>

<div class="option-group">
  <span class="option-label-text">Choose Pre-made Message:</span>
  <select class="option-select" on:change={applyPreset}>
    <option value="">(Select or write custom text below)</option>
    {#each PRESET_MESSAGES as message}
      <option value={message}>{message}</option>
    {/each}
  </select>
</div>

<div class="option-group">
  <span class="option-label-text">Custom Bubble Text:</span>
  <textarea
    class="option-textarea"
    bind:value={entity.modifiers.speech_text}
    placeholder="Type speech bubble text..."
    on:input={saveRoom}
  ></textarea>
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

  .option-textarea {
    width: 100%;
    height: 60px;
    border-radius: 6px;
    padding: 6px;
    font-size: 0.9rem;
    background: #1e293b;
    color: white;
    border: 1px solid #475569;
  }
</style>
