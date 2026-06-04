<script lang="ts">
  import { createEventDispatcher, onDestroy, onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { playSpriteEditorSound } from './lib/spriteEditorAudio';
  import {
    addAnimationFrame,
    advanceAnimationFrame,
    applyTemplateGrid,
    cloneGrid,
    createEmptyGrid,
    createPixelHistory,
    deleteAnimationFrame,
    drawPixelGrid,
    exportFramesToPngBase64,
    floodFillGrid,
    paintBrush,
    pushPixelHistory,
    restorePixelHistory,
    selectAnimationFrame,
    type PixelGrid,
    type PixelFrameState,
    type PixelHistoryState
  } from './lib/spriteGrid';
  import { SPRITE_EDITOR_COLORS, SPRITE_EDITOR_GRID_SIZE } from './lib/spriteEditorConfig';
  import { SPRITE_TEMPLATES, type SpriteTemplateName } from './lib/spriteTemplates';
  import SpriteTemplatesPanel from './SpriteTemplatesPanel.svelte';
  import SpriteEditorPalette from './SpriteEditorPalette.svelte';

  export let targetAssetId = '';
  export let category = 'decorations';
  export let isMuted = false;

  const dispatch = createEventDispatcher<{
    saved: string;
  }>();

  const GRID_SIZE = SPRITE_EDITOR_GRID_SIZE;
  let canvasElement: HTMLCanvasElement;
  let ctx: CanvasRenderingContext2D | null = null;

  let currentColor = '#ff4b4b';
  let isDrawing = false;
  let isEraser = false;
  let brushSize = 1;
  let isBucket = false;
  let symmetryMode: 'none' | 'horizontal' | 'vertical' | 'both' = 'none';
  let isRainbowBrush = false;
  let rainbowHue = 0;

  let pixels: PixelGrid = createEmptyGrid(GRID_SIZE);

  // Undo/Redo history stack
  let historyState: PixelHistoryState = { history: [], index: -1 };
  let history: PixelGrid[] = [];
  let historyIndex = -1;
  $: history = historyState.history;
  $: historyIndex = historyState.index;

  // Animation frames state
  let frameList: PixelGrid[] = [createEmptyGrid(GRID_SIZE)];
  let currentFrameIdx = 0;
  let isAnimPlaying = false;
  let animIntervalId: ReturnType<typeof setInterval> | null = null;

  function currentFrameState(): PixelFrameState {
    return { frames: frameList, currentIndex: currentFrameIdx, pixels };
  }

  function applyFrameState(state: PixelFrameState) {
    frameList = state.frames;
    currentFrameIdx = state.currentIndex;
    pixels = state.pixels;
  }

  onMount(async () => {
    initCanvas();
    await loadExistingSprite();
  });

  onDestroy(() => {
    stopAnimPlayback(false);
  });

  function playDrawSound(type: 'draw' | 'clear' | 'chime') {
    playSpriteEditorSound(type, isMuted);
  }

  function saveHistoryState() {
    historyState = pushPixelHistory(historyState, pixels);
  }

  function handleUndo() {
    const restored = restorePixelHistory(historyState, 'undo');
    if (!restored) return;
    historyState = restored.state;
    pixels = restored.grid;
    redrawGrid();
    triggerAutoSave();
    playDrawSound('draw');
  }

  function handleRedo() {
    const restored = restorePixelHistory(historyState, 'redo');
    if (!restored) return;
    historyState = restored.state;
    pixels = restored.grid;
    redrawGrid();
    triggerAutoSave();
    playDrawSound('draw');
  }

  function applyTemplate(templateName: SpriteTemplateName) {
    pixels = applyTemplateGrid(SPRITE_TEMPLATES[templateName], GRID_SIZE);
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('chime');
  }

  function initCanvas() {
    ctx = canvasElement.getContext('2d');
    if (!ctx) return;
    ctx.imageSmoothingEnabled = false;
  }

  function addFrame() {
    const nextFrameState = addAnimationFrame(currentFrameState());
    if (!nextFrameState) return;
    applyFrameState(nextFrameState);
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('chime');
  }

  function deleteFrame(idx: number) {
    if (isAnimPlaying) toggleAnimPlayback();
    const nextFrameState = deleteAnimationFrame(currentFrameState(), idx);
    if (!nextFrameState) return;
    applyFrameState(nextFrameState);
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('clear');
  }

  function selectFrame(idx: number) {
    if (isAnimPlaying) toggleAnimPlayback();
    const nextFrameState = selectAnimationFrame(currentFrameState(), idx);
    if (!nextFrameState) return;
    applyFrameState(nextFrameState);
    redrawGrid();
    playDrawSound('draw');
  }

  function toggleAnimPlayback() {
    isAnimPlaying = !isAnimPlaying;
    if (isAnimPlaying) {
      const savedFrameState = selectAnimationFrame(currentFrameState(), currentFrameIdx);
      if (savedFrameState) {
        applyFrameState(savedFrameState);
      }
      animIntervalId = setInterval(() => {
        applyFrameState(advanceAnimationFrame(currentFrameState()));
        redrawGrid();
      }, 150); // 8fps loop
    } else {
      stopAnimPlayback();
    }
  }

  function stopAnimPlayback(shouldRedraw = true) {
    if (animIntervalId) {
      clearInterval(animIntervalId);
      animIntervalId = null;
    }
    isAnimPlaying = false;
    pixels = frameList[currentFrameIdx];
    if (shouldRedraw) {
      redrawGrid();
    }
  }

  async function loadExistingSprite() {
    if (targetAssetId) {
      try {
        const loadedFrames = await invoke<string[][][]>('load_child_sprite', {
          assetId: targetAssetId,
          category: category
        });
        if (loadedFrames && loadedFrames.length > 0) {
          frameList = loadedFrames;
          currentFrameIdx = 0;
          pixels = frameList[0];
        }
      } catch (err) {
        console.error('Failed to load existing sprite:', err);
        frameList = [createEmptyGrid(GRID_SIZE)];
        currentFrameIdx = 0;
        pixels = frameList[0];
      }
    } else {
      frameList = [createEmptyGrid(GRID_SIZE)];
      currentFrameIdx = 0;
      pixels = frameList[0];
    }
    redrawGrid();
    historyState = createPixelHistory(pixels);
  }

  function redrawGrid() {
    if (!ctx || !canvasElement) return;
    drawPixelGrid(ctx, canvasElement, pixels);
  }

  function paintPixel(x: number, y: number, color: string): boolean {
    return paintBrush(pixels, x, y, color, brushSize);
  }

  function handlePointer(clientX: number, clientY: number) {
    if (!canvasElement || !ctx) return;
    const rect = canvasElement.getBoundingClientRect();
    const x = Math.floor((clientX - rect.left) / (canvasElement.width / GRID_SIZE));
    const y = Math.floor((clientY - rect.top) / (canvasElement.height / GRID_SIZE));

    if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
      let colorToUse = isEraser ? 'transparent' : currentColor;
      if (isRainbowBrush && !isEraser && !isBucket) {
        colorToUse = `hsl(${rainbowHue}, 100%, 50%)`;
        rainbowHue = (rainbowHue + 15) % 360;
      }
      
      if (isBucket) {
        const targetColor = pixels[y][x];
        if (targetColor !== colorToUse) {
          floodFillGrid(pixels, x, y, targetColor, colorToUse);
          redrawGrid();
          playDrawSound('chime');
        }
      } else {
        let drawnAny = false;
        drawnAny = paintPixel(x, y, colorToUse) || drawnAny;
        
        if (symmetryMode === 'horizontal' || symmetryMode === 'both') {
          drawnAny = paintPixel(GRID_SIZE - 1 - x, y, colorToUse) || drawnAny;
        }
        if (symmetryMode === 'vertical' || symmetryMode === 'both') {
          drawnAny = paintPixel(x, GRID_SIZE - 1 - y, colorToUse) || drawnAny;
        }
        if (symmetryMode === 'both') {
          drawnAny = paintPixel(GRID_SIZE - 1 - x, GRID_SIZE - 1 - y, colorToUse) || drawnAny;
        }
        
        if (drawnAny) {
          redrawGrid();
          playDrawSound('draw');
        }
      }
    }
  }

  async function triggerAutoSave() {
    if (!canvasElement) return;

    if (!targetAssetId) {
      const randomId = Math.random().toString(36).substring(2, 7);
      targetAssetId = `custom_${category.slice(0, 4)}_${randomId}`;
    }

    // Save current frame into frameList list
    frameList[currentFrameIdx] = cloneGrid(pixels);

    const isSpritesheetVal = frameList.length > 1 && (category === 'heroes' || category === 'enemies');
    const base64Data = exportFramesToPngBase64(frameList, pixels, GRID_SIZE, isSpritesheetVal);
    if (!base64Data) return;
    
    // Compile frames array coordinates
    const framesCoords = frameList.map((_, idx) => ({
      x: idx * GRID_SIZE,
      y: 0,
      w: GRID_SIZE,
      h: GRID_SIZE
    }));

    try {
      await invoke('save_child_sprite', {
        assetId: targetAssetId,
        category: category,
        base64Data: base64Data,
        isSpritesheet: isSpritesheetVal,
        frames: isSpritesheetVal ? framesCoords : null
      });
      dispatch('saved', targetAssetId);
    } catch (err) {
      console.error('Background sprite save failure:', err);
    }
  }

  function handleClear() {
    pixels = createEmptyGrid(GRID_SIZE);
    redrawGrid();
    triggerAutoSave();
    playDrawSound('clear');
  }
