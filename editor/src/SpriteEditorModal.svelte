<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
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

  let activeTab: 'draw' | 'sound' | 'magic' = 'draw';
  let magicPrompt = '';
  let magicCategory = 'decorations';
  let isGenerating = false;
  let errorMsg = '';

  $: if (isVisible) {
    activeTab = 'draw';
    magicPrompt = '';
    magicCategory = category;
    errorMsg = '';
  }

  function playTabChime() {
    playSpriteEditorSound('chime', isMuted);
  }

  function handleSaved(event: CustomEvent<string>) {
    targetAssetId = event.detail;
    dispatch('saved', targetAssetId);
  }

  async function handleGenerateStamp() {
    if (!magicPrompt.trim()) return;
    isGenerating = true;
    errorMsg = '';
    playSpriteEditorSound('chime', isMuted);

    const randomId = Math.random().toString(36).substring(2, 7);
    const newAssetId = `magic_${magicCategory.slice(0, 4)}_${randomId}`;

    try {
      await invoke('generate_magic_stamp', {
        assetId: newAssetId,
        category: magicCategory,
        prompt: magicPrompt.trim()
      });
      targetAssetId = newAssetId;
      category = magicCategory;
      dispatch('saved', targetAssetId);
      activeTab = 'draw';
      playSpriteEditorSound('chime', isMuted);
    } catch (err) {
      console.error(err);
      errorMsg = '⚠️ The wand sputtered! Try a different prompt.';
    } finally {
      isGenerating = false;
    }
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
        <button class="tab-btn" class:active={activeTab === 'magic'} on:click={() => { activeTab = 'magic'; playTabChime(); }}>🪄 Magic Stamp</button>
        <button class="tab-btn" class:active={activeTab === 'sound'} on:click={() => { activeTab = 'sound'; playTabChime(); }}>🎵 Toy Sound</button>
      </div>

      {#if activeTab === 'draw'}
        {#key targetAssetId}
          <SpriteDrawStudio
            bind:targetAssetId
            bind:category
            {isMuted}
            on:saved={handleSaved}
          />
        {/key}
      {:else}
        {#if activeTab === 'magic'}
          <div class="magic-generator-container">
            <p class="instruction-text">
              Type anything you want (like "red hot sword" or "spooky green potion") and our magical AI will paint a starting design for you!
            </p>

            <div class="form-group">
              <label for="magic-prompt-input">✨ What should we make?</label>
              <input
                id="magic-prompt-input"
                type="text"
                bind:value={magicPrompt}
                placeholder="e.g. gold key, ice gem, cute red slime, fire brick..."
                on:keydown={(e) => { if (e.key === 'Enter') handleGenerateStamp(); }}
              />
            </div>

            <div class="category-panel-magic">
              <span class="category-label">Choose Category:</span>
              <div class="category-options">
                <button class:active={magicCategory === 'decorations'} on:click={() => magicCategory = 'decorations'}>🧸 Toy</button>
                <button class:active={magicCategory === 'terrain'} on:click={() => magicCategory = 'terrain'}>🪨 Floor</button>
                <button class:active={magicCategory === 'heroes'} on:click={() => magicCategory = 'heroes'}>🦸 Hero</button>
                <button class:active={magicCategory === 'enemies'} on:click={() => magicCategory = 'enemies'}>👾 Monster</button>
                <button class:active={magicCategory === 'collectibles'} on:click={() => magicCategory = 'collectibles'}>🪙 Reward</button>
              </div>
            </div>

            <div class="suggestions-row">
              <span class="sug-label">💡 Ideas:</span>
              <button class="tag-btn" on:click={() => magicPrompt = 'lava block'}>🌋 lava block</button>
              <button class="tag-btn" on:click={() => magicPrompt = 'ice sword'}>❄️ ice sword</button>
              <button class="tag-btn" on:click={() => magicPrompt = 'green potion'}>🧪 green potion</button>
              <button class="tag-btn" on:click={() => magicPrompt = 'shadow heart'}>🖤 shadow heart</button>
              <button class="tag-btn" on:click={() => magicPrompt = 'space alien'}>👽 space alien</button>
            </div>

            <button class="generate-btn" class:pulsing={isGenerating} disabled={isGenerating || !magicPrompt} on:click={handleGenerateStamp}>
              {#if isGenerating}
                🪄 Casting spell... ✨
              {:else}
                ✨ 🪄 Generate Magic Stamp! 🪄 ✨
              {/if}
            </button>

            {#if errorMsg}
              <div class="error-msg">{errorMsg}</div>
            {/if}
          </div>
        {:else}
          <SpriteSoundStudio
            {targetAssetId}
            {category}
            {isMuted}
          />
        {/if}
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

  .magic-generator-container {
    display: flex;
    flex-direction: column;
    gap: 20px;
    background: #0f172a;
    padding: 24px;
    border-radius: 24px;
    border: 2px solid #334155;
    width: 600px;
    max-width: 90vw;
  }

  .instruction-text {
    color: #94a3b8;
    font-size: 0.95rem;
    line-height: 1.5;
    margin: 0;
  }

  .form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .form-group label {
    font-weight: 800;
    color: #fbbf24;
    font-size: 0.95rem;
  }

  .form-group input {
    background: #1e293b;
    border: 2px solid #334155;
    border-radius: 12px;
    color: white;
    padding: 12px;
    font-size: 1rem;
    outline: none;
    font-weight: 600;
  }

  .form-group input:focus {
    border-color: #fbbf24;
  }

  .category-panel-magic {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .category-panel-magic .category-label {
    font-weight: 800;
    color: #94a3b8;
    font-size: 0.9rem;
  }

  .category-panel-magic .category-options {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .category-panel-magic .category-options button {
    border: 0;
    background: #1e293b;
    color: #cbd5e1;
    font-weight: 800;
    padding: 8px 14px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    border: 2px solid transparent;
  }

  .category-panel-magic .category-options button.active {
    background: #eab308;
    color: #0f172a;
    border-color: #fbbf24;
  }

  .suggestions-row {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
  }

  .suggestions-row .sug-label {
    color: #94a3b8;
    font-weight: 800;
    font-size: 0.85rem;
  }

  .tag-btn {
    background: #1e293b;
    border: 1px solid #334155;
    color: #cbd5e1;
    font-size: 0.8rem;
    font-weight: 700;
    padding: 6px 12px;
    border-radius: 10px;
    cursor: pointer;
    box-shadow: none;
  }

  .tag-btn:hover {
    border-color: #fbbf24;
    color: white;
  }

  .generate-btn {
    background: #fbbf24;
    color: #0f172a;
    font-weight: 900;
    border: 0;
    border-radius: 16px;
    padding: 14px;
    font-size: 1.1rem;
    cursor: pointer;
    transition: transform 0.1s, background-color 0.2s;
    box-shadow: 0 4px 0 #d97706;
  }

  .generate-btn:hover:not(:disabled) {
    background: #fcd34d;
  }

  .generate-btn:active:not(:disabled) {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #d97706;
  }

  .generate-btn:disabled {
    background: #475569;
    color: #94a3b8;
    box-shadow: none;
    cursor: not-allowed;
  }

  .error-msg {
    color: #ef4444;
    font-weight: 700;
    font-size: 0.9rem;
    text-align: center;
  }
</style>
