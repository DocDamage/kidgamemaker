<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { favoriteInventoryItems, getInventoryAssetUrl, isEmojiVisual, isStampReadyAsset } from './lib/assetInventory';
  import { createAudioContext } from './lib/webAudio';
  import type { AssetInventory, ToyboxAsset } from './lib/canvasState';

  export let isVisible = false;
  export let inventory: AssetInventory = {};
  export let isMuted = false;
  export let favorites: string[] = [];
  export let unlockedStamps: string[] = [];

  const LOCKED_BY_DEFAULT = ['effects_fire', 'effects_snow', 'effects_sparkles', 'celestial_sprite'];
  const LOCK_RECIPES: Record<string, string> = {
    'effects_fire': '🔥 Place 3 Fire Torches to unlock!',
    'effects_snow': '❄️ Place 3 Ice Crystals to unlock!',
    'effects_sparkles': '🌟 Place 3 Star Pieces to unlock!',
    'celestial_sprite': '🌌 Connect the Pegasus Diamond constellation in the Star Mapper drawer to unlock!'
  };

  function isItemLocked(itemId: string) {
    return LOCKED_BY_DEFAULT.includes(itemId) && !unlockedStamps.includes(itemId);
  }

  function handleToyClick(item: ToyboxAsset) {
    if (isItemLocked(item.id)) {
      alert(`🔒 Locked Stamp: ${item.name}\nQuest: ${LOCK_RECIPES[item.id]}`);
      return;
    }
    dispatch('itemSelected', item);
  }

  const dispatch = createEventDispatcher<{
    itemSelected: ToyboxAsset;
    close: void;
  }>();

  let activeCategory = 'terrain';
  let activePack = 'all';

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

  $: packOptions = buildPackOptions(inventory);
  $: if (isVisible && !packOptions.some((pack) => pack.id === activePack)) {
    activePack = 'all';
  }
  $: packFilteredInventory = filterInventoryByPack(inventory, activePack);

  // Keep first available category active inside the selected pack.
  $: if (isVisible && packFilteredInventory) {
    const keys = Object.keys(CATEGORY_MAP);
    const available = keys.filter(k => k === 'favorites' || (packFilteredInventory[k] && packFilteredInventory[k].length > 0));
    if (available.length > 0 && !available.includes(activeCategory)) {
      activeCategory = available[0];
    }
  }

  $: itemsToDisplay = (activeCategory === 'favorites'
    ? favoriteInventoryItems(packFilteredInventory, favorites)
    : (packFilteredInventory[activeCategory] || [])).filter(isStampReadyAsset);

  function packIdFor(item: ToyboxAsset) {
    return item.source_pack || item.source_author || 'built-in';
  }

  function packLabelFor(packId: string) {
    if (packId === 'all') return 'All Toyboxes';
    if (packId === 'built-in') return 'Built-in';
    return packId;
  }

  function buildPackOptions(sourceInventory: AssetInventory) {
    const counts = new Map<string, number>();
    for (const items of Object.values(sourceInventory)) {
      for (const item of items) {
        if (!isStampReadyAsset(item)) continue;
        const packId = packIdFor(item);
        counts.set(packId, (counts.get(packId) ?? 0) + 1);
      }
    }

    return [
      { id: 'all', label: 'All Toyboxes', count: Array.from(counts.values()).reduce((total, count) => total + count, 0) },
      ...Array.from(counts.entries())
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([id, count]) => ({ id, label: packLabelFor(id), count }))
    ];
  }

  function filterInventoryByPack(sourceInventory: AssetInventory, packId: string): AssetInventory {
    const next: AssetInventory = {};
    for (const [category, items] of Object.entries(sourceInventory)) {
      const filtered = items.filter((item) => isStampReadyAsset(item) && (packId === 'all' || packIdFor(item) === packId));
      if (filtered.length > 0) {
        next[category] = filtered;
      }
    }
    return next;
  }

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
        <div>
          <h2>🧸 Toybox</h2>
          <p class="pack-credit">{activePack === 'all' ? 'Choose a creator pack or browse everything.' : `Creator pack: ${packLabelFor(activePack)}`}</p>
        </div>
        <button class="close-btn" on:click={() => dispatch('close')}>✕ Close</button>
      </header>

      <div class="pack-tabs" aria-label="Toybox packs">
        {#each packOptions as pack}
          <button
            class="pack-btn"
            class:active={activePack === pack.id}
            type="button"
            on:click={() => { activePack = pack.id; playTabSound(); }}
          >
            <span>{pack.label}</span>
            <small>{pack.count}</small>
          </button>
        {/each}
      </div>

      <!-- Emoji tabs -->
      <div class="tabs-container">
        {#each Object.entries(CATEGORY_MAP) as [catId, info]}
          {#if catId === 'favorites' ? favoriteInventoryItems(packFilteredInventory, favorites).length > 0 : (packFilteredInventory[catId] && packFilteredInventory[catId].length > 0)}
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
                class:toy-locked={isItemLocked(item.id)}
                role="button" 
                tabindex="0" 
                on:click={() => handleToyClick(item)}
                on:keydown={(e) => e.key === 'Enter' && handleToyClick(item)}
              >
                {#if !isItemLocked(item.id)}
                  <button
                    type="button"
                    class="favorite-btn"
                    on:click={(e) => toggleFavorite(item.id, e)}
                    title="Favorite this toy"
                  >
                    {favorites.includes(item.id) ? '❤️' : '🤍'}
                  </button>
                {/if}
                <span class="toy-visual-container">
                  {#if isItemLocked(item.id)}
                    <span class="lock-overlay-emoji">🔒</span>
                  {:else if item.visual && !isEmojiVisual(item.visual)}
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
                <strong>{isItemLocked(item.id) ? 'Locked' : item.name}</strong>
                {#if !isItemLocked(item.id)}
                  <span class="source-credit">{packLabelFor(packIdFor(item))}</span>
                {/if}
                {#if isItemLocked(item.id)}
                  <span class="recipe-hint">{LOCK_RECIPES[item.id]}</span>
                {/if}
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

  .pack-credit {
    margin: 4px 0 0;
    color: #cbd5e1;
    font-size: 0.9rem;
    font-weight: 700;
  }

  .pack-tabs {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-top: 20px;
    padding: 10px;
    border-radius: 18px;
    background: rgba(15, 23, 42, 0.45);
    border: 1px solid rgba(148, 163, 184, 0.18);
  }

  .pack-btn {
    border: 1px solid rgba(148, 163, 184, 0.28);
    border-radius: 10px;
    padding: 8px 10px;
    background: #0f172a;
    color: #cbd5e1;
    font-weight: 900;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    box-shadow: none;
  }

  .pack-btn small {
    color: #94a3b8;
    font-size: 0.75rem;
  }

  .pack-btn.active {
    background: #fbbf24;
    color: #0f172a;
    border-color: #fbbf24;
  }

  .pack-btn.active small {
    color: #334155;
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
    grid-template-columns: repeat(auto-fill, minmax(104px, 1fr));
    gap: 18px;
  }

  .toy {
    position: relative;
    min-height: 104px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    border: 0;
    border-radius: 8px;
    background: transparent;
    color: #f8fafc;
    cursor: pointer;
    font-weight: 900;
    padding: 8px;
    box-shadow: none;
    transition: transform 0.1s, background 0.2s;
  }

  .toy:hover {
    background: rgba(148, 163, 184, 0.12);
    transform: translateY(-2px);
    box-shadow: none;
  }

  .toy:active {
    transform: translateY(1px);
    box-shadow: none;
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

  .toy-locked {
    background: rgba(71, 85, 105, 0.35) !important;
    color: #94a3b8 !important;
    cursor: not-allowed;
    box-shadow: none !important;
    opacity: 0.8;
  }

  .toy-locked:hover {
    background: rgba(71, 85, 105, 0.35) !important;
    transform: none !important;
    box-shadow: none !important;
  }

  .lock-overlay-emoji {
    font-size: 2.4rem !important;
  }

  .recipe-hint {
    font-size: 0.65rem;
    color: #fca5a5;
    text-align: center;
    line-height: 1.1;
  }

  .source-credit {
    font-size: 0.65rem !important;
    line-height: 1;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0;
  }
</style>
