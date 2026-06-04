<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isShopkeeper = entity.type === 'shopkeeper';
  $: isBbqSpit = entity.type === 'bbq_spit';
  $: isGrappleRing = entity.type === 'grapple_ring';
  $: isBoomerang = entity.asset_id === 'weapon_boomerang';
  $: isBomb = entity.asset_id === 'weapon_bomb';
  $: isFocusAmulet = entity.asset_id === 'focus_amulet';
  $: isRunSurface = entity.type === 'wall_run_surface' || entity.type === 'ceiling_run_surface';

  function saveRoom() {
    dispatch('saveRoom');
  }
</script>

{#if isShopkeeper}
  <div class="option-group">
    <span class="option-label-text">Shop Slot 1 Item:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.shop_item_1}
      on:change={saveRoom}
    >
      <option value="alchemy_potion_speed">Speed Potion 🧪</option>
      <option value="alchemy_potion_jump">Jump Potion 🥤</option>
      <option value="tool_hammer">Toy Hammer 🔨</option>
      <option value="weapon_sword">Toy Sword ⚔️</option>
      <option value="weapon_boomerang">Boomerang 🪃</option>
    </select>
    <div class="option-label price-label">
      <span>Slot 1 Price:</span>
      <span>{entity.modifiers.shop_price_1 ?? 10} Coins</span>
    </div>
    <input
      type="range"
      min="2"
      max="50"
      step="1"
      class="option-slider"
      bind:value={entity.modifiers.shop_price_1}
      on:change={saveRoom}
    />
  </div>
  <div class="option-group">
    <span class="option-label-text">Shop Slot 2 Item:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.shop_item_2}
      on:change={saveRoom}
    >
      <option value="alchemy_potion_speed">Speed Potion 🧪</option>
      <option value="alchemy_potion_jump">Jump Potion 🥤</option>
      <option value="tool_hammer">Toy Hammer 🔨</option>
      <option value="weapon_sword">Toy Sword ⚔️</option>
      <option value="weapon_boomerang">Boomerang 🪃</option>
    </select>
    <div class="option-label price-label">
      <span>Slot 2 Price:</span>
      <span>{entity.modifiers.shop_price_2 ?? 15} Coins</span>
    </div>
    <input
      type="range"
      min="2"
      max="50"
      step="1"
      class="option-slider"
      bind:value={entity.modifiers.shop_price_2}
      on:change={saveRoom}
    />
  </div>
{:else if isBbqSpit}
  <div class="option-group">
    <span class="option-label-text">Cooking Difficulty 🍖:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.cook_difficulty}
      on:change={saveRoom}
    >
      <option value="easy">🟢 Easy (Slow color shifts)</option>
      <option value="medium">🟡 Medium (Normal timing)</option>
      <option value="hard">🔴 Hard (Rapid color shifts)</option>
    </select>
  </div>
{:else if isGrappleRing}
  <div class="option-group">
    <div class="option-label">
      <span>Grapple Range ⭕:</span>
      <span>{entity.modifiers.grapple_range ?? 180}px</span>
    </div>
    <input
      type="range"
      min="100"
      max="400"
      step="20"
      class="option-slider"
      bind:value={entity.modifiers.grapple_range}
      on:change={saveRoom}
    />
  </div>
{:else if isBoomerang}
  <div class="option-group">
    <span class="option-label-text">Boomerang Speed 🪃:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.boomerang_speed}
      on:change={saveRoom}
    >
      <option value="slow">🟢 Slow (Easy Catch)</option>
      <option value="medium">🟡 Medium</option>
      <option value="fast">🔴 Fast</option>
    </select>
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Boomerang Damage:</span>
      <span>{entity.modifiers.damage ?? 15}</span>
    </div>
    <input
      type="range"
      min="5"
      max="50"
      step="5"
      class="option-slider"
      bind:value={entity.modifiers.damage}
      on:change={saveRoom}
    />
  </div>
{:else if isBomb}
  <div class="option-group">
    <div class="option-label">
      <span>Blast Radius 💣:</span>
      <span>{entity.modifiers.blast_radius ?? 80}px</span>
    </div>
    <input
      type="range"
      min="50"
      max="150"
      step="10"
      class="option-slider"
      bind:value={entity.modifiers.blast_radius}
      on:change={saveRoom}
    />
  </div>
  <div class="option-group">
    <div class="option-label">
      <span>Fuse Time:</span>
      <span>{entity.modifiers.fuse_time ?? 2.0}s</span>
    </div>
    <input
      type="range"
      min="1.0"
      max="5.0"
      step="0.5"
      class="option-slider"
      bind:value={entity.modifiers.fuse_time}
      on:change={saveRoom}
    />
  </div>
{:else if isFocusAmulet}
  <div class="option-group">
    <div class="option-label">
      <span>Slow Motion Speed ⏳:</span>
      <span>{Math.round((entity.modifiers.time_slow_factor ?? 0.2) * 100)}%</span>
    </div>
    <input
      type="range"
      min="0.1"
      max="0.5"
      step="0.05"
      class="option-slider"
      bind:value={entity.modifiers.time_slow_factor}
      on:change={saveRoom}
    />
  </div>
{:else if isRunSurface}
  <div class="option-group">
    <div class="option-label">
      <span>Magnet Duration ⚡:</span>
      <span>{entity.modifiers.magnet_duration ?? 3.0}s</span>
    </div>
    <input
      type="range"
      min="1.0"
      max="8.0"
      step="0.5"
      class="option-slider"
      bind:value={entity.modifiers.magnet_duration}
      on:change={saveRoom}
    />
  </div>
{/if}

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .option-label,
  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-label {
    display: flex;
    justify-content: space-between;
  }

  .price-label {
    margin-top: 4px;
  }

  .option-select {
    width: 100%;
    background: #0f172a;
    color: white;
    font-weight: 800;
    padding: 10px;
    border-radius: 12px;
    border: 2px solid #334155;
    cursor: pointer;
  }

  .option-slider {
    width: 100%;
    accent-color: #fbbf24;
    cursor: pointer;
  }
</style>
