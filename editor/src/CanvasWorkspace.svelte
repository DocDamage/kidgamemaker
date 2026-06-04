<script lang="ts">
  import StampVisual from './StampVisual.svelte';
  import type { PlacedEntity, ToyboxAsset, WorldSettings } from './lib/canvasState';

  export let worldSettings: WorldSettings;
  export let placed: PlacedEntity[];
  export let activeAsset: ToyboxAsset;
  export let eraserMode: boolean;
  export let offsetX: number;
  export let offsetY: number;
  export let zoom: number;
  export let isHovering: boolean;
  export let hoverPos: { x: number; y: number };
  export let draggingEntity: PlacedEntity | null;
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;
  export let startDrawing: (event: MouseEvent) => void;
  export let stopDrawing: (event: MouseEvent) => void;
  export let handleMouseMove: (event: MouseEvent) => void;
  export let handleDragMove: (event: MouseEvent) => void;
  export let handleWheel: (event: WheelEvent) => void;
  export let handleMouseDown: (event: MouseEvent) => void;
  export let handleMouseUp: (event: MouseEvent) => void;
  export let handleCanvasLeave: () => void;
  export let handleStampLongPressStart: (event: MouseEvent, item: PlacedEntity) => void;
  export let handleStampLongPressEnd: () => void;
  export let handlePlacedStampClick: (item: PlacedEntity) => void;

  function handleCanvasMove(event: MouseEvent) {
    handleMouseMove(event);
    handleDragMove(event);
  }

  function handleCanvasMouseUp(event: MouseEvent) {
    stopDrawing(event);
    handleStampLongPressEnd();
  }

</script>

<!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
  class="canvas theme-{worldSettings.theme || 'default'}"
  on:mousedown={startDrawing}
  on:mousemove={handleCanvasMove}
  on:mouseup={handleCanvasMouseUp}
  on:mouseleave={handleCanvasLeave}
  on:wheel={handleWheel}
  on:contextmenu|preventDefault
  on:mousedown|stopPropagation={handleMouseDown}
  on:mouseup|stopPropagation={handleMouseUp}
  aria-label="Game canvas"
>
  <div
    class="canvas-inner"
    style:transform={`translate(${offsetX}px, ${offsetY}px) scale(${zoom})`}
    style:transform-origin="0 0"
  >
    <div class="horizon"></div>
    {#each placed as item (item.instance_id)}
      {@const asset = findAsset(item.asset_id)}
      <button
        class="stamp {item.category}"
        class:stamp-dragging={draggingEntity?.instance_id === item.instance_id}
        style:left={`${item.position.x}px`}
        style:top={`${item.position.y}px`}
        title={`${item.asset_id} ${item.instance_id}${item.modifiers.target_room ? ` (Leads to ${item.modifiers.target_room})` : ''}`}
        on:click|stopPropagation={() => handlePlacedStampClick(item)}
        on:mousedown|stopPropagation={(event) => handleStampLongPressStart(event, item)}
        on:mouseup|stopPropagation={handleStampLongPressEnd}
        style:border-radius={item.category === 'terrain' ? '14px' : '50%'}
        style:width={item.category === 'terrain' ? '160px' : '56px'}
        style:overflow="hidden"
      >
        <StampVisual {asset} category={item.category} />
      </button>
    {/each}

    {#if isHovering && !eraserMode}
      <div
        class="hover-guide {activeAsset.category}"
        style:left={`${hoverPos.x}px`}
        style:top={`${hoverPos.y}px`}
        style:border-radius={activeAsset.category === 'terrain' ? '14px' : '50%'}
        style:width={activeAsset.category === 'terrain' ? '160px' : '56px'}
        style:overflow="hidden"
      >
        <StampVisual asset={activeAsset} category={activeAsset.category} />
      </div>
    {/if}
  </div>
</div>

<style>
  .canvas {
    position: relative;
    overflow: hidden;
    cursor: grab;
    transition: background 0.6s cubic-bezier(0.2, 0.8, 0.2, 1);
  }

  .canvas:active {
    cursor: grabbing;
  }

  .canvas.theme-default {
    background: linear-gradient(#31466d, #1d2d45 55%, #1b2331 55%);
  }

  .canvas.theme-space {
    background: linear-gradient(#0d1130, #06081c 55%, #030412 55%);
  }

  .canvas.theme-candy {
    background: linear-gradient(#fecdd3, #fda4af 55%, #f43f5e 55%);
  }

  .canvas.theme-jungle {
    background: linear-gradient(#4d7c0f, #15803d 55%, #14532d 55%);
  }

  .canvas.theme-ice {
    background: linear-gradient(#e0f2fe, #bae6fd 55%, #38bdf8 55%);
  }

  .canvas.theme-volcano {
    background: linear-gradient(#7f1d1d, #ef4444 55%, #450a0a 55%);
  }

  .canvas-inner {
    position: absolute;
    width: 5000px;
    height: 3000px;
    pointer-events: none;
    background:
      linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
    background-size: 32px 32px, 32px 32px;
  }

  .canvas-inner :global(*) {
    pointer-events: auto;
  }

  .horizon {
    position: absolute;
    left: 0;
    right: 0;
    top: 55%;
    height: 4px;
    background: rgba(255, 255, 255, 0.08);
  }

  .stamp {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    padding: 0;
    display: grid;
    place-items: center;
    font-size: 2rem;
    border-radius: 50%;
    animation: stamp-pop-in 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }

  .stamp.terrain {
    width: 160px;
    border-radius: 14px;
  }

  .hover-guide {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    opacity: 0.5;
    border: 3px dashed #ffd84d;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 2rem;
    pointer-events: none;
  }

  .hover-guide.terrain {
    width: 160px;
    border-radius: 14px;
  }

  @keyframes stamp-pop-in {
    0% {
      transform: translate(-50%, -50%) scale(0);
      opacity: 0;
    }
    50% {
      transform: translate(-50%, -50%) scale(1.3);
      opacity: 1;
    }
    70% {
      transform: translate(-50%, -50%) scale(0.9);
    }
    100% {
      transform: translate(-50%, -50%) scale(1);
    }
  }

  .stamp-dragging {
    outline: 4px dashed #fbbf24 !important;
    z-index: 999 !important;
    cursor: grabbing !important;
    filter: drop-shadow(0 0 12px rgba(251, 191, 36, 0.7));
    animation: none !important;
  }
</style>
