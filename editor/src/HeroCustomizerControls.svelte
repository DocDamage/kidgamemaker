<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { HERO_COSTUMES, HERO_JOBS, PHYSICS_PRESETS } from './lib/customizerOptions';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isHero = entity.category === 'heroes' && entity.type === 'player';

  function selectCostume(id: string, tint: string) {
    entity.modifiers.costume_id = id;
    entity.modifiers.costume_tint = tint;
    dispatch('saveRoom');
  }

  function selectJob(id: string) {
    entity.modifiers.hero_class = id;
    dispatch('saveRoom');
  }

  function selectPhysicsPreset(id: string) {
    entity.modifiers.physics_preset = id;
    dispatch('saveRoom');
  }

  let startingItems: string[] = [];
  $: startingItems = entity.modifiers.starting_items || [];

  function toggleStartingItem(itemId: string) {
    let items = [...startingItems];
    const idx = items.indexOf(itemId);
    if (idx >= 0) {
      items.splice(idx, 1);
    } else {
      items.push(itemId);
    }
    entity.modifiers.starting_items = items;
    dispatch('saveRoom');
  }

  let socketedGems: string[] = [];
  $: socketedGems = entity.modifiers.socketed_gems || ['', '', ''];

  function updateGem(slotIndex: number, gemId: string) {
    let gems = [...socketedGems];
    while (gems.length < 3) {
      gems.push('');
    }
    gems[slotIndex] = gemId;
    entity.modifiers.socketed_gems = gems;
    dispatch('saveRoom');
  }

  // Pack starting items into a 4x4 grid representation
  interface GridItem {
    id: string;
    emoji: string;
    name: string;
    root_r: number;
    root_c: number;
    w: number;
    h: number;
    color: string;
  }
  
  let backpackGrid: (GridItem | null)[][] = [];
  
  export const ITEM_TEMPLATES = [
    { id: 'weapon_sword', emoji: '⚔️', name: 'Sword', w: 1, h: 2, color: '#854d0e' },
    { id: 'weapon_boomerang', emoji: '🪃', name: 'Boomerang', w: 1, h: 1, color: '#1d4ed8' },
    { id: 'weapon_bomb', emoji: '💣', name: 'Bomb', w: 1, h: 1, color: '#b91c1c' },
    { id: 'weapon_paint_gun', emoji: '🔫', name: 'Paint Gun', w: 1, h: 1, color: '#047857' },
    { id: 'tool_hammer', emoji: '🔨', name: 'Hammer', w: 1, h: 2, color: '#b45309' },
    { id: 'tool_lantern', emoji: '🏮', name: 'Lantern', w: 1, h: 1, color: '#c2410c' },
    { id: 'mat_metal_scrap', emoji: '🔩', name: 'Metal', w: 1, h: 1, color: '#475569' },
    { id: 'mat_fire_powder', emoji: '🌶️', name: 'Spice', w: 1, h: 1, color: '#ea580c' },
    { id: 'mat_green_herb', emoji: '🌿', name: 'Herb', w: 1, h: 1, color: '#16a34a' },
    { id: 'mat_sweet_honey', emoji: '🍯', name: 'Honey', w: 1, h: 1, color: '#ca8a04' }
  ];

  $: {
    let tempGrid: (GridItem | null)[][] = Array(4).fill(null).map(() => Array(4).fill(null));
    let selectedWithTemplates = startingItems
      .map(id => ITEM_TEMPLATES.find(t => t.id === id))
      .filter((t): t is typeof ITEM_TEMPLATES[number] => !!t);

    for (const item of selectedWithTemplates) {
      let w = item.w;
      let h = item.h;
      let fitted = false;
      
      for (let r = 0; r <= 4 - h; r++) {
        for (let c = 0; c <= 4 - w; c++) {
          let fits = true;
          for (let dr = 0; dr < h; dr++) {
            for (let dc = 0; dc < w; dc++) {
              if (tempGrid[r + dr][c + dc] !== null) {
                fits = false;
                break;
              }
            }
            if (!fits) break;
          }
          
          if (fits) {
            const gridItem: GridItem = {
              id: item.id,
              emoji: item.emoji,
              name: item.name,
              root_r: r,
              root_c: c,
              w,
              h,
              color: item.color
            };
            
            for (let dr = 0; dr < h; dr++) {
              for (let dc = 0; dc < w; dc++) {
                tempGrid[r + dr][c + dc] = gridItem;
              }
            }
            fitted = true;
            break;
          }
        }
        if (fitted) break;
      }
    }
    backpackGrid = tempGrid;
  }
</script>

