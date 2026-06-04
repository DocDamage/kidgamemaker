<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { HERO_COSTUMES, HERO_JOBS } from './lib/customizerOptions';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isHero = entity.category === 'heroes' && entity.type === 'player';

  function selectCostume(id: string, tint: string) {
    entity.modifiers.costume_id = id;
    entity.modifiers.costume_tint = tint;
    dispatch('saveRoom');
  }

  function selectJob(id: string) {
    entity.modifiers.hero_class = id;
    dispatch('saveRoom');
  }
</script>

{#if isHero}
  <div class="option-group">
    <span class="option-label-text">👕 Costume Wardrobe:</span>
    <div class="costume-grid">
      {#each HERO_COSTUMES as costume}
        <button
          type="button"
          class:active-option={entity.modifiers.costume_id === costume.id}
          style:--option-color={costume.color}
          on:click={() => selectCostume(costume.id, costume.tint)}
        >
          {costume.name}
        </button>
      {/each}
    </div>
  </div>

  <div class="option-group hero-job-group">
    <span class="option-label-text">🛡️ Hero Job / Class:</span>
    <div class="class-grid">
      {#each HERO_JOBS as job}
        <button
          type="button"
          title={job.desc}
          class:active-option={entity.modifiers.hero_class === job.id}
          style:--option-color={job.color}
          on:click={() => selectJob(job.id)}
        >
          {job.name}
        </button>
      {/each}
    </div>
  </div>
{/if}

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .hero-job-group {
    margin-top: 16px;
  }

  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .costume-grid,
  .class-grid {
    display: grid;
    gap: 8px;
    margin-top: 8px;
  }

  .costume-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .class-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  button {
    background: #1e293b;
    color: white;
    border: 2px solid var(--option-color);
    padding: 8px 4px;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: bold;
    cursor: pointer;
    text-align: center;
    box-shadow: 0 3px 0 rgba(0, 0, 0, 0.3);
  }

  .active-option {
    background: var(--option-color);
    color: #0f172a;
  }
</style>
