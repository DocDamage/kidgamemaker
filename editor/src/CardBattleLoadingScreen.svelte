<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';

  export let isMuted = false;

  const dispatch = createEventDispatcher<{
    complete: { bonus: string | null };
    skip: void;
  }>();

  interface Card {
    id: string;
    name: string;
    emoji: string;
    description: string;
    pattern: [number, number][]; // Relative offsets from click point [dx, dy]
  }

  const CARD_TEMPLATES: Card[] = [
    {
      id: 'roller',
      name: 'Splat Roller 🛹',
      emoji: '🛹',
      description: 'Inks a 3-cell horizontal line.',
      pattern: [[0, 0], [-1, 0], [1, 0]]
    },
    {
      id: 'brush',
      name: 'Ink Brush 🖌️',
      emoji: '🖌️',
      description: 'Inks a 3-cell vertical line.',
      pattern: [[0, 0], [0, -1], [0, 1]]
    },
    {
      id: 'mine',
      name: 'Ink Mine 💣',
      emoji: '💣',
      description: 'Inks a sturdy 2x2 square.',
      pattern: [[0, 0], [1, 0], [0, 1], [1, 1]]
    },
    {
      id: 'bomb',
      name: 'Splash Bomb 💥',
      emoji: '💥',
      description: 'Blasts ink in a cross shape.',
      pattern: [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]]
    },
    {
      id: 'shot',
      name: 'Splattershot 🔫',
      emoji: '🔫',
      description: 'Hooks a corner L-shape.',
      pattern: [[0, 0], [0, -1], [1, 0]]
    },
    {
      id: 'storm',
      name: 'Ink Storm 🌀',
      emoji: '🌀',
      description: 'Sprays ink in an X shape.',
      pattern: [[0, 0], [-1, -1], [1, 1], [-1, 1], [1, -1]]
    }
  ];

  const BONUSES = [
    { id: 'speed_boost', label: '🏃 Speed Boost (+25% speed)', name: 'Speed Boost' },
    { id: 'extra_hp', label: '💖 Extra Heart (+30 Max HP)', name: 'Extra Heart' },
    { id: 'shield', label: '🛡️ Power Shield (20% defense)', name: 'Power Shield' }
  ];

  // Game state variables
  let selectedBonus = BONUSES[0];
  let grid: number[][] = Array(6).fill(null).map(() => Array(6).fill(0)); // 0: empty, 1: player, 2: AI
  let deck: Card[] = [];
  let hand: Card[] = [];
  let selectedCardIndex: number | null = null;
  let currentRound = 1;
  const maxRounds = 4;
  let isGameOver = false;
  let winner: 'player' | 'opponent' | 'tie' | null = null;
  let playerCellCount = 0;
  let opponentCellCount = 0;
  let hoverCell: [number, number] | null = null;
  let statusText = 'Draw a card and click the grid to claim your territory!';

  // Loading progress simulation
  let loadingProgress = 0;
  let progressInterval: number;

  onMount(() => {
    initGame();
    // Simulate loading progress
    progressInterval = window.setInterval(() => {
      if (loadingProgress < 100) {
        // Grow faster if game is over
        loadingProgress += isGameOver ? 15 : 2;
        if (loadingProgress > 100) loadingProgress = 100;
      }
    }, 250);

    return () => {
      clearInterval(progressInterval);
    };
  });

  function initGame() {
    selectedBonus = BONUSES[Math.floor(Math.random() * BONUSES.length)];
    grid = Array(6).fill(null).map(() => Array(6).fill(0));
    currentRound = 1;
    isGameOver = false;
    winner = null;
    selectedCardIndex = null;
    hoverCell = null;
    statusText = 'Your turn! Choose an Ink Card and claim territory.';

    // Create a deck of 8 cards
    deck = [];
    for (let i = 0; i < 8; i++) {
      const template = CARD_TEMPLATES[Math.floor(Math.random() * CARD_TEMPLATES.length)];
      deck.push({ ...template, id: `${template.id}_${i}` });
    }

    // Draw initial hand of 3
    hand = [];
    for (let i = 0; i < 3; i++) {
      drawCard();
    }
    updateScores();
    playSfx('pop');
  }

  function drawCard() {
    if (deck.length > 0 && hand.length < 3) {
      hand = [...hand, deck.pop()!];
    }
  }

  function selectCard(index: number) {
    if (isGameOver) return;
    selectedCardIndex = index;
    statusText = `Hover over the grid and click to place ${hand[index].name}!`;
    playSfx('pop');
  }

  function updateScores() {
    let pCount = 0;
    let oCount = 0;
    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        if (grid[r][c] === 1) pCount++;
        else if (grid[r][c] === 2) oCount++;
      }
    }
    playerCellCount = pCount;
    opponentCellCount = oCount;
  }

  // Get list of absolute coordinates covered by placing card at (r, c)
  function getCoveredCells(card: Card, r: number, c: number): [number, number][] {
    const coords: [number, number][] = [];
    for (const [dx, dy] of card.pattern) {
      const targetR = r + dy;
      const targetC = c + dx;
      if (targetR >= 0 && targetR < 6 && targetC >= 0 && targetC < 6) {
        coords.push([targetR, targetC]);
      }
    }
    return coords;
  }

  function handleCellClick(r: number, c: number) {
    if (isGameOver || selectedCardIndex === null) return;
    const card = hand[selectedCardIndex];

    // Apply player ink
    const cells = getCoveredCells(card, r, c);
    for (const [tr, tc] of cells) {
      grid[tr][tc] = 1;
    }
    grid = [...grid]; // trigger update

    // Consume card
    hand.splice(selectedCardIndex, 1);
    hand = [...hand];
    selectedCardIndex = null;
    drawCard();
    updateScores();
    playSfx('chime');

    // Check if player finished turn
    if (currentRound <= maxRounds) {
      statusText = 'AI is playing...';
      setTimeout(playAiTurn, 800);
    }
  }

  function playAiTurn() {
    if (isGameOver) return;

    // Pick a random card template
    const aiCard = CARD_TEMPLATES[Math.floor(Math.random() * CARD_TEMPLATES.length)];

    // Find a good place to ink (prioritize overlapping player ink or empty spaces)
    let bestR = Math.floor(Math.random() * 6);
    let bestC = Math.floor(Math.random() * 6);
    let bestScore = -999;

    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        const cells = getCoveredCells(aiCard, r, c);
        let score = 0;
        for (const [tr, tc] of cells) {
          if (grid[tr][tc] === 0) score += 2; // Empty cells are good
          else if (grid[tr][tc] === 1) score += 3; // Stealing player cells is great!
          else if (grid[tr][tc] === 2) score -= 1; // Overlapping self is bad
        }
        if (score > bestScore) {
          bestScore = score;
          bestR = r;
          bestC = c;
        }
      }
    }

    // Apply AI ink
    const aiCells = getCoveredCells(aiCard, bestR, bestC);
    for (const [tr, tc] of aiCells) {
      grid[tr][tc] = 2;
    }
    grid = [...grid];
    updateScores();
    playSfx('squeak');

    if (currentRound < maxRounds) {
      currentRound++;
      statusText = `Round ${currentRound}/${maxRounds}: Your Turn! Select a card.`;
    } else {
      endGame();
    }
  }

  function endGame() {
    isGameOver = true;
    updateScores();
    if (playerCellCount > opponentCellCount) {
      winner = 'player';
      statusText = `🎉 VICTORY! Captured more territory. Bonus Unlocked: ${selectedBonus.name}!`;
      playSfx('chime');
    } else if (playerCellCount < opponentCellCount) {
      winner = 'opponent';
      statusText = 'Defeat! AI colored more grid. Better luck next time!';
    } else {
      winner = 'tie';
      statusText = 'Draw! Grid territory is equal.';
    }
  }

  function handleCellEnter(r: number, c: number) {
    if (selectedCardIndex !== null) {
      hoverCell = [r, c];
    }
  }

  function handleCellLeave() {
    hoverCell = null;
  }

  function isCellHighlighted(r: number, c: number): boolean {
    if (selectedCardIndex === null || hoverCell === null) return false;
    const card = hand[selectedCardIndex];
    const cells = getCoveredCells(card, hoverCell[0], hoverCell[1]);
    return cells.some(([tr, tc]) => tr === r && tc === c);
  }

  function enterLevel() {
    const bonusToPass = winner === 'player' ? selectedBonus.id : null;
    dispatch('complete', { bonus: bonusToPass });
  }

  function playSfx(type: 'pop' | 'squeak' | 'chime') {
    if (isMuted) return;
    try {
      const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);

      if (type === 'pop') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(150, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.1);
        gain.gain.setValueAtTime(0.15, ctx.currentTime);
        gain.gain.linearRampToValueAtTime(0.01, ctx.currentTime + 0.1);
        osc.start();
        osc.stop(ctx.currentTime + 0.1);
      } else if (type === 'squeak') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(400, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(800, ctx.currentTime + 0.15);
        gain.gain.setValueAtTime(0.1, ctx.currentTime);
        gain.gain.linearRampToValueAtTime(0.01, ctx.currentTime + 0.15);
        osc.start();
        osc.stop(ctx.currentTime + 0.15);
      } else if (type === 'chime') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(523.25, ctx.currentTime); // C5
        osc.frequency.setValueAtTime(659.25, ctx.currentTime + 0.1); // E5
        osc.frequency.setValueAtTime(783.99, ctx.currentTime + 0.2); // G5
        gain.gain.setValueAtTime(0.15, ctx.currentTime);
        gain.gain.linearRampToValueAtTime(0.01, ctx.currentTime + 0.4);
        osc.start();
        osc.stop(ctx.currentTime + 0.4);
      }
    } catch (e) {
      console.warn('Web Audio SFX failed:', e);
    }
  }
