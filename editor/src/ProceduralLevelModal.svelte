<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { getInventoryAssetUrl, isEmojiVisual } from './lib/assetInventory';
  import type { AssetInventory, ToyboxAsset } from './lib/canvasState';

  export let isVisible = false;
  export let inventory: AssetInventory = {};

  const dispatch = createEventDispatcher<{
    close: void;
    generate: { biome: 'forest' | 'castle' | 'space'; difficulty: 'easy' | 'medium' | 'hard'; seed: string };
  }>();

  let selectedBiome: 'forest' | 'castle' | 'space' = 'forest';
  let selectedDifficulty: 'easy' | 'medium' | 'hard' = 'medium';
  let seed = '';

  const SEED_WORDS = ['dragon', 'phoenix', 'castle', 'space', 'unicorn', 'potion', 'crystal', 'forest', 'wizard', 'goblin', 'star', 'rocket', 'comet', 'jungle', 'dungeon'];

  $: if (isVisible && !seed) {
    randomizeSeed();
  }

  $: forestPreview = pickPreview(['forest', 'grass', 'jungle', 'tree', 'plant'], 'terrain');
  $: castlePreview = pickPreview(['castle', 'dungeon', 'stone', 'torch', 'lava'], 'terrain');
  $: spacePreview = pickPreview(['space', 'sci', 'metal', 'alien', 'tech'], 'terrain');

  function randomizeSeed() {
    seed = SEED_WORDS[Math.floor(Math.random() * SEED_WORDS.length)] + '-' + Math.floor(Math.random() * 900 + 100);
  }

  function handleGenerate() {
    dispatch('generate', {
      biome: selectedBiome,
      difficulty: selectedDifficulty,
      seed: seed.trim() || 'default-seed'
    });
  }

  function pickPreview(terms: string[], preferredCategory: string): ToyboxAsset | undefined {
    const preferred = inventory[preferredCategory] ?? [];
    const all = [...preferred, ...Object.values(inventory).flat()];
    return all.find((asset) => {
      const visual = asset.visual ?? '';
      const searchable = `${asset.id} ${asset.name} ${asset.type ?? ''} ${asset.source_pack ?? ''}`.toLowerCase();
      return visual && !isEmojiVisual(visual) && terms.some((term) => searchable.includes(term));
    }) ?? all.find((asset) => asset.visual && !isEmojiVisual(asset.visual));
  }
</script>

