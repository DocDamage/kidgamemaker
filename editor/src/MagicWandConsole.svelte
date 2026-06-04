<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity, WorldSettings, ToyboxAsset } from './lib/canvasState';

  export let placed: PlacedEntity[];
  export let worldSettings: WorldSettings;

  const dispatch = createEventDispatcher<{
    close: void;
    saveRoom: void;
  }>();

  let commandText = '';
  let statusMessage = '';
  let statusColor = '#fbbf24';

  const suggestions = [
    'make it night',
    'make it sunset',
    'make it day',
    'make it rain',
    'make it snow',
    'make it clear',
    'spawn 3 slimes',
    'spawn 5 gems',
    'clear hazards'
  ];

  function selectSuggestion(sug: string) {
    commandText = sug;
    executeCommand();
  }

  function executeCommand() {
    if (!commandText.trim()) return;

    const cmd = commandText.toLowerCase().trim();
    statusMessage = '';

    // 1. Time of Day Commands
    if (cmd.includes('make it night') || cmd === 'night') {
      worldSettings.time_of_day = 'night';
      dispatch('saveRoom');
      showSuccess('🌌 The sky turns into a cozy starry night!');
      commandText = '';
      return;
    }
    if (cmd.includes('make it day') || cmd === 'day') {
      worldSettings.time_of_day = 'day';
      dispatch('saveRoom');
      showSuccess('☀️ The sun shines bright over the land!');
      commandText = '';
      return;
    }
    if (cmd.includes('make it morning') || cmd === 'morning') {
      worldSettings.time_of_day = 'morning';
      dispatch('saveRoom');
      showSuccess('🌅 A beautiful morning dawn rises!');
      commandText = '';
      return;
    }
    if (cmd.includes('make it sunset') || cmd === 'sunset') {
      worldSettings.time_of_day = 'sunset';
      dispatch('saveRoom');
      showSuccess('🌇 A warm orange sunset paints the horizon!');
      commandText = '';
      return;
    }

    // 2. Weather Commands
    if (cmd.includes('make it rain') || cmd === 'rain') {
      worldSettings.weather = 'rain';
      dispatch('saveRoom');
      showSuccess('🌧️ Pitter-patter! The rain starts to fall!');
      commandText = '';
      return;
    }
    if (cmd.includes('make it snow') || cmd === 'snow') {
      worldSettings.weather = 'snow';
      dispatch('saveRoom');
      showSuccess('❄️ Brrr! Magical snowflakes begin to drift down!');
      commandText = '';
      return;
    }
    if (cmd.includes('make it clear') || cmd === 'clear') {
      worldSettings.weather = 'clear';
      dispatch('saveRoom');
      showSuccess('🌤️ The clouds clear up for a perfect day!');
      commandText = '';
      return;
    }

    // 3. Clear Hazards Command
    if (cmd.includes('clear hazards') || cmd.includes('remove hazards') || cmd.includes('delete hazards') || cmd.includes('no hazards')) {
      const originalCount = placed.length;
      placed = placed.filter(
        (item) => item.type !== 'hazard' && item.asset_id !== 'cactus_hazard' && item.asset_id !== 'spike_hazard'
      );
      const cleared = originalCount - placed.length;
      dispatch('saveRoom');
      showSuccess(`🧹 Poof! Cleared ${cleared} dangerous hazard spikes/cacti!`);
      commandText = '';
      return;
    }

    // 4. Spawn Commands: "spawn [number] [enemy/collectible]"
    const spawnRegex = /spawn\s+(\d+)\s+([a-zA-Z\s_]+)/;
    const match = cmd.match(spawnRegex);
    if (match) {
      const count = parseInt(match[1], 10);
      const rawType = match[2].trim();
      let assetId = '';
      let category = '';
      let type = '';
      let name = '';
      let visual = '';

      if (rawType.startsWith('slime') || rawType.startsWith('enemy')) {
        assetId = 'slime_patrol';
        category = 'enemies';
        type = 'enemy';
        name = 'Slime Patrol';
        visual = 'res://data/assets/enemies/red_slime_enemy/red_slime_enemy.png';
      } else if (rawType.startsWith('gem') || rawType.startsWith('ruby') || rawType.startsWith('coin')) {
        assetId = 'gold_ruby';
        category = 'collectibles';
        type = 'collectible';
        name = 'Gold Ruby';
        visual = 'gold_ruby.svg';
      } else if (rawType.startsWith('spike') || rawType.startsWith('hazard')) {
        assetId = 'spike_hazard';
        category = 'enemies';
        type = 'hazard';
        name = 'Ice Spike';
        visual = '🧊';
      } else if (rawType.startsWith('cactus')) {
        assetId = 'cactus_hazard';
        category = 'enemies';
        type = 'hazard';
        name = 'Prickly Cactus';
        visual = '🌵';
      }

      if (assetId && count > 0 && count <= 20) {
        const newEntities: PlacedEntity[] = [];
        const startX = 200;
        const startY = 150;
        for (let i = 0; i < count; i++) {
          newEntities.push({
            instance_id: `${assetId}_wand_${Math.random().toString(36).substring(2, 8)}`,
            asset_id: assetId,
            category: category,
            type: type,
            position: { x: startX + i * 64, y: startY },
            modifiers: {
              variant: 'default',
              scale_multiplier: 1.0
            }
          });
        }
        placed = [...placed, ...newEntities];
        dispatch('saveRoom');
        showSuccess(`🪄 Abracadabra! Spawned ${count} ${name}s on the canvas!`);
        commandText = '';
        return;
      } else if (count > 20) {
        showError('⚠️ Whoa! Spawning more than 20 items might overwhelm your wand!');
        return;
      }
    }

    showError("🔮 The magic wand didn't recognize that spell. Try one of the suggestions below!");
  }

  function showSuccess(msg: string) {
    statusMessage = msg;
    statusColor = '#10b981';
  }

  function showError(msg: string) {
    statusMessage = msg;
    statusColor = '#ef4444';
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      executeCommand();
    } else if (event.key === 'Escape') {
      dispatch('close');
    }
  }
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<div class="wand-backdrop" on:click={() => dispatch('close')}>
  <div class="wand-modal" on:click|stopPropagation>
    <header class="wand-header">
      <h2>🪄 Magic Wand Command Console</h2>
      <button class="close-btn" on:click={() => dispatch('close')}>✕</button>
    </header>

    <div class="wand-body">
      <p class="wand-description">
        Type a natural language spell to magically modify your room!
      </p>

      <div class="input-row">
        <input
          type="text"
          bind:value={commandText}
          placeholder="e.g., spawn 3 slimes, make it night, clear hazards..."
          on:keydown={handleKeydown}
          autofocus
        />
        <button class="cast-btn" on:click={executeCommand}>Cast Spell! 🪄</button>
      </div>

      {#if statusMessage}
        <div class="status-box" style:border-color={statusColor} style:color={statusColor}>
          {statusMessage}
        </div>
      {/if}

      <div class="suggestions-section">
        <h3>✨ Try these magical spells:</h3>
        <div class="suggestions-grid">
          {#each suggestions as sug}
            <button class="sug-btn" on:click={() => selectSuggestion(sug)}>
              {sug}
            </button>
          {/each}
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  .wand-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(8px);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .wand-modal {
    background: #1e293b;
    border: 4px solid #fbbf24;
    border-radius: 24px;
    width: 500px;
    max-width: 90vw;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6), 0 0 20px rgba(251, 191, 36, 0.2);
    overflow: hidden;
    color: white;
    font-family: 'Inter', system-ui, sans-serif;
  }

  .wand-header {
    background: #0f172a;
    padding: 16px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #334155;
  }

  .wand-header h2 {
    margin: 0;
    color: #fbbf24;
    font-size: 1.25rem;
    font-weight: 800;
  }

  .close-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 50%;
    width: 32px;
    height: 32px;
    font-size: 1.1rem;
    cursor: pointer;
    box-shadow: none;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .wand-body {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .wand-description {
    font-size: 0.95rem;
    color: #cbd5e1;
    margin: 0;
  }

  .input-row {
    display: flex;
    gap: 10px;
  }

  input {
    flex: 1;
    background: #0f172a;
    border: 2px solid #334155;
    border-radius: 14px;
    color: white;
    padding: 12px 16px;
    font-size: 0.95rem;
    font-weight: 600;
    outline: none;
    transition: border-color 0.2s;
  }

  input:focus {
    border-color: #fbbf24;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.25);
  }

  .cast-btn {
    background: #fbbf24;
    color: #0f172a;
    font-weight: 800;
    border: 0;
    border-radius: 14px;
    padding: 0 20px;
    cursor: pointer;
    transition: transform 0.1s, background-color 0.2s;
    box-shadow: 0 4px 0 #d97706;
  }

  .cast-btn:hover {
    background: #fcd34d;
  }

  .cast-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #d97706;
  }

  .status-box {
    padding: 12px;
    border: 2px solid;
    border-radius: 12px;
    font-weight: 700;
    font-size: 0.9rem;
    background: rgba(15, 23, 42, 0.5);
  }

  .suggestions-section {
    display: flex;
    flex-direction: column;
    gap: 10px;
    border-top: 1px solid #334155;
    padding-top: 16px;
  }

  .suggestions-section h3 {
    margin: 0;
    font-size: 0.9rem;
    color: #94a3b8;
  }

  .suggestions-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .sug-btn {
    background: #1e293b;
    border: 2px solid #334155;
    color: #cbd5e1;
    font-size: 0.85rem;
    font-weight: 600;
    padding: 8px 12px;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: none;
  }

  .sug-btn:hover {
    border-color: #fbbf24;
    color: white;
    background: rgba(251, 191, 36, 0.05);
  }
</style>
