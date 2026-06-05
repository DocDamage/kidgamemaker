<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  
  export let isOpen = false;
  export let unlockedStamps: string[] = [];
  
  const dispatch = createEventDispatcher<{
    unlockStamp: string;
    close: void;
  }>();

  // Grid coordinates of active stars on a 5x5 grid
  const stars = [
    { x: 0, y: 2, label: '(0,2)' },
    { x: 2, y: 0, label: '(2,0)' },
    { x: 4, y: 2, label: '(4,2)' },
    { x: 2, y: 4, label: '(2,4)' },
    { x: 1, y: 1, label: '(1,1)' },
    { x: 3, y: 3, label: '(3,3)' }
  ];

  let selectedIndices: number[] = [];
  let isUnlocked = unlockedStamps.includes('celestial_sprite');

  // React to external unlock updates
  $: isUnlocked = unlockedStamps.includes('celestial_sprite');

  const TARGET_PATH = [0, 1, 2, 3, 0]; // (0,2) -> (2,0) -> (4,2) -> (2,4) -> (0,2)

  function handleStarClick(index: number) {
    if (isUnlocked) return;
    
    // Check if clicking the same star again (to close the loop or restart)
    if (selectedIndices.length > 0 && selectedIndices[selectedIndices.length - 1] === index) {
      return; // click same star, do nothing
    }

    selectedIndices = [...selectedIndices, index];

    // Check progress
    checkWinCondition();
  }

  function clearDrawing() {
    selectedIndices = [];
  }

  function checkWinCondition() {
    if (selectedIndices.length === TARGET_PATH.length) {
      let match = true;
      for (let i = 0; i < TARGET_PATH.length; i++) {
        if (selectedIndices[i] !== TARGET_PATH[i]) {
          match = false;
          break;
        }
      }

      if (match) {
        isUnlocked = true;
        dispatch('unlockStamp', 'celestial_sprite');
      } else {
        // Clear and shake after 800ms
        setTimeout(() => {
          if (!isUnlocked) {
            clearDrawing();
          }
        }, 800);
      }
    } else if (selectedIndices.length > TARGET_PATH.length) {
      clearDrawing();
    }
  }

  // Calculate SVG line points
  function getStarCoords(index: number) {
    const star = stars[index];
    // Scale 0-4 coordinates to SVG view box 50 to 350
    const padding = 50;
    const spacing = 75;
    return {
      x: padding + star.x * spacing,
      y: padding + star.y * spacing
    };
  }
</script>