{#if isVisible}
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')}>
    <div class="modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <header>
        <h2>Procedural Level Builder</h2>
        <button class="close-btn" on:click={() => dispatch('close')}>✕</button>
      </header>

      <div class="modal-body">
        <p class="description">
          Choose a biome and a difficulty, and let the magical level compiler assemble a grammar-based platformer map from your seed!
        </p>

        <!-- Biome selection -->
        <div class="section">
          <h3>Choose Biome Theme:</h3>
          <div class="cards-grid">
            <button class="card" class:active={selectedBiome === 'forest'} on:click={() => selectedBiome = 'forest'}>
              <span class="preview">{#if forestPreview}<img src={getInventoryAssetUrl(forestPreview)} alt="Forest preview" />{/if}</span>
              <span class="title">Forest Biome</span>
              <span class="card-desc">Charming green woods, cute slimes, hidden gems, and butterflies.</span>
            </button>
            <button class="card" class:active={selectedBiome === 'castle'} on:click={() => selectedBiome = 'castle'}>
              <span class="preview">{#if castlePreview}<img src={getInventoryAssetUrl(castlePreview)} alt="Castle preview" />{/if}</span>
              <span class="title">Spooky Castle</span>
              <span class="card-desc">Fiery volcanic dungeon with spikes, locked security gates, and red bats.</span>
            </button>
            <button class="card" class:active={selectedBiome === 'space'} on:click={() => selectedBiome = 'space'}>
              <span class="preview">{#if spacePreview}<img src={getInventoryAssetUrl(spacePreview)} alt="Space preview" />{/if}</span>
              <span class="title">Cosmic Space</span>
              <span class="card-desc">Zero-gravity zones, neon tiles, futuristic platforms, and stardust.</span>
            </button>
          </div>
        </div>

        <!-- Difficulty selection -->
        <div class="section">
          <h3>Choose Challenge Level:</h3>
          <div class="options-row">
            <button class="difficulty-btn easy" class:active={selectedDifficulty === 'easy'} on:click={() => selectedDifficulty = 'easy'}>
              Easy
            </button>
            <button class="difficulty-btn medium" class:active={selectedDifficulty === 'medium'} on:click={() => selectedDifficulty = 'medium'}>
              Medium
            </button>
            <button class="difficulty-btn hard" class:active={selectedDifficulty === 'hard'} on:click={() => selectedDifficulty = 'hard'}>
              Hard
            </button>
          </div>
        </div>

        <!-- Seed input -->
        <div class="section">
          <h3>Custom Level Seed:</h3>
          <div class="input-row">
            <input type="text" bind:value={seed} placeholder="Type a seed word..." />
            <button class="random-btn" on:click={randomizeSeed}>Randomize</button>
          </div>
        </div>

        <!-- Generate Button -->
        <button class="generate-btn" on:click={handleGenerate}>
          Compile & Generate Level
        </button>
      </div>
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
    z-index: 1000;
    font-family: 'Inter', system-ui, sans-serif;
  }

  .modal {
    background: #1e293b;
    border: 6px solid #fbbf24;
    border-radius: 40px;
    padding: 32px;
    color: white;
    width: 650px;
    max-width: 90vw;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
    outline: none;
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
    font-size: 1.8rem;
    font-weight: 900;
  }

  .close-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 50%;
    width: 36px;
    height: 36px;
    font-size: 1.2rem;
    font-weight: 900;
    cursor: pointer;
    display: grid;
    place-items: center;
    box-shadow: none;
  }

  .modal-body {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .description {
    color: #94a3b8;
    font-size: 0.95rem;
    line-height: 1.5;
    margin: 0;
  }

  .section {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .section h3 {
    margin: 0;
    font-size: 1rem;
    font-weight: 800;
    color: #fbbf24;
  }

  .cards-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
  }

  .card {
    background: #0f172a;
    border: 3px solid #334155;
    border-radius: 20px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    transition: all 0.2s;
    color: white;
  }

  .card:hover {
    border-color: #fbbf24;
    background: rgba(251, 191, 36, 0.02);
  }

  .card.active {
    border-color: #fbbf24;
    background: rgba(251, 191, 36, 0.1);
  }

  .preview {
    width: 72px;
    height: 46px;
    display: grid;
    place-items: center;
    overflow: hidden;
    border-radius: 6px;
    background: rgba(148, 163, 184, 0.12);
  }

  .preview img {
    max-width: 72px;
    max-height: 46px;
    object-fit: contain;
    display: block;
  }

  .card .title {
    font-weight: 900;
    font-size: 1rem;
    color: #f8fafc;
  }

  .card .card-desc {
    font-size: 0.75rem;
    color: #94a3b8;
    text-align: center;
    line-height: 1.4;
  }

  .options-row {
    display: flex;
    gap: 12px;
  }

  .difficulty-btn {
    flex: 1;
    border: 3px solid #334155;
    background: #0f172a;
    color: #cbd5e1;
    font-weight: 800;
    padding: 12px;
    border-radius: 16px;
    cursor: pointer;
    font-size: 1rem;
    transition: all 0.2s;
  }

  .difficulty-btn:hover {
    border-color: #fbbf24;
  }

  .difficulty-btn.active.easy {
    background: rgba(16, 185, 129, 0.2);
    border-color: #10b981;
    color: #10b981;
  }

  .difficulty-btn.active.medium {
    background: rgba(245, 158, 11, 0.2);
    border-color: #f59e0b;
    color: #f59e0b;
  }

  .difficulty-btn.active.hard {
    background: rgba(239, 68, 68, 0.2);
    border-color: #ef4444;
    color: #ef4444;
  }

  .input-row {
    display: flex;
    gap: 12px;
  }

  .input-row input {
    flex: 1;
    background: #0f172a;
    border: 2px solid #334155;
    border-radius: 16px;
    color: white;
    padding: 12px 16px;
    font-size: 1rem;
    font-weight: 600;
    outline: none;
  }

  .input-row input:focus {
    border-color: #fbbf24;
  }

  .random-btn {
    background: #334155;
    color: white;
    font-weight: 800;
    border: 0;
    border-radius: 16px;
    padding: 0 20px;
    cursor: pointer;
    box-shadow: 0 4px 0 #1e293b;
  }

  .random-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #1e293b;
  }

  .generate-btn {
    background: #fbbf24;
    color: #0f172a;
    font-weight: 900;
    font-size: 1.25rem;
    border: 0;
    border-radius: 20px;
    padding: 16px;
    cursor: pointer;
    box-shadow: 0 6px 0 #d97706;
    transition: transform 0.1s, background-color 0.2s;
    margin-top: 10px;
  }

  .generate-btn:hover {
    background: #fcd34d;
  }

  .generate-btn:active {
    transform: translateY(3px);
    box-shadow: 0 3px 0 #d97706;
  }
</style>
