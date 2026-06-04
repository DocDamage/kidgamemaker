<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { SPRITE_EDITOR_COLORS } from './lib/spriteEditorConfig';

  export let currentColor: string;
  export let brushSize: number;
  export let isEraser: boolean;
  export let isBucket: boolean;
  export let symmetryMode: 'none' | 'horizontal' | 'vertical' | 'both';
  export let isRainbowBrush: boolean;
  export let historyIndex: number;
  export let historyLength: number;

  const dispatch = createEventDispatcher<{
    undo: void;
    redo: void;
    clear: void;
  }>();

  function selectBrush(size: number) {
    brushSize = size;
    isBucket = false;
    isEraser = false;
  }

  function selectColor(color: string) {
    currentColor = color;
    isEraser = false;
    isBucket = false;
  }

  function toggleEraser() {
    isEraser = true;
    isBucket = false;
  }

  function toggleBucket() {
    isBucket = true;
    isEraser = false;
  }
</script>

<div class="side-panel">
  <div class="brush-selector">
    <button class="brush-btn" class:active={brushSize === 1 && !isBucket && !isEraser} on:click={() => selectBrush(1)} title="Small Brush">🟢 1x</button>
    <button class="brush-btn" class:active={brushSize === 2 && !isBucket && !isEraser} on:click={() => selectBrush(2)} title="Medium Brush">🟢 2x</button>
    <button class="brush-btn" class:active={brushSize === 3 && !isBucket && !isEraser} on:click={() => selectBrush(3)} title="Big Brush">🟢 3x</button>
  </div>

  <div class="colors-grid">
    {#each SPRITE_EDITOR_COLORS as color}
      <button
        class="color-dot"
        style:background={color}
        class:selected={currentColor === color && !isEraser && !isBucket}
        on:click={() => selectColor(color)}
        aria-label="Color {color}"
      ></button>
    {/each}
  </div>

  <div class="brush-selector" style="margin-top: 10px; display: flex; flex-direction: column; gap: 8px; background: #0f172a; padding: 10px; border-radius: 14px; box-shadow: inset 0 2px 4px rgba(0,0,0,0.3); border: 2px solid #334155;">
    <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
      <span style="font-size: 0.85rem; color: #94a3b8; font-weight: 800;">🪞 Mirror:</span>
      <select bind:value={symmetryMode} style="background: #1e293b; color: white; border: 1px solid #475569; border-radius: 6px; padding: 4px; font-size: 0.8rem; font-weight: bold; cursor: pointer; outline: none;">
        <option value="none">None</option>
        <option value="horizontal">↔️ Horiz</option>
        <option value="vertical">↕️ Vert</option>
        <option value="both">🔲 Both</option>
      </select>
    </div>
    <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
      <span style="font-size: 0.85rem; color: #94a3b8; font-weight: 800;">🌈 Rainbow:</span>
      <input type="checkbox" bind:checked={isRainbowBrush} style="cursor: pointer; width: 16px; height: 16px; accent-color: #fbbf24;" />
    </div>
  </div>

  <div class="tool-actions">
    <button class="tool-btn undo-btn" disabled={historyIndex <= 0} on:click={() => dispatch('undo')} title="Undo draw stroke">
      ↺ Undo
    </button>
    <button class="tool-btn redo-btn" disabled={historyIndex >= historyLength - 1} on:click={() => dispatch('redo')} title="Redo draw stroke">
      ↻ Redo
    </button>
    <button class="tool-btn eraser-btn" class:active={isEraser} on:click={toggleEraser}>
      🧽 Eraser
    </button>
    <button class="tool-btn bucket-btn" class:active={isBucket} on:click={toggleBucket}>
      🪣 Fill
    </button>
    <button class="tool-btn clear-btn" on:click={() => dispatch('clear')}>
      🗑️ Clear
    </button>
  </div>
</div>

<style>
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
    transform: scale(1.05);
  }

  .clear-btn {
    background: #475569;
    color: white;
  }

  .bucket-btn {
    background: #e0f2fe;
    color: #0369a1;
  }

  .bucket-btn.active {
    background: #0284c7;
    color: white;
    outline: 4px solid white;
    transform: scale(1.05);
  }

  .brush-selector {
    display: flex;
    gap: 6px;
    margin-bottom: 12px;
    background: #0f172a;
    padding: 6px;
    border-radius: 14px;
    justify-content: space-around;
  }

  .brush-btn {
    border: 0;
    background: #1e293b;
    color: #94a3b8;
    font-weight: 800;
    padding: 6px 10px;
    border-radius: 10px;
    cursor: pointer;
    font-size: 0.85rem;
    transition: background 0.2s, transform 0.1s;
  }

  .brush-btn.active {
    background: #fbbf24;
    color: #0f172a;
  }
</style>