{#if isOpen}
  <div class="constellation-drawer">
    <div class="drawer-header">
      <h2>🌌 Constellation Star Mapper</h2>
      <button class="close-btn" on:click={() => dispatch('close')}>✕</button>
    </div>
    
    <div class="drawer-body">
      {#if isUnlocked}
        <div class="success-screen">
          <span class="success-emoji">🦄</span>
          <h3>CELESTIAL SPRITE SUMMONED!</h3>
          <p>You connected the Pegasus Diamond constellation! Look for the Celestial Sprite in your Toybox under the 🎪 Toys category.</p>
          <button class="btn-primary" on:click={() => dispatch('close')}>Start Building!</button>
        </div>
      {:else}
        <div class="mapper-container">
          <div class="instruction-box">
            <p><strong>✨ Summons Spell:</strong> Click the stars in coordinate order to form the diamond pattern:</p>
            <div class="sequence-guide">
              <span class="step" class:active={selectedIndices.length > 0}>⭐ (0,2)</span> ➔ 
              <span class="step" class:active={selectedIndices.length > 1}>⭐ (2,0)</span> ➔ 
              <span class="step" class:active={selectedIndices.length > 2}>⭐ (4,2)</span> ➔ 
              <span class="step" class:active={selectedIndices.length > 3}>⭐ (2,4)</span> ➔ 
              <span class="step" class:active={selectedIndices.length > 4}>⭐ (0,2)</span>
            </div>
            {#if selectedIndices.length > 0}
              <button class="btn-clear" on:click={clearDrawing}>Clear Pattern 🔄</button>
            {/if}
          </div>

          <div class="sky-canvas-wrapper">
            <svg class="sky-svg" viewBox="0 0 400 400">
              <!-- Grid lines -->
              {#each Array(5) as _, i}
                <line x1={50 + i * 75} y1={40} x2={50 + i * 75} y2={360} class="grid-line" />
                <line x1={40} y1={50 + i * 75} x2={360} y2={50 + i * 75} class="grid-line" />
              {/each}
              
              <!-- Drawn lines -->
              {#if selectedIndices.length > 1}
                {#each Array(selectedIndices.length - 1) as _, i}
                  {@const p1 = getStarCoords(selectedIndices[i])}
                  {@const p2 = getStarCoords(selectedIndices[i + 1])}
                  <line x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} class="drawn-line" />
                {/each}
              {/if}

              <!-- Stars -->
              {#each stars as star, i}
                {@const coords = getStarCoords(i)}
                {@const isSelected = selectedIndices.includes(i)}
                <g class="star-group" on:click={() => handleStarClick(i)}>
                  <circle cx={coords.x} cy={coords.y} r={isSelected ? 10 : 7} class="star-circle" class:selected={isSelected} />
                  <circle cx={coords.x} cy={coords.y} r={isSelected ? 16 : 0} class="star-glow" />
                  <text x={coords.x} y={coords.y - 15} class="star-label">{star.label}</text>
                </g>
              {/each}
            </svg>
          </div>
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  .constellation-drawer {
    position: fixed;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 90%;
    max-width: 500px;
    height: 520px;
    background: linear-gradient(135deg, #090a15 0%, #151833 100%);
    border: 3px solid #6366f1;
    border-bottom: none;
    border-radius: 20px 20px 0 0;
    z-index: 1000;
    box-shadow: 0 -10px 30px rgba(99, 102, 241, 0.4);
    display: flex;
    flex-direction: column;
    color: #f3f4f6;
    font-family: 'Outfit', 'Inter', sans-serif;
  }
  
  .drawer-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 20px;
    border-bottom: 1px solid rgba(99, 102, 241, 0.3);
  }
  
  .drawer-header h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 700;
    background: linear-gradient(to right, #818cf8, #c084fc);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  
  .close-btn {
    background: transparent;
    border: none;
    color: #9ca3af;
    font-size: 1.25rem;
    cursor: pointer;
  }
  
  .close-btn:hover {
    color: #f3f4f6;
  }
  
  .drawer-body {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  
  .success-screen {
    text-align: center;
    padding: 24px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  
  .success-emoji {
    font-size: 4rem;
    margin-bottom: 16px;
    animation: pulse 1.5s infinite;
  }
  
  .success-screen h3 {
    color: #38bdf8;
    margin: 0 0 10px 0;
  }
  
  .success-screen p {
    color: #9ca3af;
    margin: 0 0 20px 0;
    font-size: 0.95rem;
    line-height: 1.5;
  }
  
  .btn-primary {
    background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
  }
  
  .mapper-container {
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .instruction-box {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 10px;
    padding: 12px 16px;
    width: 100%;
    margin-bottom: 16px;
    font-size: 0.85rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .instruction-box p {
    margin: 0 0 8px 0;
    color: #e5e7eb;
  }
  
  .sequence-guide {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #060710;
    padding: 8px;
    border-radius: 6px;
    margin-bottom: 8px;
    font-family: monospace;
    font-size: 0.75rem;
    color: #6b7280;
  }
  
  .step.active {
    color: #38bdf8;
    font-weight: bold;
    text-shadow: 0 0 8px rgba(56, 189, 248, 0.5);
  }
  
  .btn-clear {
    background: transparent;
    border: 1px dashed rgba(239, 68, 68, 0.5);
    color: #f87171;
    font-size: 0.75rem;
    padding: 4px 8px;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .sky-canvas-wrapper {
    background: #020205;
    border-radius: 12px;
    border: 1px solid rgba(99, 102, 241, 0.3);
    padding: 10px;
    box-shadow: inset 0 0 20px rgba(0,0,0,0.8);
  }
  
  .sky-svg {
    width: 280px;
    height: 280px;
  }
  
  .grid-line {
    stroke: rgba(255, 255, 255, 0.06);
    stroke-width: 1;
    stroke-dasharray: 2 2;
  }
  
  .star-circle {
    fill: #e5e7eb;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .star-circle.selected {
    fill: #38bdf8;
  }
  
  .star-glow {
    fill: #38bdf8;
    opacity: 0.2;
    cursor: pointer;
  }
  
  .star-group:hover .star-circle {
    fill: #38bdf8;
    transform: scale(1.3);
  }
  
  .star-group:hover .star-glow {
    opacity: 0.4;
  }
  
  .star-label {
    fill: #9ca3af;
    font-size: 9px;
    font-family: monospace;
    text-anchor: middle;
  }
  
  .drawn-line {
    stroke: #38bdf8;
    stroke-width: 3;
    stroke-linecap: round;
    animation: dash 1s linear;
  }
  
  @keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
  }
</style>