</script>

{#if !targetAssetId}
  <div class="category-panel">
    <span class="category-label">Choose Type:</span>
    <div class="category-options">
      <button class:active={category === 'decorations'} on:click={() => { category = 'decorations'; triggerAutoSave(); }}>🧸 Toy</button>
      <button class:active={category === 'terrain'} on:click={() => { category = 'terrain'; triggerAutoSave(); }}>🪨 Floor</button>
      <button class:active={category === 'heroes'} on:click={() => { category = 'heroes'; triggerAutoSave(); }}>🦸 Hero</button>
      <button class:active={category === 'enemies'} on:click={() => { category = 'enemies'; triggerAutoSave(); }}>👾 Monster</button>
      <button class:active={category === 'collectibles'} on:click={() => { category = 'collectibles'; triggerAutoSave(); }}>🪙 Reward</button>
    </div>
  </div>
{/if}

<SpriteTemplatesPanel on:select={(e) => applyTemplate(e.detail)} />

<div class="editor-workspace">
  <div class="canvas-area" style="display: flex; flex-direction: column; gap: 16px;">
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <canvas
      bind:this={canvasElement}
      width="360"
      height="360"
      class="draw-canvas"
      on:pointerdown={(e) => { isDrawing = true; handlePointer(e.clientX, e.clientY); }}
      on:pointermove={(e) => { if (isDrawing) handlePointer(e.clientX, e.clientY); }}
      on:pointerup={() => { if (isDrawing) { isDrawing = false; saveHistoryState(); triggerAutoSave(); } }}
      on:pointerleave={() => { isDrawing = false; }}
    ></canvas>

    {#if category === 'heroes' || category === 'enemies'}
      <div class="animation-timeline">
        <div class="timeline-frames">
          {#each frameList as _, idx}
            <button 
              class="frame-tab" 
              class:active={currentFrameIdx === idx} 
              on:click={() => selectFrame(idx)}
            >
              🎬 {idx + 1}
              {#if frameList.length > 1}
                <span class="del-frame-x" on:click|stopPropagation={() => deleteFrame(idx)} role="button" tabindex="-1" title="Delete Frame">✕</span>
              {/if}
            </button>
          {/each}
          {#if frameList.length < 4}
            <button class="frame-add-btn" on:click={addFrame}>➕ Copy Frame</button>
          {/if}
        </div>
        <button class="anim-play-btn" class:playing={isAnimPlaying} on:click={toggleAnimPlayback}>
          {isAnimPlaying ? '⏹️ Stop Preview' : '▶️ Loop Preview'}
        </button>
      </div>
    {/if}
  </div>

  <SpriteEditorPalette
    bind:currentColor
    bind:brushSize
    bind:isEraser
    bind:isBucket
    bind:symmetryMode
    bind:isRainbowBrush
    historyIndex={historyIndex}
    historyLength={history.length}
    on:undo={handleUndo}
    on:redo={handleRedo}
    on:clear={handleClear}
  />
</div>

<style>
  .category-panel {
    display: flex;
    align-items: center;
    gap: 16px;
    background: #0f172a;
    padding: 12px 20px;
    border-radius: 20px;
  }

  .category-label {
    font-weight: 900;
    color: #94a3b8;
    font-size: 1rem;
  }

  .category-options {
    display: flex;
    gap: 10px;
  }

  .category-options button {
    border: 0;
    background: #334155;
    color: white;
    font-weight: 800;
    padding: 8px 16px;
    border-radius: 14px;
    cursor: pointer;
    font-size: 0.95rem;
    transition: background 0.2s, transform 0.1s;
  }

  .category-options button.active {
    background: #eab308;
    color: #0f172a;
    transform: scale(1.05);
  }

  .editor-workspace {
    display: flex;
    gap: 28px;
    align-items: stretch;
  }

  .draw-canvas {
    background: #0f172a;
    border: 4px solid #334155;
    border-radius: 24px;
    cursor: crosshair;
    touch-action: none;
    image-rendering: pixelated;
    box-shadow: inset 0 4px 10px rgba(0, 0, 0, 0.4);
  }

  /* Timeline Styles */
  .animation-timeline {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 18px;
    gap: 12px;
    border: 2px solid #334155;
  }

  .timeline-frames {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .frame-tab {
    position: relative;
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 8px 12px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .frame-tab.active {
    background: #fbbf24;
    color: #0f172a;
  }

  .del-frame-x {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 50%;
    width: 16px;
    height: 16px;
    font-size: 0.7rem;
    cursor: pointer;
    display: grid;
    place-items: center;
    padding: 0;
    box-shadow: none;
    line-height: 1;
  }

  .frame-add-btn {
    border: 0;
    background: #10b981;
    color: white;
    font-weight: 800;
    padding: 8px 12px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
  }

  .anim-play-btn {
    border: 0;
    background: #6366f1;
    color: white;
    font-weight: 800;
    padding: 8px 14px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
  }

  .anim-play-btn.playing {
    background: #ef4444;
  }
</style>
