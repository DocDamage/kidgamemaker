<script lang="ts">
  import { createEventDispatcher, onDestroy } from 'svelte';
  import StampVisual from './StampVisual.svelte';
  import {
    eraseEntity,
    stampEntity,
    toRoomPayload,
    type PlacedEntity,
    type ToyboxAsset,
    type WorldSettings
  } from './lib/canvasState';
  import {
    getCanvasCoords as toCanvasCoords,
    getSnappedPosition as snapCanvasPosition
  } from './lib/canvasView';
  import {
    createDefaultWorldSettings
  } from './lib/editorDefaults';
  import { saveRoomPayload } from './lib/roomPersistence';

  export let worldSettings: WorldSettings;
  export let placed: PlacedEntity[];
  export let activeAsset: ToyboxAsset;
  export let eraserMode: boolean;
  export let zoom = 1.0;
  export let snapEnabled = true;
  export let rooms: string[];
  export let activeRoomId: string;
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;

  const dispatch = createEventDispatcher<{
    change: void;
    selectEntity: PlacedEntity | null;
    playSound: 'pop' | 'squeak' | 'chime';
    status: string;
    portalCreated: string;
  }>();

  let offsetX = 100;
  let offsetY = 100;
  
  let isPanning = false;
  let panStart = { x: 0, y: 0 };
  
  let isDrawing = false;
  let hoverPos = { x: 0, y: 0 };
  let isHovering = false;

  let draggingEntity: PlacedEntity | null = null;
  let dragOffset = { x: 0, y: 0 };
  let longPressTimer: ReturnType<typeof setTimeout> | null = null;
  let longPressTriggered = false;

  function getCanvasCoords(clientX: number, clientY: number, rect: DOMRect) {
    return toCanvasCoords(clientX, clientY, rect, offsetX, offsetY, zoom);
  }

  function getSnappedPosition(rawCoords: { x: number; y: number }, asset: ToyboxAsset): { x: number; y: number } {
    return snapCanvasPosition(rawCoords, asset, placed, snapEnabled);
  }

  function handleCanvasClick(event: MouseEvent) {
    dispatch('selectEntity', null);
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    if (eraserMode) {
      const hit = [...placed].reverse().find((item) => {
        const dx = item.position.x - position.x;
        const dy = item.position.y - position.y;
        return Math.sqrt(dx * dx + dy * dy) < 36 / zoom;
      });

      if (hit) {
        placed = eraseEntity(placed, hit.instance_id);
        dispatch('playSound', 'squeak');
        dispatch('change');
      }
      return;
    }

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < 4 && 
               Math.abs(ent.position.y - position.y) < 4
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
      dispatch('playSound', 'pop');
    }
  }

  function paintStamp(event: MouseEvent) {
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    const spacingThreshold = activeAsset.category === 'terrain' ? 48 : 24;

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < spacingThreshold && 
               Math.abs(ent.position.y - position.y) < 8
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
      dispatch('playSound', 'pop');
    }
  }

  function startDrawing(event: MouseEvent) {
    if (event.button === 0) {
      isDrawing = true;
      handleCanvasClick(event);
    }
  }

  function stopDrawing(event: MouseEvent) {
    if (event.button === 0 && isDrawing) {
      isDrawing = false;
      dispatch('change');
    }
  }

  function handleWheel(event: WheelEvent) {
    event.preventDefault();
    const zoomFactor = 0.08;
    let newZoom = zoom;
    if (event.deltaY < 0) {
      newZoom += zoomFactor;
    } else {
      newZoom -= zoomFactor;
    }
    zoom = Math.max(0.5, Math.min(2.0, newZoom));
  }

  function handleMouseDown(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = true;
      panStart = { x: event.clientX - offsetX, y: event.clientY - offsetY };
      event.preventDefault();
    }
  }

  function handleCanvasMove(event: MouseEvent) {
    handleMouseMove(event);
    handleDragMove(event);
  }

  function handleMouseMove(event: MouseEvent) {
    if (isPanning) {
      offsetX = event.clientX - panStart.x;
      offsetY = event.clientY - panStart.y;
    } else {
      const target = event.currentTarget as HTMLDivElement;
      const rect = target.getBoundingClientRect();
      const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
      hoverPos = getSnappedPosition(rawCoords, activeAsset);
      isHovering = true;

      if (isDrawing && !eraserMode) {
        paintStamp(event);
      }
    }
  }

  function handleCanvasMouseUp(event: MouseEvent) {
    stopDrawing(event);
    handleStampLongPressEnd();
  }

  function handleMouseUp(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = false;
    } else if (event.button === 0) {
      handleStampLongPressEnd();
    }
  }

  function handleCanvasLeave() {
    isHovering = false;
    isDrawing = false;
    handleStampLongPressEnd();
  }

  function handlePlacedStampClick(item: PlacedEntity) {
    if (longPressTriggered) {
      longPressTriggered = false;
      return;
    }

    if (eraserMode) {
      placed = eraseEntity(placed, item.instance_id);
      dispatch('playSound', 'squeak');
      dispatch('change');
    } else {
      dispatch('selectEntity', item);
    }
  }

  async function handlePortalPlacement(position: { x: number; y: number }, asset: ToyboxAsset) {
    let targetRoomId = '';
    do {
      targetRoomId = `room_${Math.random().toString(36).substring(2, 8)}`;
    } while (rooms.includes(targetRoomId));

    const thisPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;
    const targetPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;

    const newPortal: PlacedEntity = {
      instance_id: thisPortalId,
      asset_id: asset.id,
      category: asset.category,
      type: asset.type ?? asset.category,
      position,
      modifiers: {
        variant: 'default',
        scale_multiplier: 1.0,
        target_room: targetRoomId,
        target_portal: targetPortalId
      }
    };

    placed = [...placed, newPortal];
    dispatch('change');
    dispatch('status', `Placed portal ${thisPortalId} linking to room ${targetRoomId}`);

    try {
      const returnPortal: PlacedEntity = {
        instance_id: targetPortalId,
        asset_id: asset.id,
        category: asset.category,
        type: asset.type ?? asset.category,
        position: { x: position.x, y: position.y },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0,
          target_room: activeRoomId,
          target_portal: thisPortalId
        }
      };

      const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
      const floorUnderPortal: PlacedEntity = {
        instance_id: `stone_floor_${Math.random().toString(36).substring(2, 8)}`,
        asset_id: terrainAsset.id,
        category: terrainAsset.category,
        type: terrainAsset.type ?? terrainAsset.category,
        position: { x: position.x, y: position.y + 48 },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0
        }
      };

      const targetPayload = toRoomPayload(
        [returnPortal, floorUnderPortal],
        createDefaultWorldSettings(),
        'demo_project',
        targetRoomId
      );

      await saveRoomPayload(targetRoomId, targetPayload);
      dispatch('portalCreated', targetRoomId);
      dispatch('status', `Placed portal linking to auto-created room ${targetRoomId}!`);
    } catch (err) {
      dispatch('status', `Failed to auto-create target room: ${err}`);
    }
  }

  function handleStampLongPressStart(event: MouseEvent, item: PlacedEntity) {
    if (eraserMode) return;
    longPressTriggered = false;
    longPressTimer = setTimeout(() => {
      longPressTriggered = true;
      draggingEntity = item;
      const canvasEl = event.currentTarget as HTMLElement;
      const canvasRect = canvasEl.closest('.canvas')?.getBoundingClientRect();
      if (canvasRect) {
        dragOffset = {
          x: item.position.x - ((event.clientX - canvasRect.left - offsetX) / zoom),
          y: item.position.y - ((event.clientY - canvasRect.top - offsetY) / zoom)
        };
      }
      dispatch('playSound', 'pop');
    }, 400); // 400ms long press
  }

  function handleStampLongPressEnd() {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      longPressTimer = null;
    }
    if (draggingEntity) {
      draggingEntity = null;
      dispatch('change');
      dispatch('playSound', 'chime');
    }
  }

  function handleDragMove(event: MouseEvent) {
    if (!draggingEntity) return;
    const canvasEl = (event.currentTarget as HTMLElement);
    const canvasRect = canvasEl.getBoundingClientRect();
    const rawX = (event.clientX - canvasRect.left - offsetX) / zoom + dragOffset.x;
    const rawY = (event.clientY - canvasRect.top - offsetY) / zoom + dragOffset.y;

    // Snap position
    if (snapEnabled) {
      draggingEntity.position.x = Math.round(rawX / 8) * 8;
      draggingEntity.position.y = Math.round(rawY / 8) * 8;
    } else {
      draggingEntity.position.x = rawX;
      draggingEntity.position.y = rawY;
    }
    placed = [...placed]; // trigger reactivity
  }

  onDestroy(() => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      longPressTimer = null;
    }
  });
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
    border: none;
    background: none;
    cursor: pointer;
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
