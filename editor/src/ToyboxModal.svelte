<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { AssetInventory, ToyboxAsset } from './lib/canvasState';

  export let isVisible = false;
  export let inventory: AssetInventory = {};

  const dispatch = createEventDispatcher<{
    itemSelected: ToyboxAsset;
    close: void;
  }>();

  $: categories = Object.entries(inventory);
</script>

{#if isVisible}
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')} on:keydown={(e) => e.key === 'Escape' && dispatch('close')}>
    <div class="modal" role="dialog" aria-modal="true" aria-label="Toybox" tabindex="0" on:click|stopPropagation on:keydown|stopPropagation>
      <header>
        <h2>Toybox</h2>
        <button on:click={() => dispatch('close')}>Close</button>
      </header>

      {#each categories as [category, items]}
        <article class="category">
          <h3>{category}</h3>
          <div class="grid">
            {#each items as item}
              <button class="toy" on:click={() => dispatch('itemSelected', item)}>
                <span>{item.visual ?? '🎮'}</span>
                <strong>{item.name}</strong>
              </button>
            {/each}
          </div>
        </article>
      {/each}
    </div>
  </div>
{/if}

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.58);
    display: grid;
    place-items: center;
    z-index: 50;
  }

  .modal {
    width: min(920px, 92vw);
    max-height: 86vh;
    overflow: auto;
    border-radius: 28px;
    background: #111827;
    color: white;
    padding: 24px;
    box-shadow: 0 28px 80px rgba(0, 0, 0, 0.5);
  }

  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
  }

  h2, h3 {
    margin: 0;
  }

  .category {
    margin-top: 24px;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(132px, 1fr));
    gap: 14px;
    margin-top: 12px;
  }

  .toy {
    min-height: 112px;
    display: grid;
    place-items: center;
    gap: 8px;
    border: 0;
    border-radius: 22px;
    background: #f8fafc;
    color: #111827;
    cursor: pointer;
    font-weight: 800;
  }

  .toy span {
    font-size: 2.5rem;
  }
</style>