{#if isHero}
  <div class="option-group">
    <span class="option-label-text">👕 Costume Wardrobe:</span>
    <div class="costume-grid">
      {#each HERO_COSTUMES as costume}
        <button
          type="button"
          class:active-option={entity.modifiers.costume_id === costume.id}
          style:--option-color={costume.color}
          on:click={() => selectCostume(costume.id, costume.tint)}
        >
          {costume.name}
        </button>
      {/each}
    </div>
  </div>

  <div class="option-group hero-job-group">
    <span class="option-label-text">🛡️ Hero Job / Class:</span>
    <div class="class-grid">
      {#each HERO_JOBS as job}
        <button
          type="button"
          title={job.desc}
          class:active-option={entity.modifiers.hero_class === job.id}
          style:--option-color={job.color}
          on:click={() => selectJob(job.id)}
        >
          {job.name}
        </button>
      {/each}
    </div>
  </div>

  <div class="option-group physics-preset-group">
    <span class="option-label-text">🏃 Movement Feel (Physics):</span>
    <div class="physics-grid">
      {#each PHYSICS_PRESETS as preset}
        <button
          type="button"
          title={preset.desc}
          class:active-option={entity.modifiers.physics_preset === preset.id || (!entity.modifiers.physics_preset && preset.id === 'kidfriendly')}
          style:--option-color={preset.color}
          on:click={() => selectPhysicsPreset(preset.id)}
        >
          {preset.name}
        </button>
      {/each}
    </div>
  </div>

  <div class="option-group starting-items-group">
    <span class="option-label-text">🎒 Starting Backpack Items:</span>
    <div class="items-grid">
      {#each ITEM_TEMPLATES as item}
        {@const hasItem = startingItems.includes(item.id)}
        <button
          type="button"
          class:active-option={hasItem}
          style:--option-color={hasItem ? '#fbbf24' : '#475569'}
          on:click={() => toggleStartingItem(item.id)}
        >
          {item.emoji} {item.name}
        </button>
      {/each}
    </div>

    <!-- Visual Tetris Grid Inventory Preview -->
    <div class="backpack-preview-container">
      <span class="preview-title">Visual Grid Preview:</span>
      <div class="backpack-grid-ui">
        {#each Array(4) as _, r}
          {#each Array(4) as _, c}
            {@const cell = backpackGrid[r] ? backpackGrid[r][c] : null}
            {@const isRoot = cell && cell.root_r === r && cell.root_c === c}
            <div 
              class="grid-cell" 
              class:occupied={cell !== null}
              style={cell ? `background-color: ${cell.color}99; border-color: ${cell.color};` : ''}
            >
              {#if isRoot}
                <span class="cell-emoji">{cell.emoji}</span>
              {/if}
            </div>
          {/each}
        {/each}
      </div>
    </div>
  </div>

  <div class="option-group starting-items-group">
    <span class="option-label-text">🔮 Magical Badge Sockets:</span>
    <div class="sockets-grid">
      {#each [0, 1, 2] as idx}
        <div class="socket-col">
          <span class="socket-label">Slot {idx + 1}:</span>
          <select
            class="option-select"
            value={socketedGems[idx] || ''}
            on:change={(e) => updateGem(idx, e.currentTarget.value)}
          >
            <option value="">❌ Empty</option>
            <option value="gem_speed">💨 Speed Gem</option>
            <option value="gem_jump">🦘 Jump Gem</option>
            <option value="gem_magnet">🧲 Magnet Gem</option>
            <option value="gem_shield">🛡️ Shield Gem</option>
            <option value="gem_heart">💖 Heart Gem</option>
          </select>
        </div>
      {/each}
    </div>
  </div>
{/if}

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .hero-job-group,
  .physics-preset-group,
  .starting-items-group {
    margin-top: 16px;
  }

  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .costume-grid,
  .class-grid,
  .physics-grid,
  .items-grid {
    display: grid;
    gap: 8px;
    margin-top: 8px;
  }

  .costume-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .class-grid,
  .physics-grid,
  .items-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  button {
    background: #1e293b;
    color: white;
    border: 2px solid var(--option-color);
    padding: 8px 4px;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: bold;
    cursor: pointer;
    text-align: center;
    box-shadow: 0 3px 0 rgba(0, 0, 0, 0.3);
  }

  .active-option {
    background: var(--option-color);
    color: #0f172a;
  }

  .option-select {
    width: 100%;
    background: #0f172a;
    color: white;
    border: 2px solid #334155;
    padding: 8px 12px;
    border-radius: 12px;
    font-size: 0.85rem;
    font-weight: 700;
    outline: none;
    cursor: pointer;
    transition: border-color 0.2s;
  }

  .option-select:focus {
    border-color: #fbbf24;
  }

  .sockets-grid {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 8px;
  }

  .socket-col {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
  }

  .socket-label {
    font-size: 0.85rem;
    font-weight: bold;
    color: #94a3b8;
    white-space: nowrap;
  }

  .backpack-preview-container {
    margin-top: 12px;
    background: #0f172a;
    border: 1px solid #334155;
    border-radius: 8px;
    padding: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
  }

  .preview-title {
    font-size: 0.8rem;
    font-weight: 700;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .backpack-grid-ui {
    display: grid;
    grid-template-columns: repeat(4, 42px);
    grid-template-rows: repeat(4, 42px);
    gap: 4px;
    background: #020617;
    padding: 6px;
    border-radius: 6px;
    border: 1px solid #1e293b;
  }

  .grid-cell {
    background: #1e293b;
    border: 1px solid #475569;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    transition: all 0.2s ease;
  }

  .grid-cell.occupied {
    box-shadow: inset 0 0 4px rgba(255,255,255,0.1);
  }

  .cell-emoji {
    font-size: 1.25rem;
  }
</style>

