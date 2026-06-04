<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';
  import { BOSS_PHASE_OPTIONS } from './lib/customizerOptions';

  export let entity: PlacedEntity;

  const dispatch = createEventDispatcher<{
    saveRoom: void;
  }>();

  function saveRoom() {
    dispatch('saveRoom');
  }

  function updateBossMode() {
    if (entity.modifiers.boss_mode) {
      entity.modifiers.scale_multiplier = 1.8;
      if (entity.modifiers.boss_hud_style === undefined) entity.modifiers.boss_hud_style = 'retro';
      if (entity.modifiers.boss_phases_count === undefined) entity.modifiers.boss_phases_count = 2;
    } else {
      entity.modifiers.scale_multiplier = 1.0;
    }
    saveRoom();
  }
</script>

<div class="option-group">
  <div class="option-label">
    <span>Monster Speed:</span>
    <span>{entity.modifiers.patrol_speed ?? 70}</span>
  </div>
  <input
    type="range"
    min="20"
    max="300"
    step="10"
    class="option-slider"
    bind:value={entity.modifiers.patrol_speed}
    on:change={saveRoom}
  />
</div>

<div class="option-group">
  <div class="option-label">
    <span>Damage:</span>
    <span>{entity.modifiers.damage_value ?? 10}</span>
  </div>
  <input
    type="range"
    min="0"
    max="100"
    step="5"
    class="option-slider"
    bind:value={entity.modifiers.damage_value}
    on:change={saveRoom}
  />
</div>

<div class="option-group">
  <span class="option-label-text">Monster AI Behavior:</span>
  <select
    class="option-select"
    bind:value={entity.modifiers.behavior_type}
    on:change={saveRoom}
  >
    <option value="patrol">🚶 Walk back & forth</option>
    <option value="chase">🏃 Chase the player</option>
    <option value="jump">🦘 Hop & Jump around</option>
    <option value="fly">🦇 Fly like a bat</option>
  </select>
</div>

<div class="option-group flex-row">
  <span class="option-label-text">Shoots Projectiles? 🔫</span>
  <input
    type="checkbox"
    class="option-toggle"
    bind:checked={entity.modifiers.shoot_projectiles}
    on:change={saveRoom}
  />
</div>

{#if entity.modifiers.shoot_projectiles}
  <div class="option-group">
    <div class="option-label">
      <span>Shoot Speed:</span>
      <span>{entity.modifiers.projectile_speed ?? 250}</span>
    </div>
    <input
      type="range"
      min="100"
      max="500"
      step="50"
      class="option-slider"
      bind:value={entity.modifiers.projectile_speed}
      on:change={saveRoom}
    />
  </div>

  <div class="option-group">
    <div class="option-label">
      <span>Shoot Delay:</span>
      <span>{entity.modifiers.projectile_interval ?? 1.5}s</span>
    </div>
    <input
      type="range"
      min="0.5"
      max="4.0"
      step="0.5"
      class="option-slider"
      bind:value={entity.modifiers.projectile_interval}
      on:change={saveRoom}
    />
  </div>
{/if}

<div class="option-group flex-row">
  <span class="option-label-text">Is it a Boss? 👑</span>
  <input
    type="checkbox"
    class="option-toggle"
    bind:checked={entity.modifiers.boss_mode}
    on:change={updateBossMode}
  />
</div>

{#if entity.modifiers.boss_mode}
  <div class="boss-settings">
    <span class="option-label-text boss-title">👑 Boss Settings:</span>

    <div class="option-group compact">
      <div class="option-label compact-label">
        <span>HUD Health Bar Style:</span>
      </div>
      <select
        class="option-select compact-select"
        bind:value={entity.modifiers.boss_hud_style}
        on:change={saveRoom}
      >
        <option value="retro">👾 Retro Pixel</option>
        <option value="royal">👑 Royal Gold</option>
        <option value="spooky">💀 Spooky Skull</option>
      </select>
    </div>

    <div class="option-group compact">
      <div class="option-label compact-label">
        <span>Boss Phases:</span>
        <span class="boss-phase-count">{entity.modifiers.boss_phases_count ?? 2} Phases</span>
      </div>
      <div class="phase-buttons">
        {#each BOSS_PHASE_OPTIONS as phase}
          <button
            type="button"
            class:active={(entity.modifiers.boss_phases_count ?? 2) === phase}
            on:click={() => {
              entity.modifiers.boss_phases_count = phase;
              saveRoom();
            }}
          >
            {phase}
          </button>
        {/each}
      </div>
    </div>
  </div>
{/if}

<style>
  .option-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .option-group.flex-row {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 16px;
  }

  .option-label {
    display: flex;
    justify-content: space-between;
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
  }

  .option-slider {
    width: 100%;
    accent-color: #fbbf24;
    cursor: pointer;
  }

  .option-label-text {
    font-size: 0.95rem;
    font-weight: 800;
    color: #cbd5e1;
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

  .option-toggle {
    width: 24px;
    height: 24px;
    accent-color: #fbbf24;
    cursor: pointer;
  }

  .boss-settings {
    margin-left: 12px;
    border-left: 3px solid #eab308;
    padding-left: 12px;
    margin-top: 8px;
  }

  .boss-title,
  .boss-phase-count {
    color: #eab308;
  }

  .boss-title {
    font-size: 0.85rem;
  }

  .compact {
    margin-top: 8px;
  }

  .compact-label {
    font-size: 0.8rem;
    margin-bottom: 4px;
  }

  .compact-select {
    background: #1e293b;
    border: 1px solid #475569;
    border-radius: 8px;
    padding: 4px;
    font-size: 0.8rem;
  }

  .phase-buttons {
    display: flex;
    gap: 8px;
    margin-top: 4px;
  }

  .phase-buttons button {
    flex: 1;
    background: #1e293b;
    color: white;
    border: 1px solid #eab308;
    padding: 4px;
    border-radius: 8px;
    font-size: 0.8rem;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.2);
  }

  .phase-buttons button.active {
    background: #eab308;
    color: #0f172a;
  }
</style>
