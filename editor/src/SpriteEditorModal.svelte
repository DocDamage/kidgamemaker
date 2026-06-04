<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { playSpriteEditorSound } from './lib/spriteEditorAudio';
  import SpriteDrawStudio from './SpriteDrawStudio.svelte';
  import SpriteSoundStudio from './SpriteSoundStudio.svelte';

  export let isVisible = false;
  export let targetAssetId = '';
  export let category = 'decorations';
  export let isMuted = false;

  const dispatch = createEventDispatcher<{
    close: void;
    saved: string;
  }>();

  let activeTab: 'draw' | 'sound' = 'draw';

  $: if (isVisible) {
    activeTab = 'draw';
  }

  function playTabChime() {
    playSpriteEditorSound('chime', isMuted);
  }

  function handleSaved(event: CustomEvent<string>) {
    targetAssetId = event.detail;
    dispatch('saved', targetAssetId);
  }
</script>

{#if isVisible}
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')}>
    <div class="modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <header>
        <h2>🎨 Magic Brush</h2>
        <button class="close-btn" on:click={() => dispatch('close')}>✕ Done</button>
      </header>

      <div class="tabs-header">
        <button class="tab-btn" class:active={activeTab === 'draw'} on:click={() => activeTab = 'draw'}>🖌️ Draw Toy</button>
        <button class="tab-btn" class:active={activeTab === 'sound'} on:click={() => { activeTab = 'sound'; playTabChime(); }}>🎵 Toy Sound</button>
      </div>

      {#if activeTab === 'draw'}
        <SpriteDrawStudio
          bind:targetAssetId
          bind:category
          {isMuted}
          on:saved={handleSaved}
        />
      {:else}
        <SpriteSoundStudio
          {targetAssetId}
          {category}
          {isMuted}
        />
      {/if}
    </div>
  </div>
{/if}

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.85);
    backdrop-filter: blur(8px);
    display: grid;
    place-items: center;
    z-index: 100;
  }

  .modal {
    background: #1e293b;
    border: 6px solid #fbbf24;
    border-radius: 40px;
    padding: 32px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid rgba(255, 255, 255, 0.1);
    padding-bottom: 12px;
  }

  h2 {
    margin: 0;
    color: #fbbf24;
    font-size: 2rem;
    font-weight: 900;
    letter-spacing: -0.5px;
  }

  .close-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 4px 0 #b91c1c;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .close-btn:active {
    transform: translateY(4px);
    box-shadow: 0 0 0 #b91c1c;
  }

  /* Tabs system */
  .tabs-header {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
    background: #0f172a;
    padding: 6px;
    border-radius: 16px;
  }

  .tab-btn {
    flex: 1;
    border: 0;
    background: transparent;
    color: #94a3b8;
    font-size: 1.05rem;
    font-weight: 800;
    padding: 10px;
    border-radius: 12px;
    cursor: pointer;
    transition: background 0.2s, color 0.2s;
  }

  .tab-btn.active {
    background: #fbbf24;
    color: #0f172a;
  }
</style>
