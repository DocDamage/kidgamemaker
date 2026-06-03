<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';

  export let isVisible = false;
  export let targetAssetId = '';
  export let category = 'decorations';

  const dispatch = createEventDispatcher<{
    close: void;
    saved: string;
  }>();

  const GRID_SIZE = 16;
  let canvasElement: HTMLCanvasElement;
  let ctx: CanvasRenderingContext2D | null = null;

  // Curated premium high-contrast color palette for kids
  const COLORS = [
    '#ff4b4b', // Red
    '#ff9030', // Orange
    '#ffeb3b', // Yellow
    '#00e676', // Green
    '#2979ff', // Blue
    '#d500f9', // Purple
    '#ff4081', // Pink
    '#8d6e63', // Brown
    '#ffffff', // White
    '#212121'  // Black
  ];

  let currentColor = '#ff4b4b';
  let isDrawing = false;
  let isEraser = false;

  let pixels: string[][] = Array(GRID_SIZE)
    .fill(null)
    .map(() => Array(GRID_SIZE).fill('transparent'));

  // Run on visibility changes
  $: if (isVisible && canvasElement) {
    initCanvas();
    loadExistingSprite();
  }

  function initCanvas() {
    ctx = canvasElement.getContext('2d');
    if (!ctx) return;
    ctx.imageSmoothingEnabled = false;
  }

  async function loadExistingSprite() {
    if (targetAssetId) {
      try {
        pixels = await invoke<string[][]>('load_child_sprite', {
          assetId: targetAssetId,
          category: category
        });
      } catch (err) {
        console.error('Failed to load existing sprite:', err);
        // Fallback to blank canvas on failure
        pixels = Array(GRID_SIZE)
          .fill(null)
          .map(() => Array(GRID_SIZE).fill('transparent'));
      }
    } else {
      pixels = Array(GRID_SIZE)
        .fill(null)
        .map(() => Array(GRID_SIZE).fill('transparent'));
    }
    redrawGrid();
  }

  function redrawGrid() {
    if (!ctx || !canvasElement) return;
    ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);

    const cellSize = canvasElement.width / GRID_SIZE;

    // Draw grid pixels
    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        if (pixels[y][x] !== 'transparent') {
          ctx.fillStyle = pixels[y][x];
          ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
        }
      }
    }
  }

  function handlePointer(clientX: number, clientY: number) {
    if (!canvasElement || !ctx) return;
    const rect = canvasElement.getBoundingClientRect();
    const x = Math.floor((clientX - rect.left) / (canvasElement.width / GRID_SIZE));
    const y = Math.floor((clientY - rect.top) / (canvasElement.height / GRID_SIZE));

    if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
      pixels[y][x] = isEraser ? 'transparent' : currentColor;
      redrawGrid();
    }
  }

  // Auto-Save: Downscale to a tiny 16x16 PNG and save silently via Rust
  async function triggerAutoSave() {
    if (!canvasElement) return;

    if (!targetAssetId) {
      // Generate a child-friendly ID name based on category
      const randomId = Math.random().toString(36).substring(2, 7);
      targetAssetId = `custom_${category.slice(0, 4)}_${randomId}`;
    }

    // Downscale target drawing straight to 16x16 PNG for Godot
    const exportCanvas = document.createElement('canvas');
    exportCanvas.width = GRID_SIZE;
    exportCanvas.height = GRID_SIZE;
    const exportCtx = exportCanvas.getContext('2d');
    if (!exportCtx) return;

    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        if (pixels[y][x] !== 'transparent') {
          exportCtx.fillStyle = pixels[y][x];
          exportCtx.fillRect(x, y, 1, 1);
        }
      }
    }

    const base64Data = exportCanvas.toDataURL('image/png').split(',')[1];

    try {
      await invoke('save_child_sprite', {
        assetId: targetAssetId,
        category: category,
        base64Data: base64Data
      });
      dispatch('saved', targetAssetId);
    } catch (err) {
      console.error('Background sprite save failure:', err);
    }
  }

  function handleClear() {
    pixels = Array(GRID_SIZE)
      .fill(null)
      .map(() => Array(GRID_SIZE).fill('transparent'));
    redrawGrid();
    triggerAutoSave();
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

      <div class="editor-workspace">
        <!-- svelte-ignore a11y_no_static_element_interactions -->
        <canvas
          bind:this={canvasElement}
          width="360"
          height="360"
          class="draw-canvas"
          on:pointerdown={(e) => { isDrawing = true; handlePointer(e.clientX, e.clientY); }}
          on:pointermove={(e) => { if (isDrawing) handlePointer(e.clientX, e.clientY); }}
          on:pointerup={() => { isDrawing = false; triggerAutoSave(); }}
          on:pointerleave={() => { isDrawing = false; }}
        ></canvas>

        <div class="side-panel">
          <div class="colors-grid">
            {#each COLORS as color}
              <button
                class="color-dot"
                style:background={color}
                class:selected={currentColor === color && !isEraser}
                on:click={() => { currentColor = color; isEraser = false; }}
                aria-label="Color {color}"
              ></button>
            {/each}
          </div>

          <div class="tool-actions">
            <button class="tool-btn eraser-btn" class:active={isEraser} on:click={() => isEraser = true}>
              🧽 Eraser
            </button>
            <button class="tool-btn clear-btn" on:click={handleClear}>
              🗑️ Clear
            </button>
          </div>
        </div>
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

  .side-panel {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    width: 140px;
  }

  .colors-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .color-dot {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    border: 4px solid #1e293b;
    cursor: pointer;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
    transition: transform 0.1s;
  }

  .color-dot:hover {
    transform: scale(1.1);
  }

  .color-dot.selected {
    outline: 4px solid #fbbf24;
    transform: scale(1.05);
  }

  .tool-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-top: 20px;
  }

  .tool-btn {
    border: 0;
    border-radius: 18px;
    padding: 14px;
    font-size: 1.05rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.2);
    transition: transform 0.1s, background 0.2s;
  }

  .tool-btn:active {
    transform: translateY(2px);
  }

  .eraser-btn {
    background: #f1f5f9;
    color: #0f172a;
  }

  .eraser-btn.active {
    background: #fbbf24;
    color: #0f172a;
    outline: 4px solid white;
  }

  .clear-btn {
    background: #475569;
    color: white;
  }
</style>
