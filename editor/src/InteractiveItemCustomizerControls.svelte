<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  $: isShopkeeper = entity.type === 'shopkeeper';
  $: isBbqSpit = entity.type === 'bbq_spit';
  $: isCraftingBench = entity.type === 'crafting_bench';
  $: isGrappleRing = entity.type === 'grapple_ring';
  $: isBoomerang = entity.asset_id === 'weapon_boomerang';
  $: isBomb = entity.asset_id === 'weapon_bomb';
  $: isFocusAmulet = entity.asset_id === 'focus_amulet';
  $: isRunSurface = entity.type === 'wall_run_surface' || entity.type === 'ceiling_run_surface';

  $: if (isShopkeeper) {
    if (entity.modifiers.shop_item_1 === undefined) entity.modifiers.shop_item_1 = 'alchemy_potion_speed';
    if (entity.modifiers.shop_price_1 === undefined) entity.modifiers.shop_price_1 = 10;
    if (entity.modifiers.shop_item_2 === undefined) entity.modifiers.shop_item_2 = 'tool_hammer';
    if (entity.modifiers.shop_price_2 === undefined) entity.modifiers.shop_price_2 = 15;
    if (entity.modifiers.shop_item_3 === undefined) entity.modifiers.shop_item_3 = 'weapon_sword';
    if (entity.modifiers.shop_price_3 === undefined) entity.modifiers.shop_price_3 = 20;
  }

  $: if (isBbqSpit) {
    if (entity.modifiers.cook_difficulty === undefined) entity.modifiers.cook_difficulty = 'easy';
    if (entity.modifiers.cook_result === undefined) entity.modifiers.cook_result = 'food_steak';
  }

  $: if (isCraftingBench) {
    if (entity.modifiers.craft_result === undefined) entity.modifiers.craft_result = 'potion';
    if (entity.modifiers.craft_material_1 === undefined) entity.modifiers.craft_material_1 = 'mat_metal_scrap';
    if (entity.modifiers.craft_count_1 === undefined) entity.modifiers.craft_count_1 = 1;
    if (entity.modifiers.craft_material_2 === undefined) entity.modifiers.craft_material_2 = '';
    if (entity.modifiers.craft_count_2 === undefined) entity.modifiers.craft_count_2 = 1;
  }

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
  <div class="option-group">
    <span class="option-label-text">Shop Slot 3 Item:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.shop_item_3}
      on:change={saveRoom}
    >
      <option value="alchemy_potion_speed">Speed Potion 🧪</option>
      <option value="alchemy_potion_jump">Jump Potion 🥤</option>
      <option value="tool_hammer">Toy Hammer 🔨</option>
      <option value="weapon_sword">Toy Sword ⚔️</option>
      <option value="weapon_boomerang">Boomerang 🪃</option>
    </select>
    <div class="option-label price-label">
      <span>Slot 3 Price:</span>
      <span>{entity.modifiers.shop_price_3 ?? 20} Coins</span>
    </div>
    <input
      type="range"
      min="2"
      max="50"
      step="1"
      class="option-slider"
      bind:value={entity.modifiers.shop_price_3}
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
  <div class="option-group">
    <span class="option-label-text">Cooking Result 🥩:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.cook_result}
      on:change={saveRoom}
    >
      <option value="food_steak">🍖 Healing Steak (+50 HP)</option>
      <option value="food_kebab">🔥 Speed Kebab (Speed Boost!)</option>
      <option value="food_soup">🍄 Super Soup (Giant Form!)</option>
    </select>
  </div>
{:else if isCraftingBench}
  <div class="option-group">
    <span class="option-label-text">Crafted Item Result 🧪:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.craft_result}
      on:change={saveRoom}
    >
      <option value="potion">🧪 Magic Potion</option>
      <option value="sword">⚔️ Toy Sword</option>
      <option value="shield">🛡️ Wooden Shield</option>
      <option value="weapon_boomerang">🪃 Boomerang</option>
      <option value="weapon_bomb">💣 Bomb</option>
      <option value="weapon_paint_gun">🔫 Paint Gun</option>
    </select>
  </div>
  <div class="option-group">
    <span class="option-label-text">Input Material 1 🔩:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.craft_material_1}
      on:change={saveRoom}
    >
      <option value="mat_metal_scrap">🔩 Metal Scrap</option>
      <option value="mat_fire_powder">🌶️ Fire Powder</option>
      <option value="mat_green_herb">🌿 Green Herb</option>
      <option value="mat_sweet_honey">🍯 Sweet Honey</option>
      <option value="sword">⚔️ Toy Sword</option>
    </select>
    <div class="option-label">
      <span>Count 1:</span>
      <span>{entity.modifiers.craft_count_1 ?? 1}</span>
    </div>
    <input
      type="range"
      min="1"
      max="5"
      step="1"
      class="option-slider"
      bind:value={entity.modifiers.craft_count_1}
      on:change={saveRoom}
    />
  </div>
  <div class="option-group">
    <span class="option-label-text">Input Material 2 (Optional) 🍯:</span>
    <select
      class="option-select"
      bind:value={entity.modifiers.craft_material_2}
      on:change={saveRoom}
    >
      <option value="">❌ None</option>
      <option value="mat_metal_scrap">🔩 Metal Scrap</option>
      <option value="mat_fire_powder">🌶️ Fire Powder</option>
      <option value="mat_green_herb">🌿 Green Herb</option>
      <option value="mat_sweet_honey">🍯 Sweet Honey</option>
      <option value="sword">⚔️ Toy Sword</option>
    </select>
    {#if entity.modifiers.craft_material_2}
      <div class="option-label">
        <span>Count 2:</span>
        <span>{entity.modifiers.craft_count_2 ?? 1}</span>
      </div>
      <input
        type="range"
        min="1"
        max="5"
        step="1"
        class="option-slider"
        bind:value={entity.modifiers.craft_count_2}
        on:change={saveRoom}
      />
    {/if}
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
