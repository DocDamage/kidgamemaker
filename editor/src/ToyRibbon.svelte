<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { getInventoryAssetUrl, isEmojiVisual } from './lib/assetInventory';
  import type { ToyboxAsset } from './lib/canvasState';

  export let favorites: ToyboxAsset[] = [];
  export let quickItems: ToyboxAsset[] = [];
  export let activeAsset: ToyboxAsset;
  export let eraserMode = false;
  export let unlockedStamps: string[] = [];

  const dispatch = createEventDispatcher<{
    select: ToyboxAsset;
  }>();

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

  function animateClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLElement;
    target.classList.remove('bounce-click');
    void target.offsetWidth;
    target.classList.add('bounce-click');
  }

  function selectAsset(event: MouseEvent, asset: ToyboxAsset) {
    if (isItemLocked(asset.id)) {
      alert(`🔒 Locked Stamp: ${asset.name}\nQuest: ${LOCK_RECIPES[asset.id]}`);
      return;
    }
    animateClick(event);
    dispatch('select', asset);
  }
</script>

{#if favorites.length > 0}
  <section class="favorites-ribbon" aria-label="Favorites ribbon">
    <span class="ribbon-label">⭐ Favorites:</span>
    {#each favorites as asset}
      {@const locked = isItemLocked(asset.id)}
      <button
        class="ribbon-btn fav-ribbon-btn"
        class:active={activeAsset.id === asset.id && !eraserMode}
        class:ribbon-btn-locked={locked}
        on:click={(event) => selectAsset(event, asset)}
        title={locked ? `Locked: ${LOCK_RECIPES[asset.id]}` : asset.name}
      >
        <span class="ribbon-visual-container favorite">
          {#if locked}
            <span class="ribbon-lock-emoji">🔒</span>
          {:else if asset.visual && !isEmojiVisual(asset.visual)}
            {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
              <img
                src={getInventoryAssetUrl(asset)}
                alt={asset.name}
                style="
                  width: {asset.frames[0].w}px;
                  height: {asset.frames[0].h}px;
                  object-fit: none;
                  object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                  transform: scale({Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                  transform-origin: center;
                  display: block;
                "
              />
            {:else}
              <img
                src={getInventoryAssetUrl(asset)}
                alt={asset.name}
              />
            {/if}
          {:else}
            <span>{asset.visual ?? '🎮'}</span>
          {/if}
        </span>
        <small>{locked ? 'Locked' : asset.name}</small>
      </button>
    {/each}
  </section>
{/if}

<section class="quick-ribbon" aria-label="Quick toybox ribbon">
  {#each quickItems as asset}
    {@const locked = isItemLocked(asset.id)}
    <button
      class="ribbon-btn"
      class:active={activeAsset.id === asset.id && !eraserMode}
      class:ribbon-btn-locked={locked}
      on:click={(event) => selectAsset(event, asset)}
      title={locked ? `Locked: ${LOCK_RECIPES[asset.id]}` : asset.name}
    >
      <span class="ribbon-visual-container">
        {#if locked}
          <span class="ribbon-lock-emoji">🔒</span>
        {:else if asset.visual && !isEmojiVisual(asset.visual)}
          {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
            <img
              src={getInventoryAssetUrl(asset)}
              alt={asset.name}
              style="
                width: {asset.frames[0].w}px;
                height: {asset.frames[0].h}px;
                object-fit: none;
                object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                transform: scale({Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                transform-origin: center;
                display: block;
              "
            />
          {:else}
            <img
              src={getInventoryAssetUrl(asset)}
              alt={asset.name}
            />
          {/if}
        {:else}
          <span>{asset.visual ?? '🎮'}</span>
        {/if}
      </span>
      <small>{locked ? 'Locked' : asset.name}</small>
    </button>
  {/each}
</section>

<style>
  .quick-ribbon {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px;
    background: #101827;
    border-bottom: 3px solid rgba(255, 255, 255, 0.08);
    overflow-x: auto;
  }

  .favorites-ribbon {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 8px 12px;
    background: #1e1b4b;
    border-bottom: 2px solid rgba(251, 191, 36, 0.4);
    overflow-x: auto;
  }

  .ribbon-btn {
    display: grid;
    place-items: center;
    min-width: 104px;
    transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  .ribbon-btn:hover {
    transform: translateY(-5px) scale(1.05);
  }

  .ribbon-btn:hover span {
    animation: wobble 0.5s ease-in-out infinite alternate;
  }

  .favorites-ribbon .ribbon-btn {
    min-width: 80px;
    padding: 6px 12px;
  }

  .ribbon-visual-container {
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .ribbon-visual-container span,
  .quick-ribbon .ribbon-visual-container {
    font-size: 2rem;
  }

  .ribbon-visual-container.favorite,
  .favorites-ribbon .ribbon-visual-container span {
    font-size: 1.5rem;
  }

  img {
    max-width: 48px;
    max-height: 48px;
    object-fit: contain;
    display: block;
  }

  small {
    max-width: 88px;
    overflow-wrap: anywhere;
  }

  .ribbon-label {
    color: #fbbf24;
    font-weight: 900;
    font-size: 1rem;
    white-space: nowrap;
    margin-right: 8px;
    text-transform: uppercase;
  }

  :global(.bounce-click) {
    animation: bounce-pop 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  @keyframes bounce-pop {
    0% { transform: scale(1); }
    30% { transform: scale(1.15) rotate(-3deg); }
    50% { transform: scale(0.92) rotate(2deg); }
    80% { transform: scale(1.05) rotate(-1deg); }
    100% { transform: scale(1) rotate(0deg); }
  }

  @keyframes wobble {
    0% { transform: rotate(-5deg); }
    100% { transform: rotate(5deg); }
  }

  .ribbon-btn-locked {
    opacity: 0.65;
    background: #374151 !important;
    border: 2px dashed #4b5563 !important;
    cursor: not-allowed;
    transform: none !important;
  }

  .ribbon-btn-locked:hover {
    transform: none !important;
  }

  .ribbon-lock-emoji {
    font-size: 1.8rem !important;
  }
</style>