</script>

<div class="card-battle-overlay">
  <div class="card-battle-card">
    <div class="card-battle-header">
      <div class="title-row">
        <h3>🎨 Territory Card Battle! ⚔️</h3>
        <span class="prize-tag">Prize: {selectedBonus.label}</span>
      </div>
      <p class="status-subtitle">{statusText}</p>
    </div>

    <div class="battle-arena">
      <!-- Grid Panel -->
      <div class="grid-container">
        <div class="grid-board">
          {#each Array(6) as _, r}
            <div class="grid-row">
              {#each Array(6) as _, c}
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <!-- svelte-ignore a11y-no-static-element-interactions -->
                <div
                  class="grid-cell"
                  class:cell-empty={grid[r][c] === 0}
                  class:cell-player={grid[r][c] === 1}
                  class:cell-opponent={grid[r][c] === 2}
                  class:cell-highlighted={isCellHighlighted(r, c)}
                  on:click={() => handleCellClick(r, c)}
                  on:mouseenter={() => handleCellEnter(r, c)}
                  on:mouseleave={handleCellLeave}
                ></div>
              {/each}
            </div>
          {/each}
        </div>

        <div class="score-legend">
          <div class="legend-item player">
            <span class="dot player-dot"></span>
            <span>You: {playerCellCount} cells ({Math.round((playerCellCount / 36) * 100)}%)</span>
          </div>
          <div class="legend-item round-tracker">
            <span>Round {Math.min(currentRound, maxRounds)} / {maxRounds}</span>
          </div>
          <div class="legend-item opponent">
            <span class="dot opponent-dot"></span>
            <span>AI: {opponentCellCount} cells ({Math.round((opponentCellCount / 36) * 100)}%)</span>
          </div>
        </div>
      </div>

      <!-- Cards Panel -->
      <div class="cards-panel">
        <h4>🃏 Your Ink Cards</h4>
        {#if hand.length === 0}
          <div class="empty-cards">No cards in hand!</div>
        {:else}
          <div class="hand-container">
            {#each hand as card, idx}
              <button
                class="card-item"
                class:card-selected={selectedCardIndex === idx}
                on:click={() => selectCard(idx)}
                disabled={isGameOver}
              >
                <div class="card-emoji">{card.emoji}</div>
                <div class="card-name">{card.name}</div>
                <div class="card-desc">{card.description}</div>
              </button>
            {/each}
          </div>
        {/if}

        <div class="actions-row">
          {#if isGameOver}
            <button class="btn btn-restart" on:click={initGame}>🔄 Rematch</button>
            <button class="btn btn-enter btn-pulse" on:click={enterLevel}>🏆 Enter Level with Reward</button>
          {:else}
            <button class="btn btn-skip" on:click={enterLevel}>⏭️ Skip & Enter Level</button>
          {/if}
        </div>
      </div>
    </div>

    <!-- Progress bar -->
    <div class="loading-bar-wrapper">
      <div class="loading-bar-fill" style="width: {loadingProgress}%"></div>
      <span class="loading-text">Loading Room Elements... {Math.round(loadingProgress)}%</span>
    </div>
  </div>
</div>

<style>
  .card-battle-overlay {
    position: absolute;
    inset: 0;
    background: rgba(15, 23, 42, 0.95);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    z-index: 50;
    font-family: 'Outfit', 'Inter', system-ui, -apple-system, sans-serif;
  }

  .card-battle-card {
    background: #1e293b;
    border: 5px dashed #ec4899;
    border-radius: 30px;
    padding: 24px;
    color: white;
    width: 100%;
    max-width: 800px;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(236, 72, 153, 0.1);
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .card-battle-header {
    border-bottom: 2px solid #334155;
    padding-bottom: 12px;
  }

  .title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
  }

  h3 {
    margin: 0;
    font-size: 1.6rem;
    color: #f43f5e;
    text-shadow: 0 0 8px rgba(244, 63, 94, 0.4);
  }

  .prize-tag {
    background: #eab308;
    color: #1e293b;
    font-weight: 900;
    font-size: 0.9rem;
    padding: 4px 12px;
    border-radius: 12px;
    border: 2px solid #ca8a04;
  }

  .status-subtitle {
    margin: 8px 0 0 0;
    color: #94a3b8;
    font-size: 1rem;
    font-weight: 600;
  }

  .battle-arena {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }

  @media (max-width: 640px) {
    .battle-arena {
      grid-template-columns: 1fr;
    }
  }

  .grid-container {
    display: flex;
    flex-direction: column;
    gap: 12px;
    align-items: center;
  }

  .grid-board {
    background: #0f172a;
    border: 3px solid #334155;
    border-radius: 16px;
    padding: 8px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .grid-row {
    display: flex;
    gap: 4px;
  }

  .grid-cell {
    width: 38px;
    height: 38px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .cell-empty {
    background: #1e293b;
    border: 1px solid #334155;
  }

  .cell-empty:hover {
    background: #334155;
  }

  .cell-player {
    background: #ec4899;
    box-shadow: 0 0 10px rgba(236, 72, 153, 0.6);
  }

  .cell-opponent {
    background: #06b6d4;
    box-shadow: 0 0 10px rgba(6, 182, 212, 0.6);
  }

  .cell-highlighted {
    background: rgba(236, 72, 153, 0.4);
    border: 2px solid #ec4899;
    transform: scale(0.95);
  }

  .score-legend {
    display: flex;
    justify-content: space-between;
    width: 100%;
    font-size: 0.85rem;
    font-weight: 700;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
  }

  .player-dot {
    background: #ec4899;
  }

  .opponent-dot {
    background: #06b6d4;
  }

  .round-tracker {
    color: #eab308;
    background: rgba(234, 179, 8, 0.1);
    padding: 2px 8px;
    border-radius: 8px;
  }

  .cards-panel {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  h4 {
    margin: 0;
    color: #94a3b8;
    font-size: 1.1rem;
    border-bottom: 1px solid #334155;
    padding-bottom: 6px;
  }

  .hand-container {
    display: flex;
    gap: 8px;
    justify-content: space-between;
  }

  .card-item {
    background: #0f172a;
    border: 2px solid #334155;
    border-radius: 12px;
    padding: 10px 6px;
    width: 31%;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
  }

  .card-item:hover:not(:disabled) {
    transform: translateY(-4px);
    border-color: #ec4899;
    box-shadow: 0 4px 12px rgba(236, 72, 153, 0.2);
  }

  .card-selected {
    border-color: #ec4899;
    background: rgba(236, 72, 153, 0.08);
    box-shadow: 0 0 15px rgba(236, 72, 153, 0.4);
    transform: scale(1.05);
  }

  .card-item:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .card-emoji {
    font-size: 1.4rem;
    margin-bottom: 4px;
  }

  .card-name {
    font-size: 0.8rem;
    font-weight: 800;
    color: white;
    margin-bottom: 4px;
    line-height: 1.1;
  }

  .card-desc {
    font-size: 0.65rem;
    color: #64748b;
    line-height: 1.2;
  }

  .actions-row {
    margin-top: auto;
    display: flex;
    gap: 12px;
  }

  .btn {
    flex: 1;
    border: 0;
    border-radius: 16px;
    padding: 12px 16px;
    font-weight: 900;
    cursor: pointer;
    font-size: 0.95rem;
    color: white;
    transition: transform 0.1s;
  }

  .btn:active {
    transform: translateY(2px);
  }

  .btn-skip {
    background: #475569;
    border-bottom: 4px solid #334155;
  }

  .btn-restart {
    background: #3b82f6;
    border-bottom: 4px solid #1d4ed8;
  }

  .btn-enter {
    background: #10b981;
    border-bottom: 4px solid #047857;
  }

  .btn-pulse {
    animation: pulse 1.5s infinite alternate;
  }

  @keyframes pulse {
    0% {
      box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
    }
    100% {
      box-shadow: 0 0 15px 5px rgba(16, 185, 129, 0.4);
    }
  }

  .loading-bar-wrapper {
    position: relative;
    height: 20px;
    background: #0f172a;
    border-radius: 10px;
    overflow: hidden;
    border: 1px solid #334155;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .loading-bar-fill {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    background: linear-gradient(90deg, #ec4899, #f43f5e);
    transition: width 0.25s linear;
  }

  .loading-text {
    position: relative;
    font-size: 0.75rem;
    font-weight: 900;
    color: white;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.8);
    z-index: 10;
  }
</style>
