<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { favoriteInventoryItems, getInventoryAssetUrl, isEmojiVisual } from './lib/assetInventory';
  import { createAudioContext } from './lib/webAudio';
  import type { AssetInventory, ToyboxAsset } from './lib/canvasState';

  export let isVisible = false;
  export let inventory: AssetInventory = {};
  export let isMuted = false;
  export let favorites: string[] = [];

  const dispatch = createEventDispatcher<{
    itemSelected: ToyboxAsset;
    close: void;
  }>();

  let activeCategory = 'terrain';

  const CATEGORY_MAP: Record<string, { label: string; emoji: string; color: string }> = {
    favorites: { label: 'Favorites', emoji: '⭐', color: '#fbbf24' },
    terrain: { label: 'Floor', emoji: '🧱', color: '#fbbf24' },
    heroes: { label: 'Hero', emoji: '🦸', color: '#60a5fa' },
    enemies: { label: 'Monster', emoji: '👾', color: '#f87171' },
    collectibles: { label: 'Reward', emoji: '🪙', color: '#34d399' },
    portals: { label: 'Portal', emoji: '🚪', color: '#a78bfa' },
    decorations: { label: 'Toy', emoji: '🎪', color: '#ec4899' },
    particles: { label: 'Effects', emoji: '✨', color: '#c084fc' }
  };

  // Keep first available category active if 'terrain' doesn't exist
  $: if (isVisible && inventory) {
    const keys = Object.keys(CATEGORY_MAP);
    const available = keys.filter(k => k === 'favorites' || (inventory[k] && inventory[k].length > 0));
    if (available.length > 0 && !available.includes(activeCategory)) {
      activeCategory = available[0];
    }
  }

  $: itemsToDisplay = activeCategory === 'favorites'
    ? favoriteInventoryItems(inventory, favorites)
    : (inventory[activeCategory] || []);

  function toggleFavorite(itemId: string, event: Event) {
    event.stopPropagation();
    if (favorites.includes(itemId)) {
      favorites = favorites.filter(id => id !== itemId);
    } else {
      favorites = [...favorites, itemId];
    }
    playTabSound();
  }

  // Local synthesizer sound trigger
  let audioCtx: AudioContext | null = null;
  function getAudioContext() {
    if (!audioCtx) {
      audioCtx = createAudioContext();
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  function playTabSound() {
    if (isMuted) return;
    try {
      const ctx = getAudioContext();
      const now = ctx.currentTime;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(320, now);
      osc.frequency.exponentialRampToValueAtTime(750, now + 0.08);
      gain.gain.setValueAtTime(0.08, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.08);
    } catch (_) {}
  }
</script>

{#if isVisible}
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')} on:keydown={(e) => e.key === 'Escape' && dispatch('close')}>
    <div class="modal" role="dialog" aria-modal="true" aria-label="Toybox" tabindex="0" on:click|stopPropagation on:keydown|stopPropagation>
      <header>
        <h2>🧸 Toybox</h2>
        <button class="close-btn" on:click={() => dispatch('close')}>✕ Close</button>
      </header>

      <!-- Emoji tabs -->
      <div class="tabs-container">
        {#each Object.entries(CATEGORY_MAP) as [catId, info]}
          {#if catId === 'favorites' ? favorites.length > 0 : (inventory[catId] && inventory[catId].length > 0)}
            <button
              class="tab-btn"
              class:active={activeCategory === catId}
              style="--accent-color: {info.color}"
              on:click={() => { activeCategory = catId; playTabSound(); }}
            >
              <span class="tab-emoji">{info.emoji}</span>
              <span class="tab-label">{info.label}</span>
            </button>
          {/if}
        {/each}
      </div>

      <!-- Active category toys -->
      <div class="active-category-section">
        {#if itemsToDisplay && itemsToDisplay.length > 0}
          <div class="grid">
            {#each itemsToDisplay as item}
              <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
              <!-- svelte-ignore a11y_click_events_have_key_events -->
              <div 
                class="toy" 
                role="button" 
                tabindex="0" 
                on:click={() => dispatch('itemSelected', item)}
                on:keydown={(e) => e.key === 'Enter' && dispatch('itemSelected', item)}
              >
                <button
                  type="button"
                  class="favorite-btn"
                  on:click={(e) => toggleFavorite(item.id, e)}
                  title="Favorite this toy"
                >
                  {favorites.includes(item.id) ? '❤️' : '🤍'}
                </button>
                <span class="toy-visual-container">
                  {#if item.visual && !isEmojiVisual(item.visual)}
                    {#if item.is_spritesheet && item.frames && item.frames[0]}
                      <img
                        src={getInventoryAssetUrl(item)}
                        alt={item.name}
                        style="
                          width: {item.frames[0].w}px;
                          height: {item.frames[0].h}px;
                          object-fit: none;
                          object-position: -{item.frames[0].x}px -{item.frames[0].y}px;
                          transform: scale({Math.min(1.5, 48 / Math.max(item.frames[0].w, item.frames[0].h))});
                          transform-origin: center;
                          display: block;
                        "
                      />
                    {:else}
                      <img
                        src={getInventoryAssetUrl(item)}
                        alt={item.name}
                        style="max-width: 48px; max-height: 48px; object-fit: contain; display: block;"
                      />
                    {/if}
                  {:else}
                    <span>{item.visual ?? '🎮'}</span>
                  {/if}
                </span>
                <strong>{item.name}</strong>
              </div>
            {/each}
          </div>
        {:else}
          <p class="empty-state">No toys here yet!</p>
        {/if}
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
    z-index: 100;
  }

  .modal {
    width: min(850px, 92vw);
    max-height: 86vh;
    overflow: auto;
    border-radius: 40px;
    border: 6px solid #fbbf24;
    background: #1e293b;
    color: white;
    padding: 32px;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
  }

  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
  }

  h2 {
    margin: 0;
    font-size: 2.2rem;
    color: #fbbf24;
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

  /* Emoji Tabs layout */
  .tabs-container {
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
    margin-top: 24px;
    background: rgba(15, 23, 42, 0.4);
    padding: 12px;
    border-radius: 24px;
    border: 2px solid rgba(255, 255, 255, 0.05);
  }

  .tab-btn {
    border: 0;
    background: #334155;
    color: #94a3b8;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.3);
    transition: transform 0.1s, background 0.2s, color 0.2s, box-shadow 0.2s;
  }

  .tab-btn:hover {
    background: #475569;
    color: white;
  }

  .tab-btn.active {
    background: var(--accent-color);
    color: #0f172a;
    transform: scale(1.06);
    box-shadow: 0 4px 14px var(--accent-color);
  }

  .tab-btn:active {
    transform: translateY(3px) scale(0.97);
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.3);
  }

  .tab-emoji {
    font-size: 1.6rem;
  }

  .active-category-section {
    margin-top: 24px;
    padding: 10px 0;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(136px, 1fr));
    gap: 16px;
  }

  .toy {
    position: relative;
    min-height: 116px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    border: 0;
    border-radius: 24px;
    background: #f8fafc;
    color: #0f172a;
    cursor: pointer;
    font-weight: 900;
    padding: 12px;
    box-shadow: 0 5px 0 #cbd5e1;
    transition: transform 0.1s, box-shadow 0.1s, background 0.2s;
  }

  .toy:hover {
    background: #ffffff;
    transform: translateY(-4px);
    box-shadow: 0 9px 0 #cbd5e1;
  }

  .toy:active {
    transform: translateY(3px);
    box-shadow: 0 2px 0 #cbd5e1;
  }

  .favorite-btn {
    position: absolute;
    top: 8px;
    right: 8px;
    background: transparent;
    border: none;
    font-size: 1.3rem;
    cursor: pointer;
    padding: 4px;
    box-shadow: none !important;
    transform: none;
    transition: transform 0.1s;
    z-index: 10;
  }

  .favorite-btn:hover {
    transform: scale(1.2);
    background: transparent !important;
  }

  .favorite-btn:active {
    transform: scale(0.9);
    background: transparent !important;
  }

  .toy span {
    font-size: 2.8rem;
  }


  .toy-visual-container {
    width: 60px;
    height: 60px;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .empty-state {
    text-align: center;
    color: #94a3b8;
    font-size: 1.3rem;
    margin-top: 48px;
  }
</style>
