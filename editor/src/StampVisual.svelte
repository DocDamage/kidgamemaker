<script lang="ts">
  import { getInventoryAssetUrl, isEmojiVisual } from './lib/assetInventory';
  import type { ToyboxAsset } from './lib/canvasState';

  export let asset: ToyboxAsset | undefined;
  export let category = '';

  $: firstFrame = asset?.frames?.[0];
  $: isTerrain = category === 'terrain';
  $: maxStillWidth = isTerrain ? '150px' : '48px';
  $: spriteScale = firstFrame
    ? isTerrain
      ? Math.min(2.0, 160 / firstFrame.w)
      : Math.min(1.5, 48 / Math.max(firstFrame.w, firstFrame.h))
    : 1;
</script>

<span class="stamp-visual-container">
  {#if asset?.visual && !isEmojiVisual(asset.visual)}
    {#if asset.is_spritesheet && firstFrame}
      <img
        src={getInventoryAssetUrl(asset)}
        alt={asset.name}
        style:width={`${firstFrame.w}px`}
        style:height={`${firstFrame.h}px`}
        style:object-fit="none"
        style:object-position={`-${firstFrame.x}px -${firstFrame.y}px`}
        style:transform={`scale(${spriteScale})`}
        style:transform-origin="center"
      />
    {:else}
      <img
        src={getInventoryAssetUrl(asset)}
        alt={asset.name}
        style:max-width={maxStillWidth}
        style:max-height="48px"
        style:object-fit="contain"
      />
    {/if}
  {:else}
    <span>{asset?.visual ?? '🎮'}</span>
  {/if}
</span>

<style>
  .stamp-visual-container {
    width: 100%;
    height: 100%;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  img {
    display: block;
  }
</style>
